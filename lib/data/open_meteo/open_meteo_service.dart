import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/core/region_matching.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/open_meteo/open_meteo_dtos.dart';
import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/weather_reading.dart';
import 'package:dio/dio.dart';
import 'package:timezone/timezone.dart' as tz;

/// [AqiService] backed by the free, key-less Open-Meteo APIs (TECH_DESIGN §8).
/// All requests are GET, no auth, CORS-enabled — safe to call from the browser.
class OpenMeteoService implements AqiService {
  OpenMeteoService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _airQualityUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String _forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Overall + per-pollutant sub-indices and concentrations requested for the
  /// current AQI reading.
  static const List<String> _currentAqiFields = <String>[
    'us_aqi',
    'us_aqi_pm2_5',
    'us_aqi_pm10',
    'us_aqi_o3',
    'us_aqi_no2',
    'us_aqi_so2',
    'us_aqi_co',
    'pm2_5',
    'pm10',
    'ozone',
    'nitrogen_dioxide',
    'sulphur_dioxide',
    'carbon_monoxide',
  ];

  @override
  Future<List<GeocodeResult>> geocode(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return const <GeocodeResult>[];

    // Split "City, State, Country" into the place name (searched) and region
    // qualifiers (filtered locally — Open-Meteo only matches the bare name).
    final List<String> segments = trimmed
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    final String name = segments.isEmpty ? trimmed : segments.first;
    final List<String> qualifiers = segments.skip(1).toList();
    if (name.isEmpty) return const <GeocodeResult>[];

    final Map<String, dynamic> json = await _getJson(
      _geocodingUrl,
      <String, dynamic>{
        'name': name,
        // Fetch a wider set so region filtering has candidates to match.
        'count': qualifiers.isEmpty ? 5 : 10,
        'language': 'en',
        'format': 'json',
      },
    );

    final GeocodingResponseDto dto = GeocodingResponseDto.fromJson(json);
    final List<GeocodingResultDto> results =
        dto.results ?? const <GeocodingResultDto>[];

    // Keep only candidates whose region matches every qualifier the user typed.
    List<GeocodingResultDto> ranked = results;
    if (qualifiers.isNotEmpty) {
      final List<GeocodingResultDto> matched = results
          .where(
            (GeocodingResultDto r) => qualifiers.every(
              (String q) => regionQualifierMatches(
                q,
                admin1: r.admin1,
                country: r.country,
                countryCode: r.countryCode,
              ),
            ),
          )
          .toList();
      // Fall back to the name-only results if nothing matched, so the user
      // still sees candidates rather than a dead end.
      ranked = matched.isNotEmpty ? matched : results;
    }

    return <GeocodeResult>[
      for (final GeocodingResultDto r in ranked.take(5))
        GeocodeResult(
          name: r.name,
          latitude: r.latitude,
          longitude: r.longitude,
          admin1: r.admin1,
          country: r.country,
          countryCode: r.countryCode,
          timezone: r.timezone,
        ),
    ];
  }

  @override
  Future<AqiReading> getAqi(double lat, double lon) async {
    final Map<String, dynamic> json =
        await _getJson(_airQualityUrl, <String, dynamic>{
          'latitude': lat,
          'longitude': lon,
          'current': _currentAqiFields.join(','),
          'timezone': 'auto',
        });

    final AirQualityResponseDto dto = AirQualityResponseDto.fromJson(json);
    final AirQualityCurrentDto? current = dto.current;
    if (current == null || current.usAqi == null) {
      throw const AqiServiceException(
        'Air quality data is unavailable for this location.',
      );
    }

    final int usAqi = current.usAqi!.round();
    final DateTime observedAt = _parseTime(current.time);
    final Map<String, double> pollutants = _pollutantMap(current);
    return AqiReading(
      usAqi: usAqi,
      category: aqiCategoryFor(usAqi),
      observedAt: observedAt,
      dominantPollutant: _dominantPollutant(current),
      pollutants: pollutants.isEmpty ? null : pollutants,
      timezoneLabel: _zoneLabel(
        dto.timezone,
        observedAt,
        dto.timezoneAbbreviation,
      ),
    );
  }

  @override
  Future<WeatherReading> getWeather(double lat, double lon) async {
    final Map<String, dynamic> json = await _getJson(
      _forecastUrl,
      <String, dynamic>{
        'latitude': lat,
        'longitude': lon,
        'current': 'temperature_2m',
        'timezone': 'auto',
      },
    );

    final ForecastCurrentDto? current = ForecastResponseDto.fromJson(
      json,
    ).current;
    if (current == null || current.temperature2m == null) {
      throw const AqiServiceException(
        'Temperature is unavailable for this location.',
      );
    }
    return WeatherReading(
      temperatureC: current.temperature2m!.toDouble(),
      observedAt: _parseTime(current.time),
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String url,
    Map<String, dynamic> query,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(url, queryParameters: query);
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        throw const AqiServiceException('Empty response from Open-Meteo.');
      }
      return data;
    } on DioException catch (e) {
      throw AqiServiceException(
        'Network error contacting Open-Meteo: ${e.message ?? e.type.name}',
      );
    }
  }

  /// The pollutant code with the highest US AQI sub-index, or null if none are
  /// reported. This is the pollutant driving the overall index.
  String? _dominantPollutant(AirQualityCurrentDto c) {
    String? best;
    num bestValue = -1;
    _subIndices(c).forEach((String code, num? value) {
      if (value != null && value > bestValue) {
        bestValue = value;
        best = code;
      }
    });
    return best;
  }

  static Map<String, num?> _subIndices(AirQualityCurrentDto c) =>
      <String, num?>{
        'pm2_5': c.usAqiPm25,
        'pm10': c.usAqiPm10,
        'o3': c.usAqiO3,
        'no2': c.usAqiNo2,
        'so2': c.usAqiSo2,
        'co': c.usAqiCo,
      };

  Map<String, double> _pollutantMap(AirQualityCurrentDto c) {
    final Map<String, double> out = <String, double>{};
    void put(String code, num? value) {
      if (value != null) out[code] = value.toDouble();
    }

    put('pm2_5', c.pm25);
    put('pm10', c.pm10);
    put('o3', c.ozone);
    put('no2', c.nitrogenDioxide);
    put('so2', c.sulphurDioxide);
    put('co', c.carbonMonoxide);
    return out;
  }

  /// Open-Meteo returns local wall-clock time (we pass `timezone=auto`), e.g.
  /// `2026-07-18T14:00`. Falls back to now if the field is malformed.
  DateTime _parseTime(String raw) => DateTime.tryParse(raw) ?? DateTime.now();

  /// A named, DST-aware zone abbreviation (e.g. "EDT", "CDT", "JST") for the
  /// location's [iana] zone at [localWallClock]. Falls back to [fallback] (the
  /// provider's "GMT-x" label) when the zone is unknown or tz data isn't loaded.
  String? _zoneLabel(String? iana, DateTime localWallClock, String? fallback) {
    if (iana == null || iana.isEmpty) return fallback;
    try {
      final tz.Location location = tz.getLocation(iana);
      final tz.TZDateTime local = tz.TZDateTime(
        location,
        localWallClock.year,
        localWallClock.month,
        localWallClock.day,
        localWallClock.hour,
        localWallClock.minute,
      );
      final String name = local.timeZoneName;
      return name.isEmpty ? fallback : name;
    } on Object {
      return fallback;
    }
  }
}

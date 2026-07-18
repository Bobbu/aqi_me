import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/models/weather_reading.dart';

/// Orchestrates the data layer for the UI (TECH_DESIGN §5, §10).
///
/// Composes AQI + weather into a [LocationReading], and caches the last reading
/// per location so we skip re-fetching inside the freshness window. A failed
/// weather fetch degrades gracefully (weather becomes null); a failed AQI fetch
/// propagates, so the card can show an error.
class LocationRepository {
  LocationRepository({
    required AqiService service,
    Duration freshness = const Duration(minutes: 60),
    DateTime Function() now = DateTime.now,
  }) : _service = service,
       _freshness = freshness,
       _now = now;

  final AqiService _service;
  final Duration _freshness;
  final DateTime Function() _now;
  final Map<String, _CachedReading> _cache = <String, _CachedReading>{};

  /// Passthrough for the add-location flow's disambiguation step.
  Future<List<GeocodeResult>> geocode(String query) => _service.geocode(query);

  /// Returns the current reading for [location], from cache when fresh.
  Future<LocationReading> getReading(
    Location location, {
    bool forceRefresh = false,
    bool includeWeather = true,
  }) async {
    final _CachedReading? cached = _cache[location.id];
    if (!forceRefresh &&
        cached != null &&
        _now().difference(cached.fetchedAt) < _freshness) {
      return cached.reading;
    }

    final Future<AqiReading> aqiFuture = _service.getAqi(
      location.lat,
      location.lon,
    );
    final Future<WeatherReading?> weatherFuture = includeWeather
        ? _service
              .getWeather(location.lat, location.lon)
              .then<WeatherReading?>((WeatherReading w) => w)
              // Weather is a nice-to-have — never let it fail the whole reading.
              .catchError((_) => null)
        : Future<WeatherReading?>.value();

    final AqiReading aqi = await aqiFuture;
    final WeatherReading? weather = await weatherFuture;

    final LocationReading reading = LocationReading(
      location: location,
      aqi: aqi,
      weather: weather,
    );
    _cache[location.id] = _CachedReading(reading: reading, fetchedAt: _now());
    return reading;
  }

  /// Drops the cached reading for a location (forces a fresh fetch next time).
  void invalidate(String locationId) => _cache.remove(locationId);

  /// Clears all cached readings.
  void clearCache() => _cache.clear();
}

class _CachedReading {
  _CachedReading({required this.reading, required this.fetchedAt});

  final LocationReading reading;
  final DateTime fetchedAt;
}

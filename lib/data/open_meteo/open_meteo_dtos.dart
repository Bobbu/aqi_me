import 'package:json_annotation/json_annotation.dart';

part 'open_meteo_dtos.g.dart';

// Wire-format DTOs for the Open-Meteo responses (TECH_DESIGN §8). These mirror
// the raw JSON; `OpenMeteoService` maps them to the domain models. Parse-only —
// we never serialize these back.

@JsonSerializable(createToJson: false)
class GeocodingResponseDto {
  const GeocodingResponseDto({this.results});

  factory GeocodingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResponseDtoFromJson(json);

  final List<GeocodingResultDto>? results;
}

@JsonSerializable(createToJson: false)
class GeocodingResultDto {
  const GeocodingResultDto({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.admin1,
    this.country,
    this.countryCode,
    this.timezone,
  });

  factory GeocodingResultDto.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResultDtoFromJson(json);

  final String name;
  final double latitude;
  final double longitude;
  final String? admin1;
  final String? country;
  @JsonKey(name: 'country_code')
  final String? countryCode;
  final String? timezone;
}

@JsonSerializable(createToJson: false)
class AirQualityResponseDto {
  const AirQualityResponseDto({this.current});

  factory AirQualityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AirQualityResponseDtoFromJson(json);

  final AirQualityCurrentDto? current;
}

@JsonSerializable(createToJson: false)
class AirQualityCurrentDto {
  const AirQualityCurrentDto({
    required this.time,
    this.usAqi,
    this.usAqiPm25,
    this.usAqiPm10,
    this.usAqiO3,
    this.usAqiNo2,
    this.usAqiSo2,
    this.usAqiCo,
    this.pm25,
    this.pm10,
    this.ozone,
    this.nitrogenDioxide,
    this.sulphurDioxide,
    this.carbonMonoxide,
  });

  factory AirQualityCurrentDto.fromJson(Map<String, dynamic> json) =>
      _$AirQualityCurrentDtoFromJson(json);

  final String time;

  // Overall and per-pollutant US AQI sub-indices (dominant = the max sub-index).
  @JsonKey(name: 'us_aqi')
  final num? usAqi;
  @JsonKey(name: 'us_aqi_pm2_5')
  final num? usAqiPm25;
  @JsonKey(name: 'us_aqi_pm10')
  final num? usAqiPm10;
  @JsonKey(name: 'us_aqi_o3')
  final num? usAqiO3;
  @JsonKey(name: 'us_aqi_no2')
  final num? usAqiNo2;
  @JsonKey(name: 'us_aqi_so2')
  final num? usAqiSo2;
  @JsonKey(name: 'us_aqi_co')
  final num? usAqiCo;

  // Concentrations (µg/m³) for the breakdown detail.
  @JsonKey(name: 'pm2_5')
  final num? pm25;
  @JsonKey(name: 'pm10')
  final num? pm10;
  @JsonKey(name: 'ozone')
  final num? ozone;
  @JsonKey(name: 'nitrogen_dioxide')
  final num? nitrogenDioxide;
  @JsonKey(name: 'sulphur_dioxide')
  final num? sulphurDioxide;
  @JsonKey(name: 'carbon_monoxide')
  final num? carbonMonoxide;
}

@JsonSerializable(createToJson: false)
class ForecastResponseDto {
  const ForecastResponseDto({this.current});

  factory ForecastResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseDtoFromJson(json);

  final ForecastCurrentDto? current;
}

@JsonSerializable(createToJson: false)
class ForecastCurrentDto {
  const ForecastCurrentDto({required this.time, this.temperature2m});

  factory ForecastCurrentDto.fromJson(Map<String, dynamic> json) =>
      _$ForecastCurrentDtoFromJson(json);

  final String time;
  @JsonKey(name: 'temperature_2m')
  final num? temperature2m;
}

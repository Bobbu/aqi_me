import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_reading.freezed.dart';

/// Current temperature for a location (a nice-to-have alongside AQI). Stored in
/// Celsius; the UI decides the display unit.
@freezed
class WeatherReading with _$WeatherReading {
  const factory WeatherReading({
    required double temperatureC,
    required DateTime observedAt,
  }) = _WeatherReading;
}

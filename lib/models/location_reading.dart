import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/weather_reading.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_reading.freezed.dart';

/// The composed, render-ready state for one card: the tracked [location], its
/// current [aqi], and optionally the current [weather] (temperature). Weather is
/// nullable so a card still renders when only AQI is available.
@freezed
class LocationReading with _$LocationReading {
  const factory LocationReading({
    required Location location,
    required AqiReading aqi,
    WeatherReading? weather,
  }) = _LocationReading;
}

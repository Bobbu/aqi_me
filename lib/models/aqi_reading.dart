import 'package:aqi_me/core/aqi_scale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'aqi_reading.freezed.dart';

/// A single current AQI observation for a location.
///
/// [usAqi] is the overall US EPA index; [category] is derived from it. When
/// available, [dominantPollutant] is the pollutant code driving the index (the
/// one whose sub-index equals the overall value), and [pollutants] carries the
/// concentration breakdown for the expandable detail (µg/m³).
@freezed
class AqiReading with _$AqiReading {
  const factory AqiReading({
    required int usAqi,
    required AqiCategory category,
    required DateTime observedAt,
    String? dominantPollutant,
    Map<String, double>? pollutants,
    // Offset-style zone label for [observedAt] (the location's local time),
    // e.g. "GMT-6". Null when the provider doesn't report one.
    String? timezoneLabel,
  }) = _AqiReading;
}

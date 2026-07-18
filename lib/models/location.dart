import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// How a [Location] was entered by the user.
enum LocationSource { typedName, coordinates }

/// A user-added place to track. This is the *input* the user chose (with its
/// resolved coordinates and display name) — not the AQI reading, which is fetched
/// separately. Persisted to `shared_preferences` as JSON, so it is JSON-round-trippable.
@freezed
class Location with _$Location {
  const factory Location({
    required String id,
    required double lat,
    required double lon,
    required String label,
    required LocationSource source,
    String? admin1,
    String? country,
    String? timezone,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

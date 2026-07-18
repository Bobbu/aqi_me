import 'package:freezed_annotation/freezed_annotation.dart';

part 'geocode_result.freezed.dart';

/// A candidate place returned by a geocoding search — shown in the disambiguation
/// sheet when a typed query matches more than one location (TECH_DESIGN §9.1).
@freezed
class GeocodeResult with _$GeocodeResult {
  const factory GeocodeResult({
    required String name,
    required double latitude,
    required double longitude,
    String? admin1,
    String? country,
    String? countryCode,
    String? timezone,
  }) = _GeocodeResult;
}

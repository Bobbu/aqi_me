import 'package:aqi_me/core/coord_parser.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/location.dart';

/// Builds a [Location] from raw coordinates the user typed.
Location locationFromCoord(double lat, double lon) {
  return Location(
    id: locationIdFor(lat, lon),
    lat: lat,
    lon: lon,
    label: '${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)}',
    source: LocationSource.coordinates,
  );
}

/// Builds a [Location] from a chosen geocoding candidate.
Location locationFromGeocode(GeocodeResult r) {
  return Location(
    id: locationIdFor(r.latitude, r.longitude),
    lat: r.latitude,
    lon: r.longitude,
    label: r.name,
    admin1: r.admin1,
    country: r.country,
    timezone: r.timezone,
    source: LocationSource.typedName,
  );
}

/// A short secondary line for a location card: region + country for named
/// places, or a "GPS" marker for coordinate entries.
String locationSubtitle(Location location) {
  if (location.source == LocationSource.coordinates) return 'GPS';
  final List<String> parts = <String>[
    if (location.admin1 != null && location.admin1!.isNotEmpty)
      location.admin1!,
    if (location.country != null && location.country!.isNotEmpty)
      location.country!,
  ];
  return parts.isEmpty ? '' : parts.join(' · ');
}

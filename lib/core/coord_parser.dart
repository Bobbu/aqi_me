/// A parsed latitude/longitude pair.
class Coord {
  const Coord(this.lat, this.lon);

  final double lat;
  final double lon;
}

/// Tries to read a `lat, lon` pair from raw user input (TECH_DESIGN §9.1).
///
/// Accepts two numbers separated by a comma and/or whitespace, e.g.
/// `39.7392, -104.9903` or `39.7392 -104.9903`. Returns null when the input
/// isn't a clean coordinate pair (so it can be treated as a place name), or when
/// the values fall outside valid ranges (−90..90 / −180..180).
Coord? tryParseCoordinates(String input) {
  final List<String> parts = input
      .trim()
      .split(RegExp(r'[,\s]+'))
      .where((String s) => s.isNotEmpty)
      .toList();
  if (parts.length != 2) return null;

  final double? lat = double.tryParse(parts[0]);
  final double? lon = double.tryParse(parts[1]);
  if (lat == null || lon == null) return null;
  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;

  return Coord(lat, lon);
}

/// Stable id / dedupe key for a coordinate, rounded to ~100 m (3 decimals).
/// Two inputs resolving to the same rounded point are treated as one location.
String locationIdFor(double lat, double lon) =>
    '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';

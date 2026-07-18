import 'package:aqi_me/core/coord_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryParseCoordinates', () {
    test('parses comma-separated coordinates', () {
      final Coord? c = tryParseCoordinates('39.7392, -104.9903');
      expect(c, isNotNull);
      expect(c!.lat, closeTo(39.7392, 1e-9));
      expect(c.lon, closeTo(-104.9903, 1e-9));
    });

    test('parses whitespace-separated and no-space forms', () {
      expect(tryParseCoordinates('39.74 -104.99'), isNotNull);
      expect(tryParseCoordinates('39.74,-104.99'), isNotNull);
      expect(tryParseCoordinates('  0, 0  '), isNotNull);
    });

    test('rejects place names', () {
      expect(tryParseCoordinates('Denver, CO'), isNull);
      expect(tryParseCoordinates('New York'), isNull);
      expect(tryParseCoordinates('Tokyo'), isNull);
    });

    test('rejects a single number or too many parts', () {
      expect(tryParseCoordinates('42'), isNull);
      expect(tryParseCoordinates('1, 2, 3'), isNull);
    });

    test('rejects out-of-range values', () {
      expect(tryParseCoordinates('91, 0'), isNull);
      expect(tryParseCoordinates('-91, 0'), isNull);
      expect(tryParseCoordinates('0, 181'), isNull);
      expect(tryParseCoordinates('0, -181'), isNull);
    });

    test('accepts range boundaries', () {
      expect(tryParseCoordinates('90, 180'), isNotNull);
      expect(tryParseCoordinates('-90, -180'), isNotNull);
    });
  });

  group('locationIdFor', () {
    test('rounds to 3 decimals so near-identical points share an id', () {
      expect(
        locationIdFor(39.73915, -104.9847),
        locationIdFor(39.7392, -104.9847),
      );
    });

    test('distinct points get distinct ids', () {
      expect(
        locationIdFor(39.74, -104.98) == locationIdFor(40.71, -74.01),
        isFalse,
      );
    });
  });
}

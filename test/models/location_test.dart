import 'package:aqi_me/models/location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Location JSON', () {
    test('round-trips through toJson/fromJson', () {
      const Location original = Location(
        id: 'abc-123',
        lat: 39.7392,
        lon: -104.9903,
        label: 'Denver, Colorado',
        source: LocationSource.typedName,
        admin1: 'Colorado',
        country: 'United States',
        timezone: 'America/Denver',
      );

      final Location restored = Location.fromJson(original.toJson());

      expect(restored, original);
    });

    test('encodes the source enum by name', () {
      const Location coords = Location(
        id: 'xy',
        lat: 1,
        lon: 2,
        label: '1, 2',
        source: LocationSource.coordinates,
      );

      expect(coords.toJson()['source'], 'coordinates');
      expect(
        Location.fromJson(coords.toJson()).source,
        LocationSource.coordinates,
      );
    });

    test('optional fields survive being absent', () {
      const Location minimal = Location(
        id: 'min',
        lat: 0,
        lon: 0,
        label: 'Null Island',
        source: LocationSource.coordinates,
      );

      final Location restored = Location.fromJson(minimal.toJson());

      expect(restored.admin1, isNull);
      expect(restored.country, isNull);
      expect(restored.timezone, isNull);
    });
  });
}

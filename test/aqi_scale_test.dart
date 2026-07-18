import 'package:aqi_me/core/aqi_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aqiCategoryFor — EPA breakpoints', () {
    test('maps each band to the right category', () {
      expect(aqiCategoryFor(0), AqiCategory.good);
      expect(aqiCategoryFor(50), AqiCategory.good);
      expect(aqiCategoryFor(51), AqiCategory.moderate);
      expect(aqiCategoryFor(100), AqiCategory.moderate);
      expect(aqiCategoryFor(101), AqiCategory.unhealthySensitive);
      expect(aqiCategoryFor(150), AqiCategory.unhealthySensitive);
      expect(aqiCategoryFor(151), AqiCategory.unhealthy);
      expect(aqiCategoryFor(200), AqiCategory.unhealthy);
      expect(aqiCategoryFor(201), AqiCategory.veryUnhealthy);
      expect(aqiCategoryFor(300), AqiCategory.veryUnhealthy);
      expect(aqiCategoryFor(301), AqiCategory.hazardous);
      expect(aqiCategoryFor(500), AqiCategory.hazardous);
    });

    test('clamps out-of-range values to the end categories', () {
      expect(aqiCategoryFor(-10), AqiCategory.good);
      expect(aqiCategoryFor(9999), AqiCategory.hazardous);
    });
  });

  group('AqiCategoryScale', () {
    test('lower bounds are contiguous and ascending', () {
      const List<AqiCategory> ordered = AqiCategory.values;
      for (int i = 1; i < ordered.length; i++) {
        expect(ordered[i].lowerBound, greaterThan(ordered[i - 1].lowerBound));
      }
    });

    test('haze strength increases with severity', () {
      const List<AqiCategory> ordered = AqiCategory.values;
      for (int i = 1; i < ordered.length; i++) {
        expect(
          ordered[i].hazeStrength,
          greaterThan(ordered[i - 1].hazeStrength),
        );
      }
    });

    test('every category has a non-empty label', () {
      for (final AqiCategory category in AqiCategory.values) {
        expect(category.label, isNotEmpty);
      }
    });
  });
}

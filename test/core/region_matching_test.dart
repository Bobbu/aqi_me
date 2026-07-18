import 'package:aqi_me/core/region_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('regionQualifierMatches', () {
    test('US state abbreviation matches the full admin1 name', () {
      expect(
        regionQualifierMatches('IL', admin1: 'Illinois', countryCode: 'US'),
        isTrue,
      );
      expect(
        regionQualifierMatches(
          'DC',
          admin1: 'District of Columbia',
          countryCode: 'US',
        ),
        isTrue,
      );
    });

    test('short abbreviations do not loose-match other states', () {
      // "IN" (Indiana) must NOT match Illinois via substring.
      expect(
        regionQualifierMatches('IN', admin1: 'Illinois', countryCode: 'US'),
        isFalse,
      );
    });

    test('full state name matches', () {
      expect(regionQualifierMatches('Illinois', admin1: 'Illinois'), isTrue);
      expect(regionQualifierMatches('vermont', admin1: 'Vermont'), isTrue);
    });

    test('country code, name, and synonyms match', () {
      expect(regionQualifierMatches('US', countryCode: 'US'), isTrue);
      expect(
        regionQualifierMatches(
          'USA',
          country: 'United States',
          countryCode: 'US',
        ),
        isTrue,
      );
      expect(
        regionQualifierMatches('United States', country: 'United States'),
        isTrue,
      );
      expect(regionQualifierMatches('UK', countryCode: 'GB'), isTrue);
    });

    test('non-matching qualifier returns false', () {
      expect(
        regionQualifierMatches('TX', admin1: 'Illinois', countryCode: 'US'),
        isFalse,
      );
      expect(
        regionQualifierMatches('France', country: 'United States'),
        isFalse,
      );
    });

    test('empty qualifier is treated as a match', () {
      expect(regionQualifierMatches('  ', admin1: 'Illinois'), isTrue);
    });
  });
}

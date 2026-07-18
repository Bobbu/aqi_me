import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/open_meteo/open_meteo_service.dart';
import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/weather_reading.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fake_http_adapter.dart';
import '../fixtures/open_meteo_fixtures.dart';

/// Routes a request to the right fixture by host.
FakeResponse _byHost(RequestOptions options) {
  final String host = options.uri.host;
  if (host.contains('geocoding-api')) {
    return const FakeResponse(200, geocodingDenverJson);
  }
  if (host.contains('air-quality-api')) {
    return const FakeResponse(200, airQualityJson);
  }
  return const FakeResponse(200, forecastJson);
}

void main() {
  group('OpenMeteoService.geocode', () {
    test('parses candidates and preserves order', () async {
      final OpenMeteoService service = OpenMeteoService(dio: fakeDio(_byHost));

      final List<GeocodeResult> results = await service.geocode('Denver');

      expect(results, hasLength(2));
      expect(results.first.name, 'Denver');
      expect(results.first.admin1, 'Colorado');
      expect(results.first.country, 'United States');
      expect(results.first.countryCode, 'US');
      expect(results.first.latitude, closeTo(39.739, 0.001));
      expect(results.first.timezone, 'America/Denver');
      expect(results[1].admin1, 'Indiana');
    });

    test(
      'returns empty for a blank query without calling the network',
      () async {
        var called = false;
        final OpenMeteoService service = OpenMeteoService(
          dio: fakeDio((RequestOptions o) {
            called = true;
            return const FakeResponse(200, geocodingEmptyJson);
          }),
        );

        final List<GeocodeResult> results = await service.geocode('   ');

        expect(results, isEmpty);
        expect(called, isFalse);
      },
    );

    test('handles a response with no results', () async {
      final OpenMeteoService service = OpenMeteoService(
        dio: fakeDio((_) => const FakeResponse(200, geocodingEmptyJson)),
      );

      expect(await service.geocode('Nowhereville'), isEmpty);
    });
  });

  group('OpenMeteoService.getAqi', () {
    test('maps overall AQI, category, and dominant pollutant', () async {
      final OpenMeteoService service = OpenMeteoService(dio: fakeDio(_byHost));

      final AqiReading reading = await service.getAqi(39.74, -104.98);

      expect(reading.usAqi, 78);
      expect(reading.category, AqiCategory.moderate);
      // Ozone has the highest sub-index (78) in the fixture.
      expect(reading.dominantPollutant, 'o3');
      expect(reading.observedAt, DateTime(2026, 7, 18, 14));
      expect(reading.pollutants, isNotNull);
      expect(reading.pollutants!['pm2_5'], closeTo(13.2, 0.001));
      expect(reading.pollutants!['o3'], closeTo(92.0, 0.001));
    });

    test('throws AqiServiceException when current data is missing', () async {
      final OpenMeteoService service = OpenMeteoService(
        dio: fakeDio((_) => const FakeResponse(200, airQualityMissingJson)),
      );

      expect(
        () => service.getAqi(39.74, -104.98),
        throwsA(isA<AqiServiceException>()),
      );
    });

    test('wraps transport failures as AqiServiceException', () async {
      final OpenMeteoService service = OpenMeteoService(
        dio: fakeDio((_) => const FakeResponse(500, '{}')),
      );

      expect(
        () => service.getAqi(39.74, -104.98),
        throwsA(isA<AqiServiceException>()),
      );
    });
  });

  group('OpenMeteoService.getWeather', () {
    test('maps current temperature', () async {
      final OpenMeteoService service = OpenMeteoService(dio: fakeDio(_byHost));

      final WeatherReading weather = await service.getWeather(39.74, -104.98);

      expect(weather.temperatureC, closeTo(27.3, 0.001));
      expect(weather.observedAt, DateTime(2026, 7, 18, 14));
    });
  });
}

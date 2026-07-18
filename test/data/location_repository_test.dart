import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/location_repository.dart';
import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/models/weather_reading.dart';
import 'package:flutter_test/flutter_test.dart';

/// A controllable [AqiService] double: counts calls and can fail weather.
class _FakeService implements AqiService {
  int aqiCalls = 0;
  int weatherCalls = 0;
  bool failWeather = false;

  @override
  Future<List<GeocodeResult>> geocode(String query) async =>
      const <GeocodeResult>[];

  @override
  Future<AqiReading> getAqi(double lat, double lon) async {
    aqiCalls++;
    return AqiReading(
      usAqi: 42,
      category: aqiCategoryFor(42),
      observedAt: DateTime(2026, 7, 18, 14),
    );
  }

  @override
  Future<WeatherReading> getWeather(double lat, double lon) async {
    weatherCalls++;
    if (failWeather) {
      throw const AqiServiceException('boom');
    }
    return WeatherReading(
      temperatureC: 21,
      observedAt: DateTime(2026, 7, 18, 14),
    );
  }
}

const Location _denver = Location(
  id: 'denver',
  lat: 39.74,
  lon: -104.98,
  label: 'Denver',
  source: LocationSource.typedName,
);

void main() {
  group('LocationRepository', () {
    test('composes AQI and weather into a reading', () async {
      final _FakeService service = _FakeService();
      final LocationRepository repo = LocationRepository(service: service);

      final LocationReading reading = await repo.getReading(_denver);

      expect(reading.location, _denver);
      expect(reading.aqi.usAqi, 42);
      expect(reading.weather?.temperatureC, 21);
    });

    test('serves a fresh reading from cache (no second fetch)', () async {
      final _FakeService service = _FakeService();
      final LocationRepository repo = LocationRepository(service: service);

      await repo.getReading(_denver);
      await repo.getReading(_denver);

      expect(service.aqiCalls, 1);
    });

    test('forceRefresh bypasses the cache', () async {
      final _FakeService service = _FakeService();
      final LocationRepository repo = LocationRepository(service: service);

      await repo.getReading(_denver);
      await repo.getReading(_denver, forceRefresh: true);

      expect(service.aqiCalls, 2);
    });

    test('re-fetches once the freshness window has passed', () async {
      final _FakeService service = _FakeService();
      DateTime clock = DateTime(2026, 7, 18, 14);
      final LocationRepository repo = LocationRepository(
        service: service,
        freshness: const Duration(minutes: 60),
        now: () => clock,
      );

      await repo.getReading(_denver);
      clock = clock.add(const Duration(minutes: 61));
      await repo.getReading(_denver);

      expect(service.aqiCalls, 2);
    });

    test(
      'a failed weather fetch degrades to null, AQI still returned',
      () async {
        final _FakeService service = _FakeService()..failWeather = true;
        final LocationRepository repo = LocationRepository(service: service);

        final LocationReading reading = await repo.getReading(_denver);

        expect(reading.aqi.usAqi, 42);
        expect(reading.weather, isNull);
      },
    );

    test('a failed AQI fetch propagates', () async {
      final AqiService service = _AlwaysFailAqi();
      final LocationRepository repo = LocationRepository(service: service);

      expect(
        () => repo.getReading(_denver),
        throwsA(isA<AqiServiceException>()),
      );
    });

    test('invalidate forces a refetch for that location', () async {
      final _FakeService service = _FakeService();
      final LocationRepository repo = LocationRepository(service: service);

      await repo.getReading(_denver);
      repo.invalidate(_denver.id);
      await repo.getReading(_denver);

      expect(service.aqiCalls, 2);
    });
  });
}

class _AlwaysFailAqi implements AqiService {
  @override
  Future<List<GeocodeResult>> geocode(String query) async =>
      const <GeocodeResult>[];

  @override
  Future<AqiReading> getAqi(double lat, double lon) async =>
      throw const AqiServiceException('down');

  @override
  Future<WeatherReading> getWeather(double lat, double lon) async =>
      throw const AqiServiceException('down');
}

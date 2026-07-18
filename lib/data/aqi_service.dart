import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/geocode_result.dart';
import 'package:aqi_me/models/weather_reading.dart';

/// Provider-agnostic data interface (TECH_DESIGN §8.1).
///
/// The UI and repository depend only on this; `OpenMeteoService` is the v1
/// implementation. A future WAQI/OpenAQ provider can drop in behind the same
/// interface with no UI changes.
abstract class AqiService {
  /// Resolves a free-text place query to candidate locations (0..5).
  Future<List<GeocodeResult>> geocode(String query);

  /// Current AQI (and pollutant breakdown) for a coordinate.
  Future<AqiReading> getAqi(double lat, double lon);

  /// Current temperature for a coordinate.
  Future<WeatherReading> getWeather(double lat, double lon);
}

/// Thrown when a provider call fails or returns unusable data. Carries a
/// user-safe [message] the UI can show on an error card.
class AqiServiceException implements Exception {
  const AqiServiceException(this.message);

  final String message;

  @override
  String toString() => 'AqiServiceException: $message';
}

/// Display labels for the pollutant codes used across the app.
const Map<String, String> kPollutantLabels = <String, String>{
  'pm2_5': 'PM2.5',
  'pm10': 'PM10',
  'o3': 'O₃',
  'no2': 'NO₂',
  'so2': 'SO₂',
  'co': 'CO',
};

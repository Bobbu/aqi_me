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

/// Full names for the pollutant codes (for the help/glossary).
const Map<String, String> kPollutantNames = <String, String>{
  'pm2_5': 'Fine particulate matter',
  'pm10': 'Coarse particulate matter',
  'o3': 'Ground-level ozone',
  'no2': 'Nitrogen dioxide',
  'so2': 'Sulfur dioxide',
  'co': 'Carbon monoxide',
};

/// Plain-language descriptions for the pollutant codes (for the help/glossary).
const Map<String, String> kPollutantDescriptions = <String, String>{
  'pm2_5':
      'Tiny particles (≤2.5 µm) from smoke, exhaust, and combustion — small '
      'enough to reach deep into the lungs and bloodstream.',
  'pm10': 'Coarser particles (≤10 µm) such as dust, pollen, and mold.',
  'o3':
      'Forms when pollutants react in sunlight; the main ingredient of smog. '
      'Highest on hot, sunny afternoons.',
  'no2': 'Mostly from vehicle exhaust and other high-temperature combustion.',
  'so2': 'From burning fossil fuels at power plants and industrial facilities.',
  'co': 'From incomplete combustion — vehicles, stoves, and heaters.',
};

/// Pollutant codes in display order, for the glossary.
const List<String> kPollutantOrder = <String>[
  'pm2_5',
  'pm10',
  'o3',
  'no2',
  'so2',
  'co',
];

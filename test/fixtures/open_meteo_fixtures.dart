// Recorded-shape JSON fixtures for the Open-Meteo endpoints, used to test
// OpenMeteoService without touching the network. Values are representative of
// real responses (Denver, CO on a moderate day).

const String geocodingDenverJson = '''
{
  "results": [
    {
      "id": 5419384,
      "name": "Denver",
      "latitude": 39.73915,
      "longitude": -104.9847,
      "elevation": 1609.0,
      "feature_code": "PPLA2",
      "country_code": "US",
      "admin1": "Colorado",
      "country": "United States",
      "timezone": "America/Denver"
    },
    {
      "id": 4508722,
      "name": "Denver",
      "latitude": 40.86728,
      "longitude": -87.06862,
      "country_code": "US",
      "admin1": "Indiana",
      "country": "United States",
      "timezone": "America/Indiana/Indianapolis"
    }
  ]
}
''';

const String geocodingEmptyJson = '{"generationtime_ms": 0.4}';

/// Moderate day: overall US AQI 78, driven by ozone (its sub-index is highest).
const String airQualityJson = '''
{
  "latitude": 39.75,
  "longitude": -105.0,
  "timezone": "America/Denver",
  "current": {
    "time": "2026-07-18T14:00",
    "us_aqi": 78,
    "us_aqi_pm2_5": 55,
    "us_aqi_pm10": 30,
    "us_aqi_o3": 78,
    "us_aqi_no2": 12,
    "us_aqi_so2": 3,
    "us_aqi_co": 5,
    "pm2_5": 13.2,
    "pm10": 20.1,
    "ozone": 92.0,
    "nitrogen_dioxide": 8.4,
    "sulphur_dioxide": 1.1,
    "carbon_monoxide": 140.0
  }
}
''';

/// Response with no usable current block.
const String airQualityMissingJson = '''
{"latitude": 39.75, "longitude": -105.0, "current": {"time": "2026-07-18T14:00"}}
''';

const String forecastJson = '''
{
  "latitude": 39.75,
  "longitude": -105.0,
  "timezone": "America/Denver",
  "current": {
    "time": "2026-07-18T14:00",
    "interval": 900,
    "temperature_2m": 27.3
  }
}
''';

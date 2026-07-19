import 'package:aqi_me/core/coord_parser.dart';
import 'package:aqi_me/models/location.dart';

/// The starter locations seeded on a brand-new visitor's first load, so the app
/// shows live cards immediately instead of an empty state. Only seeded when no
/// list has ever been saved — once the user edits (including removing all), we
/// respect their choice and never re-seed. Coordinates are from the Open-Meteo
/// geocoder.
List<Location> defaultLocations() => <Location>[
  Location(
    id: locationIdFor(38.89511, -77.03637),
    lat: 38.89511,
    lon: -77.03637,
    label: 'Washington D.C.',
    admin1: 'District of Columbia',
    country: 'United States',
    timezone: 'America/New_York',
    source: LocationSource.typedName,
  ),
  Location(
    id: locationIdFor(42.21252, -88.15258),
    lat: 42.21252,
    lon: -88.15258,
    label: 'Lake Barrington',
    admin1: 'Illinois',
    country: 'United States',
    timezone: 'America/Chicago',
    source: LocationSource.typedName,
  ),
];

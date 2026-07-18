import 'package:aqi_me/data/location_store.dart';
import 'package:aqi_me/models/location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Location _denver = Location(
  id: '39.739,-104.985',
  lat: 39.739,
  lon: -104.985,
  label: 'Denver',
  source: LocationSource.typedName,
  admin1: 'Colorado',
  country: 'United States',
);

const Location _coords = Location(
  id: '1.000,2.000',
  lat: 1,
  lon: 2,
  label: '1.000, 2.000',
  source: LocationSource.coordinates,
);

Future<LocationStore> _store(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return LocationStore(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns empty on first run', () async {
    final LocationStore store = await _store(<String, Object>{});
    expect(store.load(), isEmpty);
  });

  test('round-trips the list through save/load', () async {
    final LocationStore store = await _store(<String, Object>{});
    await store.save(<Location>[_denver, _coords]);

    final List<Location> loaded = store.load();
    expect(loaded, hasLength(2));
    expect(loaded.first, _denver);
    expect(loaded[1], _coords);
    expect(loaded[1].source, LocationSource.coordinates);
  });

  test('save replaces the previous value', () async {
    final LocationStore store = await _store(<String, Object>{});
    await store.save(<Location>[_denver, _coords]);
    await store.save(<Location>[_denver]);
    expect(store.load(), <Location>[_denver]);
  });

  test('corrupt data loads as empty rather than throwing', () async {
    final LocationStore store = await _store(<String, Object>{
      'aqi_me.locations.v1': 'not json at all',
    });
    expect(store.load(), isEmpty);
  });
}

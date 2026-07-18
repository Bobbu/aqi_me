import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Location _loc(int i) => Location(
  id: 'id$i',
  lat: i.toDouble(),
  lon: i.toDouble(),
  label: 'L$i',
  source: LocationSource.typedName,
);

Future<ProviderContainer> _container(SharedPreferences prefs) async {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  test('adds a location', () async {
    final ProviderContainer c = await _container(prefs);
    final LocationsController ctrl = c.read(
      locationsControllerProvider.notifier,
    );

    expect(ctrl.add(_loc(1)), AddOutcome.added);
    expect(c.read(locationsControllerProvider), hasLength(1));
  });

  test('rejects duplicates by id', () async {
    final ProviderContainer c = await _container(prefs);
    final LocationsController ctrl = c.read(
      locationsControllerProvider.notifier,
    );

    expect(ctrl.add(_loc(1)), AddOutcome.added);
    expect(ctrl.add(_loc(1)), AddOutcome.duplicate);
    expect(c.read(locationsControllerProvider), hasLength(1));
  });

  test('caps at 20 locations', () async {
    final ProviderContainer c = await _container(prefs);
    final LocationsController ctrl = c.read(
      locationsControllerProvider.notifier,
    );

    for (int i = 0; i < 20; i++) {
      expect(ctrl.add(_loc(i)), AddOutcome.added);
    }
    expect(ctrl.isFull, isTrue);
    expect(ctrl.add(_loc(99)), AddOutcome.full);
    expect(c.read(locationsControllerProvider), hasLength(20));
  });

  test('removes a location', () async {
    final ProviderContainer c = await _container(prefs);
    final LocationsController ctrl = c.read(
      locationsControllerProvider.notifier,
    );

    ctrl.add(_loc(1));
    ctrl.add(_loc(2));
    ctrl.remove('id1');

    final List<Location> list = c.read(locationsControllerProvider);
    expect(list, hasLength(1));
    expect(list.single.id, 'id2');
  });

  test('persists across a fresh controller', () async {
    final ProviderContainer c1 = await _container(prefs);
    c1.read(locationsControllerProvider.notifier).add(_loc(1));
    await Future<void>.delayed(Duration.zero);

    // A new container backed by the same prefs should load the saved list.
    final ProviderContainer c2 = await _container(prefs);
    expect(c2.read(locationsControllerProvider), hasLength(1));
    expect(c2.read(locationsControllerProvider).single.id, 'id1');
  });
}

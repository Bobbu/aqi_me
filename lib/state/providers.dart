import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/location_repository.dart';
import 'package:aqi_me/data/location_store.dart';
import 'package:aqi_me/data/open_meteo/open_meteo_service.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The active theme mode. Defaults to following the OS; the header toggle
/// overrides it to an explicit light/dark for this session.
final StateProvider<ThemeMode> themeModeProvider = StateProvider<ThemeMode>(
  (Ref ref) => ThemeMode.system,
);

/// Provides the initialized [SharedPreferences]. Overridden in `main()` after
/// the async instance is ready, so the rest of the app can read it synchronously.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw UnimplementedError(
        'sharedPreferencesProvider must be overridden in main().',
      ),
    );

final Provider<LocationStore> locationStoreProvider = Provider<LocationStore>(
  (Ref ref) => LocationStore(ref.watch(sharedPreferencesProvider)),
);

final Provider<AqiService> aqiServiceProvider = Provider<AqiService>(
  (Ref ref) => OpenMeteoService(),
);

final Provider<LocationRepository> locationRepositoryProvider =
    Provider<LocationRepository>(
      (Ref ref) => LocationRepository(service: ref.watch(aqiServiceProvider)),
    );

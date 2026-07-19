import 'dart:async';

import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/location_repository.dart';
import 'package:aqi_me/data/location_store.dart';
import 'package:aqi_me/data/open_meteo/open_meteo_service.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the initialized [SharedPreferences]. Overridden in `main()` after
/// the async instance is ready, so the rest of the app can read it synchronously.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw UnimplementedError(
        'sharedPreferencesProvider must be overridden in main().',
      ),
    );

/// The active theme mode. Defaults to following the OS, but an explicit
/// light/dark choice from the header toggle is persisted per device so it sticks
/// across reloads and reopens.
class ThemeModeController extends Notifier<ThemeMode> {
  static const String _key = 'aqi_me.themeMode.v1';

  @override
  ThemeMode build() {
    switch (ref.read(sharedPreferencesProvider).getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void set(ThemeMode mode) {
    state = mode;
    unawaited(ref.read(sharedPreferencesProvider).setString(_key, mode.name));
  }
}

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

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

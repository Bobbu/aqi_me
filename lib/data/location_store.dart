import 'dart:convert';

import 'package:aqi_me/models/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-device persistence of the user's tracked locations, stored as a single
/// JSON string in `shared_preferences` (TECH_DESIGN §6.4, §15). Nothing leaves
/// the device.
class LocationStore {
  LocationStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'aqi_me.locations.v1';

  /// Reads the saved list. Returns empty on first run or if the stored value is
  /// unreadable (corrupt data should never crash startup).
  List<Location> load() {
    final String? raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const <Location>[];
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return const <Location>[];
      return <Location>[
        for (final Object? item in decoded)
          if (item is Map<String, dynamic>) Location.fromJson(item),
      ];
    } on FormatException {
      return const <Location>[];
    }
  }

  /// Persists the full list, replacing any previous value.
  Future<void> save(List<Location> locations) {
    final String raw = jsonEncode(<Map<String, dynamic>>[
      for (final Location l in locations) l.toJson(),
    ]);
    return _prefs.setString(_key, raw);
  }
}

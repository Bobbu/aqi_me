import 'dart:async';

import 'package:aqi_me/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How the tracked locations are laid out.
enum ViewMode { grid, list }

/// The active [ViewMode], persisted per device so the choice sticks.
class ViewModeController extends Notifier<ViewMode> {
  static const String _key = 'aqi_me.viewMode.v1';

  @override
  ViewMode build() {
    final String? raw = ref.read(sharedPreferencesProvider).getString(_key);
    return raw == ViewMode.list.name ? ViewMode.list : ViewMode.grid;
  }

  void toggle() => _set(state == ViewMode.grid ? ViewMode.list : ViewMode.grid);

  void _set(ViewMode mode) {
    state = mode;
    unawaited(ref.read(sharedPreferencesProvider).setString(_key, mode.name));
  }
}

final NotifierProvider<ViewModeController, ViewMode> viewModeProvider =
    NotifierProvider<ViewModeController, ViewMode>(ViewModeController.new);

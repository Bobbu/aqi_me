import 'dart:async';

import 'package:aqi_me/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the tutorial call-out has been dismissed (or the video opened).
/// Persisted per device so the badge doesn't keep coming back.
class TutorialDismissedController extends Notifier<bool> {
  static const String _key = 'aqi_me.tutorialDismissed.v1';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  void dismiss() {
    if (state) return;
    state = true;
    unawaited(ref.read(sharedPreferencesProvider).setBool(_key, true));
  }
}

final NotifierProvider<TutorialDismissedController, bool>
tutorialDismissedProvider = NotifierProvider<TutorialDismissedController, bool>(
  TutorialDismissedController.new,
);

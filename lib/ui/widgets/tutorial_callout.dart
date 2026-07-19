import 'dart:async';

import 'package:aqi_me/state/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// The how-to tutorial on YouTube.
const String kTutorialVideoUrl = 'https://youtu.be/Ofsa78ADW_k';

/// A friendly accent for the tutorial call-out (deliberately not an AQI color).
const Color _accent = Color(0xFF3B6FD4);

/// Opens the tutorial video in a new tab.
void openTutorialVideo() {
  unawaited(
    launchUrl(Uri.parse(kTutorialVideoUrl), webOnlyWindowName: '_blank'),
  );
}

/// A dismissible "watch the tutorial" call-out shown until the user opens the
/// video or dismisses it (persisted). Also reachable any time from the Help sheet.
class TutorialCallout extends ConsumerWidget {
  const TutorialCallout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tutorialDismissedProvider)) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    void openAndDismiss() {
      openTutorialVideo();
      ref.read(tutorialDismissedProvider.notifier).dismiss();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: openAndDismiss,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.play_circle_fill, color: _accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'New to AQI Me? Watch the quick tutorial',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'A short how-to video — tap to play',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Dismiss',
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: () =>
                        ref.read(tutorialDismissedProvider.notifier).dismiss(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

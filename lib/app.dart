import 'package:aqi_me/core/theme.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:aqi_me/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget. One route (single-page app); theme follows the OS until the
/// header toggle sets an explicit light/dark.
class AqiApp extends ConsumerWidget {
  const AqiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // Flutter writes this to document.title at runtime (what a bookmark
      // captures), so it must match the HTML <title> brand.
      title: 'AQI Me',
      debugShowCheckedModeBanner: false,
      theme: AqiTheme.light(),
      darkTheme: AqiTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      home: const HomePage(),
    );
  }
}

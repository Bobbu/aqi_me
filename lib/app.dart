import 'package:aqi_me/core/theme.dart';
import 'package:aqi_me/ui/home_page.dart';
import 'package:flutter/material.dart';

/// Root widget. One route for now (single-page app); light/dark follow the OS.
class AqiApp extends StatelessWidget {
  const AqiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQI.me',
      debugShowCheckedModeBanner: false,
      theme: AqiTheme.light(),
      darkTheme: AqiTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

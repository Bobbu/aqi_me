import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The neutral "instrument" chrome for AQI.me (TECH_DESIGN §4).
///
/// The interface contributes almost no color of its own — all chroma comes from
/// the AQI category of each location (see `aqi_scale.dart`). These tokens define
/// only the quiet panel the air's color sits inside.
abstract final class AqiColors {
  // Light — "Porcelain"
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightInk = Color(0xFF12161C);
  static const Color lightMuted = Color(0xFF5B6572);
  static const Color lightHairline = Color(0xFFE2E6EC);

  // Dark — "Observatory"
  static const Color darkBackground = Color(0xFF0E1116);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkInk = Color(0xFFE7ECF2);
  static const Color darkMuted = Color(0xFF8A94A3);
  static const Color darkHairline = Color(0xFF232A33);
}

/// Builds the light and dark [ThemeData] for the app.
///
/// Typography is the instrument-readout pairing from §4.2:
///  - Space Grotesk — display (location names, headers)
///  - Inter — body / UI (labels, secondary detail)
///  - IBM Plex Mono — the numeric AQI readout (applied at the widget layer)
abstract final class AqiTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  /// The monospaced style for large AQI readouts. Callers supply size/color so
  /// the same instrument face is used everywhere a gauge value appears.
  static TextStyle readout({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      // Tabular figures keep changing numbers from shifting width.
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1,
    );
  }

  static ThemeData _base(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background = isDark
        ? AqiColors.darkBackground
        : AqiColors.lightBackground;
    final Color surface = isDark
        ? AqiColors.darkSurface
        : AqiColors.lightSurface;
    final Color ink = isDark ? AqiColors.darkInk : AqiColors.lightInk;
    final Color muted = isDark ? AqiColors.darkMuted : AqiColors.lightMuted;
    final Color hairline = isDark
        ? AqiColors.darkHairline
        : AqiColors.lightHairline;

    final ColorScheme scheme =
        ColorScheme.fromSeed(seedColor: ink, brightness: brightness).copyWith(
          surface: surface,
          onSurface: ink,
          outline: hairline,
          outlineVariant: hairline,
        );

    // Display face for headings, body face for everything textual.
    final TextTheme textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: ink, displayColor: ink);

    final TextTheme displayTheme = GoogleFonts.spaceGroteskTextTheme(textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: hairline,
      textTheme: textTheme.copyWith(
        headlineLarge: displayTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        headlineMedium: displayTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleLarge: displayTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        // Eyebrow / label style — uppercase, tracked (§4.2).
        labelSmall: textTheme.labelSmall?.copyWith(
          color: muted,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: ink),
        bodySmall: textTheme.bodySmall?.copyWith(color: muted),
      ),
    );
  }
}

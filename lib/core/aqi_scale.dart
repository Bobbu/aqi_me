import 'package:flutter/painting.dart';

/// US EPA Air Quality Index categories, ordered by ascending severity.
///
/// Colors follow the refined palette in TECH_DESIGN §4.1: hues stay within EPA
/// identity (recognizable at a glance) but are tuned for UI cohesion and WCAG AA
/// text contrast. Each category exposes a [solid] (badge / numeric readout / card
/// spine) and a [hazeStrength] that scales the soft card wash so worse air reads
/// as visually heavier.
enum AqiCategory {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

/// The inclusive US AQI value at which each category begins. The final category
/// ([AqiCategory.hazardous]) has no fixed upper bound.
extension AqiCategoryScale on AqiCategory {
  /// Human-readable category name, as shown on a card.
  String get label {
    switch (this) {
      case AqiCategory.good:
        return 'Good';
      case AqiCategory.moderate:
        return 'Moderate';
      case AqiCategory.unhealthySensitive:
        return 'Unhealthy for Sensitive Groups';
      case AqiCategory.unhealthy:
        return 'Unhealthy';
      case AqiCategory.veryUnhealthy:
        return 'Very Unhealthy';
      case AqiCategory.hazardous:
        return 'Hazardous';
    }
  }

  /// Compact label for tight spaces (e.g. the color spine tooltip).
  String get shortLabel {
    switch (this) {
      case AqiCategory.unhealthySensitive:
        return 'USG';
      default:
        return label;
    }
  }

  /// Lower bound (inclusive) of this category on the US AQI scale.
  int get lowerBound {
    switch (this) {
      case AqiCategory.good:
        return 0;
      case AqiCategory.moderate:
        return 51;
      case AqiCategory.unhealthySensitive:
        return 101;
      case AqiCategory.unhealthy:
        return 151;
      case AqiCategory.veryUnhealthy:
        return 201;
      case AqiCategory.hazardous:
        return 301;
    }
  }

  /// The solid brand color for this category — used for the numeric readout,
  /// the card's color spine, badges, and the air-ribbon segment.
  Color get solid {
    switch (this) {
      case AqiCategory.good:
        return const Color(0xFF3DAE7A);
      case AqiCategory.moderate:
        return const Color(0xFFD9A400);
      case AqiCategory.unhealthySensitive:
        return const Color(0xFFF2843A);
      case AqiCategory.unhealthy:
        return const Color(0xFFE5484D);
      case AqiCategory.veryUnhealthy:
        return const Color(0xFF8E5BD9);
      case AqiCategory.hazardous:
        return const Color(0xFF9B1C46);
    }
  }

  /// How dense the card's ambient haze should be, 0..1 — clear for good air,
  /// smoggy for hazardous (TECH_DESIGN §4.3). The widget layer applies this as
  /// the alpha of a radial [solid] wash.
  double get hazeStrength {
    switch (this) {
      case AqiCategory.good:
        return 0.06;
      case AqiCategory.moderate:
        return 0.10;
      case AqiCategory.unhealthySensitive:
        return 0.14;
      case AqiCategory.unhealthy:
        return 0.18;
      case AqiCategory.veryUnhealthy:
        return 0.24;
      case AqiCategory.hazardous:
        return 0.30;
    }
  }

  /// The [solid] color at the category's haze alpha — the soft card wash.
  Color get haze => solid.withValues(alpha: hazeStrength);
}

/// Maps a US AQI value to its EPA category.
///
/// Negative inputs are clamped to [AqiCategory.good]; anything at or above 301
/// (including the 301–500 band and any out-of-range readings) is
/// [AqiCategory.hazardous].
AqiCategory aqiCategoryFor(int usAqi) {
  if (usAqi <= 50) return AqiCategory.good;
  if (usAqi <= 100) return AqiCategory.moderate;
  if (usAqi <= 150) return AqiCategory.unhealthySensitive;
  if (usAqi <= 200) return AqiCategory.unhealthy;
  if (usAqi <= 300) return AqiCategory.veryUnhealthy;
  return AqiCategory.hazardous;
}

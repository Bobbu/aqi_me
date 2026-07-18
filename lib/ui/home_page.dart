import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/core/theme.dart';
import 'package:flutter/material.dart';

/// M0 placeholder home page.
///
/// This is scaffolding, not the real product screen — it renders the design
/// tokens (chrome, typography, and the AQI palette from `aqi_scale.dart`) so we
/// can see the "instrument for the air" direction take shape. It will be
/// replaced by the location grid in M2/M3.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// A representative AQI value per category, for the preview only.
  static const Map<AqiCategory, int> _sampleValues = <AqiCategory, int>{
    AqiCategory.good: 42,
    AqiCategory.moderate: 78,
    AqiCategory.unhealthySensitive: 132,
    AqiCategory.unhealthy: 175,
    AqiCategory.veryUnhealthy: 240,
    AqiCategory.hazardous: 350,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AQI·ME',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'An instrument for the air — scaffolding preview (M0)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  const _AirRibbon(),
                  const SizedBox(height: 32),
                  _CategoryLabel('The AQI scale', theme: theme),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: <Widget>[
                      for (final AqiCategory category in AqiCategory.values)
                        _CategoryCard(
                          category: category,
                          value: _sampleValues[category]!,
                        ),
                    ],
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

/// The aggregate "air ribbon" — one segment per category (TECH_DESIGN §4.3).
class _AirRibbon extends StatelessWidget {
  const _AirRibbon();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: <Widget>[
            for (final AqiCategory category in AqiCategory.values)
              Expanded(child: ColoredBox(color: category.solid)),
          ],
        ),
      ),
    );
  }
}

/// A single category preview: color spine + haze wash + mono readout.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.value});

  final AqiCategory category;
  final int value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        // The haze: a soft radial wash whose density scales with severity.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.1,
            center: const Alignment(-0.6, -0.8),
            colors: <Color>[category.haze, Colors.transparent],
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Color spine.
              Container(width: 4, color: category.solid),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$value',
                        style: AqiTheme.readout(
                          fontSize: 52,
                          color: category.solid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label.toUpperCase(),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small uppercase section label (eyebrow).
class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel(this.text, {required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
    );
  }
}

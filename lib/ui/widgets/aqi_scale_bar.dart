import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/state/card_anchors.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The aggregate air view as a **scale**: a green→maroon gradient spanning the
/// EPA AQI categories, with each tracked location plotted as a dot at its
/// current value. Unlike the per-location ribbon, this shows where your places
/// sit on the scale — and relative to each other — so a glance answers "how bad,
/// and how close to the next category?" (see the "air ribbon" discussion).
///
/// Reading a dot:
/// - **Tap / click** a dot to scroll to that location's card (the mobile-
///   friendly identity path, since labels and hover tooltips are limited there).
/// - **Hover / long-press** shows a tooltip (name · AQI · category).
///
/// Wide layouts label all six category bands beneath the bar; narrow layouts
/// show just the "Good" and "Hazardous" endpoints so the scale still reads.
class AqiScaleBar extends ConsumerWidget {
  const AqiScaleBar({required this.locations, super.key});

  final List<Location> locations;

  /// Below this content width we collapse the six band labels to the endpoints.
  static const double _wideThreshold = 560;
  static const double _barHeight = 12;
  static const double _dot = 13;
  static const double _rowGap = 4;

  /// Touch target around each dot (larger than the dot itself for tappability).
  static const double _hit = 30;

  /// Compact category names for the under-bar legend (the full labels are too
  /// long for a sixth of the bar).
  static const List<String> _bandLabels = <String>[
    'Good',
    'Moderate',
    'Sensitive',
    'Unhealthy',
    'Very Unhealthy',
    'Hazardous',
  ];

  /// Normalized 0..1 position of [aqi] on the scale, using equal-width category
  /// bands (so the common 0–150 range isn't crushed against the left the way a
  /// linear 0–500 axis would). Within its band, the value is placed
  /// proportionally.
  static double _fractionFor(int aqi) {
    const List<AqiCategory> values = AqiCategory.values;
    final AqiCategory category = aqiCategoryFor(aqi);
    final int i = values.indexOf(category);
    final int lower = category.lowerBound;
    final int upper = i + 1 < values.length
        ? values[i + 1].lowerBound - 1
        : 500;
    final double within = ((aqi - lower) / (upper - lower)).clamp(0.0, 1.0);
    return (i + within) / values.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (locations.isEmpty) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);
    final TextStyle? labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.2,
    );

    // Collect the resolved readings; unresolved locations simply have no dot yet.
    final List<_Marker> markers = <_Marker>[];
    for (final Location location in locations) {
      final LocationReading? reading = ref
          .watch(locationReadingProvider(location))
          .valueOrNull;
      if (reading != null) {
        markers.add(
          _Marker(
            location: location,
            aqi: reading.aqi.usAqi,
            category: reading.aqi.category,
            fraction: _fractionFor(reading.aqi.usAqi),
          ),
        );
      }
    }

    // Scroll a location's card into view when its dot is tapped.
    void revealCard(String id) {
      final BuildContext? cardContext = ref
          .read(cardAnchorsProvider)[id]
          ?.currentContext;
      if (cardContext != null) {
        Scrollable.ensureVisible(
          cardContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool wide = width >= _wideThreshold;
        final int rows = _assignRows(markers, width);
        const double rowStride = _dot + _rowGap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The scale itself: a smooth green→maroon gradient across the six
            // category solids.
            Container(
              height: _barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: <Color>[
                    for (final AqiCategory c in AqiCategory.values) c.solid,
                  ],
                ),
              ),
            ),
            // Location dots, stacked into as many rows as needed to avoid
            // overlap when several places sit at similar AQI values.
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                height: (rows - 1) * rowStride + _hit,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    for (final _Marker m in markers)
                      Positioned(
                        left: (m.fraction * width - _hit / 2).clamp(
                          0.0,
                          width - _hit,
                        ),
                        top: m.row * rowStride,
                        child: _Dot(
                          marker: m,
                          theme: theme,
                          onTap: () => revealCard(m.location.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: wide
                  ? Row(
                      children: <Widget>[
                        for (final String label in _bandLabels)
                          Expanded(
                            child: Center(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: labelStyle,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Good', style: labelStyle),
                        Text('Hazardous', style: labelStyle),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Greedy vertical packing: walking dots left-to-right, drop each into the
  /// first row whose previous dot is far enough left, else start a new row.
  /// Mutates [_Marker.row] and returns the number of rows used (at least 1).
  static int _assignRows(List<_Marker> markers, double width) {
    if (markers.isEmpty) return 1;
    final List<_Marker> sorted = <_Marker>[...markers]
      ..sort((_Marker a, _Marker b) => a.fraction.compareTo(b.fraction));
    final List<double> rowLastX = <double>[];
    const double minGap = _dot + 2;
    for (final _Marker m in sorted) {
      final double x = m.fraction * width;
      int row = 0;
      while (row < rowLastX.length && x - rowLastX[row] < minGap) {
        row++;
      }
      if (row == rowLastX.length) {
        rowLastX.add(x);
      } else {
        rowLastX[row] = x;
      }
      m.row = row;
    }
    return rowLastX.length;
  }
}

class _Marker {
  _Marker({
    required this.location,
    required this.aqi,
    required this.category,
    required this.fraction,
  });

  final Location location;
  final int aqi;
  final AqiCategory category;
  final double fraction;
  int row = 0;
}

class _Dot extends StatelessWidget {
  const _Dot({required this.marker, required this.theme, required this.onTap});

  final _Marker marker;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Tooltip(
          message:
              '${marker.location.label} · ${marker.aqi} · ${marker.category.shortLabel}',
          child: SizedBox(
            width: AqiScaleBar._hit,
            height: AqiScaleBar._hit,
            child: Center(
              child: Container(
                width: AqiScaleBar._dot,
                height: AqiScaleBar._dot,
                decoration: BoxDecoration(
                  color: marker.category.solid,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

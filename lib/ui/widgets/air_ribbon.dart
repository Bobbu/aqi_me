import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The aggregate "air ribbon" — one segment per tracked location, colored by its
/// AQI category, giving an at-a-glance spectrum of your world's air
/// (TECH_DESIGN §4.3). Segments show neutral until their reading resolves.
class AirRibbon extends StatelessWidget {
  const AirRibbon({required this.locations, super.key});

  final List<Location> locations;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final Location location in locations)
              Expanded(child: _Segment(location: location)),
          ],
        ),
      ),
    );
  }
}

class _Segment extends ConsumerWidget {
  const _Segment({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LocationReading> reading = ref.watch(
      locationReadingProvider(location),
    );
    final Color color =
        reading.valueOrNull?.aqi.category.solid ??
        Theme.of(context).colorScheme.outlineVariant;
    return ColoredBox(color: color);
  }
}

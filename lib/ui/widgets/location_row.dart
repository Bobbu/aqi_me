import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/core/formatters.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:aqi_me/data/location_builders.dart';
import 'package:aqi_me/models/aqi_reading.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:aqi_me/ui/widgets/animated_aqi_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A compact horizontal row for a tracked location — the list-view counterpart
/// to `LocationCard`. Includes a drag handle for reordering.
class LocationRow extends ConsumerWidget {
  const LocationRow({required this.location, required this.index, super.key});

  final Location location;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LocationReading> reading = ref.watch(
      locationReadingProvider(location),
    );
    final ThemeData theme = Theme.of(context);
    final AqiCategory? category = reading.valueOrNull?.aqi.category;
    final Color spineColor = category?.solid ?? theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: category == null
              ? null
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[category.haze, Colors.transparent],
                  stops: const <double>[0, 0.6],
                ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 4, color: spineColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 58,
                        child: reading.when(
                          data: (LocationReading r) => AnimatedAqiNumber(
                            value: r.aqi.usAqi,
                            color: r.aqi.category.solid,
                            fontSize: 30,
                          ),
                          loading: () => const _Dot(),
                          error: (_, _) => Icon(
                            Icons.error_outline,
                            size: 22,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              location.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            reading.when(
                              data: (LocationReading r) => Text(
                                _detail(r),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                              loading: () => Text(
                                locationSubtitle(location),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                              error: (Object e, _) => Text(
                                e is AqiServiceException
                                    ? e.message
                                    : 'Could not load this location.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (reading.hasError)
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'Retry',
                          visualDensity: VisualDensity.compact,
                          color: theme.colorScheme.outline,
                          onPressed: () => refreshLocation(ref, location),
                        ),
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.drag_handle,
                            size: 20,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Remove ${location.label}',
                        visualDensity: VisualDensity.compact,
                        color: theme.colorScheme.outline,
                        onPressed: () => ref
                            .read(locationsControllerProvider.notifier)
                            .remove(location.id),
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

  String _detail(LocationReading r) {
    final AqiReading aqi = r.aqi;
    final String? pollutant = aqi.dominantPollutant == null
        ? null
        : kPollutantLabels[aqi.dominantPollutant];
    final String? temp = r.weather == null
        ? null
        : formatTempF(r.weather!.temperatureC);
    final String asOf =
        'as of ${formatClock(aqi.observedAt)}'
        '${aqi.timezoneLabel == null ? '' : ' ${aqi.timezoneLabel}'}';
    return <String>[aqi.category.label, ?pollutant, ?temp, asOf].join(' · ');
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

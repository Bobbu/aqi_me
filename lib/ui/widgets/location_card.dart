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

/// One tracked location. Watches its own [AsyncValue] reading and renders the
/// loading / data / error state, with the air-tinted haze + color spine + mono
/// readout signature (TECH_DESIGN §4.3).
class LocationCard extends ConsumerWidget {
  const LocationCard({required this.location, this.dragHandle, super.key});

  static const double width = 240;

  final Location location;

  /// Optional drag affordance shown in the header (grid reordering).
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LocationReading> reading = ref.watch(
      locationReadingProvider(location),
    );
    final ThemeData theme = Theme.of(context);

    final AqiCategory? category = reading.valueOrNull?.aqi.category;
    final Color spineColor = category?.solid ?? theme.colorScheme.outline;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: category == null
              ? null
              : RadialGradient(
                  radius: 1.1,
                  center: const Alignment(-0.6, -0.8),
                  colors: <Color>[category.haze, Colors.transparent],
                ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 4, color: spineColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Header(location: location, dragHandle: dragHandle),
                      const SizedBox(height: 10),
                      reading.when(
                        // Flash the loading state on manual/auto refresh so it's
                        // visible that a re-fetch happened.
                        skipLoadingOnRefresh: false,
                        data: (LocationReading r) =>
                            _CardBody(reading: r, theme: theme),
                        loading: () => const _CardLoading(),
                        error: (Object e, _) => _CardError(
                          location: location,
                          message: e is AqiServiceException
                              ? e.message
                              : 'Could not load this location.',
                        ),
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

class _Header extends ConsumerWidget {
  const _Header({required this.location, this.dragHandle});

  final Location location;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String subtitle = locationSubtitle(location);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                location.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        ?dragHandle,
        _IconButton(
          icon: Icons.close,
          tooltip: 'Remove ${location.label}',
          onPressed: () => ref
              .read(locationsControllerProvider.notifier)
              .remove(location.id),
        ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.reading, required this.theme});

  final LocationReading reading;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final AqiReading aqi = reading.aqi;
    final String? pollutant = aqi.dominantPollutant == null
        ? null
        : kPollutantLabels[aqi.dominantPollutant];
    final String? temp = reading.weather == null
        ? null
        : formatTempF(reading.weather!.temperatureC);
    final String meta = <String>[?pollutant, ?temp].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedAqiNumber(value: aqi.usAqi, color: aqi.category.solid),
        const SizedBox(height: 6),
        Text(
          aqi.category.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        if (meta.isNotEmpty) Text(meta, style: theme.textTheme.bodySmall),
        Text(
          'as of ${formatClock(aqi.observedAt)}'
          '${aqi.timezoneLabel == null ? '' : ' ${aqi.timezoneLabel}'}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CardLoading extends StatelessWidget {
  const _CardLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _CardError extends ConsumerWidget {
  const _CardError({required this.location, required this.message});

  final Location location;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(message, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => refreshLocation(ref, location),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:aqi_me/ui/widgets/add_location_field.dart';
import 'package:aqi_me/ui/widgets/air_ribbon.dart';
import 'package:aqi_me/ui/widgets/empty_state.dart';
import 'package:aqi_me/ui/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single app screen: header, smart add-field, the air ribbon, and the
/// grid of location cards (or an empty state).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Location> locations = ref.watch(locationsControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Header(locations: locations),
                  const SizedBox(height: 20),
                  const AddLocationField(),
                  const SizedBox(height: 20),
                  if (locations.isEmpty)
                    const EmptyState()
                  else ...<Widget>[
                    AirRibbon(locations: locations),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        for (final Location location in locations)
                          LocationCard(
                            location: location,
                            key: ValueKey<String>(location.id),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.locations});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'AQI·ME',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                  letterSpacing: 1.5,
                ),
              ),
              Text('Air quality at a glance', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        if (locations.isNotEmpty) ...<Widget>[
          Text(
            '${locations.length} / ${LocationsController.maxLocations}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh all',
            color: theme.colorScheme.outline,
            onPressed: () {
              for (final Location location in locations) {
                refreshLocation(ref, location);
              }
            },
          ),
        ],
      ],
    );
  }
}

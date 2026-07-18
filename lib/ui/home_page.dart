import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/providers.dart';
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

/// Toggles the app between light and dark, seeded from the current effective
/// brightness so the first tap always flips what the user sees.
class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ThemeMode mode = ref.watch(themeModeProvider);
    final bool platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bool isDark =
        mode == ThemeMode.dark || (mode == ThemeMode.system && platformDark);

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
      color: theme.colorScheme.outline,
      onPressed: () => ref.read(themeModeProvider.notifier).state = isDark
          ? ThemeMode.light
          : ThemeMode.dark,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/aqi_me_logo.png',
            width: 44,
            height: 44,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(width: 14),
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
        const _ThemeToggle(),
      ],
    );
  }
}

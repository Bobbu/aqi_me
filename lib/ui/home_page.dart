import 'dart:async';

import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:aqi_me/state/view_mode.dart';
import 'package:aqi_me/ui/widgets/add_location_field.dart';
import 'package:aqi_me/ui/widgets/air_ribbon.dart';
import 'package:aqi_me/ui/widgets/app_footer.dart';
import 'package:aqi_me/ui/widgets/empty_state.dart';
import 'package:aqi_me/ui/widgets/help_sheet.dart';
import 'package:aqi_me/ui/widgets/location_card.dart';
import 'package:aqi_me/ui/widgets/location_row.dart';
import 'package:aqi_me/ui/widgets/tutorial_callout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The single app screen: header, smart add-field, the air ribbon, and the
/// grid of location cards (or an empty state).
///
/// Also owns auto-refresh (TECH_DESIGN §9.3): every 60 minutes while the tab is
/// visible, all readings are refreshed. Background tabs throttle timers, so on
/// resume we also catch up if a full interval has elapsed.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  static const Duration _interval = Duration(minutes: 60);
  Timer? _timer;
  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(_interval, (_) => _refreshAll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Catch up on return if the periodic timer was throttled while hidden.
    if (state == AppLifecycleState.resumed &&
        DateTime.now().difference(_lastRefresh) >= _interval) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    _lastRefresh = DateTime.now();
    for (final Location location in ref.read(locationsControllerProvider)) {
      refreshLocation(ref, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Location> locations = ref.watch(locationsControllerProvider);

    return Scaffold(
      // Sticky footer that still scrolls: the content is one sliver at its full
      // natural height (so a tall list scrolls all the way to the last card), and
      // a trailing SliverFillRemaining pins the footer to the bottom of the
      // viewport when the content is short — without clipping tall content.
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Header(locations: locations),
                        const SizedBox(height: 20),
                        const AddLocationField(),
                        const TutorialCallout(),
                        const SizedBox(height: 20),
                        if (locations.isEmpty)
                          const EmptyState()
                        else ...<Widget>[
                          AirRibbon(locations: locations),
                          const SizedBox(height: 24),
                          if (ref.watch(viewModeProvider) == ViewMode.list)
                            _LocationList(locations: locations)
                          else
                            _LocationGrid(locations: locations),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 48),
                  Center(child: AppFooter()),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
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
      color: theme.colorScheme.onSurfaceVariant,
      onPressed: () => ref
          .read(themeModeProvider.notifier)
          .set(isDark ? ThemeMode.light : ThemeMode.dark),
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
                'AQI Me',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 30,
                  letterSpacing: 0.5,
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
          const _ViewToggle(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh all',
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: () {
              for (final Location location in locations) {
                refreshLocation(ref, location);
              }
            },
          ),
        ],
        IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: 'What am I looking at?',
          color: theme.colorScheme.onSurfaceVariant,
          onPressed: () => showHelpSheet(context),
        ),
        const _ThemeToggle(),
      ],
    );
  }
}

/// Switches between the grid and list layouts (persisted).
class _ViewToggle extends ConsumerWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ViewMode mode = ref.watch(viewModeProvider);
    final bool isList = mode == ViewMode.list;
    return IconButton(
      icon: Icon(isList ? Icons.grid_view_outlined : Icons.view_list_outlined),
      tooltip: isList ? 'Grid view' : 'List view',
      color: theme.colorScheme.onSurfaceVariant,
      onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
    );
  }
}

/// The reorderable card grid. Long-press a card and drop it onto another to
/// reorder; the order is shared with the list view and persisted.
class _LocationGrid extends ConsumerWidget {
  const _LocationGrid({required this.locations});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        for (int i = 0; i < locations.length; i++)
          _DraggableGridCard(
            key: ValueKey<String>(locations[i].id),
            location: locations[i],
            index: i,
          ),
      ],
    );
  }
}

class _DraggableGridCard extends ConsumerWidget {
  const _DraggableGridCard({
    required this.location,
    required this.index,
    super.key,
  });

  final Location location;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> d) => d.data != index,
      onAcceptWithDetails: (DragTargetDetails<int> d) =>
          ref.read(locationsControllerProvider.notifier).reorder(d.data, index),
      builder:
          (BuildContext context, List<int?> candidate, List<dynamic> rejected) {
            final bool hovering = candidate.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hovering
                      ? theme.colorScheme.onSurface
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: LocationCard(
                location: location,
                // Drag this handle onto another card to reorder.
                dragHandle: Draggable<int>(
                  data: index,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.92,
                      child: SizedBox(
                        width: LocationCard.width,
                        child: LocationCard(location: location),
                      ),
                    ),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Tooltip(
                      message: 'Drag to reorder',
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.drag_indicator,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }
}

/// The reorderable list layout — drag the handle on each row to reorder.
class _LocationList extends ConsumerWidget {
  const _LocationList({required this.locations});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: locations.length,
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        ref
            .read(locationsControllerProvider.notifier)
            .reorder(oldIndex, newIndex);
      },
      itemBuilder: (BuildContext context, int i) => Padding(
        key: ValueKey<String>(locations[i].id),
        padding: const EdgeInsets.only(bottom: 12),
        child: LocationRow(location: locations[i], index: i),
      ),
    );
  }
}

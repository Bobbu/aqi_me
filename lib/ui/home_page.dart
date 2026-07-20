import 'dart:async';

import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/card_anchors.dart';
import 'package:aqi_me/state/locations_controller.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:aqi_me/state/reading_providers.dart';
import 'package:aqi_me/state/view_mode.dart';
import 'package:aqi_me/ui/widgets/add_location_field.dart';
import 'package:aqi_me/ui/widgets/app_footer.dart';
import 'package:aqi_me/ui/widgets/aqi_scale_bar.dart';
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
                          AqiScaleBar(locations: locations),
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
    final ThemeMode mode = ref.watch(themeModeProvider);
    final bool platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bool isDark =
        mode == ThemeMode.dark || (mode == ThemeMode.system && platformDark);

    return _HeaderIcon(
      icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      tooltip: isDark ? 'Switch to light' : 'Switch to dark',
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
    // Phones can't fit the 30px title plus the logo, count, and action icons on
    // one row, so shrink the title on narrow widths and keep it to a line.
    final bool narrow = MediaQuery.sizeOf(context).width < 480;
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
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: narrow ? 24 : 30,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Air quality at a glance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (locations.isNotEmpty) ...<Widget>[
          Text(
            '${locations.length} / ${LocationsController.maxLocations}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(width: 4),
          const _ViewToggle(),
          _HeaderIcon(
            icon: Icons.refresh,
            tooltip: 'Refresh all',
            onPressed: () {
              for (final Location location in locations) {
                refreshLocation(ref, location);
              }
            },
          ),
        ],
        _HeaderIcon(
          icon: Icons.help_outline,
          tooltip: 'What am I looking at?',
          onPressed: () => showHelpSheet(context),
        ),
        const _ThemeToggle(),
      ],
    );
  }
}

/// A compact icon button sized to keep the header on one row on phones.
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
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
      icon: Icon(icon),
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      iconSize: 22,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
    );
  }
}

/// Switches between the grid and list layouts (persisted).
class _ViewToggle extends ConsumerWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ViewMode mode = ref.watch(viewModeProvider);
    final bool isList = mode == ViewMode.list;
    return _HeaderIcon(
      icon: isList ? Icons.grid_view_outlined : Icons.view_list_outlined,
      tooltip: isList ? 'Grid view' : 'List view',
      onPressed: () => ref.read(viewModeProvider.notifier).toggle(),
    );
  }
}

/// The reorderable card grid. Drag a card's handle onto another to reorder; the
/// order is shared with the list view and persisted.
///
/// Cards fill the available width in equal columns (1–3 depending on space) so
/// the grid aligns to the outer margins with no ragged right edge, and every
/// card in a row shares the tallest card's height.
class _LocationGrid extends ConsumerWidget {
  const _LocationGrid({required this.locations});

  final List<Location> locations;

  static const double _gap = 16;
  static const double _minCardWidth = 260;
  static const int _maxColumns = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final int columns = ((maxWidth + _gap) / (_minCardWidth + _gap))
            .floor()
            .clamp(1, _maxColumns);
        final double cardWidth = (maxWidth - _gap * (columns - 1)) / columns;

        final List<Widget> rows = <Widget>[];
        for (int start = 0; start < locations.length; start += columns) {
          if (rows.isNotEmpty) rows.add(const SizedBox(height: _gap));
          final List<Widget> cells = <Widget>[];
          for (int c = 0; c < columns; c++) {
            if (c > 0) cells.add(const SizedBox(width: _gap));
            final int index = start + c;
            final bool hasCard = index < locations.length;
            cells.add(
              SizedBox(
                // Anchor the cell so a tapped scale-bar dot can scroll here.
                key: hasCard ? cardAnchorKey(ref, locations[index].id) : null,
                width: cardWidth,
                // Empty trailing slots keep the last row's cards left-aligned
                // and the same width as the rows above.
                child: hasCard
                    ? _DraggableGridCard(
                        key: ValueKey<String>(locations[index].id),
                        location: locations[index],
                        index: index,
                        width: cardWidth,
                      )
                    : null,
              ),
            );
          }
          // IntrinsicHeight bounds the row to the tallest card, and stretch then
          // makes every card in the row match that height. (Plain stretch alone
          // throws here — the row's height is unbounded inside the scroll view.)
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cells,
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class _DraggableGridCard extends ConsumerWidget {
  const _DraggableGridCard({
    required this.location,
    required this.index,
    required this.width,
    super.key,
  });

  final Location location;
  final int index;
  final double width;

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
                        width: width,
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
        // Anchor the row so a tapped scale-bar dot can scroll here.
        child: KeyedSubtree(
          key: cardAnchorKey(ref, locations[i].id),
          child: LocationRow(location: locations[i], index: i),
        ),
      ),
    );
  }
}

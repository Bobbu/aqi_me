import 'dart:async';

import 'package:aqi_me/data/default_locations.dart';
import 'package:aqi_me/data/location_store.dart';
import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outcome of trying to add a location.
enum AddOutcome { added, duplicate, full }

/// Owns the user's list of tracked locations: loads it on start, enforces the
/// 20-location cap and de-duplication, and persists every change (TECH_DESIGN §6.4).
class LocationsController extends Notifier<List<Location>> {
  static const int maxLocations = 20;

  @override
  List<Location> build() {
    final LocationStore store = ref.read(locationStoreProvider);
    // First-ever visit: seed starter locations and persist them so they're
    // treated as the user's list from then on.
    if (!store.hasSavedList) {
      final List<Location> seeded = defaultLocations();
      unawaited(store.save(seeded));
      return seeded;
    }
    return store.load();
  }

  bool get isFull => state.length >= maxLocations;

  /// Adds [location], unless the list is full or it duplicates an existing entry
  /// (same rounded coordinates). Persists on success.
  AddOutcome add(Location location) {
    if (isFull) return AddOutcome.full;
    if (state.any((Location l) => l.id == location.id)) {
      return AddOutcome.duplicate;
    }
    state = <Location>[...state, location];
    _persist();
    return AddOutcome.added;
  }

  /// Removes the location with [id] and persists.
  void remove(String id) {
    state = state.where((Location l) => l.id != id).toList();
    _persist();
  }

  /// Moves the location at [oldIndex] to [newIndex] (plain remove-then-insert;
  /// callers pass the final insert position) and persists.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    final List<Location> next = <Location>[...state];
    final Location moved = next.removeAt(oldIndex);
    next.insert(newIndex.clamp(0, next.length), moved);
    state = next;
    _persist();
  }

  void _persist() {
    unawaited(ref.read(locationStoreProvider).save(state));
  }
}

final NotifierProvider<LocationsController, List<Location>>
locationsControllerProvider =
    NotifierProvider<LocationsController, List<Location>>(
      LocationsController.new,
    );

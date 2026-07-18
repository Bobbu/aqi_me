import 'package:aqi_me/models/location.dart';
import 'package:aqi_me/models/location_reading.dart';
import 'package:aqi_me/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current [LocationReading] for one location, as an [AsyncValue] the card
/// renders directly (loading / data / error). The repository serves cached
/// readings inside the freshness window, so re-watching is cheap.
final FutureProviderFamily<LocationReading, Location> locationReadingProvider =
    FutureProvider.family<LocationReading, Location>((
      Ref ref,
      Location location,
    ) {
      return ref.watch(locationRepositoryProvider).getReading(location);
    });

/// Forces a fresh fetch for one location: drops the repository cache entry, then
/// invalidates the provider so watchers re-run against the network.
void refreshLocation(WidgetRef ref, Location location) {
  ref.read(locationRepositoryProvider).invalidate(location.id);
  ref.invalidate(locationReadingProvider(location));
}

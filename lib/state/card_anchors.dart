import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [GlobalKey] per location id, attached to that location's card (grid) or row
/// (list). The AQI scale bar reads these to scroll a card into view when its dot
/// is tapped — the touch-friendly way to identify a dot on mobile, where the
/// category labels and hover tooltips aren't available.
final Provider<Map<String, GlobalKey<State<StatefulWidget>>>>
cardAnchorsProvider = Provider<Map<String, GlobalKey<State<StatefulWidget>>>>(
  (Ref ref) => <String, GlobalKey<State<StatefulWidget>>>{},
);

/// The stable anchor key for [id], created on first use. Call from a card/row
/// build so the key is attached to the widget the scale bar should reveal.
GlobalKey<State<StatefulWidget>> cardAnchorKey(WidgetRef ref, String id) => ref
    .read(cardAnchorsProvider)
    .putIfAbsent(id, () => GlobalKey<State<StatefulWidget>>());

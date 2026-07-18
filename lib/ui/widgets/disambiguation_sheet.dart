import 'package:aqi_me/models/geocode_result.dart';
import 'package:flutter/material.dart';

/// Presents ambiguous geocoding matches so the user can pick the right one
/// (TECH_DESIGN §9.1). Resolves to the chosen result, or null if dismissed.
Future<GeocodeResult?> showDisambiguationSheet(
  BuildContext context,
  List<GeocodeResult> options,
) {
  return showModalBottomSheet<GeocodeResult>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => _DisambiguationSheet(options: options),
  );
}

class _DisambiguationSheet extends StatelessWidget {
  const _DisambiguationSheet({required this.options});

  final List<GeocodeResult> options;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'WHICH ONE?',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
            ),
          ),
          for (final GeocodeResult option in options)
            ListTile(
              title: Text(option.name),
              subtitle: Text(_subtitle(option)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pop(option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _subtitle(GeocodeResult r) {
    return <String>[
      if (r.admin1 != null && r.admin1!.isNotEmpty) r.admin1!,
      if (r.country != null && r.country!.isNotEmpty) r.country!,
    ].join(' · ');
  }
}

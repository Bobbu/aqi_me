import 'package:flutter/material.dart';

/// Shown when no locations are tracked yet — an invitation to add the first one
/// (TECH_DESIGN §11).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: <Widget>[
          Icon(Icons.air, size: 44, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Add your first location',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Track up to 20 places by name (Denver, CO) or\ncoordinates (39.74, -104.99).',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

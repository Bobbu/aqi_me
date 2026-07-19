import 'package:aqi_me/core/aqi_scale.dart';
import 'package:aqi_me/data/aqi_service.dart';
import 'package:flutter/material.dart';

/// Shows the help/key sheet: the AQI scale (ranges, colors, health notes) and a
/// glossary of the pollutants (PM2.5, O₃, …).
Future<void> showHelpSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 620),
    builder: (BuildContext context) => const _HelpSheet(),
  );
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Air Quality Index',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'AQI summarizes air quality on a 0–500 scale — lower is cleaner. '
                'Each location is colored by its category:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final AqiCategory category
                  in AqiCategory.values) ...<Widget>[
                _ScaleRow(category: category),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              Text(
                'POLLUTANTS',
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                'Each card shows the pollutant most responsible for that '
                "location's AQI:",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              for (final String code in kPollutantOrder) ...<Widget>[
                _PollutantRow(code: code),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 6),
              Text(
                'Times shown are each location\'s local time. Air-quality and '
                'weather data from Open-Meteo, using the US EPA AQI scale.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({required this.category});

  final AqiCategory category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: category.solid,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: category.rangeLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: category.solid,
                      ),
                    ),
                    TextSpan(
                      text: '   ${category.label}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(category.healthNote, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _PollutantRow extends StatelessWidget {
  const _PollutantRow({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(
            kPollutantLabels[code] ?? code,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                kPollutantNames[code] ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                kPollutantDescriptions[code] ?? '',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

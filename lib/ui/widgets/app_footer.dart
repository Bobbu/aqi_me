import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The shared "Any Stupid Idea" footer, matching the other Ideas (e.g.
/// quote-me): a quiet, centered credit line over Privacy · Terms links.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const String _home = 'https://anystupididea.com';
  static const String _privacy = 'https://anystupididea.com/privacy.html';
  static const String _terms = 'https://anystupididea.com/terms.html';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? base = theme.textTheme.bodySmall;
    final int year = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text.rich(
            TextSpan(
              style: base,
              children: <InlineSpan>[
                TextSpan(text: '© $year '),
                _linkSpan(context, 'Any Stupid Idea', _home),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _FooterLink(label: 'Privacy', url: _privacy),
              Text('  ·  ', style: base),
              const _FooterLink(label: 'Terms', url: _terms),
            ],
          ),
        ],
      ),
    );
  }

  InlineSpan _linkSpan(BuildContext context, String label, String url) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: _FooterLink(label: label, url: url),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.url});

  final String label;
  final String url;

  void _open() {
    unawaited(launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _open,
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

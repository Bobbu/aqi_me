import 'package:aqi_me/core/theme.dart';
import 'package:flutter/material.dart';

/// The large AQI readout that counts up from 0 on first appearance
/// (TECH_DESIGN §4.5). Honors `prefers-reduced-motion`: when animations are
/// disabled, the final value is shown immediately.
class AnimatedAqiNumber extends StatelessWidget {
  const AnimatedAqiNumber({
    required this.value,
    required this.color,
    this.fontSize = 46,
    super.key,
  });

  final int value;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AqiTheme.readout(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w600,
    );

    if (MediaQuery.of(context).disableAnimations) {
      return Text('$value', style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double v, _) =>
          Text('${v.round()}', style: style),
    );
  }
}

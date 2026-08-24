import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

/// Circular reading-progress indicator with the percentage in the middle.
///
/// Accessibility: the percentage is announced as a semantic label, because a
/// ring with a number inside reads as meaningless digits to a screen reader.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    this.size = 56,
    this.strokeWidth = 5,
    this.label,
    super.key,
  }) : assert(progress >= 0 && progress <= 1, 'progress must be 0..1');

  final double progress;
  final double size;
  final double strokeWidth;

  /// Overrides the centre text. Defaults to the rounded percentage.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).round();

    return Semantics(
      label: '$percent percent read',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: Motion.slow,
                curve: Motion.easeOut,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  strokeCap: StrokeCap.round,
                  backgroundColor: context.hairline,
                  valueColor: AlwaysStoppedAnimation(context.gold),
                ),
              ),
            ),
            Text(
              label ?? '$percent%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: size * 0.22,
                letterSpacing: 0,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

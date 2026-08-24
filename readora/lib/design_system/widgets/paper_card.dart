import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

/// The signature surface: warm paper, a hairline edge, and a soft warm shadow.
///
/// This replaces the earlier frosted-glass treatment. The design export
/// contains **no `backdrop-filter` anywhere** — the depth in the artboards
/// comes entirely from `--rd-shadow` over `--rd-surface`. That is a better fit
/// for an India-first audience on budget Android hardware too: a blur costs a
/// full-screen render pass per surface, and this costs nothing.
class PaperCard extends StatelessWidget {
  const PaperCard({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.card),
    this.onTap,
    this.elevated = true,
    this.borderRadius,
    this.color,
    super.key,
  });

  /// Flat variant for list rows and dense layouts.
  ///
  /// Shadows are for surfaces that sit *above* the page. A scrolling list of
  /// drop-shadows just reads as noise, so rows keep the fill and hairline and
  /// drop the elevation.
  const PaperCard.flat({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(Spacing.card),
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? color,
    Key? key,
  }) : this(
          child: child,
          padding: padding,
          onTap: onTap,
          elevated: false,
          borderRadius: borderRadius,
          color: color,
          key: key,
        );

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(Radii.lg);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? context.surface,
        borderRadius: radius,
        border: Border.all(color: context.hairline),
        boxShadow: elevated ? context.shadow : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: context.gold.withValues(alpha: 0.06),
          highlightColor: context.gold.withValues(alpha: 0.04),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The page ground: the warm background plus two soft orbs of `--rd-surface2`.
///
/// In the artboards these are radial gradients, not blurs — a gradient is
/// already soft, so nothing here needs an `ImageFilter`.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({required this.child, this.orbs = true, super.key});

  final Widget child;

  /// Set false on dense screens where the orbs would sit behind a long list and
  /// only add visual noise.
  final bool orbs;

  @override
  Widget build(BuildContext context) {
    if (!orbs) return ColoredBox(color: context.bg, child: child);

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: context.bg)),
        Positioned(top: 120, left: -40, child: _Orb(color: context.surfaceWarm)),
        Positioned(
          bottom: -60,
          right: -70,
          child: _Orb(color: context.surfaceWarm, size: 300),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, this.size = 260});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.7,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small uppercase, wide-tracked label — the design's signature micro-type.
///
/// Wraps the `text-transform: uppercase` that Flutter has no equivalent for, so
/// no call site has to remember `.toUpperCase()`.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, this.semanticsLabel, super.key});

  final String text;
  final Color? color;

  /// Screen readers should hear the natural sentence, not the shouted one.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      semanticsLabel: semanticsLabel ?? text,
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: color ?? context.ink3),
    );
  }
}

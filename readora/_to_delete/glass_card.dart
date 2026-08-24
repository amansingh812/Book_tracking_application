import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_colors.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

/// The signature surface of the Glass design.
///
/// Performance note: every [PaperCard] costs a backdrop filter pass. Two or
/// three on a screen is fine; a scrolling list of them is not — use
/// [PaperCard.flat] inside lists, which keeps the look without the blur.
class PaperCard extends StatelessWidget {
  const PaperCard({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.onTap,
    this.blurred = true,
    this.borderRadius,
    super.key,
  });

  /// Non-blurred variant for list items and dense layouts.
  const PaperCard.flat({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(Spacing.lg),
    VoidCallback? onTap,
    Key? key,
  }) : this(child: child, padding: padding, onTap: onTap, blurred: false, key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool blurred;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(Radii.lg);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? ReadoraColors.darkSurfaceGlass : ReadoraColors.lightSurfaceGlass,
        borderRadius: radius,
        border: Border.all(
          color: isDark ? ReadoraColors.darkBorder : ReadoraColors.lightBorder,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    final content = blurred
        ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: Blur.glass, sigmaY: Blur.glass),
            child: surface,
          )
        : surface;

    return ClipRRect(
      borderRadius: radius,
      child: onTap == null
          ? content
          : Stack(
              children: [
                content,
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: onTap, borderRadius: radius),
                  ),
                ),
              ],
            ),
    );
  }
}

/// The soft gradient wash that sits behind the glass surfaces.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? ReadoraColors.darkAmbient : ReadoraColors.lightAmbient,
        ),
      ),
      child: child,
    );
  }
}

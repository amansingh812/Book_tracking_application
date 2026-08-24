import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/paper_card.dart';

/// Honest placeholder for a screen that is scaffolded but not built.
///
/// Used by the M1 walking skeleton so navigation, theming, and routing can be
/// exercised end to end before the features behind them exist. Every one of
/// these should be gone by the end of M3 — grep for `ComingSoon` to find what
/// is left.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    required this.title,
    required this.description,
    this.milestone,
    super.key,
  });

  final String title;
  final String description;

  /// e.g. 'M3' — which milestone in docs/ROADMAP.md delivers this.
  final String? milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AmbientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.gutter),
            child: PaperCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (milestone != null) ...[
                    Eyebrow('Planned for $milestone', color: context.gold),
                    const SizedBox(height: Spacing.md),
                  ],
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(color: context.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/features/flashcards/domain/entities/flashcard.dart';
import 'package:readora/features/flashcards/presentation/bloc/flashcards_bloc.dart';

/// Review queue. With a bloc scoped to one book (`FlashcardsBloc(repo,
/// userBookId: ...)`) this shows that book's cards plus a Generate button.
/// With the library-wide bloc it is the due-today study session.
class FlashcardsReviewPage extends StatefulWidget {
  const FlashcardsReviewPage({this.bookTitle, super.key});

  /// Set only when scoped to a single book — enables the empty-state copy
  /// and the "Generate flashcards" action.
  final String? bookTitle;

  @override
  State<FlashcardsReviewPage> createState() => _FlashcardsReviewPageState();
}

class _FlashcardsReviewPageState extends State<FlashcardsReviewPage> {
  bool _showingBack = false;
  int _reviewedThisSession = 0;

  void _flip() => setState(() => _showingBack = !_showingBack);

  void _grade(BuildContext context, String cardId, ReviewGrade grade) {
    HapticFeedback.lightImpact();
    context.read<FlashcardsBloc>().add(FlashcardGraded(cardId, grade));
    setState(() {
      _showingBack = false;
      _reviewedThisSession++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBookScoped = widget.bookTitle != null;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        title: Text(isBookScoped ? 'Flashcards' : 'Review'),
      ),
      body: BlocConsumer<FlashcardsBloc, FlashcardsState>(
        listenWhen: (a, b) => a.error != b.error && b.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: context.danger),
          );
        },
        builder: (context, state) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.cards.isEmpty) {
            return _EmptyState(
              isBookScoped: isBookScoped,
              bookTitle: widget.bookTitle,
              generating: state.generating,
              reviewedThisSession: _reviewedThisSession,
              onGenerate: isBookScoped
                  ? () => context.read<FlashcardsBloc>().add(const FlashcardsGenerateRequested())
                  : null,
            );
          }

          final card = state.cards.first;
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.md,
              Spacing.gutter,
              Spacing.lg,
            ),
            child: Column(
              children: [
                Text(
                  '${state.cards.length} card${state.cards.length == 1 ? '' : 's'} left',
                  style: ReadoraType.eyebrow.copyWith(color: context.ink3),
                ),
                const SizedBox(height: Spacing.lg),
                Expanded(
                  child: GestureDetector(
                    onTap: _flip,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey('${card.id}-$_showingBack'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.xl),
                        decoration: BoxDecoration(
                          color: context.surface,
                          border: Border.all(color: context.hairline),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          boxShadow: context.shadow,
                        ),
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _showingBack ? 'ANSWER' : 'QUESTION',
                                style: ReadoraType.eyebrow.copyWith(color: context.gold),
                              ),
                              const SizedBox(height: Spacing.lg),
                              Text(
                                _showingBack ? card.back : card.front,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (!_showingBack) ...[
                                const SizedBox(height: Spacing.xl),
                                Text(
                                  'Tap to reveal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: context.ink3),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                if (_showingBack)
                  Row(
                    children: [
                      _GradeButton(
                        label: 'Again',
                        color: context.danger,
                        onTap: () => _grade(context, card.id, ReviewGrade.again),
                      ),
                      const SizedBox(width: Spacing.sm),
                      _GradeButton(
                        label: 'Hard',
                        color: context.ink2,
                        onTap: () => _grade(context, card.id, ReviewGrade.hard),
                      ),
                      const SizedBox(width: Spacing.sm),
                      _GradeButton(
                        label: 'Good',
                        color: context.gold,
                        onTap: () => _grade(context, card.id, ReviewGrade.good),
                      ),
                      const SizedBox(width: Spacing.sm),
                      _GradeButton(
                        label: 'Easy',
                        color: context.ai,
                        onTap: () => _grade(context, card.id, ReviewGrade.easy),
                      ),
                    ],
                  )
                else
                  FilledButton(onPressed: _flip, child: const Text('Show answer')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isBookScoped,
    required this.generating,
    required this.reviewedThisSession,
    this.bookTitle,
    this.onGenerate,
  });

  final bool isBookScoped;
  final String? bookTitle;
  final bool generating;
  final int reviewedThisSession;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reviewedThisSession > 0 ? Icons.check_circle_outline : Icons.style_outlined,
              size: 48,
              color: context.ink3,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              reviewedThisSession > 0
                  ? 'All caught up'
                  : isBookScoped
                      ? 'No flashcards yet'
                      : 'Nothing due today',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              reviewedThisSession > 0
                  ? 'You reviewed $reviewedThisSession card${reviewedThisSession == 1 ? '' : 's'}. Come back tomorrow for more.'
                  : isBookScoped
                      ? 'Generate flashcards from your notes on "$bookTitle".'
                      : 'New cards will show up here as they come due.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink2),
            ),
            if (onGenerate != null && reviewedThisSession == 0) ...[
              const SizedBox(height: Spacing.lg),
              FilledButton.icon(
                onPressed: generating ? null : onGenerate,
                icon: generating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(generating ? 'Generating…' : 'Generate flashcards'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

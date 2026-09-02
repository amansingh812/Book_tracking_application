import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/features/quiz/domain/entities/quiz.dart';
import 'package:readora/features/quiz/presentation/bloc/quiz_bloc.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({required this.bookTitle, super.key});

  final String bookTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        title: Text('Quizzes', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listenWhen: (a, b) => a.error != b.error && b.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: context.danger),
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: !state.loaded
                    ? const Center(child: CircularProgressIndicator())
                    : state.quizzes.isEmpty
                        ? _EmptyQuizzes(bookTitle: bookTitle)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.gutter,
                              Spacing.md,
                              Spacing.gutter,
                              Spacing.md,
                            ),
                            itemCount: state.quizzes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                            itemBuilder: (_, i) => _QuizCard(quiz: state.quizzes[i]),
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter,
                  0,
                  Spacing.gutter,
                  Spacing.lg,
                ),
                child: FilledButton.icon(
                  onPressed: state.generating
                      ? null
                      : () => context.read<QuizBloc>().add(const QuizGenerateRequested()),
                  icon: state.generating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(state.generating ? 'Generating…' : 'Generate a new quiz'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyQuizzes extends StatelessWidget {
  const _EmptyQuizzes({required this.bookTitle});
  final String bookTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: context.ink3),
            const SizedBox(height: Spacing.lg),
            Text('No quizzes yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Generate a quiz from your notes on "$bookTitle" to test how much '
              'actually stuck.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz});
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: () => context.push('/quiz/${quiz.id}/take', extra: quiz),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.hairline),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            Icon(Icons.quiz_outlined, color: context.gold),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title ?? 'Quiz',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    '${quiz.questions.length} questions',
                    style: ReadoraType.eyebrow.copyWith(color: context.ink3),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.ink3),
          ],
        ),
      ),
    );
  }
}

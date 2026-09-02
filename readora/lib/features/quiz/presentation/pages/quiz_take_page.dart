import 'package:flutter/material.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/features/quiz/domain/entities/quiz.dart';
import 'package:readora/features/quiz/domain/repositories/quiz_repository.dart';

/// Question-by-question quiz flow, self-contained: takes the already-loaded
/// [Quiz] as a route `extra` (no need to refetch), scores locally against the
/// answer key, and records the attempt through [QuizRepository] on submit.
class QuizTakePage extends StatefulWidget {
  const QuizTakePage({required this.quiz, super.key});

  final Quiz quiz;

  @override
  State<QuizTakePage> createState() => _QuizTakePageState();
}

class _QuizTakePageState extends State<QuizTakePage> {
  late final List<int?> _answers = List.filled(widget.quiz.questions.length, null);
  int _index = 0;
  QuizAttempt? _result;
  bool _submitting = false;

  List<QuizQuestion> get _questions => widget.quiz.questions;

  void _select(int optionIndex) {
    setState(() => _answers[_index] = optionIndex);
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() => _index++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final attempt = await sl<QuizRepository>().submitAttempt(
        quizId: widget.quiz.id,
        answers: _answers,
      );
      if (mounted) setState(() => _result = attempt);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(backgroundColor: context.bg),
        body: const Center(child: Text('This quiz has no questions.')),
      );
    }
    if (_result != null) return _ResultView(quiz: widget.quiz, attempt: _result!);

    final question = _questions[_index];
    final selected = _answers[_index];

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        title: Text('Question ${_index + 1} of ${_questions.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.md,
            Spacing.gutter,
            Spacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.pill),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 4,
                  backgroundColor: context.hairline,
                  valueColor: AlwaysStoppedAnimation(context.gold),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Spacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                  itemBuilder: (_, i) {
                    final isSelected = selected == i;
                    return InkWell(
                      borderRadius: BorderRadius.circular(Radii.md),
                      onTap: () => _select(i),
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.gold.withValues(alpha: 0.12)
                              : context.surface,
                          border: Border.all(
                            color: isSelected ? context.gold : context.hairline,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Text(question.options[i]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: selected == null || _submitting ? null : _next,
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_index < _questions.length - 1 ? 'Next' : 'Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.quiz, required this.attempt});
  final Quiz quiz;
  final QuizAttempt attempt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.md,
          Spacing.gutter,
          Spacing.xxxl,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Text('${attempt.score}%', style: ReadoraType.megaStat.copyWith(color: context.gold)),
                const SizedBox(height: Spacing.sm),
                Text(
                  attempt.score >= 80
                      ? 'Great recall'
                      : attempt.score >= 50
                          ? 'Solid — worth another pass'
                          : 'Time to revisit your notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          for (var i = 0; i < quiz.questions.length; i++) ...[
            _QuestionReview(
              question: quiz.questions[i],
              chosen: i < attempt.answers.length ? attempt.answers[i] : null,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ],
      ),
    );
  }
}

class _QuestionReview extends StatelessWidget {
  const _QuestionReview({required this.question, required this.chosen});
  final QuizQuestion question;
  final int? chosen;

  @override
  Widget build(BuildContext context) {
    final correct = chosen != null && chosen == question.answerIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.hairline),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                correct ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: correct ? context.gold : context.danger,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(question.prompt, style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
          if (!correct && question.answerIndex != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'Correct answer: ${question.options[question.answerIndex!]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.ink2),
            ),
          ],
          if (question.explanation != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              question.explanation!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

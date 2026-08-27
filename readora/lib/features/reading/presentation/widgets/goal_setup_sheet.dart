import 'package:flutter/material.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';

class GoalSetupSheet extends StatefulWidget {
  const GoalSetupSheet({super.key, this.currentMinutes});
  final int? currentMinutes;

  static Future<void> show(BuildContext context, {int? currentMinutes}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => GoalSetupSheet(currentMinutes: currentMinutes),
    );
  }

  @override
  State<GoalSetupSheet> createState() => _GoalSetupSheetState();
}

class _GoalSetupSheetState extends State<GoalSetupSheet> {
  static const _presets = [10, 15, 20, 30, 45, 60];
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentMinutes ?? 20;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: context.hairline,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
            Text('Daily reading goal', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'How many minutes do you want to read each day?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: _presets.map((min) {
                final selected = _selected == min;
                return ChoiceChip(
                  label: Text('$min min'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = min),
                );
              }).toList(),
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: _save,
              child: Text('Set goal — $_selected min/day'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await sl<ReadingRepository>().setDailyGoalMinutes(_selected);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal set: $_selected minutes a day')),
      );
    }
  }
}

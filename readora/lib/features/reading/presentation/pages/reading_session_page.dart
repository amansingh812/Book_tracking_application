import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';
import 'package:readora/features/reading/presentation/bloc/reading_session_bloc.dart';

class ReadingSessionPage extends StatefulWidget {
  const ReadingSessionPage({super.key, required this.book});
  final LibraryBook book;

  @override
  State<ReadingSessionPage> createState() => _ReadingSessionPageState();
}

class _ReadingSessionPageState extends State<ReadingSessionPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ReadingSessionBloc>()
        .add(ReadingSessionStarted(widget.book.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmEnd(context);
      },
      child: BlocConsumer<ReadingSessionBloc, ReadingSessionState>(
        listener: (context, state) {
          if (state is ReadingSessionIdle) {
            Navigator.of(context).pop();
          }
          if (state is ReadingSessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: context.danger),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.bg,
            appBar: AppBar(
              backgroundColor: context.bg,
              foregroundColor: context.ink,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _confirmEnd(context),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.gutter, 0, Spacing.gutter, Spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Book header
                    PaperCard(
                      child: Row(
                        children: [
                          BookCover(
                            title: widget.book.title,
                            coverUrl: widget.book.coverUrl,
                            width: 48,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reading session',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: Spacing.xxs),
                                Text(
                                  widget.book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Timer display
                    if (state is ReadingSessionActive) ...[
                      _TimerDisplay(elapsed: state.elapsed),
                      const SizedBox(height: Spacing.sm),
                      Center(
                        child: Text(
                          'Reading…',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ] else
                      const Center(child: CircularProgressIndicator()),

                    const Spacer(),

                    // End button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.gold,
                        foregroundColor: context.bg,
                      ),
                      onPressed: state is ReadingSessionActive
                          ? () => _confirmEnd(context)
                          : null,
                      icon: const Icon(Icons.check),
                      label: const Text('End & update progress'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmEnd(BuildContext context) {
    final state = context.read<ReadingSessionBloc>().state;
    if (state is! ReadingSessionActive) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EndSessionSheet(
        book: widget.book,
        elapsed: state.elapsed,
        onEnd: (pagesRead) {
          context.read<ReadingSessionBloc>().add(ReadingSessionEnded(pagesRead: pagesRead));
        },
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.elapsed});
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final label = hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';

    return Center(
      child: Text(
        label,
        style: ReadoraType.stat.copyWith(
          fontSize: 72,
          color: context.gold,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _EndSessionSheet extends StatefulWidget {
  const _EndSessionSheet({
    required this.book,
    required this.elapsed,
    required this.onEnd,
  });
  final LibraryBook book;
  final Duration elapsed;
  final void Function(int pagesRead) onEnd;

  @override
  State<_EndSessionSheet> createState() => _EndSessionSheetState();
}

class _EndSessionSheetState extends State<_EndSessionSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final mins = widget.elapsed.inMinutes;

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
            Text('End session', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'Great work — $mins ${mins == 1 ? 'minute' : 'minutes'} of reading.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: Spacing.lg),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Pages read this session',
                hintText: '0',
                suffixText: widget.book.pageCount != null
                    ? '/ ${widget.book.pageCount}'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: () {
                final pages = int.tryParse(_ctrl.text) ?? 0;
                Navigator.pop(context);
                widget.onEnd(pages);
              },
              child: const Text('Save session'),
            ),
            const SizedBox(height: Spacing.sm),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onEnd(0);
              },
              child: const Text('End without logging pages'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_colors.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';

/// Modal bottom sheet to update reading progress for a [LibraryBook].
///
/// Writes locally through [LibraryBloc] -> [LibraryRepository] -> Isar,
/// and automatically enqueues the mutation to the outbox for background sync.
class ProgressUpdateSheet extends StatefulWidget {
  const ProgressUpdateSheet({
    required this.book,
    super.key,
  });

  final LibraryBook book;

  /// Convenience method to open the sheet as a modal.
  static Future<void> show(
    BuildContext context, {
    required LibraryBook book,
  }) {
    final libraryBloc = context.read<LibraryBloc>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ReadoraColors.darkSurface
          : ReadoraColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: libraryBloc,
        child: ProgressUpdateSheet(book: book),
      ),
    );
  }

  @override
  State<ProgressUpdateSheet> createState() => _ProgressUpdateSheetState();
}

class _ProgressUpdateSheetState extends State<ProgressUpdateSheet> {
  late int _currentPage;
  late ReadingStatus _status;
  late final TextEditingController _pageController;
  late final FocusNode _pageFocusNode;

  int get _totalPages => widget.book.pageCount ?? 0;
  bool get _hasTotalPages => _totalPages > 0;
  int get _maxPage => _hasTotalPages ? _totalPages : 99999;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage;
    _status = widget.book.status;
    _pageController = TextEditingController(text: '$_currentPage');
    _pageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  void _setPage(int newPage, {bool updateTextController = true}) {
    final clamped = newPage.clamp(0, _maxPage);
    if (clamped == _currentPage) return;

    setState(() {
      _currentPage = clamped;

      // Auto-transition status when starting or finishing
      if (_currentPage > 0 && _status == ReadingStatus.wantToRead) {
        _status = ReadingStatus.reading;
      } else if (_hasTotalPages && _currentPage >= _totalPages) {
        _status = ReadingStatus.finished;
      } else if (_currentPage < _totalPages &&
          _status == ReadingStatus.finished) {
        _status = ReadingStatus.reading;
      }
    });

    if (updateTextController && !_pageFocusNode.hasFocus) {
      _pageController.text = '$_currentPage';
    }
  }

  void _adjustPage(int delta) {
    HapticFeedback.selectionClick();
    _setPage(_currentPage + delta);
  }

  void _onStatusChanged(ReadingStatus newStatus) {
    HapticFeedback.selectionClick();
    setState(() {
      _status = newStatus;
      if (newStatus == ReadingStatus.finished && _hasTotalPages) {
        _currentPage = _totalPages;
        _pageController.text = '$_currentPage';
      }
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();

    final libraryBloc = context.read<LibraryBloc>()
      ..add(
        LibraryProgressUpdated(
          userBookId: widget.book.id,
          page: _currentPage,
        ),
      );

    // 2. Dispatch status update if changed
    if (_status != widget.book.status) {
      libraryBloc.add(
        LibraryStatusChanged(
          userBookId: widget.book.id,
          status: _status,
        ),
      );
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _currentPage >= _totalPages && _hasTotalPages
              ? '🎉 Finished reading "${widget.book.title}"!'
              : 'Progress updated to page $_currentPage.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    final progressRatio = _hasTotalPages
        ? (_currentPage / _totalPages).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progressRatio * 100).round();
    final pagesDelta = _currentPage - widget.book.currentPage;
    final pagesLeft = _hasTotalPages
        ? (_totalPages - _currentPage).clamp(0, _totalPages)
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.sm,
            Spacing.gutter,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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

              // Book Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Eyebrow('LOG READING PROGRESS'),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          widget.book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          widget.book.authorLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.ink3, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.lg),

              // Main Progress Card
              PaperCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_currentPage',
                          key: const Key('progress_stat_text'),
                          style: ReadoraType.stat.copyWith(
                            fontSize: 42,
                            color: context.gold,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          _hasTotalPages
                              ? '/ $_totalPages pages'
                              : 'pages read',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_hasTotalPages) ...[
                          const SizedBox(width: Spacing.sm),
                          Container(
                            key: const Key('progress_percent_badge'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: Spacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: context.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(Radii.pill),
                            ),
                            child: Text(
                              '$percent%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: context.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (_hasTotalPages) ...[
                      const SizedBox(height: Spacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Radii.pill),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 8,
                          backgroundColor: context.hairline,
                          valueColor: AlwaysStoppedAnimation(context.gold),
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pagesDelta != 0
                                ? '${pagesDelta > 0 ? '+' : ''}'
                                    '$pagesDelta pages this log'
                                : 'No change yet',
                            key: const Key('progress_delta_text'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: pagesDelta > 0
                                  ? context.success
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (pagesLeft != null)
                            Text(
                              pagesLeft == 0
                                  ? 'Finished!'
                                  : '$pagesLeft pages remaining',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: Spacing.md),

              // Quick Step Adjusters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepButton(
                      label: '-10',
                      onPressed: _currentPage >= 10
                          ? () => _adjustPage(-10)
                          : null,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _StepButton(
                      label: '-1',
                      onPressed: _currentPage >= 1
                          ? () => _adjustPage(-1)
                          : null,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _StepButton(
                      label: '+1',
                      isHighlight: true,
                      onPressed: _currentPage < _maxPage
                          ? () => _adjustPage(1)
                          : null,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _StepButton(
                      label: '+5',
                      onPressed: _currentPage + 5 <= _maxPage
                          ? () => _adjustPage(5)
                          : null,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _StepButton(
                      label: '+10',
                      onPressed: _currentPage + 10 <= _maxPage
                          ? () => _adjustPage(10)
                          : null,
                    ),
                    const SizedBox(width: Spacing.xs),
                    _StepButton(
                      label: '+25',
                      onPressed: _currentPage + 25 <= _maxPage
                          ? () => _adjustPage(25)
                          : null,
                    ),
                  ],
                ),
              ),

              // Slider (if page count known)
              if (_hasTotalPages) ...[
                const SizedBox(height: Spacing.md),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 9,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 18,
                    ),
                    activeTrackColor: context.gold,
                    inactiveTrackColor: context.hairline,
                    thumbColor: context.gold,
                    overlayColor: context.gold.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: _currentPage
                        .toDouble()
                        .clamp(0, _totalPages.toDouble()),
                    max: _totalPages.toDouble(),
                    onChanged: (val) => _setPage(val.round()),
                  ),
                ),
              ],

              const SizedBox(height: Spacing.sm),

              // Direct page number entry input
              TextField(
                key: const Key('progress_page_textfield'),
                controller: _pageController,
                focusNode: _pageFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Jump to exact page',
                  prefixIcon: Icon(
                    Icons.bookmark_outline,
                    size: 18,
                    color: context.ink3,
                  ),
                  suffixText: _hasTotalPages ? '/ $_totalPages' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null) {
                    _setPage(parsed, updateTextController: false);
                  }
                },
              ),

              const SizedBox(height: Spacing.lg),

              // Status Selector
              const Eyebrow('STATUS'),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  for (final s in ReadingStatus.values)
                    ChoiceChip(
                      label: Text(s.label),
                      selected: _status == s,
                      onSelected: (_) => _onStatusChanged(s),
                    ),
                ],
              ),

              const SizedBox(height: Spacing.xl),

              // Submit Button
              FilledButton(
                key: const Key('progress_save_button'),
                onPressed: _save,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: Spacing.sm),
                    Text('Save Progress'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.onPressed,
    this.isHighlight = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    final backgroundColor = isHighlight
        ? context.gold.withValues(alpha: 0.18)
        : context.surface;

    final borderColor = isHighlight
        ? context.gold.withValues(alpha: 0.4)
        : context.hairline;

    final textColor = !enabled
        ? context.ink3
        : isHighlight
            ? context.gold
            : context.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/features/library/data/models/library_models.dart';

/// Modal bottom sheet that asks the reader which shelf to add the book to.
///
/// Returns the chosen [ReadingStatus], or null if dismissed.
class StatusPickerSheet extends StatelessWidget {
  const StatusPickerSheet({required this.title, super.key});

  final String title;

  static Future<ReadingStatus?> show(BuildContext context, String bookTitle) {
    return showModalBottomSheet<ReadingStatus>(
      context: context,
      builder: (_) => StatusPickerSheet(title: bookTitle),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter,
          vertical: Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add to library', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.xs),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: Spacing.lg),
            ...ReadingStatus.values.map(
              (s) => ListTile(
                leading: Icon(_iconForStatus(s)),
                title: Text(s.label),
                contentPadding: EdgeInsets.zero,
                onTap: () => Navigator.of(context).pop(s),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForStatus(ReadingStatus status) => switch (status) {
        ReadingStatus.reading => Icons.menu_book_outlined,
        ReadingStatus.finished => Icons.done_all,
        ReadingStatus.wantToRead => Icons.bookmark_border,
        ReadingStatus.paused => Icons.pause_circle_outline,
        ReadingStatus.dnf => Icons.cancel_outlined,
      };
}

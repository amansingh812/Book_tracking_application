import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';

/// Confirms before firing [AuthAccountDeletionRequested] — the one action in
/// the app that cannot be undone, so it gets a dialog when nothing else on
/// this page does.
class DeleteAccountDialog {
  const DeleteAccountDialog._();

  static Future<void> show(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes your account and everything in it — your '
          'library, notes, quizzes, flashcards, and reading history. '
          "This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authBloc.add(const AuthAccountDeletionRequested());
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: dialogContext.danger),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
  }
}

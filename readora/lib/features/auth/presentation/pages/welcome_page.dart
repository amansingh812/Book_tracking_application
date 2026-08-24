import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/core/config/brand_config.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';

/// First screen a new user sees.
///
/// "Start without an account" is deliberately given equal weight to signing up.
/// Activation is the metric that matters early, and asking for an email before
/// someone has added a single book is the fastest way to lose them.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AmbientBackground(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (a, b) => a.failure != b.failure,
          listener: (context, state) {
            if (state.failure != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),
                    Text(BrandConfig.appName, style: ReadoraType.textTheme.displayLarge),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      BrandConfig.tagline,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    PaperCard(
                      child: Text(
                        'Track what you read, keep your notes in one place, and turn '
                        'them into things you actually remember.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const Spacer(flex: 3),
                    FilledButton(
                      onPressed: () => context.push('/auth/sign-in'),
                      child: const Text('Sign in or create an account'),
                    ),
                    const SizedBox(height: Spacing.md),
                    OutlinedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<AuthBloc>().add(const AuthGuestRequested()),
                      child: state.isSubmitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start without an account'),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'You can create an account later — nothing you track will be lost.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

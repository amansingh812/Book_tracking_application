import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/core/config/brand_config.dart';
import 'package:readora/core/config/env.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGuest = state.status == AuthStatus.guest;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: AmbientBackground(
            child: ListView(
              padding: const EdgeInsets.all(Spacing.gutter),
              children: [
                PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user?.greetingName ?? 'Reader',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        isGuest
                            ? 'Reading on this device only'
                            : state.user?.email ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                PaperCard.flat(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.md,
                  ),
                  onTap: () => context.push('/profile/stats'),
                  child: Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          'Reading stats',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                if (isGuest) ...[
                  PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keep your library safe', style: theme.textTheme.titleMedium),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'Create an account and everything you have tracked so far '
                          'moves with you — nothing is lost.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: Spacing.lg),
                        FilledButton(
                          onPressed: () => context.push('/auth/sign-in'),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(const AuthSignOutRequested()),
                    child: const Text('Sign out'),
                  ),
                ],
                const SizedBox(height: Spacing.xxl),
                Text(
                  '${BrandConfig.appName} · ${Env.flavorName} build',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

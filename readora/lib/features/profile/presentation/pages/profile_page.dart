import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:readora/core/config/brand_config.dart';
import 'package:readora/core/config/env.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/profile/presentation/widgets/delete_account_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (a, b) => a.failure != b.failure,
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
        }
      },
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
                  const SizedBox(height: Spacing.lg),
                ],
                PaperCard.flat(
                  onTap: () => context.push('/paywall'),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: context.gold),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Readora Plus', style: theme.textTheme.titleSmall),
                            Text(
                              'AI Companion, unlimited quizzes & flashcards, My Knowledge',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: context.ink2),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.ink3),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                PaperCard.flat(
                  onTap: () => context.push('/profile/study'),
                  child: Row(
                    children: [
                      Icon(Icons.style_outlined, color: context.gold),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Study', style: theme.textTheme.titleSmall),
                            Text(
                              'Review flashcards due today',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: context.ink2),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.ink3),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                PaperCard.flat(
                  onTap: () => context.push('/profile/stats'),
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart, color: context.gold),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text('Stats', style: theme.textTheme.titleSmall),
                      ),
                      Icon(Icons.chevron_right, color: context.ink3),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _openLegal(BrandConfig.privacyPolicyUrl),
                      child: const Text('Privacy Policy'),
                    ),
                    Text('·', style: TextStyle(color: context.ink3)),
                    TextButton(
                      onPressed: () => _openLegal(BrandConfig.termsOfServiceUrl),
                      child: const Text('Terms of Service'),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                if (!isGuest) ...[
                  OutlinedButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(const AuthSignOutRequested()),
                    child: const Text('Sign out'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => DeleteAccountDialog.show(context),
                    style: TextButton.styleFrom(foregroundColor: context.danger),
                    child: const Text('Delete account'),
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

Future<void> _openLegal(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

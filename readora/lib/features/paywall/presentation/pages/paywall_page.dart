import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/paywall/presentation/bloc/paywall_bloc.dart';

const _kBenefits = [
  ('AI Companion', 'Unlimited chat grounded in your own notes and highlights'),
  ('Quizzes & flashcards', 'Unlimited generation, plus SM-2 spaced repetition'),
  ('My Knowledge', 'Cross-book connections and Ask My Library'),
  ('Advanced analytics', 'Reading Wrapped, trends, and consistency insights'),
  ('Sync everywhere', 'Your library, notes, and progress on every device'),
];

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
      ),
      body: BlocConsumer<PaywallBloc, PaywallState>(
        listenWhen: (a, b) => a.error != b.error && b.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: context.danger),
          );
        },
        builder: (context, state) {
          if (state.isPlus) return const _AlreadyPlusView();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              0,
              Spacing.gutter,
              Spacing.xxxl,
            ),
            children: [
              Icon(Icons.auto_awesome, size: 40, color: context.gold),
              const SizedBox(height: Spacing.md),
              Text('Readora Plus', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: Spacing.xs),
              Text(
                'Turn what you read into what you remember.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.ink2),
              ),
              const SizedBox(height: Spacing.xl),
              for (final (title, desc) in _kBenefits) ...[
                _BenefitRow(title: title, description: desc),
                const SizedBox(height: Spacing.md),
              ],
              const SizedBox(height: Spacing.md),
              if (state.loading)
                const Center(child: CircularProgressIndicator())
              else if (state.packages.isEmpty)
                Text(
                  'Pricing is not available on this build yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink3),
                )
              else
                for (final package in state.packages) ...[
                  _PackageCard(
                    package: package,
                    purchasing: state.purchasing,
                    onTap: () => context.read<PaywallBloc>().add(PaywallPurchaseRequested(package)),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              const SizedBox(height: Spacing.lg),
              Center(
                child: TextButton(
                  onPressed: state.purchasing
                      ? null
                      : () => context.read<PaywallBloc>().add(const PaywallRestoreRequested()),
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlreadyPlusView extends StatelessWidget {
  const _AlreadyPlusView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 48, color: context.gold),
            const SizedBox(height: Spacing.lg),
            Text("You're on Readora Plus", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Every AI feature is unlocked — thank you for backing Readora.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 18, color: context.gold),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.purchasing, required this.onTap});
  final Package package;
  final bool purchasing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    return PaperCard.flat(
      onTap: purchasing ? null : onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.ink2),
                ),
              ],
            ),
          ),
          Text(
            product.priceString,
            style: ReadoraType.stat.copyWith(fontSize: 18, color: context.gold),
          ),
        ],
      ),
    );
  }
}

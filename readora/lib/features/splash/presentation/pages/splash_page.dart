import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/brand_mark.dart';
import 'package:readora/design_system/widgets/paper_card.dart';

/// Shown while [AuthStatus] is `unknown` — the gap between the native splash
/// screen (which covers `bootstrap()`'s Supabase/Isar/sync setup) and the
/// router knowing whether to send the reader to `/auth` or `/home`.
///
/// Without this, the router's `initialLocation` briefly renders whatever
/// screen it's pointed at before the redirect fires, so a returning user can
/// see a flash of the wrong UI on cold start. This screen is that flash,
/// made intentional instead of accidental.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        orbs: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 96),
              const SizedBox(height: Spacing.xxl),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(context.gold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

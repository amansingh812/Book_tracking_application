import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

/// The Readora glyph, in one place.
///
/// Points at the same placeholder mark used for the app icon and native
/// splash screen (`assets/icons/`) so the brand is consistent everywhere it
/// shows up in-app, not just at launch. Swapping the real logo in later is a
/// four-file asset change — nothing that reads [BrandMark] needs to change.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = context.isDark
        ? 'assets/icons/brand_glyph_dark.png'
        : 'assets/icons/brand_glyph_light.png';
    return Image.asset(asset, width: size, fit: BoxFit.contain);
  }
}

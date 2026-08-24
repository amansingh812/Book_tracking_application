import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Type tokens — imported from the Claude Design export.
///
/// Source of truth: `_ds/.../colors_and_type.css` (`--font-serif`,
/// `--font-sans`, the `.swr-*` semantic styles) and the measured values in
/// `ReadoraApp.dc.html`.
///
/// Two families carry the whole app:
///
///   * **Playfair Display** (`--font-serif`) — a high-contrast display serif.
///     Used for every title, heading, book title and stat. It appears more
///     often than the sans in the artboards; it is the voice of the brand.
///   * **Montserrat** (`--font-sans`) — geometric sans, set light and small.
///     Body copy, and the wide-tracked uppercase micro-labels that are the
///     design's real signature.
///
/// Both are bundled under `assets/fonts/` rather than fetched at runtime.
/// Readora opens offline on first launch; a font that needs the network is a
/// font that flashes fallback on the one screen that matters most.
///
/// Rule: no widget constructs its own `TextStyle`. Use
/// `Theme.of(context).textTheme` or a token below.
abstract final class ReadoraType {
  /// Display/heading family — the voice of the brand. `--font-serif`
  static const String displayFamily = 'PlayfairDisplay';

  /// UI + body family. `--font-sans`
  static const String bodyFamily = 'Montserrat';

  /// Long-form reading (notes, AI answers).
  ///
  /// The export defines no third family, so this stays on the body sans at a
  /// looser leading rather than inventing one. Playfair is a display cut — its
  /// thin hairlines fall apart in a paragraph — so it is deliberately not used
  /// here. If long-form reading proves tiring in testing, the fix is to add a
  /// true text serif (Literata, Lora) as a third family in the design file
  /// first, then import it here.
  static const String readingFamily = bodyFamily;

  static const TextTheme textTheme = TextTheme(
    // Welcome / brand moments.
    displayLarge: TextStyle(
      fontFamily: displayFamily,
      fontSize: 34,
      height: 1.1,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.68, // --tracking-tight (-0.02em)
    ),
    // Page greeting — the artboard's h1.
    displayMedium: TextStyle(
      fontFamily: displayFamily,
      fontSize: 29,
      height: 1.15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.3,
    ),
    displaySmall: TextStyle(
      fontFamily: displayFamily,
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      fontFamily: displayFamily,
      fontSize: 21,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
    // Card headings, book titles.
    titleLarge: TextStyle(
      fontFamily: displayFamily,
      fontSize: 19,
      height: 1.25,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontFamily: displayFamily,
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontFamily: displayFamily,
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w500,
    ),
    // .swr-lede
    bodyLarge: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 15,
      height: 1.6,
      fontWeight: FontWeight.w400,
    ),
    // .swr-body — note the light weight; the design sets body at 300.
    bodyMedium: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 13,
      height: 1.55,
      fontWeight: FontWeight.w300,
    ),
    // .swr-body-sm
    bodySmall: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w300,
    ),
    // Buttons.
    labelLarge: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.52, // --tracking-wide (0.04em)
    ),
    // .swr-eyebrow — see [eyebrow]; callers must uppercase the string.
    labelMedium: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w400,
      letterSpacing: 2.2, // --tracking-widest (0.22em)
    ),
    // .swr-meta-sm
    labelSmall: TextStyle(
      fontFamily: bodyFamily,
      fontSize: 9,
      height: 1.2,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.98, // 0.22em
    ),
  );

  /// The design's signature micro-label: tiny, uppercase, very wide tracking.
  ///
  /// Flutter has no `text-transform`, so the **caller** must uppercase the
  /// string — `Text('Continue reading'.toUpperCase(), style: …eyebrow)`.
  /// Tinting it gold is what marks a section as the primary action on a screen.
  static const eyebrow = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.2, // 0.22em
  );

  /// Note bodies and AI answers — the only place [readingFamily] is used.
  static const reading = TextStyle(
    fontFamily: readingFamily,
    fontSize: 16,
    height: 1.7,
    fontWeight: FontWeight.w300,
  );

  /// Numerals in stat tiles: tabular so they stop jittering as they count up.
  static const stat = TextStyle(
    fontFamily: displayFamily,
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

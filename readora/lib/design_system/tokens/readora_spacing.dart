import 'package:flutter/material.dart';

import 'package:readora/design_system/tokens/readora_colors.dart';

/// Spacing, radius, shadow, and motion tokens — imported from the Claude
/// Design export (`colors_and_type.css` `--s-*`, `--radius-*`, `--shadow-*`,
/// `--dur-*`, `--ease-*`, and the measured values in `ReadoraApp.dc.html`).

/// One 4pt scale for the whole app. A widget that needs 13 pixels of padding is
/// a widget that has not decided what it is — pick a step.
abstract final class Spacing {
  static const xxs = 2.0;
  static const xs = 4.0; // --s-1
  static const sm = 8.0; // --s-2
  static const md = 12.0; // --s-3
  static const lg = 16.0; // --s-4
  static const xl = 24.0; // --s-6
  static const xxl = 32.0; // --s-8
  static const xxxl = 48.0; // --s-12

  /// Standard horizontal page gutter. The artboards pad every screen at 20.
  static const gutter = 20.0; // --s-5

  /// Inner padding of a standard card in the artboards.
  static const card = 18.0;
}

abstract final class Radii {
  static const xs = 4.0; // --radius-sm
  static const sm = 8.0; // --radius-md

  /// The dominant radius in the artboards — chips, tiles, inner surfaces.
  static const md = 14.0; // --radius-lg

  /// Primary content cards.
  static const lg = 20.0;

  /// Bottom sheets and large modals (top corners only in the design).
  static const xl = 24.0; // --radius-xl

  static const pill = 999.0; // --radius-pill

  /// Book covers are drawn as objects, not thumbnails: a tight spine edge on
  /// the left and a rounder fore-edge on the right. The artboard uses
  /// `border-radius: 2px 7px 7px 2px`.
  static const coverSpine = 2.0;
  static const cover = 7.0;

  static const BorderRadius coverRadius = BorderRadius.only(
    topLeft: Radius.circular(coverSpine),
    bottomLeft: Radius.circular(coverSpine),
    topRight: Radius.circular(cover),
    bottomRight: Radius.circular(cover),
  );
}

/// Warm, low-contrast elevation. Never blue-tinted — that is the fastest way to
/// make this palette look cheap.
abstract final class Shadows {
  /// `--rd-shadow` — the resting elevation of a card.
  static const List<BoxShadow> light = [
    BoxShadow(color: Color(0x0F1F1B16), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x141F1B16), blurRadius: 40, offset: Offset(0, 12)),
  ];

  /// `--rd-lift` — raised: sheets, pressed cards, the active book.
  static const List<BoxShadow> lightLift = [
    BoxShadow(color: Color(0x1A1F1B16), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x2E1F1B16), blurRadius: 70, offset: Offset(0, 30)),
  ];

  /// `--rd-shadow` (dark)
  static const List<BoxShadow> dark = [
    BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x73000000), blurRadius: 40, offset: Offset(0, 12)),
  ];

  /// `--rd-lift` (dark)
  static const List<BoxShadow> darkLift = [
    BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x99000000), blurRadius: 70, offset: Offset(0, 30)),
  ];

  static List<BoxShadow> of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static List<BoxShadow> liftOf(Brightness brightness) =>
      brightness == Brightness.dark ? darkLift : lightLift;
}

/// Resolves the light/dark half of a token pair.
///
/// Saves every widget writing the same `isDark ? … : …` ternary, which is where
/// hardcoded colours tend to sneak back in.
extension ReadoraPalette on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? ReadoraColors.darkBackground : ReadoraColors.lightBackground;
  Color get surface => isDark ? ReadoraColors.darkSurface : ReadoraColors.lightSurface;
  Color get surfaceWarm =>
      isDark ? ReadoraColors.darkSurfaceWarm : ReadoraColors.lightSurfaceWarm;
  Color get ink => isDark ? ReadoraColors.darkTextPrimary : ReadoraColors.lightTextPrimary;
  Color get ink2 =>
      isDark ? ReadoraColors.darkTextSecondary : ReadoraColors.lightTextSecondary;
  Color get ink3 =>
      isDark ? ReadoraColors.darkTextTertiary : ReadoraColors.lightTextTertiary;
  Color get hairline => isDark ? ReadoraColors.darkBorder : ReadoraColors.lightBorder;
  Color get gold => isDark ? ReadoraColors.darkGold : ReadoraColors.lightGold;
  Color get ai => isDark ? ReadoraColors.darkAi : ReadoraColors.lightAi;
  Color get aiSoft => isDark ? ReadoraColors.darkAiSoft : ReadoraColors.lightAiSoft;
  Color get success => isDark ? ReadoraColors.darkSuccess : ReadoraColors.lightSuccess;
  Color get danger => isDark ? ReadoraColors.darkDanger : ReadoraColors.lightDanger;
  Color get scrim => isDark ? ReadoraColors.darkScrim : ReadoraColors.lightScrim;

  List<BoxShadow> get shadow => Shadows.of(Theme.of(this).brightness);
  List<BoxShadow> get shadowLift => Shadows.liftOf(Theme.of(this).brightness);
}

/// Blur radii used by backdrop-filter widgets.
///
/// Keep these small — large sigmas are expensive on mobile. Only the glass
/// card surface uses blur; everything else is opaque.
abstract final class Blur {
  /// The backdrop blur applied to [PaperCard] — just enough to frost the
  /// ambient gradient without tanking frame rate on mid-range devices.
  static const glass = 12.0;
}

/// Animation durations and curves. Named `Motion` rather than `Durations` so it
/// does not collide with Flutter's own `Durations` class.
abstract final class Motion {
  static const fast = Duration(milliseconds: 150); // --dur-fast
  static const normal = Duration(milliseconds: 250); // --dur-base
  static const slow = Duration(milliseconds: 600); // --dur-slow

  /// Long, looping background motion — the drifting orbs only.
  static const ambient = Duration(seconds: 4); // --dur-ambient

  static const easeOut = Cubic(0.22, 0.61, 0.36, 1); // --ease-out
  static const easeInOut = Cubic(0.65, 0, 0.35, 1); // --ease-in-out
}

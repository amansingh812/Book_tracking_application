import 'package:flutter/material.dart';

/// Colour tokens — imported from the Claude Design export.
///
/// Source of truth: `mobile-app-design-scope/project/readora.css`
/// (`.rd-app` for light, `.rd-dark .rd-app` for dark), which sits on top of the
/// Swarom foundations in `_ds/.../colors_and_type.css`.
///
/// The CSS variable name is kept in a comment beside every token so the next
/// import is a diff, not an archaeology exercise.
///
/// The palette is warm paper — cream and ink with a single warm gold accent,
/// plus a muted violet reserved exclusively for AI surfaces. There are no cool
/// greys and no blue-tinted shadows anywhere in this system.
///
/// Rule: no widget anywhere may write `Color(0x...)` or `Colors.blue`. If a
/// colour is missing, add a token here.
abstract final class ReadoraColors {
  // ---------------------------------------------------------------------------
  // Light — `.rd-app`
  // ---------------------------------------------------------------------------
  static const lightBackground = Color(0xFFF6F1EA); // --rd-bg
  static const lightSurface = Color(0xFFFBF8F4); // --rd-surface
  static const lightSurfaceWarm = Color(0xFFEDE3D4); // --rd-surface2
  static const lightTextPrimary = Color(0xFF1F1B16); // --rd-ink
  static const lightTextSecondary = Color(0xB81F1B16); // --rd-ink2  rgba(…,.72)
  static const lightTextTertiary = Color(0x801F1B16); // --rd-ink3  rgba(…,.50)
  static const lightBorder = Color(0x241F1B16); // --rd-hair   rgba(…,.14)
  static const lightGold = Color(0xFFB8956A); // --rd-gold
  static const lightAi = Color(0xFF6C688E); // --rd-ai
  static const lightAiSoft = Color(0x1A6C688E); // --rd-ai-soft rgba(…,.10)
  static const lightSuccess = Color(0xFF5A6B3F); // --rd-success
  static const lightScrim = Color(0x611F1B16); // --rd-scrim  rgba(…,.38)

  /// Frosted-glass surface overlay — the base surface at ~60 % opacity so the
  /// blur lets the ambient gradient read through.
  static const lightSurfaceGlass = Color(0x99FBF8F4); // --rd-surface @60 %

  /// --error from colors_and_type.css. Oxidised red, never bright.
  static const lightDanger = Color(0xFF8B2E2E);

  // ---------------------------------------------------------------------------
  // Dark — `.rd-dark .rd-app`
  // ---------------------------------------------------------------------------
  static const darkBackground = Color(0xFF14120F); // --rd-bg
  static const darkSurface = Color(0xFF1D1A16); // --rd-surface
  static const darkSurfaceWarm = Color(0xFF262117); // --rd-surface2
  static const darkTextPrimary = Color(0xFFF3EDE4); // --rd-ink
  static const darkTextSecondary = Color(0xB8F3EDE4); // --rd-ink2  rgba(…,.72)
  static const darkTextTertiary = Color(0x75F3EDE4); // --rd-ink3  rgba(…,.46)
  static const darkBorder = Color(0x24F3EDE4); // --rd-hair   rgba(…,.14)
  static const darkGold = Color(0xFFC9A574); // --rd-gold
  static const darkAi = Color(0xFFA29DCB); // --rd-ai
  static const darkAiSoft = Color(0x1FA29DCB); // --rd-ai-soft rgba(…,.12)
  static const darkSuccess = Color(0xFF8A9C68); // --rd-success
  static const darkScrim = Color(0x8C080706); // --rd-scrim  rgba(8,7,6,.55)

  /// Frosted-glass surface overlay — dark equivalent of [lightSurfaceGlass].
  static const darkSurfaceGlass = Color(0x991D1A16); // --rd-surface @60 % (dark)

  /// Derived, not in the export: the design defines only a light `--error`.
  /// Lifted the same way `--rd-gold` lifts between modes, then checked for
  /// 4.5:1 against `darkBackground`.
  static const darkDanger = Color(0xFFC8776E);

  // ---------------------------------------------------------------------------
  // Semantic aliases
  //
  // Gold is the app's single warm accent: it carries brand, progress, streaks
  // and focus. The design has no separate "warning" hue — the same gold does
  // that work, so `warning` deliberately points at it rather than inventing a
  // colour the design never approved.
  // ---------------------------------------------------------------------------
  static const lightStreak = lightGold;
  static const darkStreak = darkGold;
  static const lightWarning = lightGold;
  static const darkWarning = darkGold;

  /// Book-cover placeholder tints. Muted spine colours pulled from the
  /// artboard's illustrated shelf, so a cover-less book still looks like an
  /// object on a shelf rather than a coloured rectangle.
  static const coverTints = <Color>[
    Color(0xFF2E3A2C), // forest — the artboard's primary spine
    Color(0xFF5C4433), // leather
    Color(0xFF3B4356), // slate blue
    Color(0xFF6E4A4A), // oxblood
    Color(0xFF4A4636), // olive
  ];

  /// Ink used for text printed on a [coverTints] spine.
  static const coverInk = Color(0xFFE9E4D8);

  /// The inset shade down a cover's binding edge — the `inset 6px 0 0
  /// rgba(0,0,0,.18)` in the artboard, softened into a gradient.
  static const coverSpineShade = Color(0x2E000000);
  static const coverSpineShadeFade = Color(0x00000000);

  // ---------------------------------------------------------------------------
  // Ambient background gradients
  //
  // The two-stop gradient that sits behind every glass surface. Warm paper
  // light → cream for light mode; deep ink → warm brown for dark mode.
  // ---------------------------------------------------------------------------

  /// Light ambient gradient stops — top-left to bottom-right.
  static const lightAmbient = <Color>[
    Color(0xFFF6F1EA), // --rd-bg (top)
    Color(0xFFEDE3D4), // --rd-surface2 (bottom)
  ];

  /// Dark ambient gradient stops — top-left to bottom-right.
  static const darkAmbient = <Color>[
    Color(0xFF14120F), // --rd-bg (top)
    Color(0xFF262117), // --rd-surface2 (bottom)
  ];
}

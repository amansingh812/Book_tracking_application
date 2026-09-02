"""
Generates the placeholder Readora brand mark used for the app icon and the
native splash screen, from the design system's own tokens (warm paper +
ink + gold, PlayfairDisplay for the mark, Montserrat for the wordmark).

This is explicitly a PLACEHOLDER per the design-system doc's own admission
that "Readora" / "com.readora.app" are not final. It exists so
flutter_launcher_icons / flutter_native_splash have real, on-brand source
art to build from today, rather than blocking the whole release on a final
logo. Swap the three PNGs this script writes for real art later — nothing
else needs to change.

Mark: a bold serif "R" (PlayfairDisplay-Bold, matching the app's own display
face) with a short gold rule beneath it standing in for a bookmark ribbon —
legible down to a 20x20 iOS icon slot, ties directly to the reading/notes
metaphor without needing a busy illustration.
"""

from PIL import Image, ImageDraw, ImageFont

INK = (31, 27, 22, 255)  # #1F1B16 — lightTextPrimary
CREAM = (246, 241, 234, 255)  # #F6F1EA — lightBackground
GOLD = (184, 149, 106, 255)  # #B8956A — lightGold
DARK_BG = (20, 18, 15, 255)  # #14120F — darkBackground
DARK_INK = (243, 237, 228, 255)  # #F3EDE4 — darkTextPrimary
DARK_GOLD = (201, 165, 116, 255)  # #C9A574 — darkGold

SERIF = "/home/claude/readora_assets/PlayfairDisplay-Bold.ttf"
SANS = "/home/claude/readora_assets/Montserrat-SemiBold.ttf"

OUT = "/home/claude/readora_assets"


def draw_mark(canvas_size, glyph_color, rule_color, glyph_scale=0.62, rule_width_scale=0.34):
    """Draws the R + ribbon-rule mark centered on a transparent square."""
    img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    font_size = int(canvas_size * glyph_scale)
    font = ImageFont.truetype(SERIF, font_size)

    text = "R"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    # A touch above true center so the rule has room to breathe beneath it.
    cx = canvas_size / 2
    cy = canvas_size / 2 - canvas_size * 0.06

    tx = cx - text_w / 2 - bbox[0]
    ty = cy - text_h / 2 - bbox[1]
    draw.text((tx, ty), text, font=font, fill=glyph_color)

    # Bookmark-ribbon rule beneath the glyph.
    rule_w = canvas_size * rule_width_scale
    rule_y = cy + text_h / 2 + canvas_size * 0.075
    rule_h = max(3, int(canvas_size * 0.018))
    draw.rounded_rectangle(
        [cx - rule_w / 2, rule_y, cx + rule_w / 2, rule_y + rule_h],
        radius=rule_h / 2,
        fill=rule_color,
    )
    return img


def flatten_on(img, bg_color, size):
    """Composites a transparent mark onto a solid square background."""
    bg = Image.new("RGBA", (size, size), bg_color)
    bg.alpha_composite(img)
    return bg.convert("RGB")


# ---------------------------------------------------------------------------
# 1. app_icon.png — flat square, cream bg, ink glyph, gold rule.
#    Source for iOS icon + Android legacy launcher icon.
# ---------------------------------------------------------------------------
icon_size = 1024
mark = draw_mark(icon_size, INK, GOLD, glyph_scale=0.56)
app_icon = flatten_on(mark, CREAM, icon_size)
app_icon.save(f"{OUT}/app_icon.png")

# ---------------------------------------------------------------------------
# 2. app_icon_adaptive_fg.png — same glyph, transparent bg, pulled well
#    inside the safe zone so it isn't clipped by circle/squircle/rounded-
#    square adaptive-icon masks on Android. Background colour is set
#    separately (solid cream) in the flutter_launcher_icons config.
# ---------------------------------------------------------------------------
adaptive = draw_mark(icon_size, INK, GOLD, glyph_scale=0.40)
adaptive.save(f"{OUT}/app_icon_adaptive_fg.png")

# ---------------------------------------------------------------------------
# 3. splash_logo.png — mark + tracked-out wordmark, transparent bg, used by
#    flutter_native_splash centered on the cream/ink background.
# ---------------------------------------------------------------------------
splash_w, splash_h = 720, 880
splash = Image.new("RGBA", (splash_w, splash_h), (0, 0, 0, 0))
glyph = draw_mark(520, INK, GOLD, glyph_scale=0.58)
splash.alpha_composite(glyph, (int((splash_w - 520) / 2), 0))

draw = ImageDraw.Draw(splash)
word_font = ImageFont.truetype(SANS, 64)
word = "READORA"
# Manual letter-spacing (PIL has no native tracking) to match the app's own
# uppercase-label convention (labelLarge: letterSpacing 2.2 at fontSize 11).
tracking = 18
widths = [draw.textlength(ch, font=word_font) for ch in word]
total_w = sum(widths) + tracking * (len(word) - 1)
x = (splash_w - total_w) / 2
y = 560
for ch, w in zip(word, widths):
    draw.text((x, y), ch, font=word_font, fill=INK)
    x += w + tracking

splash.save(f"{OUT}/splash_logo.png")

# Dark-mode variant (used by flutter_native_splash's `image_dark`).
splash_dark = Image.new("RGBA", (splash_w, splash_h), (0, 0, 0, 0))
glyph_dark = draw_mark(520, DARK_INK, DARK_GOLD, glyph_scale=0.58)
splash_dark.alpha_composite(glyph_dark, (int((splash_w - 520) / 2), 0))
draw_dark = ImageDraw.Draw(splash_dark)
x = (splash_w - total_w) / 2
for ch, w in zip(word, widths):
    draw_dark.text((x, y), ch, font=word_font, fill=DARK_INK)
    x += w + tracking
splash_dark.save(f"{OUT}/splash_logo_dark.png")

# ---------------------------------------------------------------------------
# 4. brand_glyph_{light,dark}.png — tightly-cropped glyph-only mark for
#    in-app use (BrandMark widget), as opposed to app_icon_adaptive_fg's
#    generous OS-mask safe-zone padding. Trimmed to the glyph's own bounds
#    so it sits naturally inline with other UI, not floating in whitespace.
# ---------------------------------------------------------------------------
def tight_glyph(glyph_color, rule_color):
    big = draw_mark(1024, glyph_color, rule_color, glyph_scale=0.62, rule_width_scale=0.34)
    bbox = big.getbbox()
    pad = 24
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(1024, r + pad)
    b = min(1024, b + pad)
    return big.crop((l, t, r, b))

tight_glyph(INK, GOLD).save(f"{OUT}/brand_glyph_light.png")
tight_glyph(DARK_INK, DARK_GOLD).save(f"{OUT}/brand_glyph_dark.png")

print(
    "done:",
    f"{OUT}/app_icon.png",
    f"{OUT}/app_icon_adaptive_fg.png",
    f"{OUT}/splash_logo.png",
    f"{OUT}/splash_logo_dark.png",
    f"{OUT}/brand_glyph_light.png",
    f"{OUT}/brand_glyph_dark.png",
)

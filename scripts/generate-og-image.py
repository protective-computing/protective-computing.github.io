from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFont


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    font_paths = [
        r"C:\\Windows\\Fonts\\Inter-Regular.ttf",
        r"C:\\Windows\\Fonts\\inter.ttf",
        r"C:\\Windows\\Fonts\\segoeui.ttf",
    ]
    for path in font_paths:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size=size)
            except Exception:
                pass
    return ImageFont.load_default()


def main() -> None:
    width, height = 1200, 630
    base = Image.new("RGB", (width, height), (7, 10, 16))

    # Vertical gradient overlay to match the site's cyan/violet vibe.
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    for y in range(height):
        t = y / (height - 1)
        r = int((124 * (1 - t) + 52 * t) * 0.35)
        g = int((92 * (1 - t) + 211 * t) * 0.35)
        b = int((255 * (1 - t) + 255 * t) * 0.35)
        od.line([(0, y), (width, y)], fill=(r, g, b, 255))

    img = Image.alpha_composite(base.convert("RGBA"), overlay)
    draw = ImageDraw.Draw(img)

    margin = 72
    panel = (margin, margin, width - margin, height - margin)
    draw.rounded_rectangle(
        panel,
        radius=34,
        outline=(255, 255, 255, 35),
        width=2,
        fill=(255, 255, 255, 18),
    )

    title_font = load_font(72)
    subtitle_font = load_font(30)
    caption_font = load_font(22)

    title = "Protective Computing"
    subtitle = "Systems design under human vulnerability"
    caption = (
        "Reversibility • Exposure Minimization • Local Authority • Degraded Functionality • "
        "Coercion Resistance • Essential Utility"
    )

    x = margin + 54
    y = margin + 70

    # Title with a soft shadow for legibility.
    for dx, dy in [(0, 2), (2, 0), (2, 2)]:
        draw.text((x + dx, y + dy), title, font=title_font, fill=(0, 0, 0, 110))
    draw.text((x, y), title, font=title_font, fill=(255, 255, 255, 240))

    y2 = y + 98
    draw.text((x, y2), subtitle, font=subtitle_font, fill=(255, 255, 255, 205))

    line_y = y2 + 56
    line_x2 = width - margin - 54
    draw.line((x, line_y, line_x2, line_y), fill=(255, 255, 255, 55), width=2)

    cap_y = line_y + 28
    words = caption.split(" ")
    lines: list[str] = []
    cur = ""
    max_width = line_x2 - x

    for word in words:
        test = (cur + " " + word).strip()
        if draw.textlength(test, font=caption_font) <= max_width:
            cur = test
        else:
            lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)

    for i, line in enumerate(lines[:3]):
        draw.text((x, cap_y + i * 32), line, font=caption_font, fill=(255, 255, 255, 170))

    out_path = os.path.join("assets", "og", "protective-computing.png")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img.convert("RGB").save(out_path, format="PNG", optimize=True)
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()

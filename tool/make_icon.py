"""Draw the to Audit launcher icon (variant A: navy + gold magnifier over a ticket)."""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

NAVY = (0x1F, 0x3A, 0x5F, 255)
GOLD = (0xF4, 0xC5, 0x42, 255)
LENS = (0xE8, 0xF0, 0xFA, 255)
WHITE = (255, 255, 255, 255)

# Motif in the 112-unit design space; bounding box x 24..98.5, y 20..96.5.
CX, CY = 61.25, 58.25
SS = 4  # supersampling factor


def draw_motif(d: ImageDraw.ImageDraw, size: int, scale: float) -> None:
    k = scale * SS
    ox = size * SS / 2 - CX * k
    oy = size * SS / 2 - CY * k

    def p(x, y):
        return (ox + x * k, oy + y * k)

    def rr(x0, y0, x1, y1, r, fill):
        d.rounded_rectangle([p(x0, y0), p(x1, y1)], radius=r * k, fill=fill)

    rr(24, 20, 72, 86, 4, WHITE)            # ticket
    rr(32, 32, 62, 36, 2, NAVY)             # ticket lines
    rr(32, 42, 54, 46, 2, NAVY)
    # handle with round caps
    w = 9 * k
    d.line([p(81, 79), p(94, 92)], fill=GOLD, width=int(w))
    for (x, y) in ((81, 79), (94, 92)):
        cx, cy = p(x, y)
        d.ellipse([cx - w / 2, cy - w / 2, cx + w / 2, cy + w / 2], fill=GOLD)
    # lens: gold ring (r 17 ± 3.5) with light glass
    cx, cy = p(68, 66)
    ro, ri = 20.5 * k, 13.5 * k
    d.ellipse([cx - ro, cy - ro, cx + ro, cy + ro], fill=GOLD)
    d.ellipse([cx - ri, cy - ri, cx + ri, cy + ri], fill=LENS)


def render(size: int, scale: float, background) -> Image.Image:
    img = Image.new("RGBA", (size * SS, size * SS), background or (0, 0, 0, 0))
    draw_motif(ImageDraw.Draw(img), size, scale)
    return img.resize((size, size), Image.LANCZOS)


def main(out_dir: str) -> None:
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    # Full-bleed square (iOS / legacy Android): motif ~62 % of the height.
    full = render(1024, 635 / 76.5, NAVY).convert("RGB")
    full.save(out / "icon.png")
    # Adaptive foreground: motif inside the 66/108 safe circle, transparent bg.
    fg = render(1024, 600 / 106.8, None)
    fg.save(out / "icon_foreground.png")
    print("written", sorted(x.name for x in out.iterdir()))


if __name__ == "__main__":
    main(sys.argv[1])

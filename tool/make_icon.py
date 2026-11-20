"""Draws the app icon and writes every size iOS and Android ask for.

The icon is the mark of the launch animation (lib/ui/launch_animation.dart):
the cycle ring on a night-blue ground, the days of the period in rose, and
the mark of the day in gold. Decision 140.

Run from the root of the project, with Pillow installed:

    python tool/make_icon.py

Nothing here ships in the app: only the pictures it writes do.
"""

import math
import os

from PIL import Image, ImageDraw

NIGHT = (0x1B, 0x2A, 0x4A)
RING = (0xF6, 0xE6, 0xC2)
PERIOD = (0xB0, 0x4E, 0x64)
DOT = (0xE3, 0xB4, 0x5C)

# Share of the ring drawn in the colour of the period, and where the mark
# of the day sits: as in the launch animation, to a hair.
PERIOD_SHARE = 5 / 28
DOT_AT = 0.92

# Drawn large, then reduced: smooth edges at every size.
MASTER = 4096


def draw_mark(size, ring_diameter, ground):
    """The mark, [ring_diameter] being a share of [size]. [ground] is the
    colour behind it, or None for a transparent picture."""
    mode = 'RGB' if ground else 'RGBA'
    image = Image.new(mode, (size, size), ground or (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    center = size / 2
    radius = size * ring_diameter / 2
    stroke = radius * 0.31

    def point(share):
        angle = -math.pi / 2 + 2 * math.pi * share
        return (
            center + radius * math.cos(angle),
            center + radius * math.sin(angle),
        )

    def disc(at, r, colour):
        draw.ellipse((at[0] - r, at[1] - r, at[0] + r, at[1] + r), fill=colour)

    def arc(start, end, colour):
        outer = radius + stroke / 2
        draw.arc(
            (center - outer, center - outer, center + outer, center + outer),
            -90 + 360 * start,
            -90 + 360 * end,
            fill=colour,
            width=round(stroke),
        )
        # Round ends.
        disc(point(start), stroke / 2, colour)
        disc(point(end), stroke / 2, colour)

    # The ring stops under the mark: a clear breath before the period
    # begins again.
    arc(PERIOD_SHARE, DOT_AT, RING)
    arc(0, PERIOD_SHARE, PERIOD)
    disc(point(DOT_AT), stroke * 0.81, NIGHT)
    disc(point(DOT_AT), stroke * 0.58, DOT)
    return image


def save(image, path, pixels):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.resize((pixels, pixels), Image.LANCZOS).save(path, optimize=True)


def main():
    # iOS: a full square without transparency; the system rounds the corners.
    full = draw_mark(MASTER, 0.56, NIGHT)
    ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for name, pixels in [
        ('20x20@1x', 20),
        ('20x20@2x', 40),
        ('20x20@3x', 60),
        ('29x29@1x', 29),
        ('29x29@2x', 58),
        ('29x29@3x', 87),
        ('40x40@1x', 40),
        ('40x40@2x', 80),
        ('40x40@3x', 120),
        ('60x60@2x', 120),
        ('60x60@3x', 180),
        ('76x76@1x', 76),
        ('76x76@2x', 152),
        ('83.5x83.5@2x', 167),
        ('1024x1024@1x', 1024),
    ]:
        save(full, '%s/Icon-App-%s.png' % (ios, name), pixels)

    # Android: the plain square for old versions, and the mark alone for the
    # adaptive icon, kept inside the part no launcher shape cuts off.
    mark = draw_mark(MASTER, 0.40, None)
    res = 'android/app/src/main/res'
    for density, pixels in [
        ('mdpi', 48),
        ('hdpi', 72),
        ('xhdpi', 96),
        ('xxhdpi', 144),
        ('xxxhdpi', 192),
    ]:
        save(full, '%s/mipmap-%s/ic_launcher.png' % (res, density), pixels)
        save(
            mark,
            '%s/mipmap-%s/ic_launcher_foreground.png' % (res, density),
            pixels * 108 // 48,
        )


if __name__ == '__main__':
    main()

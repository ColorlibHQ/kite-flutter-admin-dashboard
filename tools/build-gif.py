#!/usr/bin/env python3
"""Assemble captured frames into the README GIF.

No ffmpeg needed. Frames are quantised to a shared adaptive palette so the
whole animation uses one colour table — without that, per-frame palettes make
the file two to three times larger and flicker on flat surfaces.

    python3 tools/build-gif.py docs/frames docs/demo.gif --width 900 --ms 420
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("build-gif: pillow is required (pip install pillow)")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("frames", type=Path)
    ap.add_argument("out", type=Path)
    ap.add_argument("--width", type=int, default=900)
    ap.add_argument("--ms", type=int, default=420, help="frame duration")
    ap.add_argument("--colors", type=int, default=128)
    ap.add_argument(
        "--max-hold",
        type=int,
        default=1400,
        help="cap on a single frame's duration, ms",
    )
    args = ap.parse_args()

    files = sorted(args.frames.glob("f*.png"))
    if not files:
        sys.exit(f"build-gif: no frames in {args.frames}")

    images = []
    for f in files:
        im = Image.open(f).convert("RGB")
        if im.width != args.width:
            h = round(im.height * args.width / im.width)
            im = im.resize((args.width, h), Image.LANCZOS)
        images.append(im)

    # One palette for the whole run, derived from a montage of sampled frames
    # so it covers both themes rather than just whatever the first frame used.
    sample = images[:: max(1, len(images) // 12)]
    strip = Image.new("RGB", (images[0].width, images[0].height * len(sample)))
    for i, im in enumerate(sample):
        strip.paste(im, (0, i * images[0].height))
    palette = strip.quantize(colors=args.colors, method=Image.MEDIANCUT)

    frames = [im.quantize(palette=palette, dither=Image.FLOYDSTEINBERG) for im in images]

    # Collapse runs of identical frames into one frame with a longer duration.
    #
    # The recorder holds a still by capturing it several times. Writing those
    # as separate frames wastes bytes, and GIF optimisation drops them anyway
    # — which silently removes the pause rather than shortening it. Merging
    # them here keeps the timing and shrinks the file.
    merged: list[Image.Image] = []
    durations: list[int] = []
    for frame in frames:
        payload = frame.tobytes()
        if merged and payload == merged[-1].tobytes():
            # Capped: a long pause reads as the GIF having stalled.
            durations[-1] = min(durations[-1] + args.ms, args.max_hold)
        else:
            merged.append(frame)
            durations.append(args.ms)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    merged[0].save(
        args.out,
        save_all=True,
        append_images=merged[1:],
        duration=durations,
        loop=0,
        optimize=True,
        disposal=2,
    )
    kb = args.out.stat().st_size // 1024
    total = sum(durations) / 1000
    print(
        f"build-gif: {len(frames)} captured -> {len(merged)} frames, "
        f"{args.width}px, {total:.1f}s -> {args.out} ({kb} KB)"
    )


if __name__ == "__main__":
    main()

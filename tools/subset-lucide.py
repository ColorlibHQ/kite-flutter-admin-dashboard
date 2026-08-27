#!/usr/bin/env python3
"""Subset the Lucide icon font to the glyphs this build actually draws.

`flutter build --tree-shake-icons` only manages ~12% on Lucide, because
shadcn_ui reaches its icons through wrappers that defeat the static analysis
Flutter relies on. But shadcn only ever draws a handful of them — a chevron, a
check, a close — so the shipped font is ~1000 glyphs to serve about a dozen.

This resolves the icons referenced by shadcn_ui and by this project, maps them
to codepoints, and rewrites the font with only those. Run it after
tools/strip-fonts.mjs, which removes the six unused weight variants.

    python3 tools/subset-lucide.py build/web

Requires fonttools (pip install fonttools).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

try:
    from fontTools import subset
    from fontTools.ttLib import TTFont
except ImportError:
    sys.exit("subset-lucide: fonttools is required (pip install fonttools)")

ROOT = Path(__file__).resolve().parent.parent
WEB = Path(sys.argv[1] if len(sys.argv) > 1 else ROOT / "build/web")
ICON_RE = re.compile(r"LucideIcons\.([A-Za-z0-9_]+)")
DEF_RE = re.compile(
    r"static const IconData ([A-Za-z0-9_]+) = const IconData\((\d+)", re.M
)


def package_root(name: str) -> Path | None:
    cfg = ROOT / ".dart_tool" / "package_config.json"
    if not cfg.exists():
        return None
    for pkg in json.loads(cfg.read_text())["packages"]:
        if pkg["name"] == name:
            uri = pkg["rootUri"]
            if uri.startswith("file://"):
                return Path(uri[7:])
            return (cfg.parent / uri).resolve()
    return None


def used_icon_names() -> set[str]:
    """Every LucideIcons.<name> reachable in this app."""
    names: set[str] = set()
    roots = [ROOT / "lib"]
    shadcn = package_root("shadcn_ui")
    if shadcn:
        roots.append(shadcn / "lib")
    for root in roots:
        if not root.exists():
            continue
        for dart in root.rglob("*.dart"):
            names.update(ICON_RE.findall(dart.read_text(errors="replace")))
    return names


def codepoints(names: set[str]) -> set[int]:
    pkg = package_root("lucide_icons_flutter")
    if not pkg:
        sys.exit("subset-lucide: lucide_icons_flutter not found in package_config")
    src = (pkg / "lib" / "lucide_icons.dart").read_text(errors="replace")
    table = {m.group(1): int(m.group(2)) for m in DEF_RE.finditer(src)}
    missing = names - table.keys()
    if missing:
        print(f"  note: {len(missing)} name(s) not in the icon table: "
              f"{sorted(missing)[:5]}")
    return {table[n] for n in names if n in table}


def main() -> None:
    fonts = list(WEB.rglob("lucide.ttf"))
    if not fonts:
        print("subset-lucide: no lucide.ttf in the build — nothing to do")
        return

    names = used_icon_names()
    points = codepoints(names)
    if not points:
        sys.exit("subset-lucide: resolved zero codepoints — refusing to subset")

    for font_path in fonts:
        before = font_path.stat().st_size
        font = TTFont(font_path)
        total = len(font.getGlyphOrder())
        subsetter = subset.Subsetter(
            options=subset.Options(
                layout_features=[],
                notdef_outline=True,
                recalc_bounds=True,
                drop_tables=["FFTM"],
            )
        )
        subsetter.populate(unicodes=points)
        subsetter.subset(font)
        font.save(font_path)
        after = font_path.stat().st_size
        print(
            f"subset-lucide: {font_path.name} {total} -> {len(font.getGlyphOrder())} "
            f"glyphs, {before // 1024} KB -> {after // 1024} KB "
            f"({100 - after * 100 // before}% smaller)"
        )


if __name__ == "__main__":
    main()

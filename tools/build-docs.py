#!/usr/bin/env python3
"""Build the docs site.

Content lives as HTML fragments in docs/src/. This wraps each one in the shared
shell — head, header, sidebar, footer — and writes docs/site/. No dependencies,
no build toolchain; the point is that editing a page means editing one file of
prose, not copy-pasting navigation into it.

    python3 tools/build-docs.py
"""
from __future__ import annotations

import hashlib
import html
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "src"
OUT = ROOT / "docs" / "site"

REPO = "https://github.com/ColorlibHQ/kite-flutter-admin-dashboard"

# Sidebar promo.
#
# The angle is deliberate: DashboardPack has no Flutter product, so "buy the
# Pro version of this" would be a lie. What is true is that a team using Kite
# for Flutter often needs the same admin in React or Next.js for something
# else — that is a real need this can answer, which is why it belongs in the
# docs rather than reading as an ad.
#
# UTM-tagged so its conversion is measurable rather than assumed.
PROMO_URL = (
    "https://dashboardpack.com/"
    "?utm_source=kite-docs&utm_medium=sidebar&utm_campaign=kite-free"
)

PROMO = f"""<div class="promo">
      <span class="promo-eyebrow">From the same team</span>
      <b>Need this in React or Next&#46;js?</b>
      <p>
        Kite covers Flutter. DashboardPack has production admin templates for
        Next&#46;js, React, Vue, Angular, Laravel, Svelte and plain HTML &mdash;
        eight framework builds of Apex alone.
      </p>
      <a class="promo-cta" href="{PROMO_URL}">Browse templates &rarr;</a>
      <span class="promo-note">From $69 &middot; commercial use</span>
    </div>"""

# (section, [(slug, nav label, <title>, one-line description)])
NAV: list[tuple[str, list[tuple[str, str, str, str]]]] = [
    ("Start", [
        ("index", "Overview", "Kite — Flutter admin dashboard template",
         "A free MIT-licensed Flutter admin dashboard template running on web, iOS, Android, macOS and Windows from one codebase."),
        ("getting-started", "Getting started", "Getting started",
         "Clone, run, and find your way around Kite in about five minutes."),
        ("structure", "Project structure", "Project structure",
         "How Kite is laid out, and the one architectural rule that matters."),
        ("screens", "Screens", "Screens",
         "Every screen Kite ships, what each is for, and which are load-bearing."),
    ]),
    ("Build on it", [
        ("data", "Data layer", "Data layer",
         "The DataProvider contract, the three adapters, and how to point Kite at your own backend."),
        ("resources", "Adding a resource", "Adding a resource",
         "List, detail, create and edit are generic. A new resource is a schema entry."),
        ("routing", "Routing", "Routing",
         "go_router shells, the auth guard, nested routes and path URLs."),
        ("state", "State", "State",
         "The Riverpod patterns Kite uses, and the ones it deliberately avoids."),
        ("theming", "Theming", "Theming",
         "Colour, type, spacing and radius tokens; dark mode and accents."),
        ("components", "Components", "Component reference",
         "Every widget in kite_ui, what it is for, and how to use it."),
        ("i18n", "Localisation", "Localisation",
         "Five locales, right-to-left, and the directional widgets that keep layout honest."),
    ]),
    ("Ship it", [
        ("platforms", "Platforms", "Platforms",
         "Per-platform notes for web, iOS, Android, macOS and Windows."),
        ("deploy", "Deploying", "Deploying",
         "Building for the web, bundle size, the font tools, and pushing to Cloudflare R2."),
        ("faq", "FAQ", "FAQ and troubleshooting",
         "The traps this build actually hit, and what to do about them."),
    ]),
]

PAGES = {slug: (label, title, desc)
         for _, items in NAV for slug, label, title, desc in items}

SHELL = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<meta name="description" content="{desc}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Geist+Mono:wght@400;500&family=Geist:wght@400;500;600;650&display=swap">
<link rel="stylesheet" href="{css}">
</head>
<body>

<header class="top">
  <a class="brand" href="index.html">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round" aria-hidden="true"><path d="M12 3 21 20H3z"/></svg>
    Kite <span class="brand-sub">docs</span>
  </a>
  <nav>
    <a href="https://demo.dashboardpack.com/kite/">Live demo</a>
    <a href="{repo}">GitHub</a>
  </nav>
</header>

<div class="shell">
  <aside>
    {sidebar}
    {promo}
  </aside>
  <main>
{content}
    <nav class="pager">{pager}</nav>
  </main>
</div>

<footer>
  MIT &copy; <a href="https://colorlib.com">Colorlib</a> &mdash; the team behind
  <a href="https://github.com/ColorlibHQ/AdminLTE">AdminLTE</a>.
</footer>

</body>
</html>
"""


def sidebar_for(current: str) -> str:
    out = []
    for section, items in NAV:
        out.append(f"<h4>{section}</h4>")
        for slug, label, _, _ in items:
            cls = ' class="here"' if slug == current else ""
            out.append(f'<a href="{slug}.html"{cls}>{label}</a>')
    return "\n    ".join(out)


def pager_for(current: str) -> str:
    order = [slug for _, items in NAV for slug, *_ in items]
    i = order.index(current)
    parts = []
    if i > 0:
        prev = order[i - 1]
        parts.append(
            f'<a class="prev" href="{prev}.html">'
            f'<span>Previous</span>{PAGES[prev][0]}</a>'
        )
    else:
        parts.append("<span></span>")
    if i < len(order) - 1:
        nxt = order[i + 1]
        parts.append(
            f'<a class="next" href="{nxt}.html">'
            f'<span>Next</span>{PAGES[nxt][0]}</a>'
        )
    return "".join(parts)


def main() -> None:
    missing = [s for s in PAGES if not (SRC / f"{s}.html").exists()]
    if missing:
        sys.exit(f"build-docs: missing fragments: {', '.join(sorted(missing))}")

    OUT.mkdir(parents=True, exist_ok=True)
    for stale in list(OUT.glob("*.html")) + list(OUT.glob("style*.css")):
        stale.unlink()

    # Content-hash the stylesheet.
    #
    # These files are served with a 24-hour max-age from a CDN, so editing
    # style.css in place means the edge keeps serving the old one until it
    # expires or someone remembers to purge that exact URL. A stale stylesheet
    # does not look like a caching problem — it looks like broken markup.
    # Hashing the name means a change is always a URL that was never cached.
    css_src = (SRC / "style.css").read_bytes()
    css_name = f"style.{hashlib.sha256(css_src).hexdigest()[:10]}.css"
    (OUT / css_name).write_bytes(css_src)

    for slug, (_, title, desc) in PAGES.items():
        content = (SRC / f"{slug}.html").read_text(encoding="utf-8").rstrip()
        page = SHELL.format(
            title=html.escape(title),
            desc=html.escape(desc),
            repo=REPO,
            sidebar=sidebar_for(slug),
            promo=PROMO,
            content=content,
            pager=pager_for(slug),
            css=css_name,
        )
        (OUT / f"{slug}.html").write_text(page, encoding="utf-8")

    # Every internal link must resolve, or the site ships dead ends.
    known = {f"{s}.html" for s in PAGES} | {css_name}
    broken: list[str] = []
    for page in OUT.glob("*.html"):
        body = page.read_text(encoding="utf-8")
        for href in re.findall(r'href="([^"#:]+)(?:#[^"]*)?"', body):
            if href and not href.startswith(("http", "//", "mailto")):
                if href not in known:
                    broken.append(f"{page.name} -> {href}")
    if broken:
        sys.exit("build-docs: broken internal links:\n  " + "\n  ".join(broken))

    print(f"build-docs: {len(PAGES)} pages -> {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

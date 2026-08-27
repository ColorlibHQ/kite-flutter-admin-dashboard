# Spikes B & C — results

Measured 2026-08-26 on Flutter 3.47.1 / Dart 3.13.1. Screen under test: a dense Orders view —
title, badge, two action buttons, search input, status select, reset, and a 10,000-row
`trina_grid` with 50-row pagination.

## Spike C — does the grid survive real data? **Pass, comfortably**

Frame deltas sampled during synthetic wheel-scrolling (180 scroll events, ~415 frames).

| | Unthrottled | 4x CPU throttle |
|---|---|---|
| p50 | 8.3 ms | 8.3 ms |
| p95 | 9.0 ms | 16.7 ms |
| p99 | 9.3 ms | 25.5 ms |
| Frames missing 60fps | 1 / 418 (0.2%) | 19 / 410 (4.6%) |
| Frames missing 30fps | 1 (0.2%) | 1 (0.2%) |

10,000 rows scroll at frame budget with no virtualisation work needed. Even at 4x CPU throttle —
roughly a mid-range Android device — 95% of frames hit 60fps and essentially nothing drops below
30fps. **No fallback to a virtualised list is required.** `trina_grid` handles this.

## Spike B — does shadcn_ui hold up dense? **Pass on the chrome, work needed on the grid**

### API friction: low

The whole dense screen compiled with **one** real API surprise — `ShadApp.material` does not exist
in 0.55.x (use plain `ShadApp`; it wraps `AnimatedTheme` with Material `ThemeData` and registers
`GlobalMaterialLocalizations`, so `Scaffold` and Material icons work). Everything else —
`ShadInput`, `ShadSelect`, `ShadOption`, `ShadBadge`, `ShadButton.outline/.ghost`, `ShadCard`,
`ShadTheme.of` — behaved as guessed on first write. Two trailing nullability warnings, no
workarounds, no forked widgets.

### Visual: the shadcn chrome is genuinely good

Buttons, badge, inputs, select and the Geist type all render correctly and look modern. This is the
visual gap over stock-Material competitors that the whole positioning rests on, and it is real.

### But `trina_grid` does not inherit the shadcn theme

**Correcting an earlier assumption.** `trina_grid 2.3.0` *depends on* `shadcn_ui ^0.55.0`, and I
took that to mean the grid would come out shadcn-styled for free. It does not:

- Column headers render `trina_grid`'s own hamburger menu affordances, not shadcn iconography.
- The pagination footer is bright blue, clashing badly with the slate/near-black shadcn palette.
- Columns do not expand to fill available width — a fixed-width column set leaves a large dead
  zone to the right of the last column.

None of this is fatal, but it is **real Phase 1 work**: theming the grid to match. It belongs in
`packages/kite_ui/lib/src/data_table.dart`, which is exactly what the wrapper architecture is for — and it is a
good argument for the wrapper existing, since the theming has to live somewhere anyway.

## Correction to Spike A's font finding

Spike A concluded "strip the Lucide fonts" and measured 2.39 MB / FCP 3.37s. **That was wrong** —
the screenshot showed shadcn's own `ShadSelect` chevron rendering as a tofu box, because shadcn
components draw from the base `Lucide` family.

Corrected fix: **keep the base `Lucide` family, drop only the six numbered weight instances.**

| Variant | Transfer | FCP (Fast 4G + 4x CPU) | Icons |
|---|---|---|---|
| As built | 3.88 MB | 4.80 s | correct |
| All Lucide stripped | 2.39 MB | 3.37 s | **broken** |
| **Base Lucide kept** | **2.73 MB** | **3.62 s** | **correct** |

Saves 1.15 MB and 1.18s with no visual regression. Shipped as `tools/strip-fonts.mjs` and enforced
by the `fonts` CI job.

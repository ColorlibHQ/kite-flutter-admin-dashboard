## 0.2.0 — 2026-10-28

- Center single-line input values and placeholders with symmetric padding at
  normal and large text sizes, including right-to-left layouts.
- Retain 48-pixel input and button touch targets; improve button semantics,
  disabled states, and contrast across themes.
- Add input autofill, keyboard actions, formatters, focus, and semantic options.
- Support explicit locales and currencies in number formatting.
- Keep stat-grid row heights stable across responsive widths.
- Add regression tests for input geometry and responsive stat grids.
- Update compatible chart, data-grid, design-library, and formatting dependencies.
  `shadcn_ui` remains on 0.55.x to satisfy the data grid's constraint.

## 0.1.0

First release, extracted from the [Kite](https://github.com/ColorlibHQ/kite-flutter-admin-dashboard)
Flutter admin dashboard template where it has been in use across 22 screens.

- `KiteStatGrid` — a stat-card grid whose row height is set explicitly rather
  than derived from column width, so cards do not grow on wide viewports
- `KiteChart`, `KiteSparkline`, `KiteDonut` — themed `fl_chart` wrappers
- `KiteDataTable` — themed `trina_grid` with server-side pagination hooks
- `KiteMenu` — a popover menu that closes before running its callback
- `KiteCard`, `KiteButton`, `KiteBadge`, inputs, feedback and display widgets
- `KiteSpace`, `KiteRadius`, `KiteBreak` tokens, plus `KiteColors` and
  `KiteText` zero-cost theme facades built on extension types

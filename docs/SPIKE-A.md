# Spike A — what does a wasm Flutter admin actually weigh?

**Runnable the moment the SDK is installed. Nothing else starts until this reports a number.**

This is the one measurement that decides the launch positioning. Nobody has published it for a
current Flutter admin build, which is why it is worth taking seriously — and why publishing the
result later is itself a credibility asset.

## Why it gates everything

| Outcome | Positioning |
|---|---|
| ≤ 2.2 MB gzip **and** FCP < 3.5s on throttled 4G | Web-first. "Runs in the browser" leads. |
| Either threshold missed | **Mobile-first.** Web demoted to "also runs in a browser". |

**Result: conditional pass.** See Results below — web-first holds, contingent on the font fix.

The mobile-first framing is the stronger pitch regardless. What is not survivable is launching a
web-first claim that a reviewer disproves in ten seconds with DevTools.

## Protocol

```bash
fvm use 3.47.1
fvm flutter create --platforms=web kite_spike && cd kite_spike
fvm flutter pub add shadcn_ui fl_chart trina_grid
```

Build a throwaway shell — **do not** reuse this code:

- app shell: sidebar + top bar
- one `fl_chart` line chart with ~50 points
- one `trina_grid` table, 25 rows visible
- light/dark toggle

Then:

```bash
fvm flutter build web --wasm --release

# Gzipped transfer size — the number that matters, not the on-disk size
find build/web -type f \( -name '*.wasm' -o -name '*.js' -o -name '*.mjs' \
  -o -name '*.json' -o -name '*.html' -o -name '*.css' \) \
  -exec sh -c 'gzip -c "$1" | wc -c' _ {} \; \
  | awk '{s+=$1} END {printf "gzipped: %.2f MB\n", s/1048576}'
```

For LCP: serve `build/web` over a local static server, open Chrome DevTools → Performance,
throttle to **Fast 4G** + **4× CPU slowdown**, hard-reload, read Largest Contentful Paint.
Record the median of five runs, not the best one.

Also build `--release` without `--wasm` (`fvm flutter build web --release`) and record both. The JS fallback number matters because
~8% of traffic never gets WasmGC.

## Results — measured 2026-08-26

Flutter 3.47.1 / Dart 3.13.1. Throttled figures are **Fast 4G + 4x CPU** via CDP, measured as real
browser transfer (encoded bytes over the wire), not by summing files on disk.

| Metric | Threshold | As built | Lucide fonts stripped |
|---|---|---|---|
| Transfer (gzip, real) | ≤ 2.2 MB | 3.88 MB | 2.39 MB *(icons broken — see B&C: 2.73 MB is the shippable figure)* |
| — of which `skwasm.wasm` | — | 1.20 MB | 1.20 MB |
| — of which `main.dart.wasm` | — | 0.98 MB | 0.98 MB |
| — of which fonts | — | 1.53 MB | 0.17 MB |
| FCP, Fast 4G + 4x CPU | — | 4.80 s | **3.37 s** |
| Requests | — | 19 | 12 |
| Build time (M-series, clean) | — | 27 s | 27 s |

### Verdict: conditional pass — web-first survives, but only with the font fix

**1. 1.5 MB of the bundle was fonts nothing referenced.** `shadcn_ui` depends on
`lucide_icons_flutter`, which declares **seven** font families in `FontManifest.json` — a static
`lucide.ttf` plus six variable weight instances (`Lucide100`…`Lucide600`). Flutter web preloads
every declared family, so all seven download even though this spike used Material icons
exclusively. Dropping them cut transfer 38% and FCP 30%.

> **Superseded — see `docs/SPIKE-B-C.md`.** Stripping *all* Lucide families breaks shadcn's own
> icons (the `ShadSelect` chevron renders as a tofu box). The correct fix keeps the base `Lucide`
> family and drops only the six numbered weights: **2.73 MB / FCP 3.62s**, saving 1.15 MB and
> 1.18s with no visual regression. Implemented in `tools/strip-fonts.mjs`.

**2. `skwasm.wasm` (1.20 MB) is fetched from `gstatic.com`, not the local build.** It is shared and
cached across every Flutter web app, so a returning visitor — or anyone who has used any other
Flutter site — pays nothing for it. **The app-specific payload is ~1.2 MB**, which is genuinely
competitive. Self-hosting is possible but forfeits that shared cache.

**3. LCP is not measurable, and the threshold was ill-specified.** Flutter renders to canvas, so no
LCP-eligible element exists and `PerformanceObserver` reports 0. Use **FCP** and time-to-interactive
instead. This also means Core Web Vitals cannot score a Flutter admin — irrelevant behind a login,
but worth knowing before anyone quotes a CWV number.

**4. `build/web` ships six mutually-exclusive renderer variants** (`canvaskit`, `skwasm`,
`skwasm_heavy`, `chromium/canvaskit`, `wimp`, `webparagraph/canvaskit`) plus `.symbols` debug files.
Summing the directory gives **13.2 MB** — 5.5x the real figure. Never measure that way; the CI size
job was corrected to match.

## Spikes B and C

- **B — does `shadcn_ui` hold up dense?** Base library is decided on adoption (3× the downloads of
  the nearest rival). Open question is whether it survives a data table with filters, toolbar and
  pagination. Count how often you fight it. Fails badly → `forui` is the documented fallback, and
  `packages/kite_ui/lib/shadcn.dart` makes that a one-folder swap.
- **C — does the grid survive real data?** 10,000 rows into `trina_grid`. Scroll hard, sort, filter.
  Target: sustained 60fps on desktop web, no dropped-frame cascade on a mid-range Android device.
  Fails → virtualised list on small screens.

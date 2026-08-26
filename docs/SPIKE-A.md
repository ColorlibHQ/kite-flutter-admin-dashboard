# Spike A — what does a wasm Flutter admin actually weigh?

**Runnable the moment the SDK is installed. Nothing else starts until this reports a number.**

This is the one measurement that decides the launch positioning. Nobody has published it for a
current Flutter admin build, which is why it is worth taking seriously — and why publishing the
result later is itself a credibility asset.

## Why it gates everything

| Outcome | Positioning |
|---|---|
| ≤ 2.2 MB gzip **and** LCP < 2.5s on throttled 4G | Web-first. "Runs in the browser" leads. |
| Either threshold missed | **Mobile-first.** Web demoted to "also runs in a browser". |

The mobile-first framing is the stronger pitch regardless. What is not survivable is launching a
web-first claim that a reviewer disproves in ten seconds with DevTools.

## Protocol

```bash
flutter create --platforms=web kite_spike && cd kite_spike
flutter pub add shadcn_ui fl_chart trina_grid
```

Build a throwaway shell — **do not** reuse this code:

- app shell: sidebar + top bar
- one `fl_chart` line chart with ~50 points
- one `trina_grid` table, 25 rows visible
- light/dark toggle

Then:

```bash
flutter build web --wasm --release

# Gzipped transfer size — the number that matters, not the on-disk size
find build/web -type f \( -name '*.wasm' -o -name '*.js' -o -name '*.mjs' \
  -o -name '*.json' -o -name '*.html' -o -name '*.css' \) \
  -exec sh -c 'gzip -c "$1" | wc -c' _ {} \; \
  | awk '{s+=$1} END {printf "gzipped: %.2f MB\n", s/1048576}'
```

For LCP: serve `build/web` over a local static server, open Chrome DevTools → Performance,
throttle to **Fast 4G** + **4× CPU slowdown**, hard-reload, read Largest Contentful Paint.
Record the median of five runs, not the best one.

Also build `--release` without `--wasm` and record both. The JS fallback number matters because
~8% of traffic never gets WasmGC.

## Record here

| Metric | Threshold | Measured | Date |
|---|---|---|---|
| wasm gzipped transfer | ≤ 2.2 MB | — | — |
| JS (CanvasKit) gzipped | — | — | — |
| LCP, Fast 4G + 4× CPU | < 2.5s | — | — |
| Time to interactive | — | — | — |

Once measured: put the real number into `WASM_GZIP_BUDGET_KB` in `.github/workflows/ci.yml`
(measured + ~10% headroom) so the bundle cannot silently bloat, and quote it in the README.

## Spikes B and C

- **B — does `shadcn_ui` hold up dense?** Base library is decided on adoption (3× the downloads of
  the nearest rival). Open question is whether it survives a data table with filters, toolbar and
  pagination. Count how often you fight it. Fails badly → `forui` is the documented fallback, and
  `lib/kite_ui/_shadcn.dart` makes that a one-folder swap.
- **C — does the grid survive real data?** 10,000 rows into `trina_grid`. Scroll hard, sort, filter.
  Target: sustained 60fps on desktop web, no dropped-frame cascade on a mid-range Android device.
  Fails → virtualised list on small screens.

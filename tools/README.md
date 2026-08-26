# tools/

## measure-bundle.mjs

Spike A's measurement harness. Serves a Flutter web build over gzip, loads it in headless
Chromium, and reports **real browser transfer** (encoded bytes over the wire) plus FCP.

Do not measure by summing files in `build/web` — it ships six mutually-exclusive renderer
variants and reports ~5.5x the real figure. See `docs/SPIKE-A.md`.

```bash
npm i playwright && npx playwright install chromium
node tools/measure-bundle.mjs build/web "label"            # unthrottled
node tools/measure-bundle.mjs build/web "label" throttle    # Fast 4G + 4x CPU
```

Note: LCP always reports 0 for Flutter — it renders to canvas, so no LCP-eligible element
exists. Use FCP.

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

## strip-fonts.mjs

Drops the six Lucide variable-weight font instances (`Lucide100`..`Lucide600`).
Flutter web preloads every family declared in `FontManifest.json`, so all seven
download on first paint even though nothing references the numbered weights.

Keeps the base `Lucide` family — shadcn's own components draw from it, and
dropping it leaves tofu boxes where the chevrons should be.

```bash
node tools/strip-fonts.mjs build/web
```

## subset-lucide.py

Then subsets that base face to the glyphs the build actually draws.
`--tree-shake-icons` only manages ~12% here because shadcn reaches its icons
through wrappers that defeat Flutter's static analysis — but it only ever draws
about a dozen. 1,776 glyphs to 12; 732 KB to 2 KB.

```bash
pip install fonttools
python3 tools/subset-lucide.py build/web
```

Both run in CI before the size gate. Together they take the app payload from
2,240 KB to 1,562 KB.

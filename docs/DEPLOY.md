# Deploying Kite

Everything here goes to Cloudflare R2 behind the existing workers — the same
path every other DashboardPack demo and docs site already takes. There is no
GitHub Pages surface, deliberately: it would put one asset outside the
infrastructure that handles caching, purging and SEO for all the others.

| What | Bucket | URL |
|---|---|---|
| Web demo | `r2pro:dashboardpack-demos/kite/` | `https://demo.dashboardpack.com/kite/` |
| Docs | `r2pro:dashboardpack-docs/kite-docs/` | `https://docs.dashboardpack.com/kite-docs/` |

Both are **paths under existing hosts**, not new subdomains. That matters: the
`dbp-demo-canonical` worker already covers `demo.dashboardpack.com/{slug}/`
and `/docs*` automatically, so neither needs a `wrangler.jsonc` route added or
a deploy of the worker. A bare `kite.dashboardpack.com` would need both.

## Build

Flutter's default is hash URLs; Kite uses path URLs so detail pages are
linkable. R2 serves `index.html` for unknown paths under a prefix, which is
what makes `/kite/orders/10004` resolve on a refresh.

```bash
flutter build web --wasm --release --base-href /kite/
node tools/strip-fonts.mjs build/web
python3 tools/subset-lucide.py build/web
```

`--base-href` must match the R2 prefix or every asset 404s.

## Demo

`rclone sync` deletes remote files missing from the source. Dry-run first,
every time.

```bash
rclone sync build/web/ r2pro:dashboardpack-demos/kite/ --dry-run
rclone sync build/web/ r2pro:dashboardpack-demos/kite/
rclone check build/web/ r2pro:dashboardpack-demos/kite/   # expect "0 differences"
```

## Docs

```bash
rclone sync docs/site/ r2pro:dashboardpack-docs/kite-docs/ --dry-run
rclone sync docs/site/ r2pro:dashboardpack-docs/kite-docs/
```

## Purging

Cloudflare edge-caches per colo. Replacing a file without purging means
visitors keep getting the old one — this has bitten the downloads bucket
before.

```bash
ssh hetzner sudo cf-purge-url https://demo.dashboardpack.com/kite/
ssh hetzner sudo cf-purge-url https://docs.dashboardpack.com/kite-docs/
```

## SEO

Nothing to do. The `dbp-demo-canonical` worker owns canonicals, meta-robots
and robots.txt at the edge for every `*.dashboardpack.com` host. **Never bake
those into the build** — the edge is the source of truth, and a build that
ships its own would fight it.

One thing to check if the demo's landing path ever changes: the worker keeps
demo roots, `/docs*` and the entry paths `/login`, `/dashboard`,
`/accounts/login` indexable and noindexes everything else. Kite's root
redirects to `/sign-in`, which is **not** in that list — so either add it to
`ENTRY_PATHS` in the worker or accept that the indexable page is the root
itself. Verify with `node infra/workers/demo-canonical/verify-live.mjs` from
divilab-content-hub.

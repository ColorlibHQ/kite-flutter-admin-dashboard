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
flutter build web --wasm --release --base-href /kite/ --dart-define=KITE_DEMO=true
node tools/strip-fonts.mjs build/web
python3 tools/subset-lucide.py build/web
```

`--base-href` must match the R2 prefix or every asset 404s.

`KITE_DEMO=true` starts the hosted demo already signed in. Without it the
first thing a visitor from a link sees is a login form, which is a wall in
front of the thing they came to look at. Leave it off for any build people
clone and run — they should get the real auth flow.

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
python3 tools/build-docs.py
rclone sync docs/site/ r2pro:dashboardpack-docs/kite-docs/ --dry-run
rclone sync docs/site/ r2pro:dashboardpack-docs/kite-docs/
./tools/purge-docs.sh
```

> **Purge every file, not just the root.** `cf-purge-url` takes one URL.
> Purging `/kite-docs/` alone leaves `style.css` cached, which serves a site
> whose stylesheet is a version behind — and that reads as broken markup, not
> as a stale cache. `tools/purge-docs.sh` walks the build output.

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

**Decided 2026-08-27: leave `ENTRY_PATHS` alone.** Kite's root redirects to
`/sign-in`, which is not in the worker's entry list — so the indexable page is
`demo.dashboardpack.com/kite/` itself and every deeper demo path stays
noindex. That is the wanted outcome and it is the worker's default, so there is
no worker change and no deploy. `/docs*` remains indexable, which is what the
docs site needs.

If that ever needs revisiting, verify with
`node infra/workers/demo-canonical/verify-live.mjs` from divilab-content-hub.

# Releasing Kite

The application and local `kite_ui` package have independent version fields.
For a coordinated release, update both pubspecs, both changelogs, package usage
examples, and the app lockfile. Use `vMAJOR.MINOR.PATCH` Git tags. A GitHub release
does not publish `kite_ui` to pub.dev.

## Prepare and verify

1. Read [DISTRIBUTION.md](DISTRIBUTION.md) before editing the README. Keep its
   preview, introduction, packages, animation, and onboarding order.
2. Document behavior, migration steps, limitations, and configuration changes in
   `CHANGELOG.md` and the relevant `docs/src/` pages. Rebuild with
   `python3 tools/build-docs.py`; commit the generated `docs/site/` output.
3. Use the SDK pinned in `.fvmrc` and CI. Run:

```bash
flutter pub get --enforce-lockfile
python3 tools/check-l10n.py
flutter gen-l10n
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --coverage
(cd packages/kite_ui && flutter pub get && flutter analyze --fatal-infos && flutter test --coverage)
npm ci --prefix tools/policy-tests --ignore-scripts
npm test --prefix tools/policy-tests
node tools/local-supabase.mjs start
node tools/auth-e2e.mjs
git diff --check
```

4. Review the staged files. Keep `config/*.local.json`, build output, credentials,
   test inboxes, and operational reports out of Git and release archives.
5. Commit and push the release source. Wait for CI to pass, including all seven
   web/native build variants. Fix failures before publishing the tag.

## Publish the demo and docs

Follow [DEPLOY.md](DEPLOY.md). Build the public demo with `KITE_DEMO=true`, mock
data, and the `/kite/` base path. It opens the dashboard immediately; signing
out reveals the sample login. Never use a staging or production Supabase config
for this public preview. Apply both font tools.

Back up both existing R2 prefixes into ignored `build/ops/` directories. Inspect
`rclone sync --dry-run`, then upload only the Kite prefixes. Verify both uploads
with `rclone check`. Purge the demo shell, assets, deep-link entry points, and
all docs HTML/CSS through the existing Cloudflare purge helper.

Open the public demo in a fresh browser session. Verify the dashboard, sign-out,
sample sign-in, navigation, and a refreshed resource deep link. Check the hosted
Auth documentation and its navigation. Keep a screenshot and deployment report
in `build/ops/`; these are operational evidence, not source artifacts.

## Publish the GitHub release

Create an annotated tag on the verified commit. Build a ZIP containing the
optimized demo with its `/kite/` base path and a SHA-256 checksum. Name artifacts
with the version, for example `kite-v0.2.0-web-demo.zip`. Document that the ZIP
requires subpath hosting; root hosting requires a rebuild. GitHub also supplies
source archives for the tag.

Create the release with notes covering changes, upgrade steps, verification,
known limitations, and links to the demo, docs, and changelog. Attach only the
public demo ZIP and checksums. Verify the release tag resolves to the intended
commit and the uploaded artifact sizes/checksums match local files.

For rollback, restore the backed-up R2 prefix, purge the same URLs, and verify
in a fresh browser session. Do not rewrite a published version tag; release a
new patch for source corrections.

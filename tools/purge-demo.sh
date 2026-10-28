#!/usr/bin/env bash
# Purge the deployed demo shell, build assets, and common SPA entry points.
set -euo pipefail
BASE="${1:-https://demo.dashboardpack.com/kite}"
BUILD="${2:-build/web}"
[ -f "$BUILD/index.html" ] || { echo "purge-demo: no build at $BUILD" >&2; exit 1; }
{
  printf '%s/\n' "$BASE"
  for route in sign-in sign-up forgot-password auth/callback orders customers products; do
    printf '%s/%s\n' "$BASE" "$route"
  done
  while IFS= read -r file; do
    printf '%s/%s\n' "$BASE" "${file#"$BUILD/"}"
  done < <(find "$BUILD" -type f ! -name '*.symbols' | sort)
} | ssh -o BatchMode=yes hetzner 'while IFS= read -r url; do sudo -n cf-purge-url "$url" || exit; done'

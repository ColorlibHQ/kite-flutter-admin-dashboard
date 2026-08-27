#!/usr/bin/env bash
# Purge every deployed docs URL from the Cloudflare edge.
#
# cf-purge-url takes ONE url. Purging only the directory root leaves
# style.css cached — which ships a site whose stylesheet is a version behind,
# and looks like broken markup rather than a stale cache.
set -euo pipefail

BASE="${1:-https://docs.dashboardpack.com/kite-docs}"
SITE="$(cd "$(dirname "$0")/.." && pwd)/docs/site"

[ -d "$SITE" ] || { echo "purge-docs: no build at $SITE — run tools/build-docs.py"; exit 1; }

ssh hetzner sudo cf-purge-url "$BASE/"
while IFS= read -r f; do
  ssh hetzner sudo cf-purge-url "$BASE/$(basename "$f")"
done < <(find "$SITE" -type f \( -name '*.html' -o -name '*.css' \))

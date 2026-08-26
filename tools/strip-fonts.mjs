#!/usr/bin/env node
// Post-build: drop the six Lucide variable-weight font instances.
//
// shadcn_ui depends on lucide_icons_flutter, which declares SEVEN font families:
// the base `Lucide` (~343 KB gzip) plus `Lucide100`..`Lucide600` variable-weight
// instances (~200 KB gzip each). Flutter web preloads EVERY declared family, so
// all seven download on first paint.
//
// Keep the base family — shadcn's own components (ShadSelect's chevron, etc.)
// render from it, and dropping it leaves tofu boxes in the UI. Drop only the
// numbered weights, which nothing references unless you ask for them.
//
// Measured saving: 1.15 MB transfer, 1.18s FCP, no visual regression.
//   Usage: node tools/strip-fonts.mjs build/web
import fs from 'node:fs';
import path from 'node:path';

const webDir = process.argv[2] || 'build/web';
const manifestPath = path.join(webDir, 'assets', 'FontManifest.json');

if (!fs.existsSync(manifestPath)) {
  console.error(`strip-fonts: no FontManifest.json at ${manifestPath}`);
  process.exit(1);
}

const families = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const isWeightedLucide = (f) => {
  const name = f.family.split('/').pop();
  return name.startsWith('Lucide') && /\d$/.test(name);
};

const kept = families.filter((f) => !isWeightedLucide(f));
const dropped = families.filter(isWeightedLucide);

if (dropped.length === 0) {
  console.log('strip-fonts: nothing to drop');
  process.exit(0);
}

// Remove the asset files too, not just the manifest entries.
let freed = 0;
for (const f of dropped) {
  for (const a of f.fonts ?? []) {
    const p = path.join(webDir, 'assets', a.asset);
    if (fs.existsSync(p)) {
      freed += fs.statSync(p).size;
      fs.unlinkSync(p);
    }
  }
}

fs.writeFileSync(manifestPath, JSON.stringify(kept));
console.log(
  `strip-fonts: dropped ${dropped.length} families ` +
    `(${(freed / 1048576).toFixed(2)} MB raw), kept ${kept.map((f) => f.family.split('/').pop()).join(', ')}`,
);

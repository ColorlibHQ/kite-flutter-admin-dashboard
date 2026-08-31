#!/usr/bin/env node
/**
 * Capture the 1280×640 GitHub social preview image.
 *
 * The other Colorlib repos crop their dashboard front page directly. That
 * works when the reader already knows the brand; Kite is new, and at the size
 * these render in a Slack or X unfurl a raw dashboard crop is unreadable and
 * never says the word "Flutter". So the screenshot is real — captured from the
 * running demo, not a mockup — but it sits in a composition that names the
 * thing.
 *
 * Usage:
 *   node scripts/social-preview.mjs
 *
 * Env:
 *   URL=…       demo to capture (default: the hosted demo)
 *   OUT=…       output path (default: docs/social-preview.png)
 *   SHOT=…      reuse an existing dashboard PNG instead of capturing
 *
 * Playwright is not a dependency of this repo — point at one that exists:
 *   PLAYWRIGHT_PATH="…/tailwind-templates/node_modules/playwright" \
 *     node scripts/social-preview.mjs
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');

const { chromium } = await import(
  process.env.PLAYWRIGHT_PATH
    ? pathToFileURL(resolve(process.env.PLAYWRIGHT_PATH, 'index.mjs')).href
    : 'playwright'
);

const URL_ = process.env.URL || 'https://demo.dashboardpack.com/kite/';
const OUT = resolve(ROOT, process.env.OUT || 'docs/social-preview.png');
const W = 1280, H = 640;
// GitHub's spec is 1280×640 and its hard limit is 1 MB. Rendering at 2x looked
// like free sharpness and produced a 963 KB file for no visible gain, since the
// image is never displayed above 1280 wide. Native resolution, like the other
// Colorlib repos.
const SCALE = Number(process.env.SCALE || 1);

const browser = await chromium.launch();

// ---- 1. the dashboard itself -------------------------------------------
let shot;
if (process.env.SHOT) {
  shot = readFileSync(resolve(process.env.SHOT));
} else {
  const p = await browser.newPage({
    viewport: { width: 1600, height: 1000 },
    deviceScaleFactor: 2,
  });
  p.setDefaultTimeout(120000);
  await p.goto(URL_, { waitUntil: 'load', timeout: 120000 });
  await p.waitForTimeout(14000);           // engine boot + chart entry animation
  if (p.url().includes('sign-in')) {
    // Flutter paints to a canvas, so there is no DOM button to click.
    await p.mouse.click(800, 601);
    await p.waitForTimeout(10000);
  }
  await p.mouse.move(1595, 995);           // park the cursor off the charts
  await p.waitForTimeout(2500);
  shot = await p.screenshot();
  await p.close();
}
const shotUri = `data:image/png;base64,${shot.toString('base64')}`;

// ---- 2. the composition -------------------------------------------------
const html = `<!doctype html><html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body {
    width:${W}px; height:${H}px; overflow:hidden; position:relative;
    background:#0B1120;
    font-family:'Geist', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
    -webkit-font-smoothing:antialiased;
  }
  /* one warm-cool glow behind the copy, so the panel is not a flat rectangle */
  .glow {
    position:absolute; left:-220px; top:-180px; width:820px; height:820px;
    background:radial-gradient(circle, rgba(13,148,136,.20) 0%, rgba(13,148,136,0) 62%);
  }
  .grid {
    position:absolute; inset:0; opacity:.35;
    background-image:linear-gradient(rgba(148,163,184,.06) 1px, transparent 1px),
                     linear-gradient(90deg, rgba(148,163,184,.06) 1px, transparent 1px);
    background-size:48px 48px;
  }
  .copy { position:absolute; left:64px; top:0; width:520px; height:100%;
          display:flex; flex-direction:column; justify-content:center; z-index:3; }
  .brand { display:flex; align-items:center; gap:13px; margin-bottom:30px; }
  .brand svg { width:34px; height:34px; }
  .brand span { font-size:34px; font-weight:600; color:#F8FAFC; letter-spacing:-.6px; }
  h1 { font-size:52px; line-height:1.06; font-weight:700; color:#F8FAFC;
       letter-spacing:-1.7px; text-wrap:balance; }
  h1 em { font-style:normal; color:#2DD4BF; }
  p  { margin-top:20px; font-size:20px; line-height:1.5; color:#94A3B8; max-width:470px; }
  .chips { margin-top:34px; display:flex; gap:9px; flex-wrap:wrap; }
  .chip { font-size:15px; font-weight:500; color:#CBD5E1; padding:7px 15px;
          border:1px solid rgba(148,163,184,.28); border-radius:999px;
          background:rgba(148,163,184,.07); }
  .chip.free { color:#5EEAD4; border-color:rgba(45,212,191,.42); background:rgba(45,212,191,.11); }

  /* the screenshot bleeds off the right edge — it is evidence, not decoration */
  .shot { position:absolute; left:626px; top:96px; width:790px; height:494px;
          border-radius:14px; overflow:hidden; z-index:2;
          border:1px solid rgba(148,163,184,.22);
          box-shadow:0 40px 90px rgba(0,0,0,.62), 0 0 0 1px rgba(255,255,255,.04) inset; }
  .shot img { width:132%; display:block; }   /* crop in: legibility beats completeness here */
  /* Fade the far edge into the background so the crop does not read as a mistake.
     Wide and multi-stop on purpose: a short hard ramp met the white cards as a
     blown-out band, which looked like a rendering fault rather than a choice. */
  .fade { position:absolute; right:0; top:0; width:290px; height:100%; z-index:4;
          background:linear-gradient(90deg,
            rgba(11,17,32,0)   0%,
            rgba(11,17,32,.35) 34%,
            rgba(11,17,32,.78) 66%,
            rgba(11,17,32,1)  100%); }
</style></head><body>
  <div class="grid"></div><div class="glow"></div>
  <div class="copy">
    <div class="brand">
      <svg viewBox="0 0 24 24" fill="none" stroke="#2DD4BF" stroke-width="2"
           stroke-linecap="round" stroke-linejoin="round"><path d="M12 4 L21 19 L3 19 Z"/></svg>
      <span>Kite</span>
    </div>
    <h1>The <em>Flutter</em> admin dashboard template</h1>
    <p>Web, iOS, Android, macOS and Windows &mdash; from one codebase.</p>
    <div class="chips">
      <div class="chip free">Free &amp; MIT</div>
      <div class="chip">22 screens</div>
      <div class="chip">Flutter 3.47</div>
    </div>
  </div>
  <div class="shot"><img src="${shotUri}"></div>
  <div class="fade"></div>
</body></html>`;

const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: SCALE });
await page.setContent(html, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(600);

mkdirSync(dirname(OUT), { recursive: true });
await page.screenshot({ path: OUT });
await browser.close();

const kb = (readFileSync(OUT).length / 1024).toFixed(0);
console.log(`social-preview: ${OUT} (${W * SCALE}×${H * SCALE}, ${kb} KB)`);
if (kb > 1000) console.warn('WARNING: over GitHub\'s 1 MB limit — lower SCALE.');

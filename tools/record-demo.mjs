#!/usr/bin/env node
/**
 * Captures the frames for the README demo.
 *
 * Flutter renders to a canvas, so Playwright's video recording and `fullPage`
 * screenshots both fall over. Frames are grabbed one at a time instead and
 * assembled by tools/build-gif.py.
 *
 *   node tools/record-demo.mjs build/web docs/frames
 */
import { chromium } from 'playwright';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const ROOT = path.resolve(process.argv[2] || 'build/web');
const OUT = path.resolve(process.argv[3] || 'docs/frames');
const W = 1280, H = 800;

const MIME = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.css': 'text/css',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.png': 'image/png',
};

const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/index.html';
  let f = path.join(ROOT, p);
  if (!fs.existsSync(f) || fs.statSync(f).isDirectory()) f = path.join(ROOT, 'index.html');
  res.writeHead(200, {
    'Content-Type': MIME[path.extname(f)] || 'application/octet-stream',
    'Content-Encoding': 'gzip',
  });
  res.end(zlib.gzipSync(fs.readFileSync(f), { level: 6 }));
});
await new Promise((r) => server.listen(0, r));
const port = server.address().port;

fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
const page = await ctx.newPage();

let n = 0;
const shot = async () =>
  page.screenshot({ path: path.join(OUT, `f${String(n++).padStart(3, '0')}.png`) });
/** Hold a still for `count` frames — cheaper than capturing motion. */
const hold = async (count = 4) => { for (let i = 0; i < count; i++) await shot(); };

await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle', timeout: 120000 });
await page.waitForTimeout(3500);

// Sign in
await page.mouse.click(W / 2, H / 2 + 104);
await page.waitForTimeout(2800);
await hold(6);                                   // dashboard

// Dark mode, and back
await page.mouse.click(W - 96, 30); await page.waitForTimeout(900); await hold(5);
await page.mouse.click(W - 96, 30); await page.waitForTimeout(900); await hold(2);

// Command palette
await page.keyboard.press('Control+k'); await page.waitForTimeout(1200); await hold(2);
await page.keyboard.type('lovelace', { delay: 55 });
await page.waitForTimeout(1200); await hold(5);
await page.keyboard.press('ArrowDown'); await page.waitForTimeout(200); await shot();
await page.keyboard.press('ArrowDown'); await page.waitForTimeout(200); await shot();
await page.keyboard.press('Enter'); await page.waitForTimeout(2000); await hold(5);

// Sidebar y-positions, in CSS px.
//
// The rail is a fixed 248px wide, so these hold at any viewport width — but
// every item is 42px and every group heading ~53px, so ADDING A NAV ITEM
// SHIFTS EVERYTHING BELOW IT. If the recording lands on the wrong screens,
// this is why. Order today:
//   Overview: Dashboard 122, Projects 165
//   Manage:   Orders 241, Customers 282, Products 325
//   Apps:     Inbox 401, Board 442, Calendar 485, Chat 526
//   Build:    Components 602, Forms 645, Wizard 686, Settings 729, Profile 770
const NAV = { orders: 241, board: 442, components: 602 };

// Orders table
await page.mouse.click(64, NAV.orders); await page.waitForTimeout(1800); await hold(5);

// Board, with a drag between columns
await page.mouse.click(64, NAV.board); await page.waitForTimeout(1800); await hold(3);
const src = { x: 400, y: 190 }, dst = { x: 700, y: 260 };
await page.mouse.move(src.x, src.y);
await page.mouse.down();
for (let i = 1; i <= 6; i++) {
  await page.mouse.move(src.x + ((dst.x - src.x) * i) / 6, src.y + ((dst.y - src.y) * i) / 6);
  await page.waitForTimeout(90);
  await shot();
}
await page.mouse.up(); await page.waitForTimeout(900); await hold(5);

// Components showcase
await page.mouse.click(64, NAV.components);
await page.waitForTimeout(2000);
await hold(6);

await browser.close();
server.close();
console.log(`captured ${n} frames at ${W}x${H} -> ${OUT}`);

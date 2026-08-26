// Spike A measurement: real browser transfer + LCP, wasm vs JS renderer.
import { chromium } from 'playwright';
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.argv[2];
const LABEL = process.argv[3] || 'build';
const THROTTLE = process.argv[4] === 'throttle';

const MIME = { '.html':'text/html','.js':'text/javascript','.mjs':'text/javascript',
  '.wasm':'application/wasm','.json':'application/json','.css':'text/css',
  '.ttf':'font/ttf','.otf':'font/otf','.png':'image/png','.ico':'image/x-icon' };

const server = http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/index.html';
  const f = path.join(ROOT, p);
  if (!f.startsWith(ROOT) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) {
    res.writeHead(404); return res.end('nf');
  }
  const body = fs.readFileSync(f);
  const gz = require('node:zlib');
  res.writeHead(200, { 'Content-Type': MIME[path.extname(f)] || 'application/octet-stream',
    'Content-Encoding':'gzip', 'Cross-Origin-Opener-Policy':'same-origin',
    'Cross-Origin-Embedder-Policy':'require-corp' });
  res.end(gz.gzipSync(body, { level: 6 }));
});
const { createRequire } = await import('node:module');
const require = createRequire(import.meta.url);

await new Promise(r => server.listen(0, r));
const port = server.address().port;

const browser = await chromium.launch({ args: ['--enable-features=WebAssemblyGarbageCollection'] });
const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await ctx.newPage();

const cdp = await ctx.newCDPSession(page);
await cdp.send('Network.enable');
if (THROTTLE) {
  // Fast 4G + 4x CPU slowdown
  await cdp.send('Network.emulateNetworkConditions', {
    offline: false, latency: 70, downloadThroughput: 9000*1024/8, uploadThroughput: 1500*1024/8 });
  await cdp.send('Emulation.setCPUThrottlingRate', { rate: 4 });
}

const seen = new Map();
cdp.on('Network.loadingFinished', e => seen.set(e.requestId, e.encodedDataLength));
const urls = new Map();
cdp.on('Network.responseReceived', e => urls.set(e.requestId, e.response.url));

const t0 = Date.now();
await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle', timeout: 120000 });
await page.waitForTimeout(2500);
const wall = Date.now() - t0;

const lcp = await page.evaluate(() => new Promise(res => {
  let v = 0;
  new PerformanceObserver(l => { for (const e of l.getEntries()) v = e.startTime; })
    .observe({ type: 'largest-contentful-paint', buffered: true });
  setTimeout(() => {
    const nav = performance.getEntriesByType('navigation')[0] || {};
    const fcp = performance.getEntriesByName('first-contentful-paint')[0];
    res({ lcp: v, fcp: fcp ? fcp.startTime : null, domContentLoaded: nav.domContentLoadedEventEnd });
  }, 600);
}));

let total = 0; const rows = [];
for (const [id, len] of seen) {
  const u = urls.get(id) || '?';
  total += len;
  rows.push([len, u.replace(`http://localhost:${port}/`, '')]);
}
rows.sort((a,b) => b[0]-a[0]);

console.log(`\n=== ${LABEL}${THROTTLE ? '  [Fast 4G + 4x CPU]' : '  [unthrottled]'} ===`);
console.log(`  requests: ${rows.length}   TRANSFER: ${(total/1048576).toFixed(2)} MB`);
console.log(`  FCP ${lcp.fcp?.toFixed(0)}ms   LCP ${lcp.lcp?.toFixed(0)}ms   wall ${wall}ms`);
console.log(`  top files:`);
for (const [len, u] of rows.slice(0, 8)) console.log(`    ${(len/1024).toFixed(0).padStart(7)}K  ${u}`);

await browser.close(); server.close();

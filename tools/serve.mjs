#!/usr/bin/env node
// Local preview server for a Flutter web build.
// `python3 -m http.server` will not do: it serves .wasm as octet-stream and
// the app refuses to boot.
//   node tools/serve.mjs [dir] [port]
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const ROOT = path.resolve(process.argv[2] || 'build/web');
const PORT = Number(process.argv[3] || 8722);
const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.json': 'application/json', '.css': 'text/css',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.png': 'image/png', '.ico': 'image/x-icon',
  '.svg': 'image/svg+xml',
};

http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/index.html';
  let f = path.join(ROOT, p);
  // Deep links (/orders) are client-side routes — fall back to the shell.
  if (!fs.existsSync(f) || fs.statSync(f).isDirectory()) f = path.join(ROOT, 'index.html');
  const accepts = (req.headers['accept-encoding'] || '').includes('gzip');
  const body = fs.readFileSync(f);
  const headers = { 'Content-Type': MIME[path.extname(f)] || 'application/octet-stream' };
  if (accepts) headers['Content-Encoding'] = 'gzip';
  res.writeHead(200, headers);
  res.end(accepts ? zlib.gzipSync(body, { level: 6 }) : body);
}).listen(PORT, () => {
  console.log(`Kite preview → http://localhost:${PORT}`);
  console.log(`serving ${ROOT}`);
});

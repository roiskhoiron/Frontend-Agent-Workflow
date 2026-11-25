#!/usr/bin/env node
// Usage: page-shot.mjs --url <url> --out <file.png> [--viewport 1280x800] [--full-page]
//                      [--targets targets.json] [--browser chromium|firefox|webkit] [--wait <ms>]
// Screenshot of a page at deviceScaleFactor 1. With --targets ([{"selector","label"}]) also writes
// <out without .png>.boxes.json = [{"x","y","w","h","label"}] in image pixels: input of annotate.py.
// Boxes come from the element's real position on the page, never guessed.
// Exit: 0 ok; 1 a selector was not found / outside the viewport (the rest is still written);
//       2 usage; 3 playwright not found, browser launch or navigation failed.
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';

const die = (code, msg) => { console.error('page-shot: ' + msg); process.exit(code); };
const USAGE = 'usage: page-shot.mjs --url <url> --out <file.png> [--viewport WxH] [--full-page] [--targets file.json] [--browser chromium|firefox|webkit] [--wait ms]';

const opt = { viewport: '1280x800', browser: 'chromium', wait: '0', fullPage: false };
const a = process.argv.slice(2);
for (let i = 0; i < a.length; i++) {
  const k = a[i];
  if (k === '--full-page') { opt.fullPage = true; continue; }
  const m = { '--url': 'url', '--out': 'out', '--viewport': 'viewport', '--targets': 'targets', '--browser': 'browser', '--wait': 'wait' }[k];
  if (!m || i + 1 >= a.length) die(2, USAGE);
  opt[m] = a[++i];
}
const vp = /^(\d+)x(\d+)$/.exec(opt.viewport);
if (!opt.url || !opt.out || !vp || !/^\d+$/.test(opt.wait) || !['chromium', 'firefox', 'webkit'].includes(opt.browser)) die(2, USAGE);

let targets = [];
if (opt.targets) {
  try {
    targets = JSON.parse(readFileSync(opt.targets, 'utf8'));
    if (!Array.isArray(targets) || targets.some(t => !t || typeof t.selector !== 'string' || !t.selector)) throw new Error('need [{"selector","label"}]');
  } catch (e) { die(2, `targets tidak valid: ${e.message}`); }
}

async function loadPlaywright() {
  try { return await import('playwright'); } catch {}
  const cands = [process.env.PLAYWRIGHT_MODULE, ...(process.env.NODE_PATH || '').split(path.delimiter).filter(Boolean).map(p => path.join(p, 'playwright')),
    '/opt/node-tools/node_modules/playwright', '/usr/local/lib/node_modules/playwright', '/opt/homebrew/lib/node_modules/playwright',
    path.join(process.cwd(), 'node_modules/playwright')].filter(Boolean);
  const req = createRequire(import.meta.url);
  for (const c of cands) { try { return req(c); } catch {} }
  return null;
}

const pw = await loadPlaywright();
if (!pw) die(3, 'playwright tidak ditemukan (pasang di project, atau set PLAYWRIGHT_MODULE ke foldernya)');

let browser, rc = 0, err = null;
try {
  browser = await pw[opt.browser].launch();
  const page = await browser.newPage({ viewport: { width: +vp[1], height: +vp[2] }, deviceScaleFactor: 1 });
  try { await page.goto(opt.url, { waitUntil: 'load' }); } catch (e) { throw new Error(`navigasi gagal: ${e.message.split('\n')[0]}`); }
  if (+opt.wait) await page.waitForTimeout(+opt.wait);
  const boxes = [];
  for (const t of targets) {
    const label = String(t.label ?? '');
    const loc = page.locator(t.selector).first();
    if (!(await loc.count())) { console.error(`selector tidak ketemu: ${t.selector}`); rc = 1; continue; }
    let b = await loc.boundingBox();
    if (!b) { console.error(`elemen tidak terlihat: ${t.selector}`); rc = 1; continue; }
    if (opt.fullPage) {
      const s = await page.evaluate(() => ({ x: window.scrollX, y: window.scrollY }));
      b = { ...b, x: b.x + s.x, y: b.y + s.y };
    } else if (b.x + b.width <= 0 || b.y + b.height <= 0 || b.x >= +vp[1] || b.y >= +vp[2]) {
      console.error(`elemen di luar viewport, dilewati: ${t.selector}`); rc = 1; continue;
    }
    boxes.push({ x: Math.max(0, Math.round(b.x)), y: Math.max(0, Math.round(b.y)), w: Math.round(b.width), h: Math.round(b.height), label });
  }
  await page.screenshot({ path: opt.out, fullPage: opt.fullPage });
  if (opt.targets) writeFileSync(opt.out.replace(/\.png$/i, '') + '.boxes.json', JSON.stringify(boxes, null, 1) + '\n');
} catch (e) {
  err = e.message.split('\n')[0];
} finally {
  if (browser) await browser.close().catch(() => {});
}
if (err) die(3, err);
process.exit(rc);

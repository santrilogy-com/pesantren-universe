// Render lembar konsep Surau v2 (SVG -> PNG) via chrome-headless-shell (Remotion cache).
// Pakai: node render.mjs
import puppeteer from 'puppeteer-core';

const SHELL = '/home/hatch/workspace/pesantren-verse/video-hari-ke-1/node_modules/.remotion/chrome-headless-shell/linux64/chrome-headless-shell-linux64/chrome-headless-shell';
const SVG = 'file:///home/hatch/workspace/pesantren-verse/v2/konsep/bangunan/surau-v2-konsep.svg';
const OUT = '/home/hatch/workspace/pesantren-verse/v2/konsep/bangunan/surau-v2-konsep.png';

const browser = await puppeteer.launch({
  executablePath: SHELL,
  headless: true,
  args: ['--no-sandbox', '--disable-gpu', '--enable-unsafe-swiftshader',
         '--use-angle=swiftshader', '--window-size=1080,2600', '--hide-scrollbars'],
});
const page = await browser.newPage();
await page.setViewport({ width: 1080, height: 2600, deviceScaleFactor: 2 });
page.on('pageerror', e => console.log('[pageerror]', e.message));
await page.goto(SVG, { waitUntil: 'load', timeout: 60000 });
await new Promise(r => setTimeout(r, 1500));
await page.screenshot({ path: OUT });
await browser.close();
console.log('SELESAI ->', OUT);

// Probe fokus: kenapa seek ke 25 dtk mereset posisi ke 0?
// Langkah: boot -> klik Muat (lewat Godot, setup sama) -> seek langsung
// lewat JS (bypass Godot) ke 25 / 15 / 5, catat currentTime, seeking,
// readyState, buffered, seekable, error + event seeking/seeked/stalled.
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const puppeteer = require('/home/hatch/workspace/tools/shot/node_modules/puppeteer-core');
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const EXE = '/home/hatch/.cache/puppeteer/chrome-headless-shell/linux-157.0.8103.78/chrome-headless-shell-linux64/chrome-headless-shell';

(async () => {
  const browser = await puppeteer.launch({
    executablePath: EXE,
    headless: true,
    args: ['--no-sandbox', '--disable-gpu', '--enable-unsafe-swiftshader', '--use-gl=angle', '--use-angle=swiftshader', '--window-size=1280,720'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 720, deviceScaleFactor: 1 });
  page.on('console', (m) => { if (m.text().includes('[SPIKE') || m.text().includes('[SpikeVideo')) console.log('CONSOLE:', m.text()); });
  await page.goto('http://127.0.0.1:8932/index.html', { waitUntil: 'load', timeout: 60000 });
  await page.waitForFunction(() => window.__pv_spike_siap === true, { timeout: 90000 });
  await sleep(1000);
  const rect = await page.evaluate(() => { const r = document.getElementById('canvas').getBoundingClientRect(); return { left: r.left, top: r.top }; });
  await page.mouse.click(rect.left + 160, rect.top + 82); // Muat
  await sleep(3000);

  await page.evaluate(() => {
    const v = window.__pv_video;
    window.__pv_probe_log = [];
    ['seeking', 'seeked', 'stalled', 'waiting', 'canplay', 'canplaythrough', 'error', 'emptied', 'loadstart', 'progress', 'suspend'].forEach((ev) => {
      v.addEventListener(ev, () => window.__pv_probe_log.push(ev + '@' + v.currentTime.toFixed(2)));
    });
  });

  const sampel = () => page.evaluate(() => {
    const v = window.__pv_video;
    const buf = [];
    for (let i = 0; i < v.buffered.length; i++) buf.push([+v.buffered.start(i).toFixed(1), +v.buffered.end(i).toFixed(1)]);
    const sk = [];
    for (let i = 0; i < v.seekable.length; i++) sk.push([+v.seekable.start(i).toFixed(1), +v.seekable.end(i).toFixed(1)]);
    return { t: +v.currentTime.toFixed(2), seeking: v.seeking, paused: v.paused, readyState: v.readyState, networkState: v.networkState, durasi: v.duration, buffered: buf, seekable: sk, error: v.error ? v.error.code : null, log: window.__pv_probe_log.splice(0) };
  });

  async function ujiSeek(target) {
    console.log('== SEEK ke ' + target + ' ==');
    await page.evaluate((t) => { window.__pv_video.currentTime = t; }, target);
    for (let i = 0; i < 6; i++) {
      await sleep(500);
      console.log(JSON.stringify(await sampel()));
    }
  }

  await ujiSeek(25);
  await ujiSeek(15);
  await ujiSeek(5);
  await browser.close();
})().catch((e) => { console.error('FATAL:', e); process.exit(2); });

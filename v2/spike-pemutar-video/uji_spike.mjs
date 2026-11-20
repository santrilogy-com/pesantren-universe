// Uji spike pemutar video di browser sungguhan (chrome-headless-shell).
// Alur: boot game -> Muat -> (autoplay tanpa gestur harus DITOLAK) ->
// Putar 6 dtk -> Jeda (posisi diam) -> Seek 25 (gate TIDAK nambah) ->
// Putar sampai habis -> Seek 5 -> Putar sampai gate 80% tercapai ->
// Sembunyikan/Tampilkan -> Layar penuh -> laporan JSON + screenshot.
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const puppeteer = require('/home/hatch/workspace/tools/shot/node_modules/puppeteer-core');
const fs = require('fs');

const EXE = '/home/hatch/.cache/puppeteer/chrome-headless-shell/linux-157.0.8103.78/chrome-headless-shell-linux64/chrome-headless-shell';
const URL = 'http://127.0.0.1:8932/index.html';
const OUT = '/home/hatch/workspace/pesantren-verse/v2/spike-pemutar-video/hasil-uji/';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

fs.mkdirSync(OUT, { recursive: true });
const hasil = { langkah: [], gagal: [] };
function catat(nama, data) {
  const entri = { nama, waktu: new Date().toISOString(), ...data };
  hasil.langkah.push(entri);
  console.log('## ' + nama + ':', JSON.stringify(data));
}

async function klik(page, rect, x, y) {
  await page.mouse.click(rect.left + x, rect.top + y);
}

(async () => {
  const browser = await puppeteer.launch({
    executablePath: EXE,
    headless: true,
    args: ['--no-sandbox', '--disable-gpu', '--enable-unsafe-swiftshader', '--use-gl=angle', '--use-angle=swiftshader', '--window-size=1280,720'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 720, deviceScaleFactor: 1 });
  const consoleLog = [];
  page.on('console', (m) => { const t = m.text(); consoleLog.push(m.type() + ': ' + t); if (t.includes('[SPIKE') || t.includes('[SpikeVideo')) console.log('CONSOLE:', t); });
  page.on('pageerror', (e) => { consoleLog.push('PAGEERROR: ' + e.message); console.log('PAGEERROR:', e.message); });

  await page.goto(URL, { waitUntil: 'load', timeout: 60000 });
  // Tunggu engine Godot boot + spike siap.
  try {
    await page.waitForFunction(() => window.__pv_spike_siap === true, { timeout: 90000 });
    catat('boot-game', { siap: true });
  } catch (e) {
    catat('boot-game', { siap: false, galat: 'timeout 90 dtk menunggu __pv_spike_siap' });
    await page.screenshot({ path: OUT + '00-boot-gagal.png' });
    fs.writeFileSync(OUT + 'hasil-uji.json', JSON.stringify({ hasil, consoleLog }, null, 2));
    await browser.close();
    process.exit(1);
  }
  await sleep(1000);
  await page.screenshot({ path: OUT + '01-awal.png' });
  const rect = await page.evaluate(() => {
    const c = document.getElementById('canvas');
    const r = c.getBoundingClientRect();
    return { left: r.left, top: r.top, width: r.width, height: r.height };
  });
  catat('canvas-rect', rect);

  const bacaState = () => page.evaluate(() => {
    const v = window.__pv_video;
    if (!v) return { ada: false };
    return { ada: true, durasi: v.duration, posisi: v.currentTime, ditonton: window.__pv_watched, jeda: v.paused, berakhir: v.ended, tampil: v.style.display !== 'none', autoplay: window.__pv_autoplay, src: v.currentSrc };
  });
  const bacaLabel = () => page.evaluate(() => {
    // Baca teks label Godot tidak bisa dari DOM; ambil dari state JS saja.
    return { fullscreenElement: !!document.fullscreenElement };
  });

  // Tombol (koordinat dalam canvas 1280x720): x=160, y = tombol_y + 22.
  const T = { muat: 82, putar: 136, jeda: 190, seek25: 244, seek5: 298, sembunyi: 352, tampil: 406, fullscreen: 460, hapus: 514 };

  // 1. Muat video.
  await klik(page, rect, 160, T.muat);
  await sleep(3000);
  let s = await bacaState();
  catat('muat-video', s);
  if (!s.ada) hasil.gagal.push('elemen video tidak muncul sesudah klik Muat');
  if (s.durasi && Math.abs(s.durasi - 30) > 1) hasil.gagal.push('durasi bukan ~30 dtk: ' + s.durasi);
  if (s.autoplay) {
    if (s.autoplay.ok === false) catat('autoplay-tanpa-gestur', { ditolak: true, err: s.autoplay.err });
    else { catat('autoplay-tanpa-gestur', { ditolak: false, ok: s.autoplay.ok }); hasil.gagal.push('play() tanpa gestur TIDAK ditolak (autoplay=' + JSON.stringify(s.autoplay) + ')'); }
  } else {
    catat('autoplay-tanpa-gestur', { ditolak: 'belum-tercatat', catatan: 'metadata mungkin belum sempat memicu uji autoplay' });
  }
  await page.screenshot({ path: OUT + '02-video-dimuat.png' });

  // 2. Putar 6 detik.
  await klik(page, rect, 160, T.putar);
  await sleep(6000);
  s = await bacaState();
  catat('putar-6dtk', s);
  if (s.jeda) hasil.gagal.push('video masih jeda sesudah klik Putar');
  if (!(s.posisi > 2)) hasil.gagal.push('posisi tidak maju sesudah 6 dtk putar: ' + s.posisi);
  if (!(s.ditonton > 2)) hasil.gagal.push('ditonton kumulatif tidak naik: ' + s.ditonton);
  await page.screenshot({ path: OUT + '03-sedang-memutar.png' });

  // 3. Jeda — posisi harus diam.
  await klik(page, rect, 160, T.jeda);
  await sleep(1000);
  const pA = (await bacaState()).posisi;
  await sleep(1500);
  const pB = (await bacaState()).posisi;
  catat('jeda-posisi-diam', { posisiA: pA, posisiB: pB, diam: Math.abs(pA - pB) < 0.05 });
  if (Math.abs(pA - pB) >= 0.05) hasil.gagal.push('posisi tetap bergerak saat jeda: ' + pA + ' -> ' + pB);

  // 4. Seek ke 25 — gate TIDAK boleh nambah.
  const ditontonSebelumSeek = (await bacaState()).ditonton;
  await klik(page, rect, 160, T.seek25);
  await sleep(1500);
  s = await bacaState();
  catat('seek-25', { ...s, ditontonSebelumSeek, selisihDitonton: s.ditonton - ditontonSebelumSeek });
  if (Math.abs(s.posisi - 25) > 1) hasil.gagal.push('seek ke 25 gagal, posisi=' + s.posisi);
  if (s.ditonton - ditontonSebelumSeek > 0.5) hasil.gagal.push('seek maju MENAMBAH hitungan gate: +' + (s.ditonton - ditontonSebelumSeek));

  // 5. Putar sampai habis (25 -> 30).
  await klik(page, rect, 160, T.putar);
  await sleep(6000);
  s = await bacaState();
  catat('putar-sampai-habis', s);
  if (!s.berakhir && s.posisi < 26) hasil.gagal.push('video tidak sampai akhir: posisi=' + s.posisi);

  // 6. Seek 5 + putar sampai gate 80% (butuh 24 dtk kumulatif).
  await klik(page, rect, 160, T.seek5);
  await sleep(1000);
  await klik(page, rect, 160, T.putar);
  let tercapai = false;
  for (let i = 0; i < 15; i++) {
    await sleep(2000);
    s = await bacaState();
    if (s.ditonton >= 24) { tercapai = true; break; }
    if (s.berakhir) break;
  }
  catat('gate-80-persen', { ...s, tercapai, butuhDetik: 24 });
  if (!tercapai) hasil.gagal.push('gate 80% tidak tercapai, ditonton=' + s.ditonton);
  await page.screenshot({ path: OUT + '04-gate-tercapai.png' });

  // 7. Sembunyikan / tampilkan.
  await klik(page, rect, 160, T.sembunyi);
  await sleep(800);
  s = await bacaState();
  catat('sembunyikan', { tampil: s.tampil });
  if (s.tampil) hasil.gagal.push('video masih tampil sesudah Sembunyikan');
  await klik(page, rect, 160, T.tampil);
  await sleep(800);
  s = await bacaState();
  catat('tampilkan', { tampil: s.tampil });
  if (!s.tampil) hasil.gagal.push('video tidak tampil lagi sesudah Tampilkan');

  // 8. Layar penuh (di headless kemungkinan ditolak — dicatat, bukan gagal keras).
  await klik(page, rect, 160, T.fullscreen);
  await sleep(1500);
  const fsState = await bacaLabel();
  catat('layar-penuh', fsState);
  if (fsState.fullscreenElement) { await page.keyboard.press('Escape'); await sleep(500); }

  await page.screenshot({ path: OUT + '05-akhir.png' });
  hasil.ringkasan = hasil.gagal.length === 0 ? 'SEMUA UJI LOLOS' : 'ADA ' + hasil.gagal.length + ' KEGAGALAN';
  fs.writeFileSync(OUT + 'hasil-uji.json', JSON.stringify({ hasil, consoleLog }, null, 2));
  console.log('RINGKASAN:', hasil.ringkasan);
  if (hasil.gagal.length) console.log('GAGAL:', JSON.stringify(hasil.gagal, null, 2));
  await browser.close();
  process.exit(hasil.gagal.length === 0 ? 0 : 1);
})().catch((e) => { console.error('FATAL:', e); process.exit(2); });

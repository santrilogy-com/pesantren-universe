// Bukti boot chunked-pck (dan chunked-wasm) — headless, tanpa browser.
// Mengeksekusi patch fetch PERSIS seperti yang disisipkan stage_v2.py ke
// index.html, dengan fetch asli yang membaca file dari direktori staging,
// lalu memverifikasi hash rakitan (pck + wasm) terhadap hash file asli.
// Pola konsumsi meniru engine Godot (Preloader.getTrackedResponse):
//   - fetch pertama dibaca lewat response.body.getReader() sampai habis
//     (stream), bukan cuma arrayBuffer()
//   - fetch kedua (clone dari promise yang di-cache — jalur retry preloader)
//     dibaca lewat arrayBuffer()
//   - URL absolut (https://.../index.pck) juga diuji, karena engine bisa
//     memanggil fetch dengan URL penuh; intersepsi memakai endsWith()
//   - URL yang tidak diintersepsi (index.js) harus lolos ke fetch asli
// Usage: node test_chunked_boot.mjs <staging-dir> <expected-pck-sha256> <expected-wasm-sha256>
import { createHash } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';

const [stagingDir, expectedPckSha, expectedWasmSha, expectedPckSize] = process.argv.slice(2);
if (!stagingDir || !expectedPckSha || !expectedWasmSha || !expectedPckSize) {
  console.error('Usage: node test_chunked_boot.mjs <staging-dir> <pck-sha256> <wasm-sha256> <pck-size-bytes>');
  process.exit(2);
}

const sha256 = (buf) => createHash('sha256').update(buf).digest('hex');
let failures = 0;
function check(name, ok, detail = '') {
  console.log(`${ok ? 'LULUS' : 'GAGAL'}: ${name}${detail ? ' — ' + detail : ''}`);
  if (!ok) failures++;
}

// 1. ambil blok patch dari staged index.html (marker yang sama dengan stage_v2.py)
const html = await readFile(path.join(stagingDir, 'index.html'), 'utf-8');
const startMarker = '// Pesantren Universe: chunked wasm loader.';
const start = html.indexOf(startMarker);
const endMarker = '})();\n</script>';
const end = html.indexOf(endMarker, start);
check('blok patch ditemukan di index.html', start >= 0 && end > start);
if (start < 0 || end <= start) process.exit(1);
const scriptOpen = html.lastIndexOf('<script>', start);
const patchCode = html.slice(scriptOpen + '<script>'.length, end + '})();'.length);
check('guard: 3 <script> / 3 </script> di index.html',
  (html.match(/<script/g) || []).length === 3 && (html.match(/<\/script>/g) || []).length === 3);
check('patch menyebut pck/part-01.bin', patchCode.includes('pck/part-01.bin'));
check('patch menyebut wasm/part-04.bin', patchCode.includes('wasm/part-04.bin'));

// 2. fetch asli: baca file dari staging (URL relatif maupun absolut)
async function origFetch(input) {
  let url = typeof input === 'string' ? input : (input && input.url) || '';
  if (url.startsWith('http://') || url.startsWith('https://')) {
    url = new URL(url).pathname.replace(/^\//, '');
  }
  const file = path.join(stagingDir, decodeURIComponent(url));
  try {
    const data = await readFile(file);
    return new Response(data, { status: 200, headers: { 'Content-Type': 'application/octet-stream' } });
  } catch {
    return new Response('not found: ' + url, { status: 404 });
  }
}

// 3. eksekusi patch persis seperti di browser (window.fetch diganti)
const window = { fetch: origFetch };
eval(patchCode); // patch meng-override window.fetch

async function readStreamFully(response) {
  const reader = response.body.getReader();
  const chunks = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    total += value.byteLength;
  }
  const out = new Uint8Array(total);
  let off = 0;
  for (const c of chunks) { out.set(c, off); off += c.byteLength; }
  return out;
}

// 4a. pck — fetch pertama, dibaca via stream (pola Preloader.getTrackedResponse)
const r1 = await window.fetch('index.pck');
check('fetch index.pck ok', r1.ok, 'status ' + r1.status);
const pckStreamed = await readStreamFully(r1);
check('pck rakitan (stream) sha = pck asli', sha256(pckStreamed) === expectedPckSha,
  sha256(pckStreamed).slice(0, 16) + '... vs ' + expectedPckSha.slice(0, 16) + '...');
check('pck rakitan ukuran = ' + Number(expectedPckSize).toLocaleString('en-US') + ' B', pckStreamed.byteLength === Number(expectedPckSize),
  pckStreamed.byteLength + ' B');
check('pck rakitan magic GDPC', Buffer.from(pckStreamed.slice(0, 4)).toString('latin1') === 'GDPC');

// 4b. pck — fetch kedua (clone dari cache; jalur retry preloader), via arrayBuffer
const r2 = await window.fetch('index.pck');
const pckAgain = new Uint8Array(await r2.arrayBuffer());
check('pck rakitan (fetch ke-2/clone) sha = pck asli', sha256(pckAgain) === expectedPckSha);

// 4c. pck — URL absolut (engine bisa memanggil fetch dengan URL penuh)
const r2b = await window.fetch('https://pesantren-verse-v2.pages.dev/index.pck');
const pckAbs = new Uint8Array(await r2b.arrayBuffer());
check('pck rakitan (URL absolut) sha = pck asli', sha256(pckAbs) === expectedPckSha);

// 5. wasm — fetch + stream, hash vs wasm asli
const r3 = await window.fetch('index.wasm');
check('fetch index.wasm ok', r3.ok, 'status ' + r3.status);
check('wasm content-type application/wasm', (r3.headers.get('content-type') || '').includes('application/wasm'),
  r3.headers.get('content-type'));
const wasmStreamed = await readStreamFully(r3);
check('wasm rakitan (stream) sha = wasm asli', sha256(wasmStreamed) === expectedWasmSha,
  sha256(wasmStreamed).slice(0, 16) + '... vs ' + expectedWasmSha.slice(0, 16) + '...');
check('wasm rakitan magic \\0asm', wasmStreamed[0] === 0x00 && wasmStreamed[1] === 0x61 && wasmStreamed[2] === 0x73 && wasmStreamed[3] === 0x6d);

// 6. passthrough: file lain tidak diintersepsi
const r4 = await window.fetch('index.js');
const jsReal = await stat(path.join(stagingDir, 'index.js'));
const jsBody = new Uint8Array(await r4.arrayBuffer());
check('fetch index.js lolos ke fetch asli', r4.ok && jsBody.byteLength === jsReal.size,
  jsBody.byteLength + ' B vs ' + jsReal.size + ' B');

console.log(failures === 0 ? 'BOOT-CHECK: SEMUA LULUS' : `BOOT-CHECK: ${failures} GAGAL`);
process.exit(failures === 0 ? 0 : 1);

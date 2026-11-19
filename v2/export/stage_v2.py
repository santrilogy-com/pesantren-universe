#!/usr/bin/env python3
"""Re-stage v2 export/web -> v2/export/web-pages untuk Cloudflare Pages.
- menyalin semua file kecuali index.wasm dan index.pck
- memotong ulang index.wasm jadi wasm/part-XX.bin (8_844_228 B tiap chunk)
- memotong ulang index.pck jadi pck/part-XX.bin (PCK_CHUNKS_N = 2 chunk
  sama besar, ~13.914.822 B tiap chunk — di bawah batas 25 MiB
  Cloudflare Pages; pck 27.829.644 B / 26,54 MiB tidak bisa di-upload utuh)
- menyisipkan patch chunked fetch (wasm + pck, SATU blok <script>,
  pola yang sama persis dengan patch chunked-wasm yang sudah terbukti
  live) sebelum <script src="index.js">
- splash loading screen (ACC Mas 19 Nov 15:01, varian C Karakter):
  salin splash-landscape.png + splash-portrait.png dari konsep ke staging
  + sisipkan pemilih orientasi (portrait -> portrait, landscape ->
  landscape, swap saat diputar) + latar overlay/body #043B2C
- verifikasi: rakitan chunk sha cocok (wasm + pck), guard 4 script,
  fileSizes pck, worklet 2.973 B, TIDAK ADA file > 24 MiB di staging,
  index.pck utuh TIDAK ada di staging, splash ada + pemilih ada
- bukti boot: menjalankan test_chunked_boot.mjs (Node) yang mengeksekusi
  patch persis seperti di index.html dan memverifikasi hash rakitan
  (pck + wasm) dengan pola konsumsi engine (stream reader + clone)
Jalankan: ~/workspace/.venv-cloudflare/bin/python stage_v2.py
"""
import hashlib
import json
import os
import shutil
import subprocess
import sys

SRC = os.path.expanduser("~/workspace/pesantren-verse/v2/export/web")
DST = os.path.expanduser("~/workspace/pesantren-verse/v2/export/web-pages")
EXPORT_DIR = os.path.expanduser("~/workspace/pesantren-verse/v2/export")
SPLASH_DIR = os.path.expanduser("~/workspace/pesantren-verse/v2/konsep")
# Sumber tunggal gambar splash: file konsep (bukan salinan res:// — isinya sama,
# tapi konsep adalah yang Mas ACC). Nama staging: splash-landscape/portrait.
SPLASH_FILES = {
    "splash-landscape.png": "konsep-splash-c-karakter.png",
    "splash-portrait.png": "konsep-splash-c-karakter-portrait.png",
}
CHUNK_WASM = 8844228
PCK_CHUNKS_N = 2  # naikkan bila pck melewati ~48 MiB (2 x 24 MiB)
MAX_FILE = 25_165_824  # 24 MiB — batas aman di bawah 25 MiB Cloudflare Pages

# Template patch fetch (SATU blok <script>). Chunk list di-render dari hasil
# pemotongan export ini, jadi jumlah chunk selalu mengikuti ukuran file.
# Pola = patch chunked-wasm yang sudah terbukti live: intersepsi window.fetch,
# unduh chunk, rakit ulang, kembalikan Response (clone per request).
PATCH_TEMPLATE = """\t\t<script>
// Pesantren Universe: chunked wasm loader.
// Cloudflare Pages menolak file di atas 25 MiB, sedangkan index.wasm ~39,5 MB,
// jadi wasm dipotong jadi 5 chunk di wasm/ (masing-masing ~8,4 MB).
// Engine Godot memuat 'index.wasm' lewat window.fetch; patch ini mencegat
// request itu, mengunduh kelima chunk, merakitnya kembali, lalu mengembalikan
// Response dengan Content-Type application/wasm agar instantiateStreaming jalan.
// Pesantren Universe: chunked pck loader (pola yang sama).
// index.pck 27,8 MB (26,54 MiB) juga melewati batas 25 MiB, jadi dipotong jadi
// 2 chunk di pck/ (~13,9 MB tiap chunk). Engine memuat 'index.pck' lewat
// window.fetch juga (Preloader.loadFetch -> getTrackedResponse -> arrayBuffer),
// jadi intersepsi yang sama berlaku; tanpa Content-Type khusus.
(function () {
\tvar origFetch = window.fetch.bind(window);
\tvar WASM_CHUNKS = __WASM_CHUNKS__;
\tvar PCK_CHUNKS = __PCK_CHUNKS__;
\tvar wasmResponse = null;
\tvar pckResponse = null;
\tfunction loadChunks(chunks, contentType) {
\t\treturn Promise.all(chunks.map(function (c) {
\t\t\treturn origFetch(c).then(function (r) {
\t\t\t\tif (!r.ok) throw new Error('Failed loading chunk ' + c);
\t\t\t\treturn r.arrayBuffer();
\t\t\t});
\t\t})).then(function (parts) {
\t\t\tvar total = parts.reduce(function (n, p) { return n + p.byteLength; }, 0);
\t\t\tvar buf = new Uint8Array(total);
\t\t\tvar off = 0;
\t\t\tparts.forEach(function (p) { buf.set(new Uint8Array(p), off); off += p.byteLength; });
\t\t\tvar init = contentType ? { headers: { 'Content-Type': contentType } } : {};
\t\t\treturn new Response(buf, init);
\t\t});
\t}
\twindow.fetch = function (input, init) {
\t\tvar url = typeof input === 'string' ? input : (input && input.url) || '';
\t\tif (url.endsWith('index.wasm')) {
\t\t\tif (!wasmResponse) {
\t\t\t\twasmResponse = loadChunks(WASM_CHUNKS, 'application/wasm');
\t\t\t}
\t\t\treturn wasmResponse.then(function (r) { return r.clone(); });
\t\t}
\t\tif (url.endsWith('index.pck')) {
\t\t\tif (!pckResponse) {
\t\t\t\tpckResponse = loadChunks(PCK_CHUNKS, null);
\t\t\t}
\t\t\treturn pckResponse.then(function (r) { return r.clone(); });
\t\t}
\t\treturn origFetch(input, init);
\t};
})();
</script>"""

# Pemilih splash loading screen (SATU blok <script> sendiri — guard script
# di bawah dihitung 4, dan harness test_chunked_boot.mjs ikut diperbarui).
# Dijalankan segera saat parser mencapai blok ini (SEBELUM paint pertama),
# lalu swap lagi bila device diputar saat loading. Gambar default img adalah
# index.png (landscape, hasil export boot splash); pemilih menimpa src ke
# file eksplisit supaya tidak bergantung pada isi index.png.
SPLASH_SCRIPT = """\t\t<script>
// Pesantren Universe: splash loading screen orientasi (ACC Mas 19 Nov 15:01,
// varian C Karakter). Layar loading web memilih gambar sesuai orientasi device:
// portrait -> splash-portrait.png (judul melengkung), landscape ->
// splash-landscape.png. Latar overlay #043B2C (CSS diganti di bawah).
(function () {
\tvar img = document.getElementById('status-splash');
\tif (!img) return;
\tfunction pilih() {
\t\tvar src = (window.innerWidth < window.innerHeight) ? 'splash-portrait.png' : 'splash-landscape.png';
\t\tif (img.getAttribute('src') !== src) img.setAttribute('src', src);
\t}
\tpilih();
\twindow.addEventListener('resize', pilih);
\twindow.addEventListener('orientationchange', pilih);
})();
</script>"""


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def sha256_of_parts(parts):
    h = hashlib.sha256()
    for p in parts:
        with open(p, "rb") as f:
            for b in iter(lambda: f.read(1 << 20), b""):
                h.update(b)
    return h.hexdigest()


def split_file(src_path, out_dir, chunk_size, prefix):
    shutil.rmtree(out_dir, ignore_errors=True)
    os.makedirs(out_dir, exist_ok=True)
    parts = []
    with open(src_path, "rb") as f:
        i = 0
        while True:
            data = f.read(chunk_size)
            if not data:
                break
            p = os.path.join(out_dir, "%s-%02d.bin" % (prefix, i))
            with open(p, "wb") as out:
                out.write(data)
            assert os.path.getsize(p) < MAX_FILE, "chunk %s melewati batas 24 MiB" % p
            parts.append(p)
            i += 1
    return parts


# 1. salin semua file kecuali index.wasm dan index.pck
for name in os.listdir(SRC):
    if name in ("index.wasm", "index.pck"):
        continue
    s = os.path.join(SRC, name)
    if os.path.isdir(s):
        continue
    shutil.copy2(s, os.path.join(DST, name))
# pastikan tidak ada sisa file besar dari staging lama
for stale in ("index.wasm", "index.pck"):
    p = os.path.join(DST, stale)
    if os.path.exists(p):
        os.remove(p)
        print("hapus staging lama:", stale)

# 1b. salin splash landscape+portrait dari konsep (sumber tunggal gambar)
for dst_name, src_name in SPLASH_FILES.items():
    s = os.path.join(SPLASH_DIR, src_name)
    d = os.path.join(DST, dst_name)
    assert os.path.exists(s), "splash sumber hilang: %s" % s
    shutil.copy2(s, d)
    print("splash:", dst_name, os.path.getsize(d), "B sha256", sha256(d)[:16])

# 2. potong wasm + pck
wasm_path = os.path.join(SRC, "index.wasm")
wasm_parts = split_file(wasm_path, os.path.join(DST, "wasm"), CHUNK_WASM, "part")
print("wasm chunks:", [(os.path.basename(p), os.path.getsize(p)) for p in wasm_parts])
wasm_sha = sha256_of_parts(wasm_parts)
print("reassembled wasm sha256:", wasm_sha)
assert wasm_sha == sha256(wasm_path), "rakitan chunk wasm tidak cocok"

pck_path = os.path.join(SRC, "index.pck")
pck_size = os.path.getsize(pck_path)
pck_chunk = (pck_size + PCK_CHUNKS_N - 1) // PCK_CHUNKS_N
pck_parts = split_file(pck_path, os.path.join(DST, "pck"), pck_chunk, "part")
print("pck chunks:", [(os.path.basename(p), os.path.getsize(p)) for p in pck_parts])
assert len(pck_parts) == PCK_CHUNKS_N, "jumlah chunk pck bukan %d" % PCK_CHUNKS_N
pck_sha = sha256_of_parts(pck_parts)
print("reassembled pck sha256:", pck_sha)
assert pck_sha == sha256(pck_path), "rakitan chunk pck tidak cocok"

# 3. render patch + sisipkan ke index.html baru
wasm_list = json.dumps(["wasm/" + os.path.basename(p) for p in wasm_parts])
pck_list = json.dumps(["pck/" + os.path.basename(p) for p in pck_parts])
patch = PATCH_TEMPLATE.replace("__WASM_CHUNKS__", wasm_list).replace("__PCK_CHUNKS__", pck_list)
assert patch.count("<script") == 1 and patch.count("</script>") == 1, "blok patch tak terduga"

new_html_path = os.path.join(DST, "index.html")
with open(new_html_path, "r", encoding="utf-8") as f:
    html = f.read()
anchor = '\t\t<script src="index.js"></script>'
assert anchor in html, "anchor index.js tidak ketemu"
assert "chunked wasm loader" not in html, "patch sudah ada"
# 3a. splash orientasi + latar #043B2C (SEBELUM patch — pemilih jalan sedini
# mungkin; index.html diregenerasi tiap export, jadi dibakar di sini)
assert "splash loading screen orientasi" not in html, "splash sudah ada"
assert 'src="index.png"' in html, "img status-splash tidak ketemu"
html = html.replace(anchor, SPLASH_SCRIPT + "\n" + anchor, 1)
assert "#242424" in html, "bg #status #242424 tidak ketemu"
html = html.replace("#status {\n\tbackground-color: #242424;", "#status {\n\tbackground-color: #043B2C;", 1)
assert "background-color: black;" in html, "bg body black tidak ketemu"
html = html.replace("background-color: black;", "background-color: #043B2C;", 1)
# 3a2. progress bar naik: bottom 10% -> 25%. Di 10% bar jatuh di celah judul
# landscape (PESANTREN y 79-86%, UNIVERSE 91-98%; celah 87-90% cuma 24 px —
# bar jadi garis pemisah judul). Di 25% bar duduk di jalan kosong: landscape
# y 73-75% kosong (kaki figur 69%, judul 79%), portrait y 74-75% kosong
# (kaki figur 72%). Diukur dari piksel gambar konsep, 19 Nov 2026.
assert "#status-progress {\n\tbottom: 10%;" in html, "CSS #status-progress tidak ketemu"
html = html.replace("#status-progress {\n\tbottom: 10%;", "#status-progress {\n\tbottom: 25%;", 1)
html = html.replace(anchor, patch + "\n" + anchor, 1)
with open(new_html_path, "w", encoding="utf-8") as f:
    f.write(html)

# 4. verifikasi guard + ukuran + worklet + batas file
with open(new_html_path, "r", encoding="utf-8") as f:
    final = f.read()
print("script open:", final.count("<script"), "script close:", final.count("</script>"))
assert final.count("<script") == 4 and final.count("</script>") == 4, "jumlah script bukan 4 (patch + splash + index.js + config)"
assert "splash loading screen orientasi" in final, "pemilih splash tidak ada"
assert "splash-portrait.png" in final and "splash-landscape.png" in final, "nama file splash tidak ada di pemilih"
assert "#043B2C" in final, "latar #043B2C tidak ada"
assert "#242424" not in final and "background-color: black;" not in final, "latar lama masih ada"
assert "bottom: 25%" in final and "bottom: 10%" not in final, "progress bar bukan bottom 25%"
for _sf in ("splash-landscape.png", "splash-portrait.png"):
    _sp = os.path.join(DST, _sf)
    assert os.path.exists(_sp), "splash staging hilang: %s" % _sf
    print("splash staging OK:", _sf, os.path.getsize(_sp), "B")
assert ('"index.pck":%d' % pck_size) in final, "fileSizes pck salah"
assert "wasm/part-04.bin" in final, "chunk wasm tidak ada di patch"
assert "pck/part-01.bin" in final, "chunk pck tidak ada di patch"
worklet = os.path.join(DST, "index.audio.position.worklet.js")
assert os.path.getsize(worklet) == 2973, "worklet bukan 2.973 B"
assert not os.path.exists(os.path.join(DST, "index.pck")), "index.pck utuh masih ada di staging"
print("index.html sha256:", sha256(new_html_path), "bytes:", os.path.getsize(new_html_path))
print("worklet sha256:", sha256(worklet)[:16], "bytes: 2973")
max_file = ""
max_size = 0
for root, _dirs, files in os.walk(DST):
    for name in files:
        p = os.path.join(root, name)
        sz = os.path.getsize(p)
        if sz > max_size:
            max_size, max_file = sz, os.path.relpath(p, DST)
        assert sz < MAX_FILE, "file %s %d B melewati batas 24 MiB" % (os.path.relpath(p, DST), sz)
        print("  %s: %d B sha256 %s..." % (os.path.relpath(p, DST), sz, sha256(p)[:16]))
print("file terbesar di staging: %s %d B (%.2f MiB)" % (max_file, max_size, max_size / 1048576.0))

# 5. bukti boot: harness Node mengeksekusi patch persis seperti di index.html
harness = os.path.join(EXPORT_DIR, "test_chunked_boot.mjs")
node = shutil.which("node")
if node and os.path.exists(harness):
    print("menjalankan bukti boot:", harness)
    r = subprocess.run(
        [node, harness, DST, pck_sha, wasm_sha, str(pck_size)],
        capture_output=True, text=True, timeout=300,
    )
    print(r.stdout, end="")
    if r.stderr:
        print(r.stderr, end="", file=sys.stderr)
    assert r.returncode == 0, "BUKTI BOOT GAGAL (test_chunked_boot.mjs exit %d)" % r.returncode
else:
    print("PERINGATAN: harness boot tidak dijalankan (node/harness tidak ada) — JANGAN deploy tanpa bukti boot")
print("STAGE OK")

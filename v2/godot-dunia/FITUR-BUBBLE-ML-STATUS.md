# FITUR BUBBLE CHAT GAYA MOBILE LEGENDS — STATUS (Gita)

Koreksi Mas 17 Nov 2026 ~21:30 WIB (setelah lihat foto E2): "Buble chat
jelek.. saya pengen chat ga kayak kotak chat gitu.. tapi kayak chat
mobile legend.. muncul di sebelah analog."

## Ringkasan

- Bubble kotak 3D di atas kepala **DIMATIKAN** (player.gd + npc.gd).
- Pengganti: **feed teks melayang ala Mobile Legends di ui.gd** — teks kecil
  di sebelah analog (kiri bawah, di atas joystick), tanpa kotak/border,
  latar transparan, hilang sendiri ~4 detik, maks 3 baris.
- Panel ketik chat **TETAP** seperti sekarang (hanya tampilan pesan yang
  muncul yang berubah).
- **JANGAN deploy.** Folder v2 tidak disentuh.

## Keputusan desain

- **Node bubble 3D dipertahankan (dormant), tidak dihapus.** Alasan:
  `build_visual()` di player.gd mengembalikan dict dengan kunci
  `"bubble"` yang dipakai pemain (`_pasang_visual`) + semua NPC
  (`npc.gd setup()`). Menghapus node berarti mengubah kontrak dict +
  dua file pemakai; risikonya lebih besar daripada manfaatnya. Node
  dibuat dengan `visible = false` dan **tidak ada lagi kode yang
  menyalakannya** — tes membuktikan `visible` tetap `false` selamanya.
- **Pesan baru masuk di BAWAH, yang lama NAIK.** Alasan: ini yang paling
  MLBB — di chat in-game Mobile Legends pesan terbaru muncul di bawah
  dan yang lama bergeser ke atas; juga membuat pesan terbaru selalu
  paling dekat dengan joystick/garis pandang pemain, dan feed tumbuh ke
  atas (tidak pernah turun menutupi joystick).
- **Nama berwarna, teks putih, tanpa BBCode.** Tiap baris = HBoxContainer
  [Label nama emas `#f2c14e` + Label teks putih], font 18, bayangan hitam
  (pola label HUD poin/misi) supaya terbaca di atas dunia 3D. Tanpa
  PanelContainer / stylebox / latar apa pun.
- **Teks dipotong maks 100 karakter + "…"** (perilaku lama, via
  `Palette.rapikan_bubble`) — feed tidak pernah melebar tak terkendali.
- **Posisi feed:** VBoxContainer anak `_hud` (ikut sembunyi di layar
  login), `PRESET_BOTTOM_LEFT`, posisi (24, -464), ukuran 520x208 —
  bawah wadah di -256, yaitu **12 px di atas joystick** (joystick di
  (24,-244), 220x220). `alignment = ALIGNMENT_END` supaya baris menumpuk
  dari bawah ke atas. Tidak menutup joystick, tombol Reset Posisi
  (kanan bawah), atau minimap (kiri atas).
- **Umur baris 4,0 dtk; 1,0 dtk terakhir fade** (modulate.a 1 → 0), lalu
  baris dibuang. Lebih dari 3 baris = yang paling lama langsung dibuang.

## File yang diubah (oleh Gita)

| File | Perubahan |
|---|---|
| `scripts/player.gd` | `show_chat()` jadi no-op (bubble tidak pernah tampil); `set_bubble_ditahan()` jadi no-op (tanda tangan dipertahankan — main.gd:856 memanggilnya tiap frame); blok timer bubble + `batasi_label_kamera(_bubble)` + `_batasi_label_dinding(_bubble)` di `_process` dihapus; baris `_bubble.visible = false` di pose tidur dihapus; `_bubble_timer` dihapus; komentar diperbarui. Node `_bubble` tetap dibuat di `build_visual()` (dormant, `visible=false`). |
| `scripts/npc.gd` | `say()` tidak lagi menampilkan Label3D — kini memancarkan sinyal baru `pesan(nama, teks)`; blok timer bubble + pembatas kamera/dinding bubble di `_process` dihapus; baris sembunyikan bubble di `mulai_rute()` dihapus; `_bubble_timer` dihapus; sinyal `pesan` + komentar. Node `_bubble` tetap dibuat (dormant). |
| `scripts/ui.gd` | **DIEDIT 17 Nov ~21:52 WIB setelah GO Raka** — patch `ui_feed_ml.patch` dipasang (`patch -p1 --fuzz=0`, bersih; `--check-only` bersih). Isi: member `_feed_chat` + `_feed_baris` + konstanta `FEED_CHAT_MAKS/DURASI/FADE`; `_build_feed_chat()` dipanggil di `_build_hud()` setelah joystick; `tampilkan_pesan_melayang(nama, teks)` (publik) + getter tes `jumlah_pesan_melayang()` / `pesan_melayang_terlihat()`; tick umur + fade di `_process` (setelah blok toast). |
| `scripts/main.gd` | **READ-ONLY — tidak diedit Gita.** Spesifikasi reroute untuk Raka di bawah. |

## File tes / foto (arsip di `~/workspace/pesantren-verse/fitur-baru/`)

| File | Isi |
|---|---|
| `skrip/test_bubble_ml.gd` + `.tscn` | Tes headless: A bubble 3D mati, B sinyal NPC, C panel chat tetap jalan, D feed ML (dilewati bila patch ui.gd belum dipasang), D2 tanpa kotak, E smoke 300 frame. |
| `skrip/foto_bubble_ml.gd` + `.tscn` | Foto bukti: B1 1 baris pesan pemain, B2 3 baris menumpuk (pemain + 2 NPC). Berhenti exit 2 dengan pesan jelas bila feed belum ada. |
| `skrip/ui_feed_ml.patch` | Patch ui.gd (feed) — siap dipasang Raka/Cakra setelah GO. |
| `foto/B1-pesan-pemain.png`, `foto/B2-pesan-npc.png` | **SELESAI 17 Nov ~22:07 WIB** — `foto_bubble_ml.tscn` (xvfb 1280x720, jam 10.0, bypass login), EXIT=0. B1: 1 baris pesan pemain; B2: 3 baris menumpuk (pemain + 2 NPC, terbaru di bawah). Dicek visual oleh Gita: nama emas + teks putih, tanpa kotak, di atas joystick, tidak ada bubble di atas kepala (label nama "Tes" di atas kepala tetap ada — itu label nama, bukan bubble). |

## Hasil uji

### `test_bubble_ml.tscn` — 22 LOLOS / 0 GAGAL (xvfb 640x360, jam 10.0, bypass login, 17 Nov ~21:55 WIB)

- **A. Bubble 3D mati (8):** node bubble pemain tetap ada (kontrak
  build_visual); bubble pemain + NPC tersembunyi saat masuk dunia;
  `show_chat` tidak menyalakan bubble (ditahan maupun tidak);
  `npc.say` tidak menyalakan bubble; bubble pemain + NPC tetap mati
  setelah 6 dtk.
- **B. Sinyal NPC (2):** `say()` memancarkan `pesan("Bilal", "Ayo
  sholat berjamaah di Surau!")`; teks panjang dipotong rapi (100
  karakter + "…").
- **C. Panel ketik chat tetap jalan (5):** panel tertutup saat masuk
  dunia; terbuka lewat tombol Chat; kirim menambah 1 baris riwayat
  panel berisi teks yang dikirim; panel menutup sendiri setelah kirim
  (perilaku Eka).
- **D. Feed ML (5):** 4 pesan → maks 3 baris; yang paling lama dibuang,
  pesan baru di bawah (`["UJI2 npc", "UJI3 npc", "UJI4 pemain lagi"]`);
  feed di atas joystick (bawah feed 464, atas joystick 476 — 12 px);
  feed sejajar kiri joystick; baris hilang sendiri ~4 dtk.
- **D2. Tanpa kotak (2):** tidak ada Panel/PanelContainer di subtree
  feed; label feed tanpa stylebox latar.
- Catatan jujur: baris ringkasan HASIL di log tertulis "20 LOLOS"
  karena satu `await` ketinggalan di skrip tes (`_tes_tanpa_kotak()`
  dipanggil tanpa `await`, jadi 2 cek terakhir tercetak setelah baris
  ringkasan) — sudah diperbaiki di skrip (arsip + salinan root sudah
  dihapus dari root); hitungan benar 22 LOLOS / 0 GAGAL, diverifikasi
  dengan menghitung baris LOLOS di `/tmp/test_bubble_ml.log`.
  Satu-satunya ERROR di log adalah ALSA (tidak ada perangkat suara di
  xvfb) — noise lingkungan, bukan dari perubahan ini.
- **Smoke 300 frame TIDAK SELESAI dalam jendela tunggu:** VM sangat
  padat saat run (load average ~9,5 pada 1,5 CPU; proses Godot hanya
  mendapat ~25% satu core) — setelah semua 22 cek LOLOS + baris HASIL
  tercetak, smoke 300 frame belum selesai setelah ~10 menit, jadi run
  dihentikan Gita. Game sudah berjalan ratusan frame tanpa error selama
  semua fase tes (termasuk tunggu 6 dtk + polling kedaluwarsa). Bukan
  kegagalan tes — keterbatasan VM saat itu.

### Foto — `foto_bubble_ml.tscn`, EXIT=0 (xvfb 1280x720, 17 Nov ~22:07 WIB)

- **B1-pesan-pemain.png:** 1 baris — "Tes: Assalamu'alaikum! Ayo
  selesaikan misinya." (nama emas, teks putih, tanpa kotak, di atas
  joystick kiri bawah). Karakter pemain terlihat dari depan, label nama
  "Tes" di atas kepala tetap tampil (itu label nama, bukan bubble).
- **B2-pesan-npc.png:** 3 baris menumpuk — Tes / Bilal /
  "Ust. Aqsal Murad: Ayo sholat berjamaah — saya jadi imam." (terbaru
  di bawah, yang lama naik). Tanpa kotak, di atas joystick.
- Pelajaran dari run pertama: di xvfb (render software, ~1-2 fps),
  40 frame = puluhan detik waktu game — pesan 4 dtk akan kedaluwarsa
  sebelum difoto. Skrip foto diubah: pesan dikirim SETELAH kamera
  settle, foto diambil hanya 3 frame kemudian.

### `--check-only` bersih

`player.gd`, `npc.gd`, `ui.gd` (setelah patch), `test_bubble_ml.gd`,
`foto_bubble_ml.gd` — lolos parse tanpa error.

## Spesifikasi reroute main.gd — UNTUK RAKA (main.gd READ-ONLY bagi Gita)

Semua titik panggil `say()` / `show_chat()` yang harus dialihkan ke feed:

### 1. Pesan pemain — `main.gd` fungsi `_on_chat_sent`, baris ~1521-1535

Sekarang:

```gdscript
func _on_chat_sent(teks: String) -> void:
	_player.show_chat(teks)
	_ui.add_chat_line(String(_save["nama"]), teks)
	...
	_ui.close_chat()
```

Ganti baris `_player.show_chat(teks)` menjadi:

```gdscript
	_ui.tampilkan_pesan_melayang(String(_save["nama"]), teks)
```

Sisanya (riwayat panel `add_chat_line` + `close_chat`) **tetap** —
perilaku Eka dipertahankan. `show_chat()` di player.gd kini no-op,
jadi kalau baris lama tertinggal pun tidak ada bubble yang muncul.

### 2. Pesan NPC — sinyal `pesan`, connect SEKALI per NPC di tempat NPC dibuat

`say()` di npc.gd kini memancarkan `pesan(nama, teks)`. Sambungkan ke
feed dengan SATU baris per NPC, tepat di samping
`rute_selesai.connect(_on_npc_rute_selesai)` yang sudah ada:

| NPC | Baris connect yang sudah ada | Tambahkan di sebelahnya |
|---|---|---|
| npc1 Bilal | `npc1.rute_selesai.connect(_on_npc_rute_selesai)` (~baris 400) | `npc1.pesan.connect(_ui.tampilkan_pesan_melayang)` |
| npc2 Faris | `npc2.rute_selesai.connect(_on_npc_rute_selesai)` (~baris 410) | `npc2.pesan.connect(_ui.tampilkan_pesan_melayang)` |
| npc3 Kyai (Ust. Aqsal Murad) | `npc3.rute_selesai.connect(_on_npc_rute_selesai)` (~baris 443) | `npc3.pesan.connect(_ui.tampilkan_pesan_melayang)` |
| npc4 Ustadzah Mariyah | `npc4.rute_selesai.connect(_on_npc_rute_selesai)` (~baris 478) | `npc4.pesan.connect(_ui.tampilkan_pesan_melayang)` |
| npc5 Satpam | `npc5.rute_selesai.connect(_on_npc_rute_selesai)` (~baris 508) | `npc5.pesan.connect(_ui.tampilkan_pesan_melayang)` |

Tanda tangan cocok persis: sinyal `pesan(nama: String, teks: String)`
→ `tampilkan_pesan_melayang(nama: String, teks: String)`, jadi connect
langsung tanpa lambda.

Satu sambungan ini menjangkau **SEMUA** pesan NPC, karena ketiganya
mengalir lewat `say()`:

- `main.gd` ~1854 — Kyai: `npc.say("Ayo sholat berjamaah — saya jadi imam.")`
- `main.gd` ~1864 — Ustadzah: `npc.say("Ayo sholat berjamaah di Musholla Ar-Raudhah — saya jadi imam.")`
- `main.gd` ~1877 — NPC biasa: `npc.say("Ayo sholat berjamaah di Surau!")`
- `npc.gd` `_process` (obrolan acak tiap 25–45 dtk dari
  `MissionData.NPC_LINES`) — **ini BUKAN di main.gd**, jadi kalau hanya
  tiga baris main.gd yang diubah, obrolan acak akan hilang. Sinyal
  `pesan` menutup celah ini: obrolan acak juga lewat `say()` → sinyal
  → feed. **Tiga baris `npc.say(...)` di main.gd TIDAK PERLU diubah
  sama sekali.**
- Catatan: Satpam (`npc5`, mode diam) tidak pernah `say()` — connect
  tetap dipasang untuk konsistensi (tidak ada efek samping).

### 3. Pembersihan opsional (boleh, tidak wajib)

- `main.gd` ~856: `_player.set_bubble_ditahan(_ui.is_chat_visible())`
  — kini no-op yang aman dibiarkan; boleh dihapus Raka saat memasang
  reroute (beserta komentar RONDE 7 di atasnya). Jangan hapus baris
  `set_nama_ditahan` di sekitarnya (label nama masih dipakai).
- `scripts/palette.gd` ~167: komentar "Dipakai show_chat pemain +
  say() NPC" pada `rapikan_bubble()` — kini dipakai feed ui.gd +
  sinyal npc.gd. Hanya komentar; boleh diperbarui, boleh dibiarkan.
- `scripts/mission_data.gd` ~262: komentar "diucapkan bergantian
  sebagai chat bubble" pada `NPC_LINES` — hanya komentar; boleh
  dibiarkan.

### 4. Urutan pasang (penting)

1. ~~Cakra selesai fullscreen → Raka kirim "GO" ke Gita.~~ **SELESAI —
   GO diterima 17 Nov ~21:51 WIB.**
2. ~~Pasang `ui_feed_ml.patch`~~ **SELESAI 17 Nov ~21:52 WIB** (patch
   dipasang + `--check-only` bersih).
3. Raka pasang reroute main.gd (§1 + §2 di atas).
4. ~~Gita jalankan ulang `test_bubble_ml.tscn` + `foto_bubble_ml.tscn`
   → B1 + B2.~~ **SELESAI — tes 22/0 + foto B1/B2 (lihat "Hasil uji").**
   Catatan: tes + foto di atas memakai pemanggilan
   `tampilkan_pesan_melayang` LANGSUNG (feed-nya sendiri sudah
   terbukti); rute lengkap lewat main.gd (pemain kirim chat + NPC
   `say()` → feed) baru terbukti penuh SETELAH Raka pasang reroute —
   Gita siap tes ulang jalur itu bila Raka minta.
5. Verdict Mas atas foto B1/B2. **Jangan deploy sebelum itu.**

## Yang belum selesai / menunggu

- [x] GO dari Raka (Cakra selesai ui.gd) → patch feed dipasang.
- [x] Reroute main.gd oleh Raka (§1 + §2) — SELESAI 17 Nov ~22:13 WIB,
  lihat "Reroute main.gd — SELESAI (Raka)" di bawah.
- [x] Tes ulang penuh (bagian D + D2 aktif) + foto B1/B2.
- [ ] Verdict Mas atas foto B1/B2.
- [x] (Opsional) hapus baris `set_bubble_ditahan` main.gd:856 saat reroute.
- [x] (Opsional, bila Raka minta) tes ulang jalur lengkap main.gd →
  feed setelah reroute dipasang — `test_reroute_bubble.gd`, 11/11 LULUS.

---

## Reroute main.gd — SELESAI (Raka, 17 Nov ~22:13 WIB)

**Yang dipasang di `scripts/main.gd`:**
- §1 — `_on_chat_sent`: `_player.show_chat(teks)` → `_ui.tampilkan_pesan_melayang(String(_save["nama"]), teks)`. `add_chat_line` + `close_chat` tetap.
- §2 — connect sinyal `pesan` NPC → feed (SATU loop, bukan 5 baris).
- §3 — blok RONDE 7 + pemanggilan `_player.set_bubble_ditahan(...)`
  dihapus (kini no-op); `set_nama_ditahan` di sekitarnya dipertahankan.
- Tiga baris `npc.say(...)` (~1854/1864/1877) TIDAK diubah — kini
  memancarkan sinyal `pesan`, jadi ikut teralihkan (termasuk obrolan
  acak NPC dari `MissionData.NPC_LINES`).

**BUG YANG DITEMUKAN TES REROUTE (jujur, penting):** spesifikasi awal
("tambahkan connect di sebelah `rute_selesai.connect`") SALAH TEMPAT —
di `_ready()`, `_spawn_npcs()` dipanggil SEBELUM `_ui =
PesantrenUI.new()`. Connect pertama (npc1) error Nil (`_ui` belum ada)
dan **menghentikan `_spawn_npcs()` di tengah** — npc2–npc5 tidak pernah
dibuat, hanya Bilal yang spawn. Tes reroute pertama menangkap ini
(feed pemain jalan, feed Bilal gagal, `_npcs[2]` di luar jangkauan).
**Perbaikan:** 5 connect dicabut dari `_spawn_npcs()`, diganti satu loop
di `_ready()` SETELAH `_ui` dibuat (main.gd ~341):
`for npc in _npcs: npc.pesan.connect(_ui.tampilkan_pesan_melayang)`.
Pelajaran: connect ke `_ui` tidak boleh di `_spawn_npcs()` — `_ui`
baru ada setelahnya.

**Tes end-to-end `test_reroute_bubble.gd` (Raka) — 11/11 LULUS:**
feed kosong di awal; NPC lengkap 5 (penjaga regresi bug di atas);
`_on_chat_sent` → 1 baris "Tes: Halo dari pemain"; `say()` Bilal →
baris ke-2 "Bilal: Ayo sholat berjamaah di Surau!"; `say()` Kyai →
baris ke-3 "Ust. Aqsal Murad: Ayo sholat berjamaah — saya jadi imam.";
bubble 3D pemain + Bilal + Kyai tetap mati. `--check-only` main.gd
bersih; salinan tes di root sudah dihapus (arsip `fitur-baru/skrip/`).
Jalur lengkap main.gd → feed kini TERBUKTI, bukan hanya feed-nya saja.

# Inventaris Rebrand — Pesantren Verse → Pesantren Universe

Keputusan Mas (18:55 WIB, 18 Nov 2026): "Ya diganti jadi Universe semua" — REBRAND TOTAL.
Koordinator: Arsa. Status: Fase 1 inventaris SELESAI; Fase 2 eksekusi berjalan (6 agen, satu area tiap agen). JANGAN deploy.

## Angka inventaris
- Grep mentah (semua "verse", tanpa filter): 2.347 baris — `pesantren-verse/`: 311 "Verse" kapital + 1.380 "verse" kecil; `goals/pesantren-verse/`: 304 + 352.
- **Inventaris bersih (token brand saja, sudah dibuang vendor/backup/salinan/log/arsip): 1.467 baris** — file: `/tmp/rebrand-inventory/clean.txt` (grep: `Pesantren Verse|PESANTREN VERSE|pesantren-verse|pesantren_verse`, exclude `.git, node_modules, v2-export-copy, godot-dunia-backup-4.3, space-versions, space_data, file-versions, *.log, *.lock`).
- Perhatian: grep "verse" kecil juga menangkap false positive "reverse"/"traverse" (mis. `threejs-santri/vendor/three.module.js` 126 baris, `server.py:431` "reverse proxy") — BUKAN brand, jangan diubah.

## Per area (file inventaris bersih, top)
| Area | Agen | Hit terbanyak |
|---|---|---|
| Kode game v2 | Bara | `data/buku-draft-nahwu.json` 10, `data/buku.json` 4, `scripts/ui.gd` 3 (TARA — tunda), `project.godot` "Pesantren Verse v2" |
| Kode game v1 | Wira | `project.godot` "Pesantren Verse", `scripts/ui.gd` 3 |
| Dokumen | Cakra | `riset-dunia-virtual/RISET-DUNIA-VIRTUAL.md` 22, `organisasi/STRUKTUR-ORGANISASI.md` 12, `v2/konsep/DRAF-ALUR-MISI.md` 6, `desain-ui-misi.py` 7, `desain-hud-v3.py` 6 |
| Server | Saka | `README.md` 12, `server.py` 5, `.service` 4+4, `sync-followers.py` 2 |
| App artifact | Gita | `server/src/actions.ts` 39, `client/src/App.tsx` 6, `client/index.html` (title+meta), `space.json` "Pesantren Verse App" |
| Direktori goal | Dewi | ebook `.src/index.html` 91 + `build.py` 20, blueprint `.src/*.html` 7+7, `agent_notes` 33+28 (arsip — jangan ubah) |

## Rencana URL (terverifikasi 18 Nov ~19:00 WIB)
- **`universe.santrilogy.web.id` SUDAH menyajikan game v2 live** (HTTP 200, HTML sama dengan live v2, judul masih "Pesantren Verse v2" — judul ikut `project.godot` saat export berikutnya).
- **Rekomendasi: JANGAN rename proyek Pages `pesantren-verse-v2`.** Domain Universe sudah jadi URL login; URL `pesantren-verse-v2.pages.dev` tetap hidup sebagai fallback. Rename proyek (→ `pesantren-universe-v2.pages.dev`) memutus URL lama — hanya bila Mas setuju, setelah domain Universe dipastikan jadi URL utama. Perlu keputusan Xam/Mas sebelum menyentuh infra live.
- Judul tab game ("Pesantren Verse v2") berubah otomatis di KEDUA domain pada deploy berikutnya setelah `project.godot` direbrand.

## Yang SENGAJA TIDAK diubah (tertahan — butuh keputusan / giliran)
- **File Tara (tunda sampai HUD B mendarat):** `v2/godot-dunia/scripts/ui.gd` (baris 3 komentar + 4267 pesan landscape "Pesantren Verse lebih lega dimainkan miring"), `gaya_tombol.gd`, `virtual_joystick.gd`, `ikon_hud.gd`. Raka juga sedang implementasi UI misi di `ui.gd` (4 mockup DI-ACC 18:58) — string UI v2 diganti pada pass akhir.
- **URL/hostname live:** `pesantren-verse-v2.pages.dev`, `pesantren-verse.pages.dev`, `universe.santrilogy.web.id` — jangan diubah di teks mana pun.
- **Infra VPS:** path `/home/ubuntu/pesantren-verse-server/...`, nama service `pesantren-verse-api` / `pesantren-verse-realtime` (+ nama file `.service`), identifier health response `"service": "pesantren-verse-api"`, nama biner `pesantren-verse-server`.
- **Handle akun IG lama:** `@pesantren.verse` (akun terkunci, nama asli) — JANGAN diubah. Yang benar `@pesantren.universe` sudah dipakai di tempat lain.
- **Nama goal** `Pesantren Verse` (goal_2748dd9fad07) — diganti lewat Xam, bukan dari agen.
- **Nama direktori:** `~/workspace/pesantren-verse`, `~/workspace/goals/pesantren-verse`, `ts-spaces/pesantren-verse-app` — rename direktori merusak banyak referensi; keputusan Xam.
- **PDF (biner, butuh rebuild):** `ebook-nahwu-dasar-pesantren-verse.pdf` (source `.src/` direbrand; rebuild oleh Laras), `pesantren-verse-blueprint.pdf` (source `.src/` direbrand; rebuild terpisah).
- **Arsip/sejarah (jangan diubah):** `DEPLOY-STATUS.md` (v1+v2), `*.log`, `*.bak`, `agent_notes/`, `audits/`, `briefs/`, `file-versions/`, `space-versions/`, `space_data/`, `v2-export-copy/`, `godot-dunia-backup-4.3/`, `threejs-santri/vendor/`, `render_report.json`, output build (`dist/`, `dist-cvm/`, `.space-build-cvm/`, `v2/export/web-pages/index.html`).
- **Nama internal:** tabel/kolom DB (`drizzle/0002_pesantren_verse_core_tables.sql`), slug artifact (`pesantren-verse-app`), nama file media branding (`branding/media-generation-pesantren-verse-*`, `pesantren-verse-profile-opsi2.jpg`).

## Fakta terverifikasi (untuk eksekusi)
- `server.py:2` docstring "Pesantren Verse API"; `server.py:1154` print startup (teks boleh, path jangan); `.service:2` Description boleh direbrand.
- `buku.json:46-47` judul "Atlas Pesantren Verse — Peta dan Masterplan v2" + atribusi "Tim Pesantren Verse" (tampil di reader → wajib ganti); `buku-draft-nahwu.json:9-10` + teks ebook "PESANTREN VERSE / Nahwu Dasar ... Ebook ini materi orisinal Pesantren Verse. ... Pesantren Verse - Nyantri dari mana saja, kapan saja."
- App: `space.json:4` "Pesantren Verse App"; `client/index.html:9,18,23` meta/title; `client/index.html:29` slug — jangan ubah.
- `v2/godot-dunia/project.godot:13` "Pesantren Verse v2"; `godot-dunia/project.godot:13` "Pesantren Verse".

---

## HASIL AKHIR (Arsa, 18 Nov ~19:05 WIB — 6 agen selesai, diverifikasi Arsa dengan grep ulang)

**Total diganti: ±330 baris di ~100 file** (jumlah baris tiap file tetap — hanya swap kata). TIDAK deploy, TIDAK sentuh VPS/live.

| Area | Agen | Hasil |
|---|---|---|
| Server | Saka | 7 file — docstring `server.py`/`sync-followers.py`, judul README, komentar Caddyfile, `Description=` 2× `.service`, komentar `test-v1.3.0.sh`. py_compile OK. |
| Kode v1 | Wira | 6 file, 9 ganti — `project.godot` → "Pesantren Universe", sapaan `main.gd`, judul login "PESANTREN UNIVERSE" + pesan landscape di `ui.gd`. |
| App | Gita | 20 file, 91 ganti — `space.json`, `index.html` (title+meta), `App.tsx`, `actions.ts` (39, termasuk data seed), dll. Typecheck lolos. |
| Goal | Dewi | 17 file — `GOAL.md`, Modul 01 + tracker, source ebook (94) + `build.py` (22), source blueprint (7+7), cron harian (2). |
| Kode v2 | Bara | 18 file, 43 ganti — `project.godot` → "Pesantren Universe v2", sapaan `main.gd:925`, `onboarding.gd:126` "Apa itu Pesantren Universe", `buku.json` + `buku-draft-nahwu.json` (19×), `stage_v2.py`. |
| Dokumen | Cakra | 27 file, 81 baris — draf v5.3 (5), roadmap, KONSEP-TATA-LETAK, organisasi (12), kurikulum (4), riset (22+3+4+1+1), video Hari ke-1, skrip mockup + gambar (label render baru). |
| Sapuan akhir | Arsa | 12 file — status docs v2 (KAMERA/BUKU/FITUR-BACA-BUKU), `audio/README.md` v1, `fonts.css`, `shot.mjs`, 3 docstring skrip/model-3d, `ROADMAP-MAPS.md` (judul), 2 dokumen desain-arsitektur. |

**Sisa "Pesantren Verse" (grep akhir: 443 baris) — semuanya kategori KEEP yang disengaja:**
- Arsip/sejarah: `agent_notes/`, `briefs/`, `DEPLOY-STATUS.md`, `CATATAN.md` (catatan bug + pengukuran papan 15 Nov), `DRAF-ALUR-MISI-v4.md`, `ROADMAP-ALUR-MISI-v4.md`, `V2-ALPHA-STATUS.md` (log clone), `REBRAND-INVENTARIS.md` (dokumen ini), catatan rename 15 Nov di blueprint, butir 10 draf ("Alim Pesantren Verse" = alternatif yang ditolak).
- Output build/generated: `dist/`, `dist-cvm/`, `.space-build*/`, `server/dist/actions.js`, `render_report.json`, `v2/export/web-pages/index.html` (+ backup export), `*.bak`, audits `document-text.txt`/`report.json`.
- **Wilayah Tara (pass akhir):** `v2/godot-dunia/scripts/ui.gd` 3 hit — komentar baris 3, judul login `:539` "PESANTREN VERSE" (tampil ke pemain!), pesan landscape `:4267`.
- **Keputusan yang masih dibutuhkan (lihat bawah).**

## KEPUTUSAN YANG MASIH DIBUTUHKAN (untuk Xam/Mas)
1. **URL/proyek live:** rekomendasi JANGAN rename proyek Pages — `universe.santrilogy.web.id` sudah sajikan game live; `pesantren-verse-v2.pages.dev` jadi fallback. Rename hanya bila Mas setuju.
2. **Nama goal** `Pesantren Verse` (goal_2748dd9fad07) — ganti lewat Xam.
3. **Nama direktori** (`~/workspace/pesantren-verse`, `goals/pesantren-verse`, `ts-spaces/pesantren-verse-app`) — rename merusak banyak referensi; putuskan terpisah.
4. **Identifier API/unit:** `pesantren-verse-api` (respons `/health`, print startup, nama unit systemd, contoh README) — ubah butuh deploy VPS + update klien game.
5. **ID buku:** `atlas-pesantren-verse` / `nahwu-dasar-pesantren-verse` (`buku.json:45`, `buku-draft-nahwu.json:3`, `buat_atlas.py:5`) — kontrak data + tes baca buku; ganti harus konsisten.
6. **UID scene:** `main.tscn:1` `uid://pesantrenverse1` (v1 + v2) — jangan edit manual; regenerate via Godot bila mau diganti.
7. **Handle IG di app:** `@pesantren.verse` 14× di source app (follow/daftar, `IG_URL`) — akun terkunci; pindah ke `@pesantren.universe` berarti pindah sinkronisasi follower (ID akun 17841411153423227) — keputusan produk.
8. **Singkatan "PV":** "palet PV" / "ebook PV" di dokumen — ganti "PU" atau biarkan? (`X-PV-Token`, `PV-0001` wajib tetap.)
9. **PDF ebook + blueprint** — source sudah Universe; rebuild oleh Laras.
10. **Papan 3D "PESANTREN VERSE" di dunia game** — teks tidak ada di kode/`.tscn` (dicek Bara + Wira + Arsa); kemungkinan tekstur baked / scene v1. Butuh cek visual (Bima) + foto ulang. Dokumen yang mendeskripsikannya (`CATATAN.md`, `ROADMAP-MAPS.md:639`, `RISET-ASET-GRATIS-ZAHRA.md:151`) sengaja dibiarkan sesuai kondisi papan saat ini.
11. **SVG konsep** (`asrama-putra-konsep.svg`, `surau-v2-konsep.svg`) — teks "PESANTREN VERSE" di dalam gambar hasil render; regenerate bila perlu.
12. **Instruksi cron kurikulum** — file di disk sudah direbrand Dewi; cek apakah instruksi tersimpan di scheduler ikut berubah (`cron.view`/`cron.update`).
13. **Migrasi save pemain:** `project.godot` v2 → "Pesantren Universe v2" mengubah folder `app_userdata` Godot (`Pesantren Verse v2` → `Pesantren Universe v2`) — save pemain lama (di HP/server?) perlu dipindah saat deploy, atau pemain mulai dari nol. Cek saat persiapan deploy.
14. **Nama package** `hatch-ts-space-pesantren-verse-app` (`package.json:2`) — internal; laporkan saja.

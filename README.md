# Pesantren Universe

Pesantren virtual persisten — game 3D (Godot) + server + kurikulum.
Repo ini PRIVATE. Source code + dokumen; bukan tempat build.

Live: https://pesantren-verse-v2.pages.dev (domain: universe.santrilogy.web.id)

## Layout

- `v2/godot-dunia/` — game aktif (Godot 4.7.2, Web / GL Compatibility)
- `godot-dunia/` — v1 (arsip; folder `export/` berisi build lama, tidak ikut repo)
- `server/` — API + realtime (Python, SQLite; butuh `.env` — TIDAK ada di repo)
- `v2/konsep/` — dokumen desain, masterplan, audit tekstur, uji kompres
- `v2/model-3d/` — model 3D sumber (Blender / GLB)
- `v2/export/` — tooling staging / gate / deploy saja (artefak build tidak ikut repo)
- `MULTIPLAYER-*.md` — rencana multiplayer (Fase 1 live, Fase 2 menyusul)
- `scripts/auto-sync.sh` — auto commit + push tiap 30 menit (cron)

## Menjalankan

- Game: Godot 4.7.2, buka `v2/godot-dunia/`, jalankan scene utama.
- Server: `python3 server/server.py` (butuh `.env` di VPS).
- Deploy: staging `v2/export/stage_v2.py` + gate `v2/export/gate-deploy-A.sh`,
  lalu deploy ke Cloudflare Pages `pesantren-verse-v2`.

## Yang TIDAK ada di repo ini

- Rahasia (X-PV-Token, `.env`, skrip tes berisi token) — hanya di VPS.
- Build / export (pck, wasm, chunk) — hanya di Cloudflare Pages + staging lokal.
- Arsip foto / video besar, proyek video Remotion (`video-hari-ke-1/`),
  file Blender karakter (jalur Blender ditutup), backup lama.
- Memori keputusan + riwayat chat — ada di workspace agen (`MEMORY.md`),
  bukan di repo. Baca itu dulu sebelum mengubah arah.

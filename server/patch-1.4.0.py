#!/usr/bin/env python3
"""Patch server Pesantren Verse v1.3.0 -> v1.4.0 (lamaran pengurus).

Jalankan dari workspace:  python3 patch-1.4.0.py
Mengedit ~/workspace/pesantren-verse/server/server.py di tempat.
Setiap penggantian dicek (harus tepat 1 kemunculan); gagal -> berhenti.
"""
import sys

PATH = "/home/hatch/workspace/pesantren-verse/server/server.py"

REPLACEMENTS = []

# 1. Versi
REPLACEMENTS.append((
    'VERSION = "1.3.0"',
    'VERSION = "1.4.0"',
    "versi 1.4.0",
))

# 2. Docstring: daftar endpoint lamaran
REPLACEMENTS.append((
    """  POST /api/santri/points      -> kirim poin misi, kembalikan total terbaru (butuh token)
  GET  /api/ranking?limit=N    -> leaderboard global""",
    """  POST /api/santri/points      -> kirim poin misi, kembalikan total terbaru (butuh token)
  GET  /api/ranking?limit=N    -> leaderboard global
  POST /api/lamaran/kirim      -> kirim lamaran pengurus (publik, tanpa token)
  GET  /api/lamaran/saya       -> daftar lamaran satu santri (publik)
  GET  /api/lamaran/daftar     -> semua lamaran, filter ?status= (butuh token)
  POST /api/lamaran/rekomendasi -> rekomendasi musyrif (butuh token)
  POST /api/lamaran/keputusan  -> keputusan Pengasuh (butuh token)""",
    "docstring endpoint lamaran",
))

# 3. Docstring: paragraf auth lamaran
REPLACEMENTS.append((
    """Endpoint baca (verify, ranking, health) publik tapi dibatasi rate limit.""",
    """Endpoint baca (verify, ranking, health) publik tapi dibatasi rate limit.
Lamaran (v1.4.0): kirim + saya publik (perbuatan santri sendiri);
rekomendasi, keputusan, dan daftar butuh X-PV-Token (musyrif/Pengasuh
lewat app — token dipegang server app, bukan klien).""",
    "docstring auth lamaran",
))

# 4. Import datetime
REPLACEMENTS.append((
    """import threading
import time""",
    """import threading
import time
from datetime import datetime, timedelta, timezone""",
    "import datetime",
))

# 5. Tabel lamaran di db()
REPLACEMENTS.append((
    """            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);
            CREATE INDEX IF NOT EXISTS idx_santri_poin ON santri(total_poin DESC);""",
    """            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);
            CREATE INDEX IF NOT EXISTS idx_santri_poin ON santri(total_poin DESC);
            CREATE TABLE IF NOT EXISTS lamaran (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                posisi TEXT NOT NULL,
                posisi_cadangan TEXT,
                alasan TEXT NOT NULL,
                pengalaman TEXT,
                status TEXT NOT NULL DEFAULT 'menunggu_musyrif',
                rekomendasi_musyrif TEXT,
                catatan_musyrif TEXT,
                keputusan TEXT,
                alasan_tolak TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                diputuskan_at TEXT
            );
            CREATE INDEX IF NOT EXISTS idx_lamaran_santri ON lamaran(santri_id);
            CREATE INDEX IF NOT EXISTS idx_lamaran_status ON lamaran(status);""",
    "tabel lamaran",
))

# 6. Konstanta + penjelasan lamaran (setelah misi_selesai)
REPLACEMENTS.append((
    """def misi_selesai(c, santri_id: str) -> int:
    r = c.execute("SELECT COUNT(DISTINCT misi) AS n FROM points_log WHERE santri_id=?",
                  (santri_id,)).fetchone()
    return r["n"] if r else 0""",
    """def misi_selesai(c, santri_id: str) -> int:
    r = c.execute("SELECT COUNT(DISTINCT misi) AS n FROM points_log WHERE santri_id=?",
                  (santri_id,)).fetchone()
    return r["n"] if r else 0


# ---------------------------------------------------------------- Lamaran pengurus (v1.4.0)
# Desain: DESAIN-LAMARAN-PENGURUS.md (ACC Mas 16 Nov 2026 ~15:55 WIB).
# Posisi: 5 (Kepala Kamar + Ketua Asrama lewat vote, bukan lamaran).
# Syarat: santri terdaftar + Misi M1 selesai. Misi berurutan (M1 dulu baru
# M2/M3), jadi misi_selesai >= 1 berarti M1 sudah selesai (asumsi v1.4.0).
# 1 santri = 1 lamaran aktif (menunggu_musyrif/menunggu_pengasuh); jeda
# 1 minggu setelah penolakan terakhir. Alur: menunggu_musyrif ->
# menunggu_pengasuh -> diterima/ditolak. Rekomendasi musyrif ("setuju"/
# "tidak") selalu meneruskan ke Pengasuh — keputusan akhir di Pengasuh.
POSISI_LAMARAN = ["Keamanan", "Ubudiyah", "Kebersihan", "Pendidikan", "Humas & Media"]
STATUS_LAMARAN = ["menunggu_musyrif", "menunggu_pengasuh", "diterima", "ditolak"]
JEDA_LAMAR_HARI = 7""",
    "konstanta lamaran",
))

# 7. Routing GET lamaran
REPLACEMENTS.append((
    """        elif u.path == "/api/ranking":
            self._ranking(parse_qs(u.query))""",
    """        elif u.path == "/api/ranking":
            self._ranking(parse_qs(u.query))
        elif u.path == "/api/lamaran/saya":
            self._lamaran_saya(parse_qs(u.query))
        elif u.path == "/api/lamaran/daftar":
            self._lamaran_daftar(parse_qs(u.query))""",
    "routing GET lamaran",
))

# 8. Routing POST lamaran
REPLACEMENTS.append((
    """        elif u.path == "/api/santri/points":
            self._points()""",
    """        elif u.path == "/api/santri/points":
            self._points()
        elif u.path == "/api/lamaran/kirim":
            self._lamaran_kirim()
        elif u.path == "/api/lamaran/rekomendasi":
            self._lamaran_rekomendasi()
        elif u.path == "/api/lamaran/keputusan":
            self._lamaran_keputusan()""",
    "routing POST lamaran",
))

# 9. Daftar endpoint di root "/"
REPLACEMENTS.append((
    """                                 "POST /api/santri/points (token)",
                                 "GET  /api/ranking?limit=N",""",
    """                                 "POST /api/santri/points (token)",
                                 "GET  /api/ranking?limit=N",
                                 "POST /api/lamaran/kirim (publik)",
                                 "GET  /api/lamaran/saya?santri_id=PV-XXXX (publik)",
                                 "GET  /api/lamaran/daftar?status=... (token)",
                                 "POST /api/lamaran/rekomendasi (token)",
                                 "POST /api/lamaran/keputusan (token)",""",
    "root endpoint list",
))

# 10. Handler lamaran (disisipkan sebelum def main())
HANDLERS = '''
    # -- lamaran pengurus (v1.4.0) --------------------------------
    def _lamaran_view(self, row) -> dict:
        return {
            "lamaran_id": row["id"],
            "santri_id": row["santri_id"],
            "nama": row["nama"],
            "ig_username": row["ig_username"],
            "posisi": row["posisi"],
            "posisi_cadangan": row["posisi_cadangan"],
            "alasan": row["alasan"],
            "pengalaman": row["pengalaman"],
            "status": row["status"],
            "rekomendasi_musyrif": row["rekomendasi_musyrif"],
            "catatan_musyrif": row["catatan_musyrif"],
            "keputusan": row["keputusan"],
            "alasan_tolak": row["alasan_tolak"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
            "diputuskan_at": row["diputuskan_at"],
        }

    def _lamaran_kirim(self):
        # PUBLIK (v1.4.0): lamaran adalah perbuatan santri sendiri,
        # seperti register. Rate limit 120/menit/IP tetap berlaku.
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid = norm_id(data.get("id")) if data.get("id") else ""
        ig = norm_ig_username(data.get("ig_username")) if data.get("ig_username") else ""
        posisi = (data.get("posisi") or "").strip()
        posisi_cad = (data.get("posisi_cadangan") or "").strip() if isinstance(data.get("posisi_cadangan"), str) else ""
        alasan = (data.get("alasan") or "").strip() if isinstance(data.get("alasan"), str) else ""
        pengalaman = (data.get("pengalaman") or "").strip() if isinstance(data.get("pengalaman"), str) else ""
        if posisi not in POSISI_LAMARAN:
            self._err(400, "Posisi tidak valid (Keamanan, Ubudiyah, Kebersihan, Pendidikan, Humas & Media)")
            return
        if posisi_cad and (posisi_cad not in POSISI_LAMARAN or posisi_cad == posisi):
            self._err(400, "Posisi cadangan harus posisi lain yang valid")
            return
        if not alasan or len(alasan) > 200:
            self._err(400, "Alasan wajib diisi, maks 200 huruf")
            return
        if len(pengalaman) > 200:
            self._err(400, "Pengalaman maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = None
            if sid:
                if not ID_RE.match(sid):
                    self._err(400, "ID harus berformat PV-XXXX")
                    return
                row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            elif ig:
                row = c.execute("SELECT * FROM santri WHERE ig_username=?", (ig,)).fetchone()
            else:
                self._err(400, "ID Santri atau ig_username wajib diisi")
                return
            if row is None:
                self._err(404, "Santri tidak ditemukan")
                return
            sid = row["id"]
            # Syarat M1 (asumsi v1.4.0): misi berurutan, jadi
            # misi_selesai >= 1 berarti M1 sudah selesai.
            if misi_selesai(c, sid) < 1:
                self._err(400, "Syarat belum terpenuhi: selesaikan Misi M1 dulu")
                return
            aktif = c.execute(
                "SELECT id FROM lamaran WHERE santri_id=? AND status IN "
                "('menunggu_musyrif', 'menunggu_pengasuh')",
                (sid,)).fetchone()
            if aktif:
                self._err(409, "Masih ada lamaran aktif (lamaran_id %d)" % aktif["id"])
                return
            # Jeda 1 minggu setelah penolakan terakhir.
            tolak = c.execute(
                "SELECT diputuskan_at FROM lamaran WHERE santri_id=? AND status='ditolak' "
                "AND diputuskan_at IS NOT NULL ORDER BY diputuskan_at DESC LIMIT 1",
                (sid,)).fetchone()
            if tolak:
                try:
                    t_tolak = datetime.strptime(
                        tolak["diputuskan_at"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
                    bisa = t_tolak + timedelta(days=JEDA_LAMAR_HARI)
                    if datetime.now(timezone.utc) < bisa:
                        self._err(409, "Jeda 1 minggu setelah penolakan — bisa melamar lagi pada %s"
                                  % bisa.strftime("%Y-%m-%d"))
                        return
                except ValueError:
                    pass
            t = now_iso()
            try:
                c.execute("BEGIN IMMEDIATE")
                cur = c.execute(
                    "INSERT INTO lamaran (santri_id, posisi, posisi_cadangan, alasan, "
                    "pengalaman, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, "
                    "'menunggu_musyrif', ?, ?)",
                    (sid, posisi, posisi_cad or None, alasan, pengalaman or None, t, t))
                lamaran_id = cur.lastrowid
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(201, {"ok": True, "created": True, "lamaran_id": lamaran_id,
                         "santri_id": sid, "posisi": posisi,
                         "status": "menunggu_musyrif", "created_at": t})

    def _lamaran_saya(self, qs):
        sid = norm_id(qs.get("santri_id", [""])[0]) if qs.get("santri_id") else ""
        ig = norm_ig_username(qs.get("ig_username", [""])[0]) if qs.get("ig_username") else ""
        with _db_lock:
            c = db()
            row = None
            if sid:
                if not ID_RE.match(sid):
                    self._err(400, "ID harus berformat PV-XXXX")
                    return
                row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            elif ig:
                row = c.execute("SELECT * FROM santri WHERE ig_username=?", (ig,)).fetchone()
            else:
                self._err(400, "santri_id atau ig_username wajib diisi")
                return
            if row is None:
                self._err(404, "Santri tidak ditemukan")
                return
            rows = c.execute(
                "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                "ON s.id = l.santri_id WHERE l.santri_id=? "
                "ORDER BY l.created_at DESC, l.id DESC", (row["id"],)).fetchall()
        self._send(200, {"ok": True, "santri_id": row["id"], "nama": row["nama"],
                         "total": len(rows),
                         "lamaran": [self._lamaran_view(r) for r in rows]})

    def _lamaran_daftar(self, qs):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        status = (qs.get("status", [""])[0] or "").strip()
        if status and status not in STATUS_LAMARAN:
            self._err(400, "Status tidak valid")
            return
        with _db_lock:
            c = db()
            if status:
                rows = c.execute(
                    "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                    "ON s.id = l.santri_id WHERE l.status=? "
                    "ORDER BY l.created_at DESC, l.id DESC", (status,)).fetchall()
            else:
                rows = c.execute(
                    "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                    "ON s.id = l.santri_id ORDER BY l.created_at DESC, l.id DESC").fetchall()
        self._send(200, {"ok": True, "total": len(rows),
                         "lamaran": [self._lamaran_view(r) for r in rows]})

    def _lamaran_rekomendasi(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        lamaran_id = data.get("lamaran_id")
        rekom = (data.get("rekomendasi") or "").strip()
        catatan = (data.get("catatan") or "").strip() if isinstance(data.get("catatan"), str) else ""
        if not isinstance(lamaran_id, int) or isinstance(lamaran_id, bool):
            self._err(400, "lamaran_id wajib diisi (angka)")
            return
        if rekom not in ("setuju", "tidak"):
            self._err(400, 'rekomendasi harus "setuju" atau "tidak"')
            return
        if len(catatan) > 200:
            self._err(400, "Catatan maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM lamaran WHERE id=?", (lamaran_id,)).fetchone()
            if row is None:
                self._err(404, "Lamaran tidak ditemukan")
                return
            if row["status"] != "menunggu_musyrif":
                self._err(409, "Lamaran sudah melewati tahap musyrif (status: %s)" % row["status"])
                return
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("UPDATE lamaran SET rekomendasi_musyrif=?, catatan_musyrif=?, "
                          "status='menunggu_pengasuh', updated_at=? WHERE id=?",
                          (rekom, catatan or None, now_iso(), lamaran_id))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "rekomendasi_musyrif": rekom,
                         "status": "menunggu_pengasuh"})

    def _lamaran_keputusan(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        lamaran_id = data.get("lamaran_id")
        keput = (data.get("keputusan") or "").strip()
        alasan_tolak = (data.get("alasan_tolak") or "").strip() if isinstance(data.get("alasan_tolak"), str) else ""
        if not isinstance(lamaran_id, int) or isinstance(lamaran_id, bool):
            self._err(400, "lamaran_id wajib diisi (angka)")
            return
        if keput not in ("diterima", "ditolak"):
            self._err(400, 'keputusan harus "diterima" atau "ditolak"')
            return
        if keput == "ditolak" and not alasan_tolak:
            self._err(400, "alasan_tolak wajib diisi bila ditolak")
            return
        if len(alasan_tolak) > 200:
            self._err(400, "alasan_tolak maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM lamaran WHERE id=?", (lamaran_id,)).fetchone()
            if row is None:
                self._err(404, "Lamaran tidak ditemukan")
                return
            if row["status"] != "menunggu_pengasuh":
                self._err(409, "Lamaran belum sampai tahap Pengasuh (status: %s)" % row["status"])
                return
            t = now_iso()
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("UPDATE lamaran SET keputusan=?, alasan_tolak=?, status=?, "
                          "diputuskan_at=?, updated_at=? WHERE id=?",
                          (keput, alasan_tolak or None, keput, t, t, lamaran_id))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "keputusan": keput, "status": keput,
                         "diputuskan_at": t})

'''
REPLACEMENTS.append((
    "\ndef main():",
    HANDLERS + "\ndef main():",
    "handler lamaran",
))


def main():
    with open(PATH, encoding="utf-8") as f:
        src = f.read()
    for old, new, desc in REPLACEMENTS:
        n = src.count(old)
        if n != 1:
            print(f"GAGAL: '{desc}' ditemukan {n}x (harus 1x)")
            sys.exit(1)
        src = src.replace(old, new)
        print(f"OK: {desc}")
    with open(PATH, "w", encoding="utf-8") as f:
        f.write(src)
    print("patch selesai:", PATH)


if __name__ == "__main__":
    main()

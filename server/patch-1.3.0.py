#!/usr/bin/env python3
"""Patch server.py v1.2.0 -> v1.3.0 (register publik + token sesi).

Jalankan di VPS:  python3 patch-1.3.0.py
- Tidak menyentuh baris TOKEN (dibaca dari .env) sama sekali.
- Setiap penggantian dicek (harus ketemu tepat 1x); kalau ada yang gagal,
  script berhenti SEBELUM menulis apa pun.
- Backup server.py dibuat dulu sebagai server.py.1.2.0.bak.
"""
import shutil
import sys

PATH = "/home/ubuntu/pesantren-verse-server/server.py"


def rep(src, old, new, name):
    n = src.count(old)
    assert n == 1, f"{name}: ditemukan {n}x, harus 1x"
    return src.replace(old, new)


src = open(PATH, encoding="utf-8").read()
orig = src

# 1. Versi
src = rep(src, 'VERSION = "1.2.0"', 'VERSION = "1.3.0"', "versi")

# 2. Docstring: daftar endpoint
src = rep(src, """  POST /api/santri/register     -> daftar santri baru, terbitkan ID PV-XXXX (butuh token);
                                  sistem TUNGGAL (tanpa jalur); ig_username WAJIB (identitas
                                  login), password/kota/email opsional
  POST /api/santri/login        -> login pakai ig_username (+ password bila sudah diset)
  POST /api/santri/set_password -> isi/ubah password sendiri (butuh token)""", """  POST /api/santri/register     -> daftar santri baru, terbitkan ID PV-XXXX (PUBLIK,
                                  tanpa token); sistem TUNGGAL (tanpa jalur);
                                  ig_username WAJIB (identitas login),
                                  password/kota/email opsional
  POST /api/santri/login        -> login pakai ig_username (+ password bila sudah diset);
                                  login berhasil mengembalikan token sesi 1 jam
  POST /api/santri/set_password -> isi/ubah password sendiri (token sesi dari login,
                                  BUKAN token bersama X-PV-Token)""", "docstring-endpoint")

# 3. Docstring: paragraf Auth
src = rep(src, """Auth: header X-PV-Token (shared secret, dari file .env) untuk endpoint tulis
(register, points). Endpoint baca (verify, ranking, health) publik tapi
dibatasi rate limit per IP.""", """Auth: header X-PV-Token (shared secret, dari file .env) HANYA untuk
POST /api/santri/points (pemberian poin oleh game/server tepercaya).
POST /api/santri/register PUBLIK (pendaftaran terbuka, siapa pun boleh
daftar — rate limit 120/menit/IP tetap berlaku). POST /api/santri/login
publik dan mengembalikan token sesi (acak, 1 jam, satu sesi per santri,
hangus setelah dipakai); POST /api/santri/set_password memakai token sesi
itu (field "session" di body), BUKAN X-PV-Token — jadi token bersama tidak
pernah keluar dari server dan app cukup menyimpan token sesi santri.
Endpoint baca (verify, ranking, health) publik tapi dibatasi rate limit.""", "docstring-auth")

# 4. Tabel sesi_login (di executescript db())
src = rep(src, """            CREATE INDEX IF NOT EXISTS idx_points_santri ON points_log(santri_id);""", """            CREATE INDEX IF NOT EXISTS idx_points_santri ON points_log(santri_id);
            CREATE TABLE IF NOT EXISTS sesi_login (
                token TEXT PRIMARY KEY,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                created_epoch INTEGER NOT NULL,
                expires_epoch INTEGER NOT NULL,
                used INTEGER NOT NULL DEFAULT 0
            );
            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);""", "tabel-sesi")

# 5. Helper sesi (setelah misi_selesai, sebelum seksi HTTP)
src = rep(src, '''def misi_selesai(c, santri_id: str) -> int:
    r = c.execute("SELECT COUNT(DISTINCT misi) AS n FROM points_log WHERE santri_id=?",
                  (santri_id,)).fetchone()
    return r["n"] if r else 0
''', '''def misi_selesai(c, santri_id: str) -> int:
    r = c.execute("SELECT COUNT(DISTINCT misi) AS n FROM points_log WHERE santri_id=?",
                  (santri_id,)).fetchone()
    return r["n"] if r else 0


# ---------------------------------------------------------------- Sesi login
# Token sesi: diterbitkan _login saat login berhasil. Acak (token_urlsafe),
# berlaku 1 jam, SATU sesi per santri (login baru menghapus sesi lama santri
# itu), hangus setelah dipakai untuk set_password (sekali pakai) atau
# kedaluwarsa. Dipakai _set_password sebagai pengganti token bersama
# X-PV-Token, supaya app bisa memakai server tanpa memegang token bersama.
SESI_TTL_DETIK = 3600  # 1 jam


def _buat_sesi(santri_id: str) -> str:
    token = secrets.token_urlsafe(32)
    now = int(time.time())
    with _db_lock:
        c = db()
        c.execute("DELETE FROM sesi_login WHERE santri_id=?", (santri_id,))
        # Bersihkan sesi kedaluwarsa yang sudah lama (housekeeping ringan).
        c.execute("DELETE FROM sesi_login WHERE expires_epoch < ?", (now - 86400,))
        c.execute("INSERT INTO sesi_login (token, santri_id, created_epoch, "
                  "expires_epoch, used) VALUES (?, ?, ?, ?, 0)",
                  (token, santri_id, now, now + SESI_TTL_DETIK))
        c.commit()
    return token


def _cek_sesi(token):
    """Validasi token sesi. Kembalikan (santri_id, None) bila valid,
    atau (None, pesan_error) bila tidak valid / sudah dipakai / kedaluwarsa."""
    if not isinstance(token, str) or not token:
        return None, "Token sesi tidak valid"
    with _db_lock:
        c = db()
        row = c.execute("SELECT * FROM sesi_login WHERE token=?",
                        (token,)).fetchone()
    if row is None:
        return None, "Token sesi tidak valid"
    if row["used"]:
        return None, "Token sesi sudah dipakai"
    if int(time.time()) > row["expires_epoch"]:
        return None, "Token sesi sudah kedaluwarsa"
    return row["santri_id"], None
''', "helper-sesi")

# 6. Daftar endpoint di GET /
src = rep(src, '''                                 "POST /api/santri/register (token)",
                                 "POST /api/santri/verify",
                                 "POST /api/santri/login",
                                 "POST /api/santri/set_password (token)",''', '''                                 "POST /api/santri/register (publik)",
                                 "POST /api/santri/verify",
                                 "POST /api/santri/login (token sesi)",
                                 "POST /api/santri/set_password (token sesi)",''', "daftar-endpoint")

# 7. _register: hapus cek token
src = rep(src, '''    def _register(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()''', '''    def _register(self):
        # PUBLIK (v1.3.0): pendaftaran terbuka, tanpa token. Rate limit
        # 120/menit/IP (di do_POST) tetap berlaku.
        data, err = self._read_json()''', "register-publik")

# 8a. _login: docstring
src = rep(src, '''        """Login pakai ig_username. Bila santri belum punya password,
        username saja cukup; bila sudah punya, password wajib cocok."""''', '''        """Login pakai ig_username. Bila santri belum punya password,
        username saja cukup; bila sudah punya, password wajib cocok.
        Login berhasil mengembalikan token sesi (field "session",
        berlaku 1 jam, satu sesi per santri) untuk set_password."""''', "login-docstring")

# 8b. _login: terbitkan token sesi saat berhasil
src = rep(src, '''        if row["password_hash"]:
            if not isinstance(pw, str) or not cek_password(pw, row["password_hash"]):
                self._err(401, "Password salah")
                return
        out = santri_view(row)
        out.update({"ok": True, "found": True, "login": True,
                    "ig_username": row["ig_username"], "misi_selesai": n_misi})
        self._send(200, out)''', '''        if row["password_hash"]:
            if not isinstance(pw, str) or not cek_password(pw, row["password_hash"]):
                self._err(401, "Password salah")
                return
        # Login berhasil -> terbitkan token sesi (1 jam, satu sesi per santri).
        token_sesi = _buat_sesi(row["id"])
        out = santri_view(row)
        out.update({"ok": True, "found": True, "login": True,
                    "ig_username": row["ig_username"], "misi_selesai": n_misi,
                    "session": token_sesi, "session_expires_in": SESI_TTL_DETIK})
        self._send(200, out)''', "login-session")

# 9. _set_password: tulis ulang total (token sesi, bukan X-PV-Token)
old_set_pw = '''    def _set_password(self):
        """Isi/ubah password sendiri (butuh token)."""
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid = norm_id(data.get("id"))
        pw = data.get("password")
        if not ID_RE.match(sid):
            self._err(400, "ID harus berformat PV-XXXX")
            return
        if not isinstance(pw, str) or not (6 <= len(pw) <= 64):
            self._err(400, "Password minimal 6 karakter, maks 64")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT id FROM santri WHERE id=?", (sid,)).fetchone()
            if row is None:
                self._err(404, "ID Santri tidak ditemukan")
                return
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("UPDATE santri SET password_hash=?, updated_at=? WHERE id=?",
                          (hash_password(pw), now_iso(), sid))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "id": sid, "password_set": True})'''
new_set_pw = '''    def _set_password(self):
        """Isi/ubah password sendiri (token sesi dari login, BUKAN token
        bersama X-PV-Token). Token sesi hanya berlaku untuk santri pemiliknya
        dan hangus setelah dipakai (sekali pakai) atau kedaluwarsa (1 jam).
        Body: {"session": "<token>", "password": "<baru>"}; field "id"
        opsional — bila diisi harus sama dengan pemilik token."""
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid_sesi, err_sesi = _cek_sesi(data.get("session"))
        if err_sesi:
            self._err(401, err_sesi)
            return
        sid = norm_id(data.get("id")) if data.get("id") else sid_sesi
        if sid != sid_sesi:
            self._err(403, "Token sesi bukan milik santri ini")
            return
        pw = data.get("password")
        if not isinstance(pw, str) or not (6 <= len(pw) <= 64):
            self._err(400, "Password minimal 6 karakter, maks 64")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT id FROM santri WHERE id=?", (sid,)).fetchone()
            if row is None:
                self._err(404, "ID Santri tidak ditemukan")
                return
            try:
                c.execute("BEGIN IMMEDIATE")
                # Cek ulang di dalam transaksi (anti pakai-ganda bersamaan).
                srow = c.execute("SELECT used, expires_epoch FROM sesi_login "
                                 "WHERE token=?", (data.get("session"),)).fetchone()
                if srow is None or srow["used"] or int(time.time()) > srow["expires_epoch"]:
                    c.rollback()
                    self._err(401, "Token sesi sudah dipakai atau kedaluwarsa")
                    return
                c.execute("UPDATE santri SET password_hash=?, updated_at=? WHERE id=?",
                          (hash_password(pw), now_iso(), sid))
                # Token sesi hangus setelah dipakai (sekali pakai).
                c.execute("UPDATE sesi_login SET used=1 WHERE token=?",
                          (data.get("session"),))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "id": sid, "password_set": True})'''
src = rep(src, old_set_pw, new_set_pw, "set-password")

assert src != orig, "tidak ada perubahan?!"
shutil.copyfile(PATH, PATH + ".1.2.0.bak")
open(PATH, "w", encoding="utf-8").write(src)
print("OK: 9 patch diterapkan, backup server.py.1.2.0.bak dibuat")

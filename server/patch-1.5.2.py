#!/usr/bin/env python3
"""Patch server.py v1.5.1 -> v1.5.2: tiket realtime untuk handshake WebSocket.

Keputusan Fase 0 multiplayer (MULTIPLAYER-PLAN.md §1.3): cara (a) —
endpoint tiket baru — BUKAN cara (b) validasi read-only tabel sesi_login.
Alasan (dicek dari kode server yang sebenarnya, bukan ditebak):
- Token sesi login juga mengesahkan set_password; mengirimnya ke
  handshake realtime memperluas permukaan serangannya. Tiket khusus
  (acak, 5 menit, sekali pakai) membatasi dampak bila bocor.
- Server realtime adalah Godot dedicated server — tanpa driver sqlite.
  Cara (b) memaksanya membaca DB sqlite langsung (plugin native /
  shell-out) dan menduplikasi logika _cek_sesi (used + kedaluwarsa) di
  GDScript. Cara (a) membiarkan REST tetap satu-satunya sumber kebenaran
  auth; server realtime memvalidasi lewat HTTP localhost (HTTPRequest
  sudah bawaan Godot).
- Token sesi TIDAK hangus saat minta tiket: tetap berlaku untuk
  set_password dan untuk minta tiket lagi bila reconnect.

Perubahan:
- POST /api/santri/realtime_ticket (body {"session": "<token sesi>"})
  -> 200 {"ticket": ..., "expires_in": 300, "id", "nama",
  "jenis_kelamin"}; sesi tidak valid / sudah dipakai / kedaluwarsa -> 401.
- POST /api/santri/realtime_ticket/validate (wajib X-PV-Token, pola yang
  sama seperti /points; hanya server realtime tepercaya di VPS yang sama)
  body {"ticket": "..."} -> 200 {"id", "nama", "jenis_kelamin"} dan tiket
  langsung ditandai terpakai (sekali pakai); tiket tidak valid / sudah
  dipakai / kedaluwarsa -> 401; tanpa X-PV-Token yang benar -> 401.
- Tabel baru tiket_realtime (ticket PK, santri_id FK, created_epoch,
  expires_epoch, used) + indeks santri_id.
- Tiket TIDAK PERNAH ditulis ke log (log hanya method + path + status).
- Tidak ada perubahan pada endpoint lain, X-PV-Token, Hermes/WA, kitab.

Pelajaran v1.4.0/v1.5.0: patch script HARUS dicek output + diff-nya, bukan
hanya exit code. Script ini: tiap penggantian dicek jumlah kemunculannya
(harus tepat 1x), lalu mencetak ringkasan + diff. Jalankan dari folder
server (backup dulu: cp server.py server.py.1.5.1.bak):
    python3 patch-1.5.2.py
"""
import os
import subprocess
import sys

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "server.py")
BAK = PATH + ".1.5.1.bak"


def ganti(teks, lama, baru, nama):
    n = teks.count(lama)
    if n != 1:
        print(f"GAGAL [{nama}]: kemunculan {n} (harus tepat 1)")
        sys.exit(1)
    print(f"OK [{nama}]")
    return teks.replace(lama, baru)


def main():
    with open(PATH, encoding="utf-8") as f:
        src = f.read()

    # 1. Versi.
    src = ganti(src, 'VERSION = "1.5.1"', 'VERSION = "1.5.2"', "versi")

    # 2. Docstring: daftar endpoint baru.
    src = ganti(src,
                '  POST /api/santri/set_password -> isi/ubah password sendiri (token sesi dari login,\n'
                '                                  BUKAN token bersama X-PV-Token)\n',
                '  POST /api/santri/set_password -> isi/ubah password sendiri (token sesi dari login,\n'
                '                                  BUKAN token bersama X-PV-Token)\n'
                '  POST /api/santri/realtime_ticket -> terbitkan tiket realtime (5 menit,\n'
                '                                  sekali pakai) untuk handshake WebSocket;\n'
                '                                  pakai token sesi login yang masih berlaku\n'
                '                                  (token sesi TIDAK hangus karena ini)\n'
                '  POST /api/santri/realtime_ticket/validate -> validasi + tandai terpakai\n'
                '                                  tiket realtime (butuh X-PV-Token — hanya\n'
                '                                  server realtime tepercaya di VPS yang sama)\n',
                "docstring endpoint")

    # 3. Skema: tabel tiket_realtime + indeks.
    src = ganti(src,
                '            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);\n',
                '            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);\n'
                '            CREATE TABLE IF NOT EXISTS tiket_realtime (\n'
                '                ticket TEXT PRIMARY KEY,\n'
                '                santri_id TEXT NOT NULL REFERENCES santri(id),\n'
                '                created_epoch INTEGER NOT NULL,\n'
                '                expires_epoch INTEGER NOT NULL,\n'
                '                used INTEGER NOT NULL DEFAULT 0\n'
                '            );\n'
                '            CREATE INDEX IF NOT EXISTS idx_tiket_santri ON tiket_realtime(santri_id);\n',
                "skema tiket_realtime")

    # 4. Fungsi _buat_tiket_realtime + _cek_tiket_realtime (setelah _cek_sesi).
    src = ganti(src,
                '    if row is None:\n'
                '        return None, "Token sesi tidak valid"\n'
                '    if row["used"]:\n'
                '        return None, "Token sesi sudah dipakai"\n'
                '    if int(time.time()) > row["expires_epoch"]:\n'
                '        return None, "Token sesi sudah kedaluwarsa"\n'
                '    return row["santri_id"], None\n',
                '    if row is None:\n'
                '        return None, "Token sesi tidak valid"\n'
                '    if row["used"]:\n'
                '        return None, "Token sesi sudah dipakai"\n'
                '    if int(time.time()) > row["expires_epoch"]:\n'
                '        return None, "Token sesi sudah kedaluwarsa"\n'
                '    return row["santri_id"], None\n'
                '\n'
                '\n'
                '# ---------------------------------------------------------------- Tiket realtime (v1.5.2)\n'
                '# Tiket handshake WebSocket untuk server realtime (MULTIPLAYER-PLAN.md\n'
                '# §1.3, keputusan Fase 0: cara (a)). Token sesi login TIDAK BOLEH dipakai\n'
                '# langsung untuk handshake — token itu juga mengesahkan set_password, dan\n'
                '# server realtime (Godot, tanpa driver sqlite) tidak bisa membaca tabel\n'
                '# sesi_login. Jadi REST menerbitkan tiket khusus: acak, 5 menit, sekali\n'
                '# pakai. Token sesi TIDAK hangus saat minta tiket (tetap berlaku untuk\n'
                '# set_password dan untuk minta tiket lagi bila reconnect). Server realtime\n'
                '# memvalidasi tiket lewat POST /api/santri/realtime_ticket/validate\n'
                '# (wajib X-PV-Token, pola yang sama seperti /points) — validasi yang\n'
                '# berhasil langsung menandai tiket terpakai, dan mengembalikan identitas\n'
                '# dari DB supaya nama yang tampil ke pemain lain selalu dari DB, bukan\n'
                '# dari klien. Tiket TIDAK PERNAH ditulis ke log (log hanya mencatat\n'
                '# method + path + status, tanpa body).\n'
                'TIKET_TTL_DETIK = 300  # 5 menit\n'
                '\n'
                '\n'
                'def _buat_tiket_realtime(santri_id: str) -> str:\n'
                '    ticket = secrets.token_urlsafe(32)\n'
                '    now = int(time.time())\n'
                '    with _db_lock:\n'
                '        c = db()\n'
                '        # Bersihkan tiket kedaluwarsa yang sudah lama (housekeeping ringan).\n'
                '        c.execute("DELETE FROM tiket_realtime WHERE expires_epoch < ?", (now - 86400,))\n'
                '        c.execute("INSERT INTO tiket_realtime (ticket, santri_id, created_epoch, "\n'
                '                  "expires_epoch, used) VALUES (?, ?, ?, ?, 0)",\n'
                '                  (ticket, santri_id, now, now + TIKET_TTL_DETIK))\n'
                '        c.commit()\n'
                '    return ticket\n'
                '\n'
                '\n'
                'def _cek_tiket_realtime(ticket):\n'
                '    """Validasi tiket realtime + tandai terpakai (sekali pakai).\n'
                '    Kembalikan (santri_id, None) bila valid, atau (None, pesan_error)\n'
                '    bila tidak valid / sudah dipakai / kedaluwarsa."""\n'
                '    if not isinstance(ticket, str) or not ticket:\n'
                '        return None, "Tiket realtime tidak valid"\n'
                '    with _db_lock:\n'
                '        c = db()\n'
                '        try:\n'
                '            c.execute("BEGIN IMMEDIATE")\n'
                '            row = c.execute("SELECT * FROM tiket_realtime WHERE ticket=?",\n'
                '                            (ticket,)).fetchone()\n'
                '            if row is None:\n'
                '                c.rollback()\n'
                '                return None, "Tiket realtime tidak valid"\n'
                '            if row["used"]:\n'
                '                c.rollback()\n'
                '                return None, "Tiket realtime sudah dipakai"\n'
                '            if int(time.time()) > row["expires_epoch"]:\n'
                '                c.rollback()\n'
                '                return None, "Tiket realtime sudah kedaluwarsa"\n'
                '            c.execute("UPDATE tiket_realtime SET used=1 WHERE ticket=?", (ticket,))\n'
                '            c.commit()\n'
                '        except sqlite3.Error:\n'
                '            c.rollback()\n'
                '            return None, "Tiket realtime tidak valid"\n'
                '    return row["santri_id"], None\n',
                "fungsi tiket realtime")

    # 5. Daftar endpoint di GET /.
    src = ganti(src,
                '                                 "POST /api/santri/login (token sesi)",\n'
                '                                 "POST /api/santri/set_password (token sesi)",\n',
                '                                 "POST /api/santri/login (token sesi)",\n'
                '                                 "POST /api/santri/set_password (token sesi)",\n'
                '                                 "POST /api/santri/realtime_ticket (token sesi)",\n'
                '                                 "POST /api/santri/realtime_ticket/validate (token)",\n',
                "daftar endpoint GET /")

    # 6. Routing do_POST.
    src = ganti(src,
                '        elif u.path == "/api/santri/set_password":\n'
                '            self._set_password()\n',
                '        elif u.path == "/api/santri/set_password":\n'
                '            self._set_password()\n'
                '        elif u.path == "/api/santri/realtime_ticket":\n'
                '            self._realtime_ticket()\n'
                '        elif u.path == "/api/santri/realtime_ticket/validate":\n'
                '            self._realtime_ticket_validate()\n',
                "routing do_POST")

    # 7. Handler _realtime_ticket + _realtime_ticket_validate (setelah _set_password).
    src = ganti(src,
                '        self._send(200, {"ok": True, "id": sid, "password_set": True})\n'
                '\n'
                '    def _points(self):\n',
                '        self._send(200, {"ok": True, "id": sid, "password_set": True})\n'
                '\n'
                '    def _realtime_ticket(self):\n'
                '        """Terbitkan tiket realtime (5 menit, sekali pakai) untuk handshake\n'
                '        WebSocket server realtime. Body: {"session": "<token sesi login>"}.\n'
                '        Token sesi TIDAK hangus — tetap berlaku untuk set_password dan\n'
                '        untuk minta tiket lagi (reconnect)."""\n'
                '        data, err = self._read_json()\n'
                '        if err:\n'
                '            self._err(400, err)\n'
                '            return\n'
                '        sid_sesi, err_sesi = _cek_sesi(data.get("session"))\n'
                '        if err_sesi:\n'
                '            self._err(401, err_sesi)\n'
                '            return\n'
                '        ticket = _buat_tiket_realtime(sid_sesi)\n'
                '        with _db_lock:\n'
                '            c = db()\n'
                '            row = c.execute("SELECT * FROM santri WHERE id=?", (sid_sesi,)).fetchone()\n'
                '        if row is None:\n'
                '            self._err(404, "ID Santri tidak ditemukan")\n'
                '            return\n'
                '        self._send(200, {"ok": True, "ticket": ticket, "expires_in": TIKET_TTL_DETIK,\n'
                '                         "id": row["id"], "nama": row["nama"],\n'
                '                         "jenis_kelamin": row["jenis_kelamin"]})\n'
                '\n'
                '    def _realtime_ticket_validate(self):\n'
                '        """Validasi tiket realtime — HANYA untuk server realtime tepercaya\n'
                '        di VPS yang sama (wajib X-PV-Token, pola yang sama seperti /points).\n'
                '        Body: {"ticket": "<tiket>"}. Tiket yang valid langsung ditandai\n'
                '        terpakai (sekali pakai); respons membawa identitas dari DB supaya\n'
                '        nama yang tampil ke pemain lain selalu dari DB, bukan dari klien."""\n'
                '        if not self._need_token():\n'
                '            self._err(401, "Token tidak valid")\n'
                '            return\n'
                '        data, err = self._read_json()\n'
                '        if err:\n'
                '            self._err(400, err)\n'
                '            return\n'
                '        sid, err_tiket = _cek_tiket_realtime(data.get("ticket"))\n'
                '        if err_tiket:\n'
                '            self._err(401, err_tiket)\n'
                '            return\n'
                '        with _db_lock:\n'
                '            c = db()\n'
                '            row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()\n'
                '        if row is None:\n'
                '            self._err(404, "ID Santri tidak ditemukan")\n'
                '            return\n'
                '        self._send(200, {"ok": True, "id": row["id"], "nama": row["nama"],\n'
                '                         "jenis_kelamin": row["jenis_kelamin"]})\n'
                '\n'
                '    def _points(self):\n',
                "handler realtime_ticket")

    with open(PATH, "w", encoding="utf-8") as f:
        f.write(src)
    print("Ditulis ke server.py (7 penggantian).")
    print("--- diff terhadap backup (server.py.1.5.1.bak) ---")
    r = subprocess.run(["diff", "-u", BAK, PATH], capture_output=True, text=True)
    print(r.stdout)
    if r.returncode not in (0, 1):
        print("diff gagal:", r.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

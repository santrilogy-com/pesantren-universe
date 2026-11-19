#!/usr/bin/env python3
"""Patch server.py v1.5.0 -> v1.5.1: jenis_kelamin di registrasi santri.

Perintah Mas 17 Nov 2026 ~06:55 WIB: "daftar by gender belum ada. Saya mau
daftar sebagai santriwati pengen cek pondok putri." Kontrak (disepakati
dengan tim game, jangan diubah sepihak): field `jenis_kelamin`, nilai
"putra" atau "putri".

Perubahan:
- POST /api/santri/register terima `jenis_kelamin` (WAJIB untuk pendaftar
  baru; hanya "putra"/"putri" — nilai lain atau kosong ditolak 400).
  Disimpan di kolom baru `santri.jenis_kelamin` (TEXT, nullable).
- `jenis_kelamin` dikembalikan di respons register (201), login sukses
  (200), dan verify (200) — lewat `santri_view`.
- Santri lama tanpa gender (mis. PV-0001 "Tes") -> `jenis_kelamin: null`
  (kolom baru NULL untuk baris lama; tidak ada data lama yang diubah).
- Tidak ada perubahan pada field lain, X-PV-Token, Hermes/WA bridges.

Pelajaran v1.4.0/v1.5.0: patch script HARUS dicek output + diff-nya, bukan
hanya exit code. Script ini: tiap penggantian dicek jumlah kemunculannya
(harus tepat 1x), lalu mencetak ringkasan + diff. Jalankan dari folder
server (backup dulu: cp server.py server.py.1.5.0.bak):
    python3 patch-1.5.1.py
"""
import os
import subprocess
import sys

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "server.py")
BAK = PATH + ".1.5.0.bak"


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
    orig = src

    # 1. Versi.
    src = ganti(src, 'VERSION = "1.5.0"', 'VERSION = "1.5.1"', "versi")

    # 2. Skema: kolom jenis_kelamin di CREATE TABLE santri.
    src = ganti(src,
                '                ig_username TEXT,\n                kota TEXT,',
                '                ig_username TEXT,\n'
                '                jenis_kelamin TEXT,\n                kota TEXT,',
                "skema CREATE TABLE")

    # 3. Migrasi idempotent (pola yang sama seperti password_hash/dll):
    #    DB lama belum punya kolom ini -> ALTER TABLE saat koneksi dibuka.
    src = ganti(src,
                '        if "email" not in cols:\n'
                '            _conn.execute("ALTER TABLE santri ADD COLUMN email TEXT")\n'
                '        _conn.commit()',
                '        if "email" not in cols:\n'
                '            _conn.execute("ALTER TABLE santri ADD COLUMN email TEXT")\n'
                '        if "jenis_kelamin" not in cols:\n'
                '            _conn.execute("ALTER TABLE santri ADD COLUMN jenis_kelamin TEXT")\n'
                '        _conn.commit()',
                "migrasi ALTER TABLE")

    # 4. santri_view: kembalikan jenis_kelamin (dipakai verify + login).
    src = ganti(src,
                '        "id": row["id"],\n        "nama": row["nama"],\n        "jalur": row["jalur"],',
                '        "id": row["id"],\n        "nama": row["nama"],\n'
                '        "jenis_kelamin": row["jenis_kelamin"],\n        "jalur": row["jalur"],',
                "santri_view")

    # 5. _register: baca jenis_kelamin (normalisasi: strip + huruf kecil).
    src = ganti(src,
                '        email = (data.get("email") or "").strip() if isinstance(data.get("email"), str) else ""\n',
                '        email = (data.get("email") or "").strip() if isinstance(data.get("email"), str) else ""\n'
                '        jk = (data.get("jenis_kelamin") or "").strip().lower() \\\n'
                '            if isinstance(data.get("jenis_kelamin"), str) else ""\n',
                "register: baca jenis_kelamin")

    # 6. _register: validasi — wajib, hanya "putra"/"putri".
    src = ganti(src,
                '        if email and (len(email) > 128 or "@" not in email):\n'
                '            self._err(400, "Email tidak valid")\n            return\n',
                '        if email and (len(email) > 128 or "@" not in email):\n'
                '            self._err(400, "Email tidak valid")\n            return\n'
                '        if jk not in ("putra", "putri"):\n'
                '            self._err(400, "jenis_kelamin wajib diisi: \\"putra\\" atau \\"putri\\"")\n'
                '            return\n',
                "register: validasi jenis_kelamin")

    # 7. _register: simpan ke DB.
    src = ganti(src,
                '                c.execute("INSERT INTO santri (id, nama, total_poin, password_hash, "\n'
                '                          "ig_username, kota, email, created_at, updated_at) "\n'
                '                          "VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?)",\n'
                '                          (new_id, nama,\n'
                '                           hash_password(pw) if pw else None,\n'
                '                           ig, kota or None, email or None, t, t))',
                '                c.execute("INSERT INTO santri (id, nama, total_poin, password_hash, "\n'
                '                          "ig_username, jenis_kelamin, kota, email, created_at, updated_at) "\n'
                '                          "VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?, ?)",\n'
                '                          (new_id, nama,\n'
                '                           hash_password(pw) if pw else None,\n'
                '                           ig, jk, kota or None, email or None, t, t))',
                "register: INSERT")

    # 8. _register: kembalikan jenis_kelamin di respons 201.
    src = ganti(src,
                '        self._send(201, {"ok": True, "created": True, "id": new_id, "nama": nama,\n'
                '                         "ig_username": ig, "kota": kota or None,',
                '        self._send(201, {"ok": True, "created": True, "id": new_id, "nama": nama,\n'
                '                         "ig_username": ig, "jenis_kelamin": jk, "kota": kota or None,',
                "register: respons 201")

    with open(PATH, "w", encoding="utf-8") as f:
        f.write(src)
    print("Ditulis ke server.py (8 penggantian).")
    print("--- diff terhadap backup (server.py.1.5.0.bak) ---")
    r = subprocess.run(["diff", "-u", BAK, PATH], capture_output=True, text=True)
    print(r.stdout)
    if r.returncode not in (0, 1):
        print("diff gagal:", r.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

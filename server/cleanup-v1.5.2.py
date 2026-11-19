#!/usr/bin/env python3
"""Bersihkan data uji v1.5.2 dari DB produksi VPS.
Jalankan di VPS:  python3 cleanup-v1.5.2.py
Menghapus santri uji "Tes Tiket" (ig tes_tiket_1811) + semua baris
terkait (points_log, lamaran, sesi_login, tiket_realtime).
PV-0001 "Tes" TIDAK disentuh.
"""
import sqlite3

c = sqlite3.connect("data/pesantren.db")
row = c.execute("SELECT id FROM santri WHERE ig_username='tes_tiket_1811'").fetchone()
if row is None:
    print("santri tes tidak ditemukan (sudah bersih?)")
else:
    sid = row[0]
    print("hapus santri tes:", sid)
    for tabel, kolom in [("points_log", "santri_id"), ("lamaran", "santri_id"),
                         ("sesi_login", "santri_id"), ("tiket_realtime", "santri_id")]:
        n = c.execute(f"DELETE FROM {tabel} WHERE {kolom}=?", (sid,)).rowcount
        print(f"{tabel}: {n} baris dihapus")
    n = c.execute("DELETE FROM santri WHERE id=?", (sid,)).rowcount
    print(f"santri: {n} baris dihapus")
c.commit()
print("santri tersisa:", list(c.execute("SELECT id, nama, jenis_kelamin FROM santri")))
print("tiket_realtime tersisa:", c.execute("SELECT COUNT(*) FROM tiket_realtime").fetchone()[0])
print("sesi_login tersisa:", c.execute("SELECT COUNT(*) FROM sesi_login").fetchone()[0])

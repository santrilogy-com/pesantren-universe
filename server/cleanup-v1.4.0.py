#!/usr/bin/env python3
"""Bersihkan data uji v1.4.0 dari DB produksi VPS.
Jalankan di VPS:  python3 cleanup-v1.4.0.py
Menghapus santri uji PV-0002 + semua baris terkait (points_log, lamaran,
sesi_login). PV-0001 "Tes" TIDAK disentuh.
"""
import sqlite3

c = sqlite3.connect("data/pesantren.db")
for tabel, kolom in [("points_log", "santri_id"), ("lamaran", "santri_id"),
                     ("sesi_login", "santri_id")]:
    n = c.execute(f"DELETE FROM {tabel} WHERE {kolom}='PV-0002'").rowcount
    print(f"{tabel}: {n} baris dihapus")
n = c.execute("DELETE FROM santri WHERE id='PV-0002'").rowcount
print(f"santri: {n} baris dihapus")
c.commit()
print("santri tersisa:", list(c.execute("SELECT id, nama FROM santri")))
print("lamaran tersisa:", c.execute("SELECT COUNT(*) FROM lamaran").fetchone()[0])
print("points_log tersisa:", c.execute("SELECT COUNT(*) FROM points_log").fetchone()[0])

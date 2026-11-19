#!/usr/bin/env python3
"""Hapus santri TES v1.3.0 (PV-0002, PV-0003) + poin + sesi mereka,
supaya DB produksi kembali bersih (hanya PV-0001 'Tes').
Jalankan di VPS: python3 cleanup-v1.3.0.py"""
import sqlite3

c = sqlite3.connect("data/pesantren.db")
c.execute("DELETE FROM points_log WHERE santri_id IN ('PV-0002','PV-0003')")
c.execute("DELETE FROM sesi_login WHERE santri_id IN ('PV-0002','PV-0003')")
c.execute("DELETE FROM santri WHERE id IN ('PV-0002','PV-0003')")
c.commit()
print("santri:", list(c.execute("SELECT id, nama, ig_username, total_poin FROM santri")))
print("points_log:", c.execute("SELECT COUNT(*) FROM points_log").fetchone()[0])
print("sesi_login:", c.execute("SELECT COUNT(*) FROM sesi_login").fetchone()[0])
nxt = c.execute("SELECT MAX(CAST(SUBSTR(id,4) AS INTEGER)) FROM santri").fetchone()[0]
print("pendaftar berikut akan jadi: PV-%04d" % (nxt + 1))

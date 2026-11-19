#!/usr/bin/env python3
"""Patch server.py v1.4.0 -> v1.5.0: pustaka kitab (rak kitab interaktif).

ACC Mas 16 Nov 2026 ~18:47 WIB: Arab saja, Jurumiyah pertama, pengganti
3 kitab (Tahawiyya, al-Shafiya) diterima, atribusi OpenITI ditampilkan,
full MCP Shamela + terjemahan DITUNDA sampai ada gedung Perpustakaan.
Jurumiyah ditandai dicek_ustadz: false (teks wajib dicek ustadz sebelum
dibaca santri di game).

Pelajaran v1.4.0: patch script HARUS dicek output + diff-nya, bukan hanya
exit code (dulu main() terdefinisi tapi tidak pernah dipanggil).
Script ini: tiap penggantian dicek jumlah kemunculannya (harus tepat 1x),
lalu mencetak ringkasan + diff. Jalankan dari folder server:
    python3 patch-1.5.0.py
"""
import os
import subprocess
import sys

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "server.py")

KITAB_SECTION = '''
# ---------------------------------------------------------------- Pustaka kitab (v1.5.0)
# Rak kitab interaktif (ACC Mas 16 Nov 2026 ~18:47 WIB): Arab saja, kitab
# pertama Jurumiyah dari OpenITI (CC BY-NC-SA 4.0). File-based:
# kitab/*.json di folder yang sama dengan server.py — tambah kitab =
# tambah file JSON (tanpa migrasi DB, tanpa ubah kode). Tiap kitab
# ditandai dicek_ustadz — teks BELUM dicek ustadz (false) tidak boleh
# ditampilkan pembaca game; pengecekan adalah langkah manusia (ustadz),
# bukan tugas server. Full MCP Shamela + terjemahan DITUNDA sampai ada
# gedung Perpustakaan (200 santri).
ATRIBUSI_KITAB = "Teks: OpenITI (CC BY-NC-SA 4.0)"
KITAB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kitab")
KITAB_ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")
_kitab_cache = None


def _muat_kitab() -> dict:
    """Muat semua kitab/*.json sekali, cache di memori. File rusak /
    id tidak cocok nama file dilewati (tidak menggagalkan server)."""
    global _kitab_cache
    if _kitab_cache is not None:
        return _kitab_cache
    data = {}
    try:
        for nama in sorted(os.listdir(KITAB_DIR)):
            if not nama.endswith(".json"):
                continue
            kid = nama[:-5]
            if not KITAB_ID_RE.match(kid):
                continue
            try:
                with open(os.path.join(KITAB_DIR, nama), encoding="utf-8") as f:
                    d = json.load(f)
            except (OSError, ValueError):
                continue
            if not isinstance(d, dict) or d.get("id") != kid:
                continue
            data[kid] = d
    except OSError:
        pass
    _kitab_cache = data
    return data
'''

KITAB_HANDLERS = '''
    # -- pustaka kitab (v1.5.0) ----------------------------------
    # PUBLIK (tanpa token): membaca adalah aktivitas santri, game/app
    # memanggil langsung. Tiap respons mencantumkan atribusi OpenITI.
    # dicek_ustadz=false berarti teks BELUM dicek ustadz — pembaca game
    # hanya menampilkan kitab yang dicek_ustadz=true.
    def _kitab_daftar(self):
        kitab = _muat_kitab()
        daftar = []
        for kid in sorted(kitab):
            d = kitab[kid]
            daftar.append({
                "id": d.get("id"), "judul": d.get("judul"),
                "judul_latin": d.get("judul_latin"),
                "pengarang": d.get("pengarang"),
                "pengarang_latin": d.get("pengarang_latin"),
                "jumlah_bab": d.get("jumlah_bab", len(d.get("bab", []))),
                "ukuran_karakter": d.get("ukuran_karakter"),
                "dicek_ustadz": bool(d.get("dicek_ustadz", False)),
                "atribusi": d.get("atribusi", ATRIBUSI_KITAB),
            })
        self._send(200, {"ok": True, "atribusi": ATRIBUSI_KITAB,
                         "total": len(daftar), "kitab": daftar})

    def _kitab_baca(self, kid, qs):
        if not kid or not KITAB_ID_RE.match(kid):
            self._err(404, "Kitab tidak ditemukan")
            return
        d = _muat_kitab().get(kid)
        if d is None:
            self._err(404, "Kitab tidak ditemukan")
            return
        meta = {"ok": True, "id": d["id"], "judul": d["judul"],
                "judul_latin": d.get("judul_latin"),
                "pengarang": d.get("pengarang"),
                "dicek_ustadz": bool(d.get("dicek_ustadz", False)),
                "atribusi": d.get("atribusi", ATRIBUSI_KITAB)}
        bab_q = qs.get("bab", [""])[0]
        if bab_q:
            try:
                n = int(bab_q)
            except ValueError:
                self._err(400, "bab harus angka")
                return
            bab = next((b for b in d.get("bab", [])
                        if b.get("nomor") == n), None)
            if bab is None:
                self._err(404, "Bab tidak ditemukan")
                return
            meta["bab"] = bab
            self._send(200, meta)
            return
        meta.update({
            "pengarang_latin": d.get("pengarang_latin"),
            "sumber": d.get("sumber"), "sumber_url": d.get("sumber_url"),
            "edisi": d.get("edisi"), "lisensi": d.get("lisensi"),
            "jumlah_bab": d.get("jumlah_bab"),
            "ukuran_karakter": d.get("ukuran_karakter"),
            "bab": d.get("bab", [])})
        self._send(200, meta)
'''

# (old, new) — tiap old HARUS muncul tepat 1x.
PATCHES = [
    ('VERSION = "1.4.0"', 'VERSION = "1.5.0"'),
    ("  POST /api/lamaran/keputusan  -> keputusan Pengasuh (butuh token)",
     "  POST /api/lamaran/keputusan  -> keputusan Pengasuh (butuh token)\n"
     "  GET  /api/kitab             -> daftar kitab (publik)\n"
     "  GET  /api/kitab/<id>?bab=N  -> isi kitab / satu bab (publik)"),
    ("JEDA_LAMAR_HARI = 7", "JEDA_LAMAR_HARI = 7" + KITAB_SECTION),
    ('                                 "POST /api/lamaran/keputusan (token)",',
     '                                 "POST /api/lamaran/keputusan (token)",\n'
     '                                 "GET  /api/kitab (publik)",\n'
     '                                 "GET  /api/kitab/<id>?bab=N (publik)",'),
    ("""        elif u.path == "/api/lamaran/daftar":
            self._lamaran_daftar(parse_qs(u.query))""",
     """        elif u.path == "/api/lamaran/daftar":
            self._lamaran_daftar(parse_qs(u.query))
        elif u.path == "/api/kitab":
            self._kitab_daftar()
        elif u.path.startswith("/api/kitab/"):
            self._kitab_baca(u.path[len("/api/kitab/"):], parse_qs(u.query))"""),
    ("""        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "keputusan": keput, "status": keput,
                         "diputuskan_at": t})


def main():""",
     """        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "keputusan": keput, "status": keput,
                         "diputuskan_at": t})
""" + KITAB_HANDLERS + """

def main():"""),
]


def main():
    with open(PATH, encoding="utf-8") as f:
        src = f.read()
    if 'VERSION = "1.5.0"' in src:
        print("Sudah v1.5.0 — patch tidak dijalankan lagi.")
        return 0
    for i, (old, new) in enumerate(PATCHES, 1):
        n = src.count(old)
        print(f"Patch {i}: kemunculan old = {n} (harus 1)")
        if n != 1:
            print(f"GAGAL: patch {i} tidak diterapkan — old tidak unik.")
            return 1
        src = src.replace(old, new)
    with open(PATH, "w", encoding="utf-8") as f:
        f.write(src)
    print(f"OK: {len(PATCHES)}/{len(PATCHES)} penggantian diterapkan ke {PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

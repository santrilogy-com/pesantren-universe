#!/usr/bin/env python3
"""Konversi Jurumiyah OpenITI (mARkdown) -> JSON per bab untuk pustaka VPS.

Sumber (diambil ulang dari GitHub, bukan file /tmp):
  https://raw.githubusercontent.com/OpenITI/0725AH/master/data/0723IbnAjrum/0723IbnAjrum.Ajrumiyya/0723IbnAjrum.Ajrumiyya.Shamela0011371-ara1
  (21.326 byte; URI OpenITI: 0723IbnAjrum.Ajrumiyya.Shamela0011371)

Aturan konversi (dari riset RISET-KITAB-SHAMELA.md §3.1):
- Buang blok #META# dan penanda halaman "# PageV00P000".
- Judul bab dari "### | <judul>".
- Baris isi diawali "# "; baris lanjutan diawali "~~" (disambung ke baris
  sebelumnya dengan satu spasi).
- Penanda scan inline (PageV..P.. dan "ms2" dsb.) dibuang — itu bukan isi
  matn. Spasi ganda hasil pembuangan dirapikan.
- Teks Arab TIDAK diperbaiki diakritiknya — disimpan apa adanya; yang
  mengecek nanti ustadz (dicek_ustadz: false).

Keluaran: kitab/jurumiyah.json (di folder yang sama dengan script ini).
"""
import json
import os
import re
import sys
import urllib.request

URL = ("https://raw.githubusercontent.com/OpenITI/0725AH/master/data/"
       "0723IbnAjrum/0723IbnAjrum.Ajrumiyya/"
       "0723IbnAjrum.Ajrumiyya.Shamela0011371-ara1")
ATRIBUSI = "Teks: OpenITI (CC BY-NC-SA 4.0)"

PAGE_RE = re.compile(r"PageV\d+P\d+")
MS_RE = re.compile(r"\bms\d+\b")


def bersih_baris(s: str) -> str:
    """Buang penanda scan inline + rapikan spasi (isi matn tidak diubah)."""
    s = PAGE_RE.sub(" ", s)
    s = MS_RE.sub(" ", s)
    return re.sub(r"\s+", " ", s).strip()


def konversi(teks: str) -> dict:
    lines = teks.splitlines()
    # Lewati blok #META# (sampai "#META#Header#End#").
    i = 0
    while i < len(lines) and lines[i].strip() != "#META#Header#End#":
        i += 1
    i += 1  # lewati baris penutup header
    bab = []
    cur = None
    for raw in lines[i:]:
        line = raw.strip()
        if not line:
            continue
        if line.startswith("# PageV"):
            continue  # penanda halaman
        if line.startswith("### |"):
            judul = line[len("### |"):].strip()
            cur = {"nomor": len(bab) + 1, "judul": judul, "paragraf": []}
            bab.append(cur)
            continue
        if line.startswith("~~"):
            # Lanjutan baris sebelumnya: sambung dengan spasi.
            isi = bersih_baris(line[2:])
            if cur is not None and cur["paragraf"] and isi:
                cur["paragraf"][-1] = cur["paragraf"][-1] + " " + isi
            continue
        if line.startswith("# "):
            isi = bersih_baris(line[2:])
            if cur is not None and isi:
                cur["paragraf"].append(isi)
            continue
        # Baris lain (seharusnya tidak ada) — simpan apa adanya.
        if cur is not None:
            cur["paragraf"].append(bersih_baris(line))
    out_bab = []
    total_kar = 0
    for b in bab:
        teks_bab = "\n\n".join(b["paragraf"])
        total_kar += len(teks_bab)
        out_bab.append({"nomor": b["nomor"], "judul": b["judul"],
                        "teks": teks_bab,
                        "jumlah_karakter": len(teks_bab)})
    return {
        "id": "jurumiyah",
        "judul": "متن الآجرومية",
        "judul_latin": "Jurumiyah",
        "pengarang": "ابن آجروم، محمد بن محمد بن داود الصنهاجي، أبو عبد الله (المتوفى: 723هـ)",
        "pengarang_latin": "Ibn Ajrum (w. 723H)",
        "sumber": "OpenITI 0723IbnAjrum.Ajrumiyya.Shamela0011371-ara1",
        "sumber_url": URL,
        "shamela_id": 11371,
        "edisi": "1419هـ-1998م, دار الصميعي",
        "atribusi": ATRIBUSI,
        "lisensi": "CC BY-NC-SA 4.0",
        "dicek_ustadz": False,
        "jumlah_bab": len(out_bab),
        "ukuran_karakter": total_kar,
        "bab": out_bab,
    }


def main():
    out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kitab")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "jurumiyah.json")
    print("Unduh:", URL)
    with urllib.request.urlopen(URL, timeout=60) as r:
        raw = r.read()
    print("Ukuran mentah:", len(raw), "byte")
    teks = raw.decode("utf-8")
    data = konversi(teks)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
    print("Tersimpan:", out_path, os.path.getsize(out_path), "byte")
    print("Jumlah bab:", data["jumlah_bab"])
    print("Total karakter teks:", data["ukuran_karakter"],
          "(metadata OpenITI 8020 memakai cara hitung sendiri — tanpa spasi; "
          "teks bersih di sini 8493 tanpa spasi)")
    print("Bab 1:", data["bab"][0]["judul"], "| awal teks:",
          data["bab"][0]["teks"][:80])
    print("Bab terakhir:", data["bab"][-1]["judul"], "| akhir teks:",
          data["bab"][-1]["teks"][-60:])
    # Validasi ringan.
    assert data["jumlah_bab"] == 25, "bab bukan 25!"
    assert data["bab"][0]["judul"] == "مدخل"
    assert data["bab"][-1]["teks"].rstrip().endswith("تم بحمد الله")
    assert "PageV" not in json.dumps(data, ensure_ascii=False)
    assert "ms2" not in json.dumps(data, ensure_ascii=False)
    print("Validasi OK.")


if __name__ == "__main__":
    main()

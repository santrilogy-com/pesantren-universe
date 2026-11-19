#!/usr/bin/env python3
"""Konversi kitab OpenITI (mARkdown) + fawazahmed0 -> JSON pustaka VPS.

Pola sama seperti konversi-jurumiyah.py (16 Nov 2026). Aturan:
- Buang blok #META# dan penanda halaman "PageV..P.." / "msN".
- Mode "bab": judul bab dari "### | <judul>" (Jurumiyah, Imrithi, Abi Shuja).
- Mode "fasl": tiap "# (فصل) ..." membuka bab baru (Safinatun Naja).
- Baris isi diawali "# "; lanjutan diawali "~~" (disambung dgn satu spasi).
- Teks Arab TIDAK diperbaiki — disimpan apa adanya.
- dicek_ustadz: True (ACC Mas 17 Nov 2026 ~23:49 WIB: Jurumiyah + kitab
  lain sudah OK — cek ustadz lolos).

Keluaran: kitab/<id>.json di folder yang sama dengan script ini (di VPS).
Jalankan: python3 konversi-kitab.py [safinatun-naja|imrithi|abi-shuja|arbain-nawawi|semua]
"""
import json
import os
import re
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
KITAB_DIR = os.path.join(BASE, "kitab")
MENTAH_DIR = "/tmp/kitab-ingest"

PAGE_RE = re.compile(r"PageV\d+P\d+")
MS_RE = re.compile(r"\bms\d+\b")
STAR_RE = re.compile(r"\*+")

ATRIBUSI_OPENITI = "Teks: OpenITI (CC BY-NC-SA 4.0)"
ATRIBUSI_HADITH_API = "Teks: fawazahmed0/hadith-api (Unlicense)"


def bersih(s):
    s = PAGE_RE.sub(" ", s)
    s = MS_RE.sub(" ", s)
    return re.sub(r"\s+", " ", s).strip()


def bersih_judul(s):
    s = PAGE_RE.sub(" ", s)
    s = MS_RE.sub(" ", s)
    s = STAR_RE.sub(" ", s)
    return re.sub(r"\s+", " ", s).strip()


def lewati_meta(lines):
    i = 0
    while i < len(lines) and lines[i].strip() != "#META#Header#End#":
        i += 1
    return i + 1


def gabung_judul_terbelah(lines):
    """Gabung heading '### |' yang terbelah dua baris (mis. 'ك' + 'ان...')."""
    out = []
    k = 0
    while k < len(lines):
        line = lines[k]
        if line.strip().startswith("### |"):
            judul = bersih_judul(line.split("|", 1)[1])
            while (len(judul) <= 2 and k + 1 < len(lines)
                   and lines[k + 1].strip().startswith("### |")):
                k += 1
                judul += bersih_judul(lines[k].split("|", 1)[1])
            out.append("### | " + judul)
            k += 1
            continue
        out.append(line)
        k += 1
    return out


FASL_RE = re.compile(r"\(\s*فصل\s*\)")


def konversi_openiti(teks, mode):
    """Konversi teks OpenITI mARkdown -> daftar bab.

    Fase 1: gabung baris menjadi paragraf ("~~" adalah lanjutan baris
    sebelumnya; penanda halaman dibuang). Fase 2: susun bab — mode "bab"
    dari heading "### |", mode "fasl" dengan memecah paragraf di tiap
    marker (فصل) (marker bisa jatuh di tengah baris lanjutan karena
    pembungkusan baris OpenITI).
    """
    lines = teks.splitlines()
    i = lewati_meta(lines)
    lines = gabung_judul_terbelah(lines[i:])

    # Fase 1: item ("judul", teks) / ("paragraf", teks).
    items = []
    cur_para = None
    for raw in lines:
        line = raw.strip()
        if not line:
            continue
        if line.startswith("# PageV"):
            continue
        if mode == "bab" and line.startswith("### |"):
            if cur_para is not None:
                items.append(("paragraf", cur_para))
                cur_para = None
            judul = bersih_judul(line.split("|", 1)[1])
            if judul:
                items.append(("judul", judul))
            continue
        if line.startswith("~~"):
            isi = bersih(line[2:])
            if isi:
                cur_para = (cur_para + " " + isi) if cur_para else isi
            continue
        if line.startswith("# "):
            isi = bersih(line[2:])
            if not isi:
                continue
            if cur_para is not None:
                items.append(("paragraf", cur_para))
            cur_para = isi
            continue
        isi = bersih(line)
        if not isi:
            continue
        if cur_para is not None:
            items.append(("paragraf", cur_para))
        cur_para = isi
    if cur_para is not None:
        items.append(("paragraf", cur_para))

    # Fase 2: susun bab.
    bab = []
    cur = None

    def bab_baru(judul):
        nonlocal cur
        cur = {"nomor": len(bab) + 1, "judul": judul, "paragraf": []}
        bab.append(cur)

    def tambah_paragraf(teks):
        nonlocal cur
        if cur is None:
            bab_baru("مقدمة")
        if teks:
            cur["paragraf"].append(teks)

    for kind, teks in items:
        if kind == "judul":
            bab_baru(teks)
            continue
        if mode == "fasl" and FASL_RE.search(teks):
            parts = FASL_RE.split(teks)
            tambah_paragraf(parts[0].strip())
            for seg in parts[1:]:
                seg = seg.strip()
                if ":" in seg:
                    judul, sisa = seg.split(":", 1)
                    judul = judul.strip()
                    if len(judul) > 60:
                        judul = judul[:60].rsplit(" ", 1)[0]
                    bab_baru(judul)
                    tambah_paragraf(sisa.strip())
                else:
                    judul = seg
                    if len(judul) > 60:
                        judul = judul[:60].rsplit(" ", 1)[0]
                    bab_baru(judul)
            continue
        tambah_paragraf(teks)

    out_bab = []
    total_kar = 0
    for b in bab:
        teks_bab = "\n\n".join(b["paragraf"])
        total_kar += len(teks_bab)
        out_bab.append({"nomor": b["nomor"], "judul": b["judul"],
                        "teks": teks_bab,
                        "jumlah_karakter": len(teks_bab)})
    return out_bab, total_kar


ORDINAL = ["الأول", "الثاني", "الثالث", "الرابع", "الخامس", "السادس",
           "السابع", "الثامن", "التاسع", "العاشر", "الحادي عشر",
           "الثاني عشر", "الثالث عشر", "الرابع عشر", "الخامس عشر",
           "السادس عشر", "السابع عشر", "الثامن عشر", "التاسع عشر",
           "العشرون", "الحادي والعشرون", "الثاني والعشرون",
           "الثالث والعشرون", "الرابع والعشرون", "الخامس والعشرون",
           "السادس والعشرون", "السابع والعشرون", "الثامن والعشرون",
           "التاسع والعشرون", "الثلاثون", "الحادي والثلاثون",
           "الثاني والثلاثون", "الثالث والثلاثون", "الرابع والثلاثون",
           "الخامس والثلاثون", "السادس والثلاثون", "السابع والثلاثون",
           "الثامن والثلاثون", "التاسع والثلاثون", "الأربعون",
           "الحادي والأربعون", "الثاني والأربعون"]


def konversi_arbain(path):
    d = json.load(open(path, encoding="utf-8"))
    hadiths = sorted(d["hadiths"], key=lambda h: h["hadithnumber"])
    out_bab = []
    total_kar = 0
    for h in hadiths:
        n = h["hadithnumber"]
        teks = h["text"].strip()
        total_kar += len(teks)
        out_bab.append({"nomor": n,
                        "judul": "الحديث " + ORDINAL[n - 1],
                        "teks": teks,
                        "jumlah_karakter": len(teks)})
    return out_bab, total_kar


KONFIG = {
    "safinatun-naja": {
        "file": "safinatun-naja-ara1", "mode": "fasl",
        "judul": "متن سفينة النجا في أصول الدين والفقه",
        "judul_latin": "Safinatun Naja",
        "pengarang": "سالم بن سمير الحضرمي (المتوفى: 1271هـ)",
        "pengarang_latin": "Salim al-Hadrami (w. 1271H)",
        "sumber": "OpenITI 1271SalimHadrami.MatnSafinatNaja.ShamAY0037367-ara1",
        "sumber_url": ("https://raw.githubusercontent.com/OpenITI/1275AH/master/data/"
                       "1271SalimHadrami/1271SalimHadrami.MatnSafinatNaja/"
                       "1271SalimHadrami.MatnSafinatNaja.ShamAY0037367-ara1"),
        "shamela_id": 37367, "edisi": None,
        "atribusi": ATRIBUSI_OPENITI, "lisensi": "CC BY-NC-SA 4.0",
        "bab_harapan": 66,
    },
    "imrithi": {
        "file": "imrithi-ara1", "mode": "bab",
        "judul": "الدرة البهية نظم الآجرومية",
        "judul_latin": "Imrithi (ad-Durra al-Bahiyya)",
        "pengarang": ("يحيى بن نور الدين أبي الخير بن موسى العمريطي الشافعي "
                      "الأنصاري الأزهري، شرف الدين (المتوفى: 989هـ)"),
        "pengarang_latin": "al-Imriti (w. 989H)",
        "sumber": "OpenITI 0989SharafDinCimriti.DurraBahiyya.Shamela0002084-ara1",
        "sumber_url": ("https://raw.githubusercontent.com/OpenITI/1000AH/master/data/"
                       "0989SharafDinCimriti/0989SharafDinCimriti.DurraBahiyya/"
                       "0989SharafDinCimriti.DurraBahiyya.Shamela0002084-ara1"),
        "shamela_id": 2084, "edisi": None,
        "atribusi": ATRIBUSI_OPENITI, "lisensi": "CC BY-NC-SA 4.0",
        "bab_harapan": 34,  # 33 heading (2 terbelah digabung) + 1 مقدمة (basmala)
    },
    "abi-shuja": {
        "file": "abi-shuja-ara1", "mode": "bab",
        "judul": "الغاية والتقريب",
        "judul_latin": "Matn Abi Shuja",
        "pengarang": "أحمد بن الحسين بن أحمد، أبو شجاع، شهاب الدين الأصفهاني (المتوفى: 593هـ)",
        "pengarang_latin": "Abu Shuja (w. 593H)",
        "sumber": "OpenITI 0593IbnHusaynShihabDinIsbahani.GhayaWaTaqrib.Shamela0011370-ara1",
        "sumber_url": ("https://raw.githubusercontent.com/OpenITI/0600AH/master/data/"
                       "0593IbnHusaynShihabDinIsbahani/0593IbnHusaynShihabDinIsbahani.GhayaWaTaqrib/"
                       "0593IbnHusaynShihabDinIsbahani.GhayaWaTaqrib.Shamela0011370-ara1"),
        "shamela_id": 11370, "edisi": None,
        "atribusi": ATRIBUSI_OPENITI, "lisensi": "CC BY-NC-SA 4.0",
        "bab_harapan": 17,
    },
    "arbain-nawawi": {
        "file": "arba-in-nawawi.json", "mode": "hadith-api",
        "judul": "الأربعون النووية",
        "judul_latin": "Arbain Nawawi",
        "pengarang": "النووي، يحيى بن شرف، أبو زكريا (المتوفى: 676هـ)",
        "pengarang_latin": "al-Nawawi (w. 676H)",
        "sumber": "fawazahmed0/hadith-api (ara-nawawi)",
        "sumber_url": "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-nawawi.json",
        "shamela_id": None, "edisi": "fawazahmed0 hadith-api v1",
        "atribusi": ATRIBUSI_HADITH_API, "lisensi": "Unlicense",
        "bab_harapan": 42,
    },
}


def jalankan(kid):
    cfg = KONFIG[kid]
    path = os.path.join(MENTAH_DIR, cfg["file"])
    print(f"== {kid}: baca {path}")
    if cfg["mode"] == "hadith-api":
        out_bab, total_kar = konversi_arbain(path)
    else:
        teks = open(path, encoding="utf-8").read()
        out_bab, total_kar = konversi_openiti(teks, cfg["mode"])
    data = {
        "id": kid, "judul": cfg["judul"], "judul_latin": cfg["judul_latin"],
        "pengarang": cfg["pengarang"], "pengarang_latin": cfg["pengarang_latin"],
        "sumber": cfg["sumber"], "sumber_url": cfg["sumber_url"],
        "shamela_id": cfg["shamela_id"], "edisi": cfg["edisi"],
        "atribusi": cfg["atribusi"], "lisensi": cfg["lisensi"],
        "dicek_ustadz": True,
        "jumlah_bab": len(out_bab), "ukuran_karakter": total_kar,
        "bab": out_bab,
    }
    os.makedirs(KITAB_DIR, exist_ok=True)
    out_path = os.path.join(KITAB_DIR, kid + ".json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
    print(f"   tersimpan: {out_path} ({os.path.getsize(out_path)} byte)")
    print(f"   bab: {data['jumlah_bab']} (harapan {cfg['bab_harapan']}), "
          f"karakter: {total_kar}")
    print(f"   bab 1: {out_bab[0]['judul']} | awal: {out_bab[0]['teks'][:60]!r}")
    print(f"   bab akhir: {out_bab[-1]['judul']} | akhir: {out_bab[-1]['teks'][-50:]!r}")
    # Validasi.
    assert data["jumlah_bab"] == cfg["bab_harapan"], \
        f"bab {data['jumlah_bab']} != harapan {cfg['bab_harapan']}"
    assert all(b["teks"].strip() for b in out_bab), "ada bab kosong!"
    dump = json.dumps(data, ensure_ascii=False)
    assert "PageV" not in dump, "penanda PageV lolos!"
    assert not re.search(r"\bms\d+\b", dump), "penanda msN lolos!"
    print("   Validasi OK.")
    return data


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else "semua"
    urutan = ["safinatun-naja", "imrithi", "abi-shuja", "arbain-nawawi"]
    target = urutan if arg == "semua" else [arg]
    for kid in target:
        jalankan(kid)
    print("SELESAI.")


if __name__ == "__main__":
    main()

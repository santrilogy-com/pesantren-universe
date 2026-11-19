#!/bin/bash
# Ganti SEMUA tekstur game v2 -> .ktx2 ETC1S + linear (Mas ACC 21:33 WIB).
# ATOMIK per tekstur: (1) salin .ktx2, (2) perbarui referensi, (3) hapus sumber lama + .import (+ .uid bila ada).
# Urutan ini penting: snapshot staging di tengah jalan selalu valid (tidak pernah ada referensi menggantung).
# Jalankan dari tree kerja v2/godot-dunia. JANGAN jalankan bila render tanah linear / spot-check belum lolos.
set -u
# SUDAH DIJALANKAN 18 Nov 2026 (kompres massal selesai, 23/23 tekstur .ktx2).
# JANGAN jalankan ulang: tekstur lama sudah dihapus + GLB sudah diubah ke URI .ktx2
# (lihat CATATAN.md §8). Bila perlu ganti tekstur lagi, baca §8 dulu.
echo "ganti-tekstur.sh SUDAH dijalankan 18 Nov — berhenti. Baca CATATAN.md §8." >&2
exit 1
G="$HOME/workspace/pesantren-verse/v2/godot-dunia"
M="$HOME/workspace/pesantren-verse/v2/konsep/uji-kompres-tekstur/massal"
cd "$G" || exit 1

# $1=dir relatif (models|data/atlas) $2=basename tanpa ekstensi $3=ekstensi lama (jpg|png) $4=referensi: "file:lama" atau "-" bila tanpa referensi
ganti() {
  local dir="$1" base="$2" ext="$3" ref="$4"
  local src="$dir/$base.$ext" dst="$dir/$base.ktx2"
  [ -f "$M/$base.ktx2" ] || { echo "GAGAL $base: $M/$base.ktx2 tidak ada"; return 1; }
  cp "$M/$base.ktx2" "$dst" || { echo "GAGAL $base: cp gagal"; return 1; }
  if [ "$ref" != "-" ]; then
    local f="${ref%%:*}" lama="${ref#*:}"
    grep -q "$lama" "$f" || { echo "GAGAL $base: referensi '$lama' tidak ketemu di $f"; rm -f "$dst"; return 1; }
    sed -i "s|$lama|res://$dir/$base.ktx2|g" "$f"  # PERBAIKAN 18 Nov: dulu tanpa res:// -> referensi relatif || { echo "GAGAL $base: sed gagal"; rm -f "$dst"; return 1; }
    grep -q "$dir/$base.ktx2" "$f" || { echo "GAGAL $base: referensi baru tidak tertulis di $f"; rm -f "$dst"; return 1; }
  fi
  rm -f "$src" "$src.import" "$src.uid"
  echo "OK $base ($ext -> ktx2) $(stat -c%s "$dst") B"
}

# --- models: ada referensi kode ---
ganti models dinding_white_plaster_02_1k jpg "scripts/material_tekstur.gd:res://models/dinding_white_plaster_02_1k.jpg"
ganti models pondasi_stone_block_wall_1k jpg "scripts/material_tekstur.gd:res://models/pondasi_stone_block_wall_1k.jpg"
ganti models lantai_stone_floor_1k jpg "scripts/material_tekstur.gd:res://models/lantai_stone_floor_1k.jpg"
ganti models taman_leafy_grass_1k jpg "scripts/kampus_putri.gd:res://models/taman_leafy_grass_1k.jpg"
ganti models taman_cobblestone_01_1k jpg "scripts/kampus_putri.gd:res://models/taman_cobblestone_01_1k.jpg"
ganti models taman_farm_soil_1k jpg "scripts/kampus_putri.gd:res://models/taman_farm_soil_1k.jpg"
ganti models cotton_jersey_diff_1k jpg "scripts/player.gd:res://models/cotton_jersey_diff_1k.jpg"

# --- models: TANPA referensi (tetap dikompres, bukan dibuang — buang aset masih ditunda) ---
ganti models gubuk-santri_brown_planks_04_1k jpg "-"
ganti models pagar-bambu_brown_planks_04_1k jpg "-"
ganti models pagar-bata_brick_wall_001_1k jpg "-"
ganti models pohon-hias_bark_brown_01_1k jpg "-"
ganti models pohon-rindang_bark_brown_01_1k jpg "-"
ganti models sawah_brown_mud_03_1k jpg "-"
ganti models sawah_farm_soil_1k jpg "-"
ganti models taman_brown_planks_04_1k jpg "-"
ganti models surau-v2_kisi png "-"
ganti models surau-v2_plakat png "-"

# --- atlas: referensi di data/buku.json (dibaca reader via hal["gambar"]) ---
ganti data/atlas atlas-area-putra png "data/buku.json:res://data/atlas/atlas-area-putra.png"
ganti data/atlas atlas-kampus-putri png "data/buku.json:res://data/atlas/atlas-kampus-putri.png"
ganti data/atlas atlas-kawasan-bersama png "data/buku.json:res://data/atlas/atlas-kawasan-bersama.png"
ganti data/atlas atlas-zona-penyangga png "data/buku.json:res://data/atlas/atlas-zona-penyangga.png"
ganti data/atlas konsep-v2 png "data/buku.json:res://data/atlas/konsep-v2.png"
ganti data/atlas masterplan-v2 png "data/buku.json:res://data/atlas/masterplan-v2.png"

# --- tes: asersi halaman 1 atlas di test_baca_buku.gd ikut jalur baru ---
sed -i "s|res://data/atlas/masterplan-v2.png|res://data/atlas/masterplan-v2.ktx2|g" skrip/test_baca_buku.gd
grep -q "masterplan-v2.ktx2" skrip/test_baca_buku.gd && echo "OK test_baca_buku.gd (asersi masterplan -> ktx2)" || echo "GAGAL test_baca_buku.gd"

echo "=== selesai ==="
echo "sisa .jpg/.png di models+atlas (harusnya 0):"
find models data/atlas -type f \( -name "*.jpg" -o -name "*.png" \) | wc -l
echo "sisa referensi lama (harusnya 0):"
grep -r "taman_leafy_grass_1k.jpg\|taman_farm_soil_1k.jpg\|taman_cobblestone_01_1k.jpg\|cotton_jersey_diff_1k.jpg\|dinding_white_plaster_02_1k.jpg\|pondasi_stone_block_wall_1k.jpg\|lantai_stone_floor_1k.jpg\|atlas-area-putra.png\|atlas-kampus-putri.png\|atlas-kawasan-bersama.png\|atlas-zona-penyangga.png\|konsep-v2.png\|masterplan-v2.png" scripts/ data/ skrip/ 2>/dev/null | grep -v ".godot" | wc -l

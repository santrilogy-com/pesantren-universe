#!/bin/bash
# Gate Penutup 20261119-5 (Eka) — re-run penutup atas tree final.
# Alasan tiap re-run (semua terbukti artefak harness/tes, BUKAN regresi game):
# 1. test_tombol_telepon 37/38 — ekspektasi stempel hardcoded "20261119-4"
#    (test_tombol_telepon.gd:284). DIPERBAIKI: bandingkan ke
#    PesantrenUI.BUILD_STAMP (sesuai maksud komentar di baris 281-283).
# 2. test_salaman 30/36 (f7 guru) — cooldown pemain 5 dtk diukur WAKTU
#    NYATA (Time.get_ticks_msec) sementara tunggu tes diukur WAKTU GAME
#    (create_timer); headless --fixed-fps 60 jalan ~5-6x waktu nyata,
#    jadi tunggu 8 dtk game habis sebelum cooldown 5 dtk nyata lewat
#    (bukti: tes selesai 9 dtk dinding; debug siap=false). Re-run TANPA
#    --fixed-fps (waktu game = waktu dinding) — harus 36/36.
# 3. test_mp_alur_web 9/9 + 1 BLOKIR — stagger 20 dtk dinding saya di
#    gate utama TERLALU PANJANG: jendela tunggu peer 60 dtk game (~10-12
#    dtk dinding) habis sebelum klien kedua start. Re-run SIMULTAN
#    (pola gate -4: 11/11).
# 4. test_salaman_mp 3/3 + 1 GAGAL + 1 BLOKIR — sebab sama, stagger 30
#    dtk dinding > jendela tunggu peer. Re-run SIMULTAN.
# Urutan: telepon (Xvfb) -> salaman nofps -> MP simultan -> salaman_mp simultan.
set -u
REAL_HOME="$HOME"
GODOT="$REAL_HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$REAL_HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$REAL_HOME/workspace/.logs-gate-18nov/gate-20261119-5"
ISO_HOME="/tmp/iso-gate-20261119-5"
cd "$PROJ" || exit 1
echo "LOGDIR=$LOGDIR (penutup, tree final)"

# --- 1. test_tombol_telepon di Xvfb :95 ---
Xvfb :95 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-95-penutup.log" 2>&1 &
XVFB95=$!
sleep 3
if kill -0 $XVFB95 2>/dev/null; then
  echo "=== test_tombol_telepon ULANG [Xvfb :95] ==="
  timeout 900 env DISPLAY=":95" HOME="$ISO_HOME" "$GODOT" --path . skrip/test_tombol_telepon.tscn --resolution 412x892 > "$LOGDIR/test_tombol_telepon-ulang.log" 2>&1
  echo "test_tombol_telepon-ulang exit=$?"
  grep -E "TES TELEPON: LULUS=" "$LOGDIR/test_tombol_telepon-ulang.log"
  grep -E "^GAGAL:|TELEPON GAGAL" "$LOGDIR/test_tombol_telepon-ulang.log" | head -5
  grep -iE "SCRIPT ERROR" "$LOGDIR/test_tombol_telepon-ulang.log" | head -3
  kill $XVFB95 2>/dev/null; wait $XVFB95 2>/dev/null
else
  echo "Xvfb :95 GAGAL start — telepon-ulang DI-SKIP"
fi

# --- 2. test_salaman TANPA fixed-fps ---
echo "=== test_salaman ULANG (TANPA fixed-fps) ==="
timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --path . skrip/test_salaman.tscn > "$LOGDIR/test_salaman-ulang-nofps.log" 2>&1
echo "test_salaman-ulang-nofps exit=$?"
grep -E "SALAMAN-SELESAI" "$LOGDIR/test_salaman-ulang-nofps.log"
grep -E "^GAGAL:" "$LOGDIR/test_salaman-ulang-nofps.log" | head -10
grep -iE "SCRIPT ERROR" "$LOGDIR/test_salaman-ulang-nofps.log" | head -3

# --- 3. test_mp_alur_web SIMULTAN ---
echo "=== test_mp_alur_web ULANG 2 klien SIMULTAN ==="
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 > "$LOGDIR/test_mp_alur_web-ulang-putra.log" 2>&1 &
_mp1=$!
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putri --mp-web-nama "Tes MP Putri" --mp-web-jk putri --mp-web-id PV-0005 > "$LOGDIR/test_mp_alur_web-ulang-putri.log" 2>&1 &
_mp2=$!
wait $_mp1; _e1=$?; wait $_mp2; _e2=$?
for _f in test_mp_alur_web-ulang-putra test_mp_alur_web-ulang-putri; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
done
echo "test_mp_alur_web-ulang putra exit=$_e1 putri exit=$_e2"

# --- 4. test_salaman_mp SIMULTAN ---
echo "=== test_salaman_mp ULANG 2 klien SIMULTAN ==="
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_salaman_mp.tscn -- --mp-web-ig test_mp_putra2 --mp-web-nama "Tes MP Putra 2" --mp-web-jk putra --mp-web-id PV-0014 --mp-salaman-peran penjawab > "$LOGDIR/test_salaman_mp-ulang-penjawab.log" 2>&1 &
_s1=$!
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_salaman_mp.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 --mp-salaman-peran pengajak > "$LOGDIR/test_salaman_mp-ulang-pengajak.log" 2>&1 &
_s2=$!
wait $_s1; _se1=$?; wait $_s2; _se2=$?
for _f in test_salaman_mp-ulang-penjawab test_salaman_mp-ulang-pengajak; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
  grep -iE "SCRIPT ERROR" "$LOGDIR/$_f.log" | head -3
done
echo "test_salaman_mp-ulang penjawab exit=$_se1 pengajak exit=$_se2"
echo "=== PENUTUP SELESAI ==="

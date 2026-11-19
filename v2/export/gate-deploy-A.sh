#!/bin/bash
# Gate Deploy A (reset putri + rantai putri + Fatimah + lighting Fase 2 +
# strip atas 64 + siwak/menoleh + petunjuk santri baru) — Eka.
# Dijalankan dari TREE KERJA setelah perbaikan Kirana (jilbab ikut menoleh) masuk.
# PERBEDAAN vs gate 1952: test_kamera TANPA --fixed-fps 60 (pengukuran
# laju pakai wall-clock); sisanya tetap --fixed-fps 60.
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$HOME/workspace/pesantren-verse/v2/export/gate-deploy-$(date +%Y%m%d-%H%M)"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
echo "LOGDIR=$LOGDIR"

run_test() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) $* ==="
  timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$log" 2>&1
  local code=$?
  local lulus gagal
  lulus=$(grep -c "^LULUS:" "$log" || true)
  gagal=$(grep -c "^GAGAL:" "$log" || true)
  echo "$name: exit=$code LULUS=$lulus GAGAL=$gagal"
  if [ "$gagal" != "0" ]; then
    echo "--- GAGAL lines ($name) ---"
    grep "^GAGAL:" "$log"
  fi
  grep -iE "SCRIPT ERROR" "$log" | head -5
  echo "$name exit=$code LULUS=$lulus GAGAL=$gagal" >> "$LOGDIR/RINGKASAN.txt"
}

run_test_nofps() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) TANPA fixed-fps $* ==="
  timeout 900 "$GODOT" --headless --path . "$scene" "$@" > "$log" 2>&1
  local code=$?
  local lulus gagal
  lulus=$(grep -c "^LULUS:" "$log" || true)
  gagal=$(grep -c "^GAGAL:" "$log" || true)
  echo "$name: exit=$code LULUS=$lulus GAGAL=$gagal"
  if [ "$gagal" != "0" ]; then
    echo "--- GAGAL lines ($name) ---"
    grep "^GAGAL:" "$log"
  fi
  grep -iE "SCRIPT ERROR" "$log" | head -5
  echo "$name exit=$code LULUS=$lulus GAGAL=$gagal" >> "$LOGDIR/RINGKASAN.txt"
}

run_test_xvfb() {
  local name="$1" scene="$2" display="$3"
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) [Xvfb $display] ==="
  Xvfb "$display" -screen 0 800x1700x24 > /tmp/xvfb-gate-A.log 2>&1 &
  local xvfb_pid=$!
  sleep 3
  timeout 900 env DISPLAY="$display" "$GODOT" --path . "$scene" > "$log" 2>&1
  local code=$?
  kill $xvfb_pid 2>/dev/null; wait $xvfb_pid 2>/dev/null
  local lulus gagal
  lulus=$(grep -c "^LULUS:" "$log" || true)
  gagal=$(grep -c "^GAGAL:" "$log" || true)
  echo "$name: exit=$code LULUS=$lulus GAGAL=$gagal"
  if [ "$gagal" != "0" ]; then
    echo "--- GAGAL lines ($name) ---"
    grep "^GAGAL:" "$log"
  fi
  grep -iE "SCRIPT ERROR" "$log" | head -5
  echo "$name exit=$code LULUS=$lulus GAGAL=$gagal" >> "$LOGDIR/RINGKASAN.txt"
}

: > "$LOGDIR/RINGKASAN.txt"
run_test test_v2 skrip/test_v2.tscn
run_test test_hud_rombak skrip/test_hud_rombak.tscn
run_test test_ui_misi skrip/test_ui_misi.tscn
run_test_nofps test_kamera skrip/test_kamera.tscn
run_test test_jalan_mundur skrip/test_jalan_mundur.tscn
# test_mp_alur_web: WAJIB 2 klien paralel (putra + putri) — cek (e) butuh
# avatar peer; jalan sendiri hasilnya BLOKIR (bukan bug produk).
echo "=== test_mp_alur_web 2 klien paralel ==="
timeout 600 "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 > "$LOGDIR/test_mp_alur_web-2klien-putra.log" 2>&1 &
_mp1=$!
timeout 600 "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putri --mp-web-nama "Tes MP Putri" --mp-web-jk putri --mp-web-id PV-0005 > "$LOGDIR/test_mp_alur_web-2klien-putri.log" 2>&1 &
_mp2=$!
wait $_mp1; _e1=$?; wait $_mp2; _e2=$?
for _f in test_mp_alur_web-2klien-putra test_mp_alur_web-2klien-putri; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
done
echo "test_mp_alur_web 2klien putra exit=$_e1 putri exit=$_e2" >> "$LOGDIR/RINGKASAN.txt"

# test_adzan: file aslinya di fitur-baru/skrip (res://test_adzan.gd di root proyek).
# Salin sementara ke root proyek v2, jalankan, lalu HAPUS (jangan ikut export).
echo "=== test_adzan (salin sementara dari fitur-baru) ==="
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.gd" ./test_adzan.gd
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.tscn" ./test_adzan.tscn
timeout 900 "$GODOT" --headless --fixed-fps 60 --path . test_adzan.tscn > "$LOGDIR/test_adzan.log" 2>&1
code=$?
pass=$(grep -c "^PASS" "$LOGDIR/test_adzan.log" || true)
fail=$(grep -c "^FAIL" "$LOGDIR/test_adzan.log" || true)
echo "test_adzan: exit=$code PASS=$pass FAIL=$fail"
grep -E "^FAIL" "$LOGDIR/test_adzan.log" | head -10
grep -E "TES ADZAN" "$LOGDIR/test_adzan.log" | head -3
echo "test_adzan exit=$code PASS=$pass FAIL=$fail" >> "$LOGDIR/RINGKASAN.txt"
rm -f ./test_adzan.gd ./test_adzan.tscn ./test_adzan.gd.uid ./test_adzan.tscn.uid
ls test_adzan.* 2>/dev/null || echo "test_adzan sementara: sudah dihapus"

run_test_xvfb test_chat_fullscreen skrip/test_chat_fullscreen.tscn :97
echo "=== RINGKASAN ==="
cat "$LOGDIR/RINGKASAN.txt"

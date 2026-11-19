#!/bin/bash
# Gate export bundle 18 Nov 2026 (MP fix + adzan + chat fullscreen + idle
# + kamera + taman r4) — Rangga. Dijalankan dari SALINAN export
# (v2-export-copy/godot-dunia), BUKAN tree kerja (ui.gd tree sedang
# dirombak Tara untuk deploy berikutnya).
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2-export-copy/godot-dunia"
LOGDIR="$HOME/workspace/pesantren-verse/v2/export/gate-bundle-20261118-1447"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1

run_test() {
  local name="$1" scene="$2"
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) ==="
  timeout 600 "$GODOT" --headless --path . "$scene" > "$log" 2>&1
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
  local name="$1" scene="$2"
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) [Xvfb :99] ==="
  timeout 600 env DISPLAY=:99 "$GODOT" --path . "$scene" > "$log" 2>&1
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

: > "$LOGDIR/RINGKASAN.txt"
run_test test_v2 skrip/test_v2.tscn
run_test audit_karakter_primitif skrip/audit_karakter_primitif.tscn
run_test test_interior_asrama_putra skrip/test_interior_asrama_putra.tscn
run_test test_interior_asrama_putri skrip/test_interior_asrama_putri.tscn
run_test test_wiring_putra skrip/test_wiring_putra.tscn
run_test test_wiring_putri skrip/test_wiring_putri.tscn
run_test test_kasur skrip/test_kasur.tscn
run_test test_pencahayaan skrip/test_pencahayaan.tscn
run_test test_integrasi_pencahayaan skrip/test_integrasi_pencahayaan.tscn
run_test test_kamera skrip/test_kamera.tscn
run_test test_halaman_putri skrip/test_halaman_putri.tscn
run_test test_perluasan_putri skrip/test_perluasan_putri.tscn
run_test test_mp_alur_web skrip/test_mp_alur_web.tscn
run_test test_adzan skrip/test_adzan.tscn
run_test test_idle_diam skrip/test_idle_diam.tscn
run_test test_animasi_mixamo skrip/test_animasi_mixamo.tscn
run_test test_baca_buku skrip/test_baca_buku.tscn
run_test test_tabrakan_dunia skrip/test_tabrakan_dunia.tscn
run_test test_pintu_luar_putri skrip/test_pintu_luar_putri.tscn
run_test test_npc_tangga skrip/test_npc_tangga.tscn
run_test test_registrasi_gender skrip/test_registrasi_gender.tscn
run_test test_interior_gedung_putri skrip/test_interior_gedung_putri.tscn
run_test_xvfb test_chat_fullscreen skrip/test_chat_fullscreen.tscn
echo "=== RINGKASAN ==="
cat "$LOGDIR/RINGKASAN.txt"

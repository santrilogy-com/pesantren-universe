#!/bin/bash
# Gate export hijab rebuild — Rangga, 18 Nov 2026 ~12:57 WIB
# Jalankan semua tes headless dari tree kerja godot-dunia.
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$HOME/workspace/pesantren-verse/v2/export/gate-hijab-rebuild-20261118-1257"
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
  grep -iE "SCRIPT ERROR|ERROR:" "$log" | head -5
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
echo "=== RINGKASAN ==="
cat "$LOGDIR/RINGKASAN.txt"

#!/bin/bash
# Gate Sentuh 20261119-6 (Eka) — ULANG seksi sentuh yang ter-skip di
# gate utama karena Xvfb :95 sudah dipakai server basi (PID 15459,
# sisa sesi Sinta 16:11). Pakai display SEGAR :97 (1280x1024) + :96
# (800x1700), probe dulu. Pola gate-deploy-20261119-5.sh §5–6.
set -u
REAL_HOME="$HOME"
GODOT="$REAL_HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$REAL_HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$REAL_HOME/workspace/.logs-gate-18nov/gate-20261119-6"
ISO_HOME="/tmp/iso-gate-20261119-6"
cd "$PROJ" || exit 1

ringkas() {
  local name="$1" log="$2"
  local lulus gagal blokir
  lulus=$(grep -cE "^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|PCK LULUS:|PCK3 LULUS:|PCK4 LULUS:|FIELD LULUS:|REG LULUS:|  OK: )" "$log" || true)
  gagal=$(grep -cE "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" || true)
  blokir=$(grep -c "^BLOKIR:" "$log" || true)
  echo "$name: LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir"
  echo "$name LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir" >> "$LOGDIR/RINGKASAN-SENTUH.txt"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=|TES .*lulus|HASIL: [0-9]+ lulus|SELESAI lulus=" "$log" | tail -3
}

Xvfb :97 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-97.log" 2>&1 &
XVFB97=$!
Xvfb :96 -screen 0 800x1700x24 > "$LOGDIR/xvfb-96.log" 2>&1 &
XVFB96=$!
sleep 3
XVFB_OK=1
for p in $XVFB97 $XVFB96; do
  if ! kill -0 $p 2>/dev/null; then echo "Xvfb PID $p GAGAL start"; XVFB_OK=0; fi
done
if [ "$XVFB_OK" = 1 ]; then
  echo "=== PROBE Xvfb :97 — Godot GUI quit-after 60 (timeout 300) ==="
  timeout 300 env DISPLAY=":97" HOME="$ISO_HOME" "$GODOT" --path . --quit-after 60 --resolution 412x892 > "$LOGDIR/xvfb-probe-97.log" 2>&1
  _pe=$?
  echo "probe exit=$_pe"
  if [ "$_pe" = 124 ]; then echo "PROBE TIMEOUT — Xvfb/Godot GUI MACET, seksi sentuh DI-SKIP"; XVFB_OK=0; fi
  tail -5 "$LOGDIR/xvfb-probe-97.log"
else
  echo "Xvfb gagal start — seksi sentuh DI-SKIP"
fi
echo "XVFB_OK=$XVFB_OK" >> "$LOGDIR/RINGKASAN-SENTUH.txt"

run_test_xvfb() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) [Xvfb :97] $* ==="
  timeout 900 env DISPLAY=":97" HOME="$ISO_HOME" "$GODOT" --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

: > "$LOGDIR/RINGKASAN-SENTUH.txt"
if [ "$XVFB_OK" = 1 ]; then
  run_test_xvfb test_tombol_sentuh skrip/test_tombol_sentuh.tscn --resolution 412x892
  run_test_xvfb test_tombol_telepon skrip/test_tombol_telepon.tscn --resolution 412x892
  run_test_xvfb test_login_tombol skrip/test_login_tombol.tscn --resolution 412x892
  run_test_xvfb test_login_field-portrait skrip/test_login_field.tscn --resolution 412x892
  run_test_xvfb test_login_field-landscape skrip/test_login_field.tscn --resolution 892x412
  run_test_xvfb test_login_field_register skrip/test_login_field_register.tscn --resolution 412x892
  run_test_xvfb test_diag_toggle skrip/test_diag_toggle.tscn --resolution 412x892
  run_test_xvfb test_kualitas_adaptif skrip/test_kualitas_adaptif.tscn --resolution 1280x720
  run_test_xvfb test_msaa skrip/test_msaa.tscn --resolution 1280x720
  run_test_xvfb test_sentuh_vs_mouse skrip/test_sentuh_vs_mouse.tscn --resolution 892x412
  run_test_xvfb test_ruang_belajar_teks_sentuh skrip/test_ruang_belajar_teks_sentuh.tscn --resolution 1280x720 --audio-driver Dummy
  echo "=== test_chat_fullscreen [Xvfb :96 800x1700] ==="
  timeout 900 env DISPLAY=":96" HOME="$ISO_HOME" "$GODOT" --path . skrip/test_chat_fullscreen.tscn > "$LOGDIR/test_chat_fullscreen.log" 2>&1
  echo "test_chat_fullscreen exit=$?"
  ringkas test_chat_fullscreen "$LOGDIR/test_chat_fullscreen.log"
else
  echo "SEKSI SENTUH DI-SKIP (probe Xvfb gagal)" | tee -a "$LOGDIR/RINGKASAN-SENTUH.txt"
fi
kill $XVFB97 2>/dev/null; wait $XVFB97 2>/dev/null
kill $XVFB96 2>/dev/null; wait $XVFB96 2>/dev/null
echo "=== RINGKASAN SENTUH GATE 20261119-6 ==="
cat "$LOGDIR/RINGKASAN-SENTUH.txt"

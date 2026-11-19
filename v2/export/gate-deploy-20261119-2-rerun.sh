#!/bin/bash
# Re-run gate 20261119-2 — hanya tes yang gagal + sanity sentuh,
# setelah perbaikan: (1) project.godot komentar '#' -> ';' (Opsi A
# kini benar-benar aktif), (2) pin tingkat Sedang di test_pencahayaan
# + test_cek_perf_setting, (3) stempel 20261119-2 di test_tombol_telepon,
# (4) unmute di test_adzan. Save lokal direset dulu (kontaminasi
# kualitas_tingkat=ringan + suara_mati=true dari run sebelumnya).
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$HOME/workspace/.logs-gate-18nov/gate-20261119-2-rerun"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
SAVE="$HOME/.local/share/godot/app_userdata/Pesantren Universe v2/santri.json"
if [ -f "$SAVE" ]; then cp "$SAVE" "$LOGDIR/santri.json.sebelum-reset"; rm "$SAVE"; echo "save lokal direset (backup di $LOGDIR/santri.json.sebelum-reset)"; fi

ringkas() {
  local name="$1" log="$2"
  echo "$name: LULUS=$(grep -cE '^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|  OK: )' "$log") GAGAL=$(grep -cE '^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|  GAGAL: )' "$log")"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=|TES .*lulus|CEK PERF SETTING:|TES ADZAN:" "$log" | head -3
  grep -E "emulate_mouse_from_touch" "$log" | head -3
}

run_test() {
  local name="$1" scene="$2"; shift 2
  echo "=== $name headless fixed-fps 60 ==="
  timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$LOGDIR/$name.log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$LOGDIR/$name.log"
}

Xvfb :96 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-96.log" 2>&1 &
XVFB_PID=$!
sleep 3
run_xvfb() {
  local name="$1" scene="$2"; shift 2
  echo "=== $name [Xvfb :96] $* ==="
  timeout 900 env DISPLAY=":96" "$GODOT" --path . "$scene" "$@" > "$LOGDIR/$name.log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$LOGDIR/$name.log"
}

run_test test_pencahayaan skrip/test_pencahayaan.tscn
run_test test_cek_perf_setting skrip/test_cek_perf_setting.tscn
grep -E "CEK:" "$LOGDIR/test_cek_perf_setting.log"
run_xvfb test_tombol_telepon skrip/test_tombol_telepon.tscn --resolution 412x892
run_xvfb test_login_tombol skrip/test_login_tombol.tscn --resolution 412x892
run_xvfb test_diag_toggle skrip/test_diag_toggle.tscn --resolution 412x892
run_xvfb test_tombol_sentuh skrip/test_tombol_sentuh.tscn --resolution 412x892
kill $XVFB_PID 2>/dev/null; wait $XVFB_PID 2>/dev/null
echo "=== test_adzan (salin sementara) ==="
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.gd" ./test_adzan.gd
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.tscn" ./test_adzan.tscn
timeout 900 "$GODOT" --headless --fixed-fps 60 --path . test_adzan.tscn > "$LOGDIR/test_adzan.log" 2>&1
code=$?
echo "test_adzan: exit=$code PASS=$(grep -c '^PASS' "$LOGDIR/test_adzan.log") FAIL=$(grep -c '^FAIL' "$LOGDIR/test_adzan.log")"
grep -E "^FAIL" "$LOGDIR/test_adzan.log" | head -10
rm -f ./test_adzan.gd ./test_adzan.tscn ./test_adzan.gd.uid ./test_adzan.tscn.uid
echo "=== RERUN SELESAI ==="

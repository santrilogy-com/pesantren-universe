#!/bin/bash
# Re-run gate 20261119-2 pasca-debounce Tara — hanya 6 tes yang menyentuh UI,
# setelah perbaikan debounce toggle di scripts/ui.gd (abaikan pressed ke-2
# pada tombol yang sama dalam 200 ms). Tes lain yang sudah hijau sebelum
# perubahan tidak diulang (perintah Xam 19 Nov ~14:05 WIB).
# Pola invokasi = gate-deploy-20261119-2.sh (headless fixed-fps 60;
# tes sentuh Xvfb :96 --resolution 412x892; chat_fullscreen Xvfb :97 800x1700).
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$HOME/workspace/.logs-gate-18nov/gate-20261119-2-debounce"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
SAVE="$HOME/.local/share/godot/app_userdata/Pesantren Universe v2/santri.json"
if [ -f "$SAVE" ]; then cp "$SAVE" "$LOGDIR/santri.json.sebelum-reset"; rm "$SAVE"; echo "save lokal direset (backup di $LOGDIR/santri.json.sebelum-reset)"; fi

ringkas() {
  local name="$1" log="$2"
  echo "$name: LULUS=$(grep -cE '^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|  OK: )' "$log") GAGAL=$(grep -cE '^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|  GAGAL: )' "$log")"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=" "$log" | head -3
}

run_test() {
  local name="$1" scene="$2"; shift 2
  echo "=== $name headless fixed-fps 60 ==="
  timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$LOGDIR/$name.log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$LOGDIR/$name.log"
}

run_xvfb() {
  local name="$1" scene="$2"; shift 2
  echo "=== $name [Xvfb :96] $* ==="
  timeout 900 env DISPLAY=":96" "$GODOT" --path . "$scene" "$@" > "$LOGDIR/$name.log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$LOGDIR/$name.log"
}

run_test test_hud_rombak skrip/test_hud_rombak.tscn
run_test test_ui_misi skrip/test_ui_misi.tscn
run_test test_petunjuk_santri_baru skrip/test_petunjuk_santri_baru.tscn
run_test test_teka_teki skrip/test_teka_teki.tscn

Xvfb :96 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-96.log" 2>&1 &
XVFB_PID=$!
sleep 3
run_xvfb test_tombol_sentuh skrip/test_tombol_sentuh.tscn --resolution 412x892
kill $XVFB_PID 2>/dev/null; wait $XVFB_PID 2>/dev/null

echo "=== test_chat_fullscreen [Xvfb :97 800x1700] ==="
Xvfb :97 -screen 0 800x1700x24 > "$LOGDIR/xvfb-97.log" 2>&1 &
XVFB97=$!
sleep 3
timeout 900 env DISPLAY=":97" "$GODOT" --path . skrip/test_chat_fullscreen.tscn > "$LOGDIR/test_chat_fullscreen.log" 2>&1
echo "test_chat_fullscreen exit=$?"
kill $XVFB97 2>/dev/null; wait $XVFB97 2>/dev/null
ringkas test_chat_fullscreen "$LOGDIR/test_chat_fullscreen.log"
echo "=== DEBOUNCE RERUN SELESAI ==="

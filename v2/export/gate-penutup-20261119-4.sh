#!/bin/bash
# Gate 20261119-4 — PENUTUP (Eka). Re-run di tree FINAL (Panel Misi v2 +
# perbaikan pill AKTIF radius 12 + hapus shadow_color StyleBoxTexture):
#  - test_ui_misi + test_ruang_belajar_chat (tree pra-v2 di run utama)
#  - test_npc_20 + test_pencahayaan (kena 1 SCRIPT ERROR shadow_color
#    di run lanjutan saat draf v2 pertama masih di tree — verifikasi
#    hilang di tree final)
#  - test_profil_render (rumus frustum diperbaiki Eka)
#  - test_tombol_telepon di Xvfb :94 segar (ekspektasi stempel -4)
# Menambah ke RINGKASAN.txt yang sama. Foto web + export + staging
# langkah berikut (skrip terpisah), BUKAN di sini.
set -u
REAL_HOME="$HOME"
GODOT="$REAL_HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$REAL_HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$REAL_HOME/workspace/.logs-gate-18nov/gate-20261119-4"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
echo "LOGDIR=$LOGDIR (penutup, tree final)"

ISO_HOME="/tmp/iso-gate-20261119-4"
rm -rf "$ISO_HOME"
mkdir -p "$ISO_HOME/.local/share/godot/app_userdata"
cp -r "$REAL_HOME/.local/share/godot/app_userdata/Pesantren Universe v2" "$ISO_HOME/.local/share/godot/app_userdata/" 2>/dev/null \
  && echo "save asli di-seed ulang ke ISO_HOME" || echo "PERINGATAN: save asli TIDAK ketemu untuk di-seed"

ringkas() {
  local name="$1" log="$2"
  local lulus gagal blokir
  lulus=$(grep -cE "^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|PCK LULUS:|PCK3 LULUS:|PCK4 LULUS:|FIELD LULUS:|REG LULUS:|  OK: )" "$log" || true)
  gagal=$(grep -cE "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" || true)
  blokir=$(grep -c "^BLOKIR:" "$log" || true)
  echo "$name: LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir"
  echo "$name (final) LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir" >> "$LOGDIR/RINGKASAN.txt"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=|TES .*lulus|HASIL: [0-9]+ lulus" "$log" | tail -3
}

run_test() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name-final.log"
  echo "=== $name-final ($scene) headless fixed-fps 60 [HOME iso] ==="
  timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name-final" "$log"
}

run_test test_ui_misi skrip/test_ui_misi.tscn
run_test test_ruang_belajar_chat skrip/test_ruang_belajar_chat.tscn
run_test test_npc_20 skrip/test_npc_20.tscn
run_test test_pencahayaan skrip/test_pencahayaan.tscn
echo "=== test_profil_render-final (headless, angka) ==="
timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_profil_render.tscn > "$LOGDIR/test_profil_render-final.log" 2>&1
echo "test_profil_render exit=$?"
grep -iE "SCRIPT ERROR" "$LOGDIR/test_profil_render-final.log" | head -5
grep -iE "PROFIL-RENDER" "$LOGDIR/test_profil_render-final.log"
echo "test_profil_render (final) exit=$? (lihat angka di log)" >> "$LOGDIR/RINGKASAN.txt"

# --- Xvfb :94 segar untuk test_tombol_telepon ---
Xvfb :94 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-94-final.log" 2>&1 &
XVFB94=$!
sleep 3
if kill -0 $XVFB94 2>/dev/null; then
  echo "=== PROBE Xvfb :94-final (timeout 180) ==="
  timeout 180 env DISPLAY=":94" HOME="$ISO_HOME" "$GODOT" --path . --quit-after 30 --resolution 412x892 > "$LOGDIR/xvfb-probe-final.log" 2>&1
  _pe=$?
  echo "probe exit=$_pe"
  if [ "$_pe" = 124 ]; then
    echo "PROBE TIMEOUT — test_tombol_telepon DI-SKIP"
  else
    echo "=== test_tombol_telepon-final [Xvfb :94] ==="
    timeout 900 env DISPLAY=":94" HOME="$ISO_HOME" "$GODOT" --path . skrip/test_tombol_telepon.tscn --resolution 412x892 > "$LOGDIR/test_tombol_telepon-final.log" 2>&1
    echo "test_tombol_telepon exit=$?"
    ringkas test_tombol_telepon-final "$LOGDIR/test_tombol_telepon-final.log"
  fi
else
  echo "Xvfb :94 gagal start — test_tombol_telepon DI-SKIP"
fi
kill $XVFB94 2>/dev/null; wait $XVFB94 2>/dev/null
echo "=== PENUTUP SELESAI ==="

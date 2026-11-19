#!/bin/bash
# Gate Deploy 20261119-2 (Eka) — ronde: hapus daftar pemain online,
# sarung Kyai (motif + mekar), Kyai tembok, performa 1-6 + kualitas
# adaptif, Ruang Belajar lebar, UI v2 + hapus TEKS DRAF.
# Stempel build: 20261119-2. Pola: gate-deploy-A.sh + Xvfb :96 untuk
# tes sentuh (--resolution ukuran HP + _ke_piksel), test_kamera TANPA
# --fixed-fps 60, chat_fullscreen di Xvfb :97 800x1700 (pola gate A).
set -u
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$HOME/workspace/.logs-gate-18nov/gate-20261119-2"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
echo "LOGDIR=$LOGDIR"

ringkas() {
  local name="$1" log="$2"
  local lulus gagal blokir
  lulus=$(grep -cE "^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|PCK LULUS:|  OK: )" "$log" || true)
  gagal=$(grep -cE "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|  GAGAL: )" "$log" || true)
  blokir=$(grep -c "^BLOKIR:" "$log" || true)
  echo "$name: LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir"
  echo "$name LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir" >> "$LOGDIR/RINGKASAN.txt"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=|TES .*lulus" "$log" | head -3
}

run_test() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) headless fixed-fps 60 ==="
  timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

run_test_nofps() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) headless TANPA fixed-fps ==="
  timeout 900 "$GODOT" --headless --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

# --- Xvfb :96 untuk batch tes sentuh (satu server, semua tes) ---
Xvfb :96 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-96.log" 2>&1 &
XVFB_PID=$!
sleep 3
if ! kill -0 $XVFB_PID 2>/dev/null; then echo "Xvfb :96 GAGAL start"; cat "$LOGDIR/xvfb-96.log"; exit 1; fi

run_test_xvfb() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) [Xvfb :96] $* ==="
  timeout 900 env DISPLAY=":96" "$GODOT" --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

: > "$LOGDIR/RINGKASAN.txt"
# --- 1. Headless, fixed-fps 60 ---
run_test test_v2 skrip/test_v2.tscn
run_test test_hud_rombak skrip/test_hud_rombak.tscn
run_test test_ui_misi skrip/test_ui_misi.tscn
run_test test_jalan_mundur skrip/test_jalan_mundur.tscn
run_test test_pencahayaan skrip/test_pencahayaan.tscn
run_test test_onboarding skrip/test_onboarding.tscn
run_test test_npc_fatimah skrip/test_npc_fatimah.tscn
run_test test_fatimah skrip/test_fatimah.tscn
run_test test_idle_diam skrip/test_idle_diam.tscn
run_test test_petunjuk_santri_baru skrip/test_petunjuk_santri_baru.tscn
run_test test_teka_teki skrip/test_teka_teki.tscn
run_test test_hapus_daftar_pemain skrip/test_hapus_daftar_pemain.tscn
run_test test_kyai_tembok skrip/test_kyai_tembok.tscn
run_test test_cek_perf_setting skrip/test_cek_perf_setting.tscn
run_test test_cek_pck skrip/test_cek_pck.tscn
# --- 2. Profil (headless; angka, bukan LULUS/GAGAL) ---
for p in test_profil test_profil2 test_profil3 test_profil_caster; do
  echo "=== $p (headless, angka) ==="
  timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "skrip/$p.tscn" > "$LOGDIR/$p.log" 2>&1
  echo "$p exit=$?"
  grep -iE "SCRIPT ERROR" "$LOGDIR/$p.log" | head -5
  grep -iE "segitiga|tris|caster|draw call|omni|far" "$LOGDIR/$p.log" | head -12
  echo "$p exit=$? (lihat angka di log)" >> "$LOGDIR/RINGKASAN.txt"
done
# --- 3. Kamera TANPA fixed-fps ---
run_test_nofps test_kamera skrip/test_kamera.tscn
# --- 4. Tes sentuh di Xvfb :96 ---
run_test_xvfb test_tombol_sentuh skrip/test_tombol_sentuh.tscn --resolution 412x892
run_test_xvfb test_tombol_telepon skrip/test_tombol_telepon.tscn --resolution 412x892
run_test_xvfb test_login_tombol skrip/test_login_tombol.tscn --resolution 412x892
run_test_xvfb test_diag_toggle skrip/test_diag_toggle.tscn --resolution 412x892
run_test_xvfb test_kualitas_adaptif skrip/test_kualitas_adaptif.tscn --resolution 1280x720
run_test_xvfb test_msaa skrip/test_msaa.tscn --resolution 1280x720
kill $XVFB_PID 2>/dev/null; wait $XVFB_PID 2>/dev/null
# --- 5. Chat fullscreen di Xvfb :97 800x1700 (pola gate A) ---
echo "=== test_chat_fullscreen [Xvfb :97 800x1700] ==="
Xvfb :97 -screen 0 800x1700x24 > "$LOGDIR/xvfb-97.log" 2>&1 &
XVFB97=$!
sleep 3
timeout 900 env DISPLAY=":97" "$GODOT" --path . skrip/test_chat_fullscreen.tscn > "$LOGDIR/test_chat_fullscreen.log" 2>&1
echo "test_chat_fullscreen exit=$?"
kill $XVFB97 2>/dev/null; wait $XVFB97 2>/dev/null
ringkas test_chat_fullscreen "$LOGDIR/test_chat_fullscreen.log"
# --- 6. MP 2 klien paralel (pola gate A) ---
echo "=== test_mp_alur_web 2 klien paralel ==="
timeout 600 "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 > "$LOGDIR/test_mp_alur_web-2klien-putra.log" 2>&1 &
_mp1=$!
timeout 600 "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putri --mp-web-nama "Tes MP Putri" --mp-web-jk putri --mp-web-id PV-0005 > "$LOGDIR/test_mp_alur_web-2klien-putri.log" 2>&1 &
_mp2=$!
wait $_mp1; _e1=$?; wait $_mp2; _e2=$?
for _f in test_mp_alur_web-2klien-putra test_mp_alur_web-2klien-putri; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
  echo "$_f LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")" >> "$LOGDIR/RINGKASAN.txt"
done
echo "test_mp_alur_web 2klien putra exit=$_e1 putri exit=$_e2" >> "$LOGDIR/RINGKASAN.txt"
# --- 7. Adzan (salin sementara dari fitur-baru, pola gate A) ---
echo "=== test_adzan (salin sementara dari fitur-baru) ==="
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.gd" ./test_adzan.gd
cp "$HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.tscn" ./test_adzan.tscn
timeout 900 "$GODOT" --headless --fixed-fps 60 --path . test_adzan.tscn > "$LOGDIR/test_adzan.log" 2>&1
code=$?
pass=$(grep -c "^PASS" "$LOGDIR/test_adzan.log" || true)
fail=$(grep -c "^FAIL" "$LOGDIR/test_adzan.log" || true)
echo "test_adzan: exit=$code PASS=$pass FAIL=$fail"
grep -E "^FAIL" "$LOGDIR/test_adzan.log" | head -10
echo "test_adzan exit=$code PASS=$pass FAIL=$fail" >> "$LOGDIR/RINGKASAN.txt"
rm -f ./test_adzan.gd ./test_adzan.tscn ./test_adzan.gd.uid ./test_adzan.tscn.uid
ls test_adzan.* 2>/dev/null || echo "test_adzan sementara: sudah dihapus"
echo "=== RINGKASAN GATE 20261119-2 ==="
cat "$LOGDIR/RINGKASAN.txt"

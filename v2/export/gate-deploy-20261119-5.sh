#!/bin/bash
# Gate Deploy 20261119-5 (Eka) — ronde: pose duduk_kursi + 4 bug sarung
# (Kirana, 8ef21b8) + drape bersila v8 + Juntai v3 (Kirana, ACC Mas
# 11:01 WIB) + salaman + polish (Raka) + lokasi acak guru (Raka) +
# lampu Kantor Putra Fase 3 (Cahya) + interior tes + wiring duduk
# (Gilang) + test_fatimah sinkron (Raka).
# Stempel build: 20261119-5 (ui.gd:309 — Eka naikkan, aturan di ui.gd).
# Pola: gate-deploy-20261119-4.sh. BARU ronde ini: test_pose_kursi
# (123, v8), test_seragam_utama, test_fatimah (53), test_wiring_duduk_tes
# (50), test_kantor_putra_interior (82), test_kursi_pemain (157),
# test_salaman (36), test_salaman_mp (2 klien, pengajak PV-0004 /
# penjawab PV-0014, stagger), test_lokasi_acak (59).
# PELAJARAN: test_npc_20 cek sholat timing-marginal saat VM lambat
# (jendela 8 dtk) + hormat varian A kadang gagal run 1-2 — re-run dulu,
# bukan blokir tanpa bukti baru; test_kamera JANGAN --fixed-fps 60;
# tes sentuh WAJIB Xvfb + --resolution; pkill Xvfb by PID (trik bracket);
# HOME terisolasi di-seed save asli (JANGAN reset sebelum
# test_petunjuk_santri_baru).
set -u
REAL_HOME="$HOME"
GODOT="$REAL_HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
PROJ="$REAL_HOME/workspace/pesantren-verse/v2/godot-dunia"
LOGDIR="$REAL_HOME/workspace/.logs-gate-18nov/gate-20261119-5"
mkdir -p "$LOGDIR"
cd "$PROJ" || exit 1
echo "LOGDIR=$LOGDIR"

# --- HOME terisolasi, di-seed salinan save asli ---
ISO_HOME="/tmp/iso-gate-20261119-5"
rm -rf "$ISO_HOME"
mkdir -p "$ISO_HOME/.local/share/godot/app_userdata"
cp -r "$REAL_HOME/.local/share/godot/app_userdata/Pesantren Universe v2" "$ISO_HOME/.local/share/godot/app_userdata/" 2>/dev/null \
  && echo "save asli di-seed ke ISO_HOME" || echo "PERINGATAN: save asli TIDAK ketemu untuk di-seed"
echo "ISO_HOME=$ISO_HOME"

ringkas() {
  local name="$1" log="$2"
  local lulus gagal blokir
  lulus=$(grep -cE "^(LULUS:|SENTUH LULUS:|LOGIN LULUS:|PCK LULUS:|PCK3 LULUS:|PCK4 LULUS:|FIELD LULUS:|REG LULUS:|  OK: )" "$log" || true)
  gagal=$(grep -cE "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" || true)
  blokir=$(grep -c "^BLOKIR:" "$log" || true)
  echo "$name: LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir"
  echo "$name LULUS=$lulus GAGAL=$gagal BLOKIR=$blokir" >> "$LOGDIR/RINGKASAN.txt"
  grep -E "^(GAGAL:|SENTUH GAGAL:|LOGIN GAGAL:|PCK GAGAL:|PCK3 GAGAL:|PCK4 GAGAL:|FIELD GAGAL:|REG GAGAL:|  GAGAL: )" "$log" | head -10
  grep -iE "SCRIPT ERROR" "$log" | head -5
  grep -E "TES .*LULUS=|TES .*lulus|HASIL: [0-9]+ lulus|SELESAI lulus=" "$log" | tail -3
}

run_test() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) headless fixed-fps 60 [HOME iso] ==="
  timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

run_test_nofps() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) headless TANPA fixed-fps [HOME iso] ==="
  timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

# --- Probe Xvfb segar :95 (1280x1024) + :96 (800x1700) SEBELUM suite ---
Xvfb :95 -screen 0 1280x1024x24 > "$LOGDIR/xvfb-95.log" 2>&1 &
XVFB95=$!
Xvfb :96 -screen 0 800x1700x24 > "$LOGDIR/xvfb-96.log" 2>&1 &
XVFB96=$!
sleep 3
XVFB_OK=1
for p in $XVFB95 $XVFB96; do
  if ! kill -0 $p 2>/dev/null; then echo "Xvfb PID $p GAGAL start"; XVFB_OK=0; fi
done
if [ "$XVFB_OK" = 1 ]; then
  echo "=== PROBE Xvfb :95 — Godot GUI quit-after 60 (timeout 300) ==="
  timeout 300 env DISPLAY=":95" HOME="$ISO_HOME" "$GODOT" --path . --quit-after 60 --resolution 412x892 > "$LOGDIR/xvfb-probe.log" 2>&1
  _pe=$?
  echo "probe exit=$_pe"
  if [ "$_pe" = 124 ]; then echo "PROBE TIMEOUT — Xvfb/Godot GUI MACET, seksi sentuh DI-SKIP"; XVFB_OK=0; fi
  tail -5 "$LOGDIR/xvfb-probe.log"
else
  echo "Xvfb gagal start — seksi sentuh DI-SKIP"
fi
echo "XVFB_OK=$XVFB_OK" >> "$LOGDIR/RINGKASAN.txt"

run_test_xvfb() {
  local name="$1" scene="$2"; shift 2
  local log="$LOGDIR/$name.log"
  echo "=== $name ($scene) [Xvfb :95] $* ==="
  timeout 900 env DISPLAY=":95" HOME="$ISO_HOME" "$GODOT" --path . "$scene" "$@" > "$log" 2>&1
  echo "$name exit=$?"
  ringkas "$name" "$log"
}

: > "$LOGDIR/RINGKASAN.txt"
# --- 1. Suite ronde -5 (headless, fixed-fps 60) ---
run_test test_pose_kursi skrip/test_pose_kursi.tscn
run_test test_seragam_utama skrip/test_seragam_utama.tscn
run_test test_fatimah skrip/test_fatimah.tscn
run_test test_npc_20 skrip/test_npc_20.tscn
run_test test_wiring_duduk_tes skrip/test_wiring_duduk_tes.tscn
run_test test_kantor_putra_interior skrip/test_kantor_putra_interior.tscn
run_test test_kursi_pemain skrip/test_kursi_pemain.tscn
run_test test_salaman skrip/test_salaman.tscn
run_test test_lokasi_acak skrip/test_lokasi_acak.tscn
run_test test_pencahayaan skrip/test_pencahayaan.tscn
run_test test_onboarding skrip/test_onboarding.tscn
run_test test_ui_misi skrip/test_ui_misi.tscn
# --- 2. Suite standar (headless, fixed-fps 60) ---
run_test test_v2 skrip/test_v2.tscn
run_test test_hud_rombak skrip/test_hud_rombak.tscn
run_test test_ruang_belajar_chat skrip/test_ruang_belajar_chat.tscn
run_test test_jalan_mundur skrip/test_jalan_mundur.tscn
run_test test_audit_lantai_npc skrip/test_audit_lantai_npc.tscn
run_test test_npc_fatimah skrip/test_npc_fatimah.tscn
run_test test_idle_diam skrip/test_idle_diam.tscn
run_test test_petunjuk_santri_baru skrip/test_petunjuk_santri_baru.tscn
run_test test_teka_teki skrip/test_teka_teki.tscn
run_test test_hapus_daftar_pemain skrip/test_hapus_daftar_pemain.tscn
run_test test_kyai_tembok skrip/test_kyai_tembok.tscn
run_test test_cek_perf_setting skrip/test_cek_perf_setting.tscn
run_test test_cek_pck skrip/test_cek_pck.tscn
# --- 3. Profil (headless; angka, bukan LULUS/GAGAL) ---
for p in test_profil test_profil_caster test_profil_render; do
  echo "=== $p (headless, angka) ==="
  timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . "skrip/$p.tscn" > "$LOGDIR/$p.log" 2>&1
  echo "$p exit=$?"
  grep -iE "SCRIPT ERROR" "$LOGDIR/$p.log" | head -5
  grep -iE "PROFIL:|segitiga|tris|caster|draw call|omni|far" "$LOGDIR/$p.log" | head -14
  echo "$p exit=$? (lihat angka di log)" >> "$LOGDIR/RINGKASAN.txt"
done
# --- 4. Kamera TANPA fixed-fps ---
run_test_nofps test_kamera skrip/test_kamera.tscn
# --- 5. Tes sentuh di Xvfb :95 (hanya bila probe OK) ---
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
  # --- 6. Chat fullscreen di Xvfb :96 800x1700 ---
  echo "=== test_chat_fullscreen [Xvfb :96 800x1700] ==="
  timeout 900 env DISPLAY=":96" HOME="$ISO_HOME" "$GODOT" --path . skrip/test_chat_fullscreen.tscn > "$LOGDIR/test_chat_fullscreen.log" 2>&1
  echo "test_chat_fullscreen exit=$?"
  ringkas test_chat_fullscreen "$LOGDIR/test_chat_fullscreen.log"
else
  echo "SEKSI SENTUH DI-SKIP (probe Xvfb gagal)" | tee -a "$LOGDIR/RINGKASAN.txt"
fi
kill $XVFB95 2>/dev/null; wait $XVFB95 2>/dev/null
kill $XVFB96 2>/dev/null; wait $XVFB96 2>/dev/null
# --- 7. MP 2 klien paralel (pola gate -3/-4, staggered: penjawab dulu) ---
echo "=== test_mp_alur_web 2 klien paralel ==="
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 > "$LOGDIR/test_mp_alur_web-2klien-putra.log" 2>&1 &
_mp1=$!
sleep 20
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_mp_alur_web.tscn -- --mp-web-ig test_mp_putri --mp-web-nama "Tes MP Putri" --mp-web-jk putri --mp-web-id PV-0005 > "$LOGDIR/test_mp_alur_web-2klien-putri.log" 2>&1 &
_mp2=$!
wait $_mp1; _e1=$?; wait $_mp2; _e2=$?
for _f in test_mp_alur_web-2klien-putra test_mp_alur_web-2klien-putri; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
  echo "$_f LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")" >> "$LOGDIR/RINGKASAN.txt"
done
echo "test_mp_alur_web 2klien putra exit=$_e1 putri exit=$_e2" >> "$LOGDIR/RINGKASAN.txt"
# --- 8. Salaman MP 2 klien paralel (penjawab dulu, pengajak 30 dtk kemudian) ---
echo "=== test_salaman_mp 2 klien paralel ==="
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_salaman_mp.tscn -- --mp-web-ig test_mp_putra2 --mp-web-nama "Tes MP Putra 2" --mp-web-jk putra --mp-web-id PV-0014 --mp-salaman-peran penjawab > "$LOGDIR/test_salaman_mp-penjawab.log" 2>&1 &
_s1=$!
sleep 30
timeout 600 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_salaman_mp.tscn -- --mp-web-ig test_mp_putra --mp-web-nama "Tes MP Putra" --mp-web-jk putra --mp-web-id PV-0004 --mp-salaman-peran pengajak > "$LOGDIR/test_salaman_mp-pengajak.log" 2>&1 &
_s2=$!
wait $_s1; _se1=$?; wait $_s2; _se2=$?
for _f in test_salaman_mp-penjawab test_salaman_mp-pengajak; do
  echo "$_f: LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")"
  grep "^GAGAL:\|^BLOKIR:" "$LOGDIR/$_f.log" | head -5
  grep -iE "SCRIPT ERROR" "$LOGDIR/$_f.log" | head -5
  echo "$_f LULUS=$(grep -c '^LULUS:' "$LOGDIR/$_f.log") GAGAL=$(grep -c '^GAGAL:' "$LOGDIR/$_f.log") BLOKIR=$(grep -c '^BLOKIR:' "$LOGDIR/$_f.log")" >> "$LOGDIR/RINGKASAN.txt"
done
echo "test_salaman_mp penjawab exit=$_se1 pengajak exit=$_se2" >> "$LOGDIR/RINGKASAN.txt"
# --- 9. Adzan (salin sementara dari fitur-baru, pola gate -3) ---
echo "=== test_adzan (salin sementara dari fitur-baru) ==="
cp "$REAL_HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.gd" ./test_adzan.gd
cp "$REAL_HOME/workspace/pesantren-verse/fitur-baru/skrip/test_adzan.tscn" ./test_adzan.tscn
timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . test_adzan.tscn > "$LOGDIR/test_adzan.log" 2>&1
code=$?
pass=$(grep -c "^PASS" "$LOGDIR/test_adzan.log" || true)
fail=$(grep -c "^FAIL" "$LOGDIR/test_adzan.log" || true)
echo "test_adzan: exit=$code PASS=$pass FAIL=$fail"
grep -E "^FAIL" "$LOGDIR/test_adzan.log" | head -10
echo "test_adzan exit=$code PASS=$pass FAIL=$fail" >> "$LOGDIR/RINGKASAN.txt"
rm -f ./test_adzan.gd ./test_adzan.tscn ./test_adzan.gd.uid ./test_adzan.tscn.uid
ls test_adzan.* 2>/dev/null || echo "test_adzan sementara: sudah dihapus"
# --- 10. Tembusan NPC — ekspektasi 212 (Fase A 131 + Fase C 81) ---
echo "=== test_npc_tembus (headless) ==="
timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_npc_tembus.tscn > "$LOGDIR/test_npc_tembus.log" 2>&1
echo "test_npc_tembus exit=$?"
grep -E "NPC-TEMBUS: (fase|total_temuan|live |=== RINGKASAN ===)" "$LOGDIR/test_npc_tembus.log" | head -30
grep -iE "SCRIPT ERROR" "$LOGDIR/test_npc_tembus.log" | head -5
echo "test_npc_tembus: $(grep -E 'total_temuan=' "$LOGDIR/test_npc_tembus.log" | tail -1) | $(grep -E 'fase B selesai' "$LOGDIR/test_npc_tembus.log") | $(grep -E 'fase C selesai' "$LOGDIR/test_npc_tembus.log")" >> "$LOGDIR/RINGKASAN.txt"
echo "=== test_npc_tembus_suplemen (headless) ==="
timeout 900 env HOME="$ISO_HOME" "$GODOT" --headless --fixed-fps 60 --path . skrip/test_npc_tembus_suplemen.tscn > "$LOGDIR/test_npc_tembus_suplemen.log" 2>&1
echo "test_npc_tembus_suplemen exit=$?"
grep -E "NPC-TEMBUS-SUP:" "$LOGDIR/test_npc_tembus_suplemen.log" | tail -5
grep -iE "SCRIPT ERROR" "$LOGDIR/test_npc_tembus_suplemen.log" | head -5
echo "test_npc_tembus_suplemen: $(grep -E 'selesai, temuan=' "$LOGDIR/test_npc_tembus_suplemen.log" | tail -1)" >> "$LOGDIR/RINGKASAN.txt"
echo "=== RINGKASAN GATE 20261119-5 ==="
cat "$LOGDIR/RINGKASAN.txt"

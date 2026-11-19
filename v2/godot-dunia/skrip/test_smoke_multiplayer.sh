#!/usr/bin/env bash
# =============================================================================
# test_smoke_multiplayer.sh — Smoke test multiplayer Pesantren Universe (Fase 0.5)
# QA: Jaka | Lead: Dimas | Rencana: MULTIPLAYER-PLAN.md §2 Fase 0 butir (5)
# Pola: skill godot-multiplayer langkah 8 (2 instance headless, cek log).
#
# CARA PAKAI (dari direktori proyek v2/godot-dunia):
#   ./skrip/test_smoke_multiplayer.sh            # mode lokal (default)
#   ./skrip/test_smoke_multiplayer.sh wss        # via wss (butuh Caddy /ws/ + service hidup)
#   ./skrip/test_smoke_multiplayer.sh local      # eksplisit mode lokal
#   ./skrip/test_smoke_multiplayer.sh fase1      # FASE 1 lokal (tiket REST asli, 2 klien tes)
#   ./skrip/test_smoke_multiplayer.sh fase1-wss  # FASE 1 via wss (butuh MP_WSS_CONFIRMED=1)
#
# MODE FASE 1 (Wira, 18 Nov 2026): smoke test Fase 1 end-to-end.
#   1. Dua akun santri TES dibuat/dipakai lewat REST publik
#      (test_mp_putra / test_mp_putri — JANGAN akun produksi
#      PV-0001/0002/0003). Bila sudah ada (409), dipakai yang ada.
#   2. Login tiap akun (tanpa kata sandi — akun tes tidak punya
#      password) lalu POST /api/santri/realtime_ticket -> tiket asli
#      (5 menit, sekali pakai). Tiket HANYA di variabel shell, TIDAK
#      PERNAH dicetak ke log/konsol; X-PV-Token TIDAK dipakai di sini.
#   3. Host lokal (mode fase1) atau service VPS (fase1-wss) +
#      2 klien headless skrip/test_multiplayer_fase1.tscn:
#      klien 1 = putra + --mp-test-gerak + --mp-test-zona,
#      klien 2 = putri (pengamat gerak).
#   4. Cek kriteria (a)-(e) dari log (lihat skrip tes). Status tiap
#      kriteria: LOLOS / GAGAL / BLOKIR (BLOKIR = dependensi
#      NetworkManager/synchronizer Saka/Bara belum ada — bukan gagal
#      kode ini). Exit 0 = semua LOLOS; 1 = ada GAGAL; 2 = ada BLOKIR
#      (tanpa GAGAL) atau prasyarat tidak terpenuhi.
#   Mode fase1-wss MENOLAK jalan kecuali MP_WSS_CONFIRMED=1 — jangan
#   jalankan via wss sebelum Saka mengonfirmasi service VPS sudah
#   memakai biner Fase 1.
# ENV tambahan Fase 1:
#   REST_BASE            basis REST API, default: https://43-173-39-166.sslip.io
#   FASE1_WAIT_SECS      lama polling ringkasan tes, default: 240
#   FASE1_CLIENT_TIMEOUT timeout proses klien, default: 360
#   FASE1_HOST_TIMEOUT   timeout proses host, default: 360
#   MP_WSS_CONFIRMED     set "1" bila Saka sudah mengonfirmasi service VPS biner Fase 1
#
# ENV (opsional, override default):
#   GODOT_BIN   biner Godot editor/headless, default: godot (fallback: godot4, $GODOT_BIN)
#   SERVER_BIN  biner dedicated server hasil export (preset "Dedicated Server").
#               Bila di-set dan filenya ada, dipakai sebagai HOST (dan sebagai klien
#               bila GODOT_BIN tidak ada). Bila tidak ada, host dijalankan lewat
#               GODOT_BIN --headless --path <proyek>.
#   PROJECT_DIR direktori proyek, default: direktori induk skrip ini (godot-dunia).
#   MP_PORT     port WebSocket server realtime, default: 8791
#   WSS_URL     URL wss mode, default: wss://43-173-39-166.sslip.io/ws/
#   WAIT_SECS   lama menunggu handshake sebelum cek log, default: 8
#   HOST_TIMEOUT   timeout proses host, default: 60 (naikkan bila _ready
#               main.tscn lama, mis. 180)
#   CLIENT_TIMEOUT timeout proses klien, default: 40 (naikkan bila _ready
#               lama, mis. 120)
#   LOG_DIR     direktori log, default: <PROJECT_DIR>/skrip/smoke-logs
#
# YANG DICEK (kriteria lolos, sesuai MULTIPLAYER-PLAN.md Fase 0):
#   1. grep "^ *(SCRIPT ERROR|ERROR):" di server.log, client1.log, client2.log
#      harus KOSONG (tidak ada baris ERROR).
#   2. grep -i "connected" harus ketemu di server.log DAN client1.log DAN
#      client2.log (server: "peer_connected <id>", klien: "connected_to_server").
#      Mode wss: server.log tidak dicek (server jalan di VPS) — hanya kedua klien.
# Exit 0 = LOLOS, bukan-nol = GAGAL (alasan dicetak di ringkasan).
#
# CATATAN:
# - Skrip ini TIDAK mengubah file game apa pun; hanya membaca log + menjalankan
#   proses headless dengan timeout. v1 production tidak disentuh.
# - Bootstrap game yang dites: --mp-host / --mp-join <url> (tim Bara).
#   Klien lokal join ke ws://127.0.0.1:8791 ; klien wss join ke $WSS_URL.
# - Mode wss TIDAK menjalankan server lokal — server diasumsikan sudah hidup
#   sebagai service pesantren-verse-realtime di VPS (tim Wira).
# =============================================================================
set -u

MODE="${1:-local}"
case "$MODE" in
    local|wss|fase1|fase1-wss) ;;
    *) echo "Pemakaian: $0 [local|wss|fase1|fase1-wss]" >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-$(dirname "$SCRIPT_DIR")}"
MP_PORT="${MP_PORT:-8791}"
WSS_URL="${WSS_URL:-wss://43-173-39-166.sslip.io/ws/}"
WS_LOCAL_URL="ws://127.0.0.1:${MP_PORT}"
WAIT_SECS="${WAIT_SECS:-8}"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/smoke-logs}"
SERVER_LOG="$LOG_DIR/server.log"
CLIENT1_LOG="$LOG_DIR/client1.log"
CLIENT2_LOG="$LOG_DIR/client2.log"

mkdir -p "$LOG_DIR"
: > "$SERVER_LOG"; : > "$CLIENT1_LOG"; : > "$CLIENT2_LOG"

fail=""
note() { echo "[smoke] $*"; }

# =============================================================================
# FASE 1 (Wira) — cabang mode fase1 / fase1-wss. Berjalan lalu exit;
# mode local/wss (Fase 0.5) di bawah tidak tersentuh.
# =============================================================================
if [ "$MODE" = "fase1" ] || [ "$MODE" = "fase1-wss" ]; then
    if [ "$MODE" = "fase1-wss" ] && [ "${MP_WSS_CONFIRMED:-}" != "1" ]; then
        echo "[smoke] DITOLAK: mode fase1-wss butuh konfirmasi Saka bahwa service"
        echo "[smoke] VPS pesantren-verse-realtime sudah memakai biner Fase 1."
        echo "[smoke] Jalankan dengan MP_WSS_CONFIRMED=1 $0 fase1-wss setelah Saka mengonfirmasi."
        exit 2
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        echo "[smoke] GAGAL: python3 tidak ada — dibutuhkan untuk register/login/tiket REST."
        exit 2
    fi
    REST_BASE="${REST_BASE:-https://43-173-39-166.sslip.io}"
    FASE1_WAIT="${FASE1_WAIT_SECS:-240}"
    FASE1_CTIMEOUT="${FASE1_CLIENT_TIMEOUT:-360}"
    FASE1_HTIMEOUT="${FASE1_HOST_TIMEOUT:-360}"
    TEST_SCENE="$PROJECT_DIR/skrip/test_multiplayer_fase1.tscn"
    if [ ! -f "$TEST_SCENE" ]; then
        echo "[smoke] GAGAL: scene tes tidak ada: $TEST_SCENE"
        exit 2
    fi

    # rest_ticket <ig> <nama> <jk> — register (409 = sudah ada, lanjut),
    # login, lalu minta tiket realtime. Mencetak HANYA tiket ke stdout;
    # semua pesan lain ke stderr. Tiket TIDAK PERNAH dicetak ke log.
    rest_ticket() {
        REST_BASE="$REST_BASE" TEST_MP_PASSWORD="${TEST_MP_PASSWORD:-}" python3 - "$1" "$2" "$3" <<'PYEOF'
import json, sys, urllib.request, urllib.error, os
base = os.environ["REST_BASE"]
ig, nama, jk = sys.argv[1], sys.argv[2], sys.argv[3]
pw = os.environ.get("TEST_MP_PASSWORD", "") or None
def post(path, body):
    req = urllib.request.Request(base + path, data=json.dumps(body).encode(),
        headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        try: return e.code, json.loads(e.read())
        except Exception: return e.code, {}
s, d = post("/api/santri/register", {"nama": nama, "ig_username": ig, "jenis_kelamin": jk})
if s not in (201, 409):
    print("register %s gagal: %s %s" % (ig, s, d), file=sys.stderr); sys.exit(1)
body = {"ig_username": ig}
if pw: body["password"] = pw
s, d = post("/api/santri/login", body)
if s != 200 or not d.get("session"):
    print("login %s gagal: %s %s" % (ig, s, d), file=sys.stderr); sys.exit(1)
s, d = post("/api/santri/realtime_ticket", {"session": d["session"]})
if s != 200 or not d.get("ticket"):
    print("realtime_ticket %s gagal: %s %s" % (ig, s, d), file=sys.stderr); sys.exit(1)
print(d["ticket"])
PYEOF
    }

    # Cari biner Godot (sama seperti Fase 0.5 di bawah).
    pick_godot_f1() {
        if [ -n "${GODOT_BIN:-}" ] && command -v "$GODOT_BIN" >/dev/null 2>&1; then
            echo "$GODOT_BIN"; return 0
        fi
        for c in godot godot4; do
            if command -v "$c" >/dev/null 2>&1; then echo "$c"; return 0; fi
        done
        return 1
    }
    GODOT_F1="$(pick_godot_f1 || true)"
    SERVER_BIN_F1="${SERVER_BIN:-}"
    if [ -n "$SERVER_BIN_F1" ] && [ ! -x "$SERVER_BIN_F1" ]; then
        note "PERINGATAN: SERVER_BIN=$SERVER_BIN_F1 tidak bisa dieksekusi — diabaikan."
        SERVER_BIN_F1=""
    fi
    if [ -z "$GODOT_F1" ] && [ -z "$SERVER_BIN_F1" ]; then
        note "GAGAL: tidak ada biner Godot (godot/godot4/\$GODOT_BIN) dan tidak ada SERVER_BIN."
        exit 2
    fi
    STDBUF_F1=()
    if command -v stdbuf >/dev/null 2>&1; then STDBUF_F1=(stdbuf -oL -eL); fi

    note "Mode: $MODE | Proyek: $PROJECT_DIR | Log: $LOG_DIR"
    SERVER_PID_F1=""
    CLIENT1_PID_F1=""
    CLIENT2_PID_F1=""
    # Jaring pengaman: host/klien yang sudah jalan HARUS mati bila
    # skrip keluar lebih awal (mis. tiket gagal) — kalau tidak, host
    # yatim mengunci port 8791 dan run berikutnya gagal "Already in
    # use" (kejadian 18 Nov ~09:41 WIB).
    cleanup_f1() {
        for p in "$CLIENT1_PID_F1" "$CLIENT2_PID_F1" "$SERVER_PID_F1"; do
            [ -n "$p" ] && kill "$p" 2>/dev/null
        done
    }
    trap cleanup_f1 EXIT
    if [ "$MODE" = "fase1" ]; then
        if [ -n "$SERVER_BIN_F1" ]; then
            HOST_CMD_F1=("${STDBUF_F1[@]}" "$SERVER_BIN_F1" -- --mp-host)
        else
            HOST_CMD_F1=("${STDBUF_F1[@]}" "$GODOT_F1" --headless --path "$PROJECT_DIR" -- --mp-host)
        fi
        note "Host: ${HOST_CMD_F1[*]}"
        timeout "$FASE1_HTIMEOUT" "${HOST_CMD_F1[@]}" > "$SERVER_LOG" 2>&1 &
        SERVER_PID_F1=$!
        note "Server headless jalan (PID $SERVER_PID_F1), tunggu 2 dtk..."
        sleep 2
        JOIN_URL_F1="$WS_LOCAL_URL"
    else
        note "Mode fase1-wss: server lokal TIDAK dijalankan (service VPS diasumsikan biner Fase 1)."
        JOIN_URL_F1="$WSS_URL"
    fi

    # Tiket diambil SETELAH host jalan (TTL 300 dtk — jangan ambil
    # sebelum host, nanti kedaluwarsa di tengah jalan).
    note "Ambil tiket realtime untuk test_mp_putra + test_mp_putri (REST publik)..."
    # REST publik kadang menutup koneksi tanpa respons (RemoteDisconnected
    # — teramati 3x beruntun 18 Nov ~03:51-03:53 WIB, padahal curl/urllib
    # mandiri ke endpoint yang sama berhasil sesaat sesudahnya): ulangi
    # ambil tiket sampai 3x. Aman — kegagalan terjadi sebelum tiket
    # diterbitkan, jadi tidak ada tiket yang terbuang; bila respons
    # tiket hilang pun, percobaan berikut meminta tiket BARU.
    T1=""
    for _coba in 1 2 3; do
        T1="$(rest_ticket test_mp_putra "Tes MP Putra" putra 2>"$LOG_DIR/rest1.err")" && break
        T1=""
        note "Tiket putra gagal (percobaan $_coba/3) — coba lagi dalam 5 dtk..."
        sleep 5
    done
    [ -n "$T1" ] || {
        echo "[smoke] GAGAL ambil tiket putra:"; cat "$LOG_DIR/rest1.err" 2>/dev/null; exit 2; }
    T2=""
    for _coba in 1 2 3; do
        T2="$(rest_ticket test_mp_putri "Tes MP Putri" putri 2>"$LOG_DIR/rest2.err")" && break
        T2=""
        note "Tiket putri gagal (percobaan $_coba/3) — coba lagi dalam 5 dtk..."
        sleep 5
    done
    [ -n "$T2" ] || {
        echo "[smoke] GAGAL ambil tiket putri:"; cat "$LOG_DIR/rest2.err" 2>/dev/null; exit 2; }
    note "Tiket didapat (nilai disembunyikan, panjang ${#T1}/${#T2} karakter)."

    if [ -n "$GODOT_F1" ]; then
        CLIENT_F1_BASE=("${STDBUF_F1[@]}" "$GODOT_F1" --headless --path "$PROJECT_DIR" "$TEST_SCENE" -- --mp-join)
    elif [ -n "$SERVER_BIN_F1" ]; then
        CLIENT_F1_BASE=("${STDBUF_F1[@]}" "$SERVER_BIN_F1" "$TEST_SCENE" -- --mp-join)
    fi
    # CATATAN: tiket ada di baris perintah proses (terlihat di `ps`) —
    # itu antarmuka --mp-ticket MpBootstrap; tiket tetap TIDAK ditulis
    # ke file log mana pun oleh skrip ini.
    note "Klien 1 (putra, gerak + zona) join $JOIN_URL_F1 ..."
    timeout "$FASE1_CTIMEOUT" "${CLIENT_F1_BASE[@]}" "$JOIN_URL_F1" --mp-ticket "$T1" --mp-test-gerak --mp-test-zona > "$CLIENT1_LOG" 2>&1 &
    CLIENT1_PID_F1=$!
    sleep 1
    note "Klien 2 (putri, pengamat) join $JOIN_URL_F1 ..."
    timeout "$FASE1_CTIMEOUT" "${CLIENT_F1_BASE[@]}" "$JOIN_URL_F1" --mp-ticket "$T2" > "$CLIENT2_LOG" 2>&1 &
    CLIENT2_PID_F1=$!

    note "Tunggu ringkasan MP-TEST di kedua klien (maks ${FASE1_WAIT} dtk)..."
    START_F1=$SECONDS
    while [ $((SECONDS - START_F1)) -lt "$FASE1_WAIT" ]; do
        if grep -q "MP-TEST] RINGKASAN" "$CLIENT1_LOG" 2>/dev/null \
            && grep -q "MP-TEST] RINGKASAN" "$CLIENT2_LOG" 2>/dev/null; then
            note "Kedua klien selesai."
            break
        fi
        sleep 5
    done
    for p in "$CLIENT1_PID_F1" "$CLIENT2_PID_F1" "$SERVER_PID_F1"; do
        [ -n "$p" ] && kill "$p" 2>/dev/null
    done
    wait "$CLIENT1_PID_F1" 2>/dev/null; wait "$CLIENT2_PID_F1" 2>/dev/null
    if [ -n "$SERVER_PID_F1" ]; then wait "$SERVER_PID_F1" 2>/dev/null; fi

    echo ""
    echo "=== RINGKASAN SMOKE TEST MULTIPLAYER FASE 1 (mode: $MODE) ==="
    echo "Log: $LOG_DIR"
    for f in "$SERVER_LOG" "$CLIENT1_LOG" "$CLIENT2_LOG"; do
        echo "  $(basename "$f"): $(wc -l < "$f") baris"
    done
    F1_FAIL=0
    F1_BLOKIR=0
    # cek_kriteria <id> <file> <pola LULUS> — LOLOS bila pola ada;
    # BLOKIR bila ada baris BLOKIR untuk kriteria itu; selain itu GAGAL.
    cek_kriteria() {
        local id="$1" file="$2" pola="$3"
        if grep -q "$pola" "$file" 2>/dev/null; then
            echo "KRITERIA ($id) LOLOS — $(grep -m1 "$pola" "$file" | head -c 160)"
        elif grep -q "BLOKIR: ($id)" "$file" 2>/dev/null; then
            echo "KRITERIA ($id) BLOKIR — $(grep -m1 "BLOKIR: ($id)" "$file" | head -c 200)"
            F1_BLOKIR=1
        else
            echo "KRITERIA ($id) GAGAL — pola '$pola' tidak ditemukan di $(basename "$file")."
            F1_FAIL=1
        fi
    }
    ERR_LINES_F1="$(grep -nE '^ *(SCRIPT ERROR|ERROR):' "$SERVER_LOG" "$CLIENT1_LOG" "$CLIENT2_LOG" 2>/dev/null || true)"
    if [ -n "$ERR_LINES_F1" ]; then
        echo "CEK ERROR GAGAL — baris ERROR ditemukan:"
        echo "$ERR_LINES_F1"
        F1_FAIL=1
    else
        echo "CEK ERROR LOLOS — tidak ada baris 'ERROR:' / 'SCRIPT ERROR:' di ketiga log."
    fi
    grep -q "connected_to_server" "$CLIENT1_LOG" 2>/dev/null \
        && grep -q "connected_to_server" "$CLIENT2_LOG" 2>/dev/null \
        && echo "KRITERIA (a) LOLOS — kedua klien connected_to_server." \
        || { echo "KRITERIA (a) GAGAL — connected_to_server tidak ada di kedua klien."; F1_FAIL=1; }
    cek_kriteria "b" "$CLIENT1_LOG" "LULUS: (b) avatar sendiri"
    cek_kriteria "b" "$CLIENT2_LOG" "LULUS: (b) avatar sendiri"
    cek_kriteria "c" "$CLIENT1_LOG" "LULUS: (c) avatar peer terlihat"
    cek_kriteria "c" "$CLIENT2_LOG" "LULUS: (c) avatar peer terlihat"
    # (d) dua sisi: klien 1 jalan sendiri + klien 2 melihat peer bergerak.
    if grep -q "LULUS: (d) gerak sendiri" "$CLIENT1_LOG" 2>/dev/null; then
        echo "KRITERIA (d) LOLOS (sisi gerak) — $(grep -m1 'LULUS: (d) gerak sendiri' "$CLIENT1_LOG" | head -c 160)"
    elif grep -q "BLOKIR: (d)" "$CLIENT1_LOG" 2>/dev/null; then
        echo "KRITERIA (d) BLOKIR (sisi gerak) — $(grep -m1 'BLOKIR: (d)' "$CLIENT1_LOG" | head -c 200)"
        F1_BLOKIR=1
    else
        echo "KRITERIA (d) GAGAL (sisi gerak) — tidak ada LULUS/BLOKIR (d) di client1.log."
        F1_FAIL=1
    fi
    # Penyebaran dihitung PER PEER (dikelompokkan by id peer) lalu
    # diambil maksimumnya — log "lihat peer" kini memuat SEMUA peer
    # (pengamat melacak semua peer, perbaikan 18 Nov); menghitung
    # lintas-peer akan mengukur jarak antar titik spawn (~144 m)
    # dan memalsukan penyebaran.
    SPREAD_F1="$(python3 - "$CLIENT2_LOG" <<'PYEOF' 2>/dev/null
import re, sys, math
per_peer = {}
for line in open(sys.argv[1], errors="replace"):
    m = re.search(r"lihat peer (\S+) pos=\(([^)]+)\)", line)
    if m:
        per_peer.setdefault(m.group(1), []).append(tuple(float(x) for x in m.group(2).split(",")))
mx = 0.0
n = 0
for pts in per_peer.values():
    n += len(pts)
    for i in range(len(pts)):
        for j in range(i + 1, len(pts)):
            mx = max(mx, math.dist(pts[i], pts[j]))
print("%.3f %d" % (mx, n))
PYEOF
)"
    if grep -q "LULUS: (d) peer bergerak terlihat" "$CLIENT2_LOG" 2>/dev/null; then
        echo "KRITERIA (d) LOLOS (sisi pengamat) — penyebaran posisi peer di client2.log: $SPREAD_F1 (meter, N sampel)."
    elif grep -q "BLOKIR: (d)" "$CLIENT2_LOG" 2>/dev/null; then
        echo "KRITERIA (d) BLOKIR (sisi pengamat) — $(grep -m1 'BLOKIR: (d)' "$CLIENT2_LOG" | head -c 200)"
        F1_BLOKIR=1
    else
        echo "KRITERIA (d) GAGAL (sisi pengamat) — penyebaran posisi peer di client2.log: $SPREAD_F1 (meter, N sampel), butuh > 1 m."
        F1_FAIL=1
    fi
    cek_kriteria "e" "$CLIENT1_LOG" "LULUS: (e) zona ditolak server"
    echo ""
    if [ "$F1_FAIL" = "1" ]; then
        echo "HASIL: GAGAL (exit 1) — lihat log di $LOG_DIR"
        exit 1
    fi
    if [ "$F1_BLOKIR" = "1" ]; then
        echo "HASIL: BLOKIR (exit 2) — kriteria tertahan dependensi (NetworkManager/synchronizer Saka/Bara belum ada)."
        exit 2
    fi
    echo "HASIL: LOLOS (exit 0) — Fase 1: 2 klien saling lihat + gerak + zona ditolak server."
    exit 0
fi

# --- 1. Cari biner -----------------------------------------------------------
# Prioritas host: SERVER_BIN (dedicated) > GODOT_BIN. Klien: GODOT_BIN,
# fallback ke SERVER_BIN bila GODOT_BIN tidak ada (biner dedicated juga bisa
# jalan sebagai klien dengan --mp-join).
pick_godot() {
    if [ -n "${GODOT_BIN:-}" ] && command -v "$GODOT_BIN" >/dev/null 2>&1; then
        echo "$GODOT_BIN"; return 0
    fi
    for c in godot godot4; do
        if command -v "$c" >/dev/null 2>&1; then echo "$c"; return 0; fi
    done
    return 1
}

GODOT="$(pick_godot || true)"
SERVER_BIN_PATH="${SERVER_BIN:-}"
if [ -n "$SERVER_BIN_PATH" ] && [ ! -x "$SERVER_BIN_PATH" ]; then
    note "PERINGATAN: SERVER_BIN=$SERVER_BIN_PATH tidak bisa dieksekusi — diabaikan."
    SERVER_BIN_PATH=""
fi

if [ -z "$GODOT" ] && [ -z "$SERVER_BIN_PATH" ]; then
    note "GAGAL: tidak ada biner Godot (godot/godot4/\$GODOT_BIN) dan tidak ada SERVER_BIN."
    note "Jalankan skrip ini di mesin yang punya biner Godot 4.7.2 atau biner dedicated server."
    exit 2
fi

# Perintah host & klien (array supaya aman dari spasi di path).
# stdbuf -oL: output biner dedicated server ter-buffer blok saat dialihkan
# ke file; saat dimatikan SIGTERM, buffer yang belum ter-flush hilang dan
# server.log jadi kosong (false GAGAL di CEK 2) — padahal server sudah
# hosting + menerima peer. Line buffering memaksa tiap baris langsung
# tertulis. Bukan perubahan kriteria lolos — hanya harness logging.
STDBUF=()
if command -v stdbuf >/dev/null 2>&1; then STDBUF=(stdbuf -oL -eL); fi
if [ -n "$SERVER_BIN_PATH" ]; then
    HOST_CMD=("${STDBUF[@]}" "$SERVER_BIN_PATH" -- --mp-host)
else
    HOST_CMD=("${STDBUF[@]}" "$GODOT" --headless --path "$PROJECT_DIR" -- --mp-host)
fi
if [ -n "$GODOT" ]; then
    CLIENT_CMD_BASE=("${STDBUF[@]}" "$GODOT" --headless --path "$PROJECT_DIR" -- --mp-join)
elif [ -n "$SERVER_BIN_PATH" ]; then
    CLIENT_CMD_BASE=("${STDBUF[@]}" "$SERVER_BIN_PATH" -- --mp-join)
fi

note "Mode: $MODE | Proyek: $PROJECT_DIR | Log: $LOG_DIR"
note "Host: ${HOST_CMD[*]}"
note "Klien: ${CLIENT_CMD_BASE[*]} <url>"

# --- 2. Jalankan proses ------------------------------------------------------
SERVER_PID=""
if [ "$MODE" = "local" ]; then
    timeout "${HOST_TIMEOUT:-60}" "${HOST_CMD[@]}" > "$SERVER_LOG" 2>&1 &
    SERVER_PID=$!
    note "Server headless jalan (PID $SERVER_PID), tunggu 2 dtk..."
    sleep 2
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        note "PERINGATAN: proses server sudah berhenti sebelum klien jalan — lihat $SERVER_LOG"
    fi
    JOIN_URL="$WS_LOCAL_URL"
else
    note "Mode wss: server lokal TIDAK dijalankan (service VPS diasumsikan hidup)."
    JOIN_URL="$WSS_URL"
fi

note "Klien 1 join $JOIN_URL ..."
timeout "${CLIENT_TIMEOUT:-40}" "${CLIENT_CMD_BASE[@]}" "$JOIN_URL" > "$CLIENT1_LOG" 2>&1 &
CLIENT1_PID=$!
sleep 1
note "Klien 2 join $JOIN_URL ..."
timeout "${CLIENT_TIMEOUT:-40}" "${CLIENT_CMD_BASE[@]}" "$JOIN_URL" > "$CLIENT2_LOG" 2>&1 &
CLIENT2_PID=$!

note "Tunggu ${WAIT_SECS} dtk untuk handshake..."
sleep "$WAIT_SECS"

# Biarkan timeout mengakhiri proses yang masih jalan; tunggu sebentar.
# Matikan semua proses setelah WAIT_SECS habis (timeout hanya jaring pengaman,
# bukan mekanisme tunggu — kalau tidak, tiap run menunggu timeout penuh).
for p in "$CLIENT1_PID" "$CLIENT2_PID" "$SERVER_PID"; do
    [ -n "$p" ] && kill "$p" 2>/dev/null
done
wait "$CLIENT1_PID" 2>/dev/null; wait "$CLIENT2_PID" 2>/dev/null
if [ -n "$SERVER_PID" ]; then wait "$SERVER_PID" 2>/dev/null; fi

# --- 3. Cek log --------------------------------------------------------------
echo ""
echo "=== RINGKASAN SMOKE TEST MULTIPLAYER (mode: $MODE) ==="
echo "Log: $LOG_DIR"
for f in "$SERVER_LOG" "$CLIENT1_LOG" "$CLIENT2_LOG"; do
    echo "  $(basename "$f"): $(wc -l < "$f") baris"
done

# Cek 1: tidak ada baris ERROR.
ERR_LINES="$(grep -nE '^ *(SCRIPT ERROR|ERROR):' "$SERVER_LOG" "$CLIENT1_LOG" "$CLIENT2_LOG" || true)"
if [ -n "$ERR_LINES" ]; then
    echo "CEK 1 GAGAL — baris ERROR ditemukan:"
    echo "$ERR_LINES"
    fail=1
else
    echo "CEK 1 LOLOS — tidak ada baris 'ERROR:' / 'SCRIPT ERROR:' di ketiga log."
fi

# Cek 2: "connected" di server + kedua klien.
# Mode wss: tidak ada server lokal — server.log kosong dan TIDAK dicek; yang
# dicek hanya kedua klien (log server VPS dibaca terpisah di service
# pesantren-verse-realtime, bukan dari skrip ini).
if [ "$MODE" = "wss" ]; then
    CHECK2_LOGS=("$CLIENT1_LOG" "$CLIENT2_LOG")
    echo "CATATAN mode wss: server.log tidak dicek (server jalan di VPS, bukan lokal)."
else
    CHECK2_LOGS=("$SERVER_LOG" "$CLIENT1_LOG" "$CLIENT2_LOG")
fi
for f in "${CHECK2_LOGS[@]}"; do
    if grep -qi "connected" "$f"; then
        echo "CEK 2 LOLOS — '$(basename "$f")' memuat 'connected': $(grep -i -m1 "connected" "$f" | head -c 160)"
    else
        echo "CEK 2 GAGAL — '$(basename "$f")' TIDAK memuat 'connected'."
        fail=1
    fi
done

# Cek tambahan (informatif, bukan penentu lolos/gagal): server masih hidup saat
# klien join + ukuran log tidak kosong.
if [ "$MODE" = "local" ] && [ ! -s "$SERVER_LOG" ]; then
    echo "CATATAN: server.log kosong — server mungkin gagal start (cek biner/preset)."
    fail=1
fi

echo ""
if [ -n "$fail" ]; then
    echo "HASIL: GAGAL (exit 1) — lihat log di $LOG_DIR"
    exit 1
fi
echo "HASIL: LOLOS (exit 0) — 2 instance headless saling terhubung tanpa ERROR."
exit 0

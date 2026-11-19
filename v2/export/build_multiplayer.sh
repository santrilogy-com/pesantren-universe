#!/usr/bin/env bash
# build_multiplayer.sh — build Web + Dedicated Server dari sumber yang SAMA.
#
# Kenapa satu skrip: Godot memeriksa checksum semua method @rpc; klien web
# dan server realtime HARUS dibangun dari commit/proyek yang sama, kalau
# tidak handshake multiplayer gagal dengan error checksum RPC.
#
# Cara kerja (snapshot — lihat catatan di bawah):
#   1. Hitung sidik-jari (fingerprint) seluruh isi proyek godot-dunia.
#   2. Salin proyek ke direktori snapshot sementara, hitung sidik-jari
#      salinan itu. Kalau beda dari sidik-jari langkah 1 -> salinan
#      ketangkap di tengah edit -> build DIGAGALKAN (jendela ini hanya
#      hitungan detik, bukan menit).
#   3. Export Web dulu, lalu Dedicated Server, keduanya --export-release,
#      KEDUANYA dari snapshot yang sama. Snapshot dihapus setelah build.
#   4. Kalau proyek ini repo git, catat juga commit HEAD; kalau bukan
#      repo git (keadaan sekarang), commit dicatat sebagai "no-git-repo"
#      dan fingerprint di atas yang menjadi penanda "commit yang sama".
#   5. Tulis manifest (sidik-jari + commit + sha256 hasil build) ke
#      export/build-manifest.txt supaya tiap deploy bisa dilacak.
#
# KENAPA SNAPSHOT (bukan build langsung dari pohon live): tim Raka/Nadia
# mengedit file game di pohon yang sama secara paralel (ronde kamera,
# tabrakan, area putri). Build langsung dari pohon live digagalkan
# pengaman fingerprint 4x berturut-turut (17 Nov 2026): 2x karena edit
# file game sungguhan di tengah export (main.gd, interior_asrama_putri.gd
# — pengaman bekerja benar), 2x karena file yang TIDAK memengaruhi game
# (file *.uid buatan Godot saat import, skrip foto dev, doc status).
# Snapshot membekukan satu keadaan sumber yang konsisten: kedua artefak
# dijamin dari sumber identik, sementara edit paralel tetap boleh jalan.
# Pengaman "commit yang sama" TIDAK dihapus — dipindah ke penyalinan
# snapshot, dan sidik-jari snapshot dicatat di manifest.
#
# Idempotent: boleh dijalankan ulang; direktori output dibuat bila belum
# ada, hasil build lama ditimpa, manifest ditulis ulang tiap jalan.
#
# Pakai:  ./build_multiplayer.sh            (dari mana saja)
#         GODOT_BIN=/path/ke/godot ./build_multiplayer.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V2_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$V2_DIR/godot-dunia"
WEB_OUT="$V2_DIR/export/web/index.html"
SERVER_OUT="$V2_DIR/export/server/pesantren-verse-server"
MANIFEST="$V2_DIR/export/build-manifest.txt"
LOG="$V2_DIR/export/build-multiplayer.log"

GODOT_BIN="${GODOT_BIN:-$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S %Z')] $*" | tee -a "$LOG"; }
die() { log "FATAL: $*"; exit 1; }

mkdir -p "$(dirname "$WEB_OUT")" "$(dirname "$SERVER_OUT")"
: > "$LOG"

[ -x "$GODOT_BIN" ] || die "biner Godot tidak ditemukan / tidak bisa dieksekusi: $GODOT_BIN"
"$GODOT_BIN" --version >> "$LOG" 2>&1 || die "gagal menjalankan $GODOT_BIN --version"

# Sidik-jari isi proyek — yang dicek adalah file yang BISA memengaruhi
# game yang jalan (dan checksum RPC): semua scene/script/resource game.
# Yang DIKECUALIKAN, dengan alasan:
#   .godot/          cache editor, bukan sumber.
#   *.uid            dibuat Godot sendiri saat import/export (percobaan
#                    pertama gagal justru karena file ini muncul di
#                    tengah build — bukan perubahan sumber).
#   skrip/           tooling dev saja (foto_*, test_*, dump_*) — dijalankan
#                    dengan --script, tidak pernah direferensikan main.tscn
#                    atau scene game mana pun, tidak pernah dimuat saat
#                    game jalan, jadi tidak bisa mengubah checksum RPC.
#                    (Memang ikut ter-packing karena export_filter
#                    all_resources, tapi tidak dieksekusi game.)
#   skrip/smoke-logs/ output log tes, bukan sumber.
# Edit file game (mis. main.gd oleh ronde Raka) di tengah penyalinan
# TETAP menggagalkan build — pengaman itu yang penting.
fingerprint() {
    local dir="$1"
    ( cd "$dir" \
      && find . -type f -not -path "./.godot/*" -not -path "./skrip/*" \
          -not -name "*.uid" -print0 \
      | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}' )
}

git_commit() {
    if git -C "$PROJECT_DIR" rev-parse HEAD >/dev/null 2>&1; then
        git -C "$PROJECT_DIR" rev-parse HEAD
    else
        echo "no-git-repo"
    fi
}

COMMIT="$(git_commit)"
FP_LIVE="$(fingerprint "$PROJECT_DIR")"
log "commit: $COMMIT"
log "fingerprint pohon live: $FP_LIVE"

# --- snapshot: bekukan satu keadaan sumber yang konsisten ---------------
SNAPSHOT_DIR="$(mktemp -d "$V2_DIR/export/.snapshot-XXXXXX")"
trap 'rm -rf "$SNAPSHOT_DIR"' EXIT
log "menyalin proyek ke snapshot: $SNAPSHOT_DIR"
# cp -r (bukan -a): file proyek milik root, -a gagal preserve ownership
# di sini dan menghentikan build; isi yang penting, bukan owner-nya.
cp -r "$PROJECT_DIR/." "$SNAPSHOT_DIR/" \
    || die "gagal menyalin proyek ke snapshot"
FP_SNAP="$(fingerprint "$SNAPSHOT_DIR")"
log "fingerprint snapshot: $FP_SNAP"
if [ "$FP_SNAP" != "$FP_LIVE" ]; then
    die "ISI PROYEK BERUBAH selama penyalinan snapshot (fingerprint $FP_LIVE -> $FP_SNAP). Build digagalkan supaya checksum RPC Web vs server tidak beda. Jalankan ulang."
fi
log "snapshot konsisten — Web + server dibangun dari sumber identik ini."

log "== export Web (dari snapshot) =="
"$GODOT_BIN" --headless --path "$SNAPSHOT_DIR" \
    --export-release "Web" "$WEB_OUT" >> "$LOG" 2>&1 \
    || die "export Web gagal — lihat $LOG"
[ -f "$WEB_OUT" ] || die "export Web selesai tapi $WEB_OUT tidak ada"
log "Web OK: $WEB_OUT"

log "== export Dedicated Server (dari snapshot) =="
"$GODOT_BIN" --headless --path "$SNAPSHOT_DIR" \
    --export-release "Dedicated Server" "$SERVER_OUT" >> "$LOG" 2>&1 \
    || die "export Dedicated Server gagal — lihat $LOG"
[ -f "$SERVER_OUT" ] || die "export server selesai tapi $SERVER_OUT tidak ada"
chmod +x "$SERVER_OUT"
log "Server OK: $SERVER_OUT"

sha256() { sha256sum "$1" | awk '{print $1}'; }

{
    echo "build-manifest — Pesantren Universe multiplayer (Web + Dedicated Server)"
    echo "waktu: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "commit: $COMMIT"
    echo "fingerprint-proyek: $FP_SNAP"
    echo "sumber-build: snapshot sementara dari $PROJECT_DIR (dihapus setelah build)"
    echo "godot: $("$GODOT_BIN" --version 2>/dev/null)"
    echo "web: $WEB_OUT"
    echo "web-index.html sha256: $(sha256 "$WEB_OUT") bytes: $(stat -c%s "$WEB_OUT")"
    echo "web-index.pck sha256: $(sha256 "$V2_DIR/export/web/index.pck") bytes: $(stat -c%s "$V2_DIR/export/web/index.pck")"
    echo "server: $SERVER_OUT"
    echo "server sha256: $(sha256 "$SERVER_OUT") bytes: $(stat -c%s "$SERVER_OUT")"
} > "$MANIFEST"

log "== SELESAI =="
log "manifest: $MANIFEST"
cat "$MANIFEST" | tee -a "$LOG"

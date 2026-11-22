#!/bin/bash
# Export Web segar untuk gate 20261119-6 (Eka) — pola export-web-20261119-5.sh:
# snapshot tree (fingerprint konsisten) -> export Web dari snapshot.
# Dijalankan SETELAH gate hijau. Staging (stage_v2.py) langkah berikut.
set -u
V2="$HOME/workspace/pesantren-verse/v2"
PROJ="$V2/godot-dunia"
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
LOG="$HOME/workspace/.logs-gate-18nov/gate-20261119-6-export.log"
exec > >(tee "$LOG") 2>&1
echo "=== Export Web 20261119-6 mulai $(date '+%H:%M:%S') ==="

fp() { find "$PROJ" -type f -not -path "*/.godot/*" -not -name "*.uid" | sort | xargs md5sum 2>/dev/null | md5sum | cut -d' ' -f1; }
FP1=$(fp)
SNAP=$(mktemp -d "$V2/export/.snapshot-gate6-XXXXXX")
trap 'rm -rf "$SNAP"' EXIT
echo "snapshot: $SNAP"
cp -r "$PROJ/." "$SNAP/" || { echo "GAGAL salin snapshot"; exit 1; }
FP2=$(fp)
if [ "$FP1" != "$FP2" ]; then echo "ISI PROYEK BERUBAH selama penyalinan ($FP1 -> $FP2) — batal, jalankan ulang"; exit 1; fi
echo "snapshot konsisten fp=$FP1"
mkdir -p "$V2/export/web"
"$GODOT" --headless --path "$SNAP" --export-release "Web" "$V2/export/web/index.html" || { echo "EXPORT GAGAL"; exit 1; }
rm -rf "$SNAP"; trap - EXIT
ls -la "$V2/export/web/index.pck" "$V2/export/web/index.wasm" "$V2/export/web/index.html"
sha256sum "$V2/export/web/index.pck" "$V2/export/web/index.wasm" "$V2/export/web/index.html" "$V2/export/web/index.audio.position.worklet.js"
echo "=== Export Web 20261119-6 selesai $(date '+%H:%M:%S') ==="

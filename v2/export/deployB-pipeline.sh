#!/bin/bash
# Deploy B (tekstur terkompres) — pipeline Rangga, 18 Nov 2026.
# 1) snapshot tree -> export Web (hanya Web, bukan server)
# 2) parse index.pck baru (verifikasi .ctex hilang, .ktx2 hadir, ukuran)
# 3) stage ke web-pages-ktx2 (JANGAN web-pages — itu staging Deploy A / d08dfb5e)
# 4) gate penuh (adaptasi gate-deploy-20261118-1952.sh; test_kamera TANPA --fixed-fps 60)
# Dijalankan dari tree kerja. Staging ini BUKAN deploy — deploy oleh Damar
# setelah Deploy A, dari export segar bila tree berubah lagi.
set -u
V2="$HOME/workspace/pesantren-verse/v2"
PROJ="$V2/godot-dunia"
GODOT="$HOME/workspace/.tools/godot-4.7/Godot_v4.7.2-stable_linux.x86_64"
LOG="$V2/export/deployB-pipeline.log"
exec > >(tee -a "$LOG") 2>&1
echo "=== Deploy B pipeline mulai $(date '+%H:%M:%S') ==="

fp() { find "$PROJ" -type f -not -path "*/.godot/*" -not -name "*.uid" | sort | xargs md5sum 2>/dev/null | md5sum | cut -d' ' -f1; }
FP1=$(fp)
SNAP=$(mktemp -d "$V2/export/.snapshot-ktx2-XXXXXX")
trap 'rm -rf "$SNAP"' EXIT
echo "snapshot: $SNAP"
cp -r "$PROJ/." "$SNAP/" || { echo "GAGAL salin snapshot"; exit 1; }
FP2=$(fp)
if [ "$FP1" != "$FP2" ]; then echo "ISI PROYEK BERUBAH selama penyalinan ($FP1 -> $FP2) — batal, jalankan ulang"; exit 1; fi
echo "snapshot konsisten fp=$FP1"

echo "=== export Web (dari snapshot) ==="
mkdir -p "$V2/export/web"
"$GODOT" --headless --path "$SNAP" --export-release "Web" "$V2/export/web/index.html" || { echo "EXPORT GAGAL"; exit 1; }
rm -rf "$SNAP"; trap - EXIT
ls -la "$V2/export/web/index.pck" "$V2/export/web/index.wasm"
echo "=== parse pck baru ==="
python3 "$V2/konsep/uji-kompres-tekstur/parse-pck.py" "$V2/export/web/index.pck" | tee "$V2/export/pck-baru.txt"
echo "=== stage ke web-pages-ktx2 ==="
sed 's#v2/export/web-pages#v2/export/web-pages-ktx2#' "$V2/export/stage_v2.py" > "$V2/export/stage_v2_ktx2.py"
"$HOME/workspace/.venv-cloudflare/bin/python" "$V2/export/stage_v2_ktx2.py" || { echo "STAGE GAGAL"; exit 1; }
echo "=== pipeline export+stage selesai $(date '+%H:%M:%S') ==="

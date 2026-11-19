#!/bin/bash
# Auto-sync Pesantren Universe -> GitHub (dijalankan cron tiap 30 menit).
# Commit + push bila ada perubahan; diam bila tidak ada perubahan.
# Bila push gagal (tidak ada jaringan / auth habis / remote belum ada):
# tulis ke log dan exit 0 — jangan spam, jangan retry berulang.
set -u
REPO="$HOME/workspace/pesantren-verse"
LOG="$HOME/workspace/.logs-gate-18nov/git-auto-sync.log"
mkdir -p "$(dirname "$LOG")"
cd "$REPO" || exit 0
git add -A
if git diff --cached --quiet; then
  exit 0
fi
JUMLAH=$(git diff --cached --name-only | wc -l | tr -d ' ')
STAMP=$(TZ=Asia/Jakarta date '+%Y-%m-%d %H:%M WIB')
git commit -q -m "Auto-sync: $STAMP ($JUMLAH file berubah)" || exit 0
if ! git push -q origin main >>"$LOG" 2>&1; then
  echo "[$STAMP] push gagal" >>"$LOG"
fi
exit 0

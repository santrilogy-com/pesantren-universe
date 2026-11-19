#!/usr/bin/env bash
# Tes end-to-end v1.5.1: jenis_kelamin di registrasi santri.
# Jalankan dari mana saja (butuh curl + akses internet):  bash test-v1.5.1.sh
# Membuat 1 santri tes (PV-0002, "Tes Putri") — bersihkan setelahnya:
#   python3 cleanup-v1.5.1.py   (di VPS, folder server)
set -u
API="${PV_API:-https://43-173-39-166.sslip.io}"
LOLOS=0; GAGAL=0
cek() { # cek <nama> <perintah...>
  local nama="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "LOLOS: $nama"; LOLOS=$((LOLOS+1));
  else echo "GAGAL: $nama"; GAGAL=$((GAGAL+1)); fi
}
echo "== v1.5.1: jenis_kelamin (API: $API) =="
cek "health = version 1.5.1" \
  bash -c "curl -s $API/health | grep -q '\"version\": \"1.5.1\"'"
cek "register santriwati -> 201 + jenis_kelamin putri" \
  bash -c "curl -s -o /tmp/pv-t151-reg.json -w '%{http_code}' -X POST $API/api/santri/register -H 'Content-Type: application/json' -d '{\"nama\":\"Tes Putri\",\"ig_username\":\"tes_putri_1711\",\"jenis_kelamin\":\"putri\"}' | grep -q 201 && grep -q '\"jenis_kelamin\": \"putri\"' /tmp/pv-t151-reg.json"
cek "login -> jenis_kelamin putri" \
  bash -c "curl -s -X POST $API/api/santri/login -H 'Content-Type: application/json' -d '{\"ig_username\":\"tes_putri_1711\"}' | grep -q '\"jenis_kelamin\": \"putri\"'"
cek "verify PV-0002 -> jenis_kelamin putri" \
  bash -c "curl -s -X POST $API/api/santri/verify -H 'Content-Type: application/json' -d '{\"id\":\"PV-0002\"}' | grep -q '\"jenis_kelamin\": \"putri\"'"
cek "register nilai salah -> 400" \
  bash -c "curl -s -o /dev/null -w '%{http_code}' -X POST $API/api/santri/register -H 'Content-Type: application/json' -d '{\"nama\":\"Tes Salah\",\"ig_username\":\"tes_salah_1711\",\"jenis_kelamin\":\"laki-laki\"}' | grep -q 400"
cek "register tanpa gender -> 400" \
  bash -c "curl -s -o /dev/null -w '%{http_code}' -X POST $API/api/santri/register -H 'Content-Type: application/json' -d '{\"nama\":\"Tes Kosong\",\"ig_username\":\"tes_kosong_1711\"}' | grep -q 400"
cek "verify PV-0001 (lama) -> jenis_kelamin null" \
  bash -c "curl -s -X POST $API/api/santri/verify -H 'Content-Type: application/json' -d '{\"id\":\"PV-0001\"}' | grep -q '\"jenis_kelamin\": null'"
echo "== $LOLOS lolos, $GAGAL gagal =="
[ "$GAGAL" -eq 0 ]

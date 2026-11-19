#!/bin/bash
# Tes end-to-end server Pesantren Universe v1.3.0 via HTTPS publik.
# Jalankan dari VM: bash test-v1.3.0.sh
# Santri tes: uji.sesi130 (PV-0002) + uji.dua130 (PV-0003) — dihapus lagi
# di akhir (lihat cleanup-v1.3.0 di VPS) supaya DB produksi bersih.
BASE="https://43-173-39-166.sslip.io"
PASS=0; FAIL=0
check() { # check "nama" kondisi-angka kode-harapan kode-dapat
  local nama="$1" harap="$2" dapat="$3"
  if [ "$harap" = "$dapat" ]; then PASS=$((PASS+1)); echo "PASS: $nama ($dapat)";
  else FAIL=$((FAIL+1)); echo "FAIL: $nama (harap $harap, dapat $dapat)"; fi
}
jget() { python3 -c "import sys,json; d=json.load(sys.stdin); print(d$1)" 2>/dev/null; }

echo "== 0. health =="
H=$(curl -s -m 15 "$BASE/health")
echo "$H"
check "health version 1.3.0" "1.3.0" "$(echo "$H" | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])")"

echo "== 1. register PUBLIK tanpa token -> 201 PV-0002 =="
R1=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/register" -H 'Content-Type: application/json' -d '{"nama":"Uji Sesi","ig_username":"uji.sesi130"}')
C1=$(echo "$R1" | tail -1); B1=$(echo "$R1" | head -n -1); echo "$B1"
check "register publik" "201" "$C1"
ID1=$(echo "$B1" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
echo "id santri tes 1: $ID1"

echo "== 2. register duplikat ig -> 409 =="
R2=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/register" -H 'Content-Type: application/json' -d '{"nama":"Uji Lagi","ig_username":"uji.sesi130"}')
check "register duplikat ig" "409" "$(echo "$R2" | tail -1)"

echo "== 3. register tanpa ig_username -> 400 =="
R3=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/register" -H 'Content-Type: application/json' -d '{"nama":"Tanpa IG"}')
check "register tanpa ig" "400" "$(echo "$R3" | tail -1)"

echo "== 4. login username saja (belum berpassword) -> 200 + session =="
L1=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/login" -H 'Content-Type: application/json' -d '{"ig_username":"uji.sesi130"}')
C4=$(echo "$L1" | tail -1); B4=$(echo "$L1" | head -n -1); echo "$B4"
check "login username saja" "200" "$C4"
SES1=$(echo "$B4" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session',''))")
EXP1=$(echo "$B4" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_expires_in',''))")
[ -n "$SES1" ] && [ "$SES1" != "None" ] && PASS=$((PASS+1)) && echo "PASS: login mengembalikan session" || { FAIL=$((FAIL+1)); echo "FAIL: login tidak mengembalikan session"; }
check "session_expires_in 3600" "3600" "$EXP1"

echo "== 5. set_password dengan session -> 200 =="
S1=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/set_password" -H 'Content-Type: application/json' -d "{\"session\":\"$SES1\",\"password\":\"rahasia123\"}")
echo "$S1" | head -n -1
check "set_password dgn session" "200" "$(echo "$S1" | tail -1)"

echo "== 6. set_password lagi dgn session yg sama (sudah dipakai) -> 401 =="
S2=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/set_password" -H 'Content-Type: application/json' -d "{\"session\":\"$SES1\",\"password\":\"rahasia456\"}")
echo "$S2" | head -n -1
check "set_password session terpakai" "401" "$(echo "$S2" | tail -1)"

echo "== 7. login dgn password baru -> 200 + session baru =="
L2=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/login" -H 'Content-Type: application/json' -d '{"ig_username":"uji.sesi130","password":"rahasia123"}')
C7=$(echo "$L2" | tail -1); B7=$(echo "$L2" | head -n -1); echo "$B7"
check "login dgn password baru" "200" "$C7"
SES2=$(echo "$B7" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session',''))")
[ -n "$SES2" ] && [ "$SES2" != "$SES1" ] && PASS=$((PASS+1)) && echo "PASS: session baru berbeda" || { FAIL=$((FAIL+1)); echo "FAIL: session baru sama/kosong"; }

echo "== 8. login password salah -> 401 =="
L3=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/login" -H 'Content-Type: application/json' -d '{"ig_username":"uji.sesi130","password":"salah123"}')
check "login password salah" "401" "$(echo "$L3" | tail -1)"

echo "== 9. login username tak dikenal -> found:false =="
L4=$(curl -s -m 15 -X POST "$BASE/api/santri/login" -H 'Content-Type: application/json' -d '{"ig_username":"tidak.ada130"}')
echo "$L4"
check "login tak dikenal found=false" "False" "$(echo "$L4" | python3 -c "import sys,json; print(json.load(sys.stdin)['found'])")"

echo "== 10. santri ke-2 + set_password dgn session orang lain -> 403 =="
R4=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/register" -H 'Content-Type: application/json' -d '{"nama":"Uji Dua","ig_username":"uji.dua130"}')
C10=$(echo "$R4" | tail -1); B10=$(echo "$R4" | head -n -1); echo "$B10"
check "register santri ke-2" "201" "$C10"
ID2=$(echo "$B10" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
L5=$(curl -s -m 15 -X POST "$BASE/api/santri/login" -H 'Content-Type: application/json' -d '{"ig_username":"uji.dua130"}')
SES3=$(echo "$L5" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session',''))")
S3=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/set_password" -H 'Content-Type: application/json' -d "{\"session\":\"$SES3\",\"id\":\"$ID1\",\"password\":\"coba1234\"}")
echo "$S3" | head -n -1
check "set_password session orang lain" "403" "$(echo "$S3" | tail -1)"

echo "== 11. set_password tanpa session -> 401 =="
S4=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/set_password" -H 'Content-Type: application/json' -d '{"password":"coba1234"}')
check "set_password tanpa session" "401" "$(echo "$S4" | tail -1)"

echo "== 12. points tanpa token -> 401 (tetap) =="
P1=$(curl -s -m 15 -w "\n%{http_code}" -X POST "$BASE/api/santri/points" -H 'Content-Type: application/json' -d "{\"id\":\"$ID1\",\"misi\":\"M1\",\"poin\":10,\"event_id\":\"uji-v130-1\"}")
check "points tanpa token" "401" "$(echo "$P1" | tail -1)"

echo "== 13. verify PV-0001 (regresi) + ranking =="
V1=$(curl -s -m 15 -X POST "$BASE/api/santri/verify" -H 'Content-Type: application/json' -d '{"id":"PV-0001","nama":"Tes"}')
echo "$V1"
check "verify PV-0001 found" "True" "$(echo "$V1" | python3 -c "import sys,json; print(json.load(sys.stdin)['found'])")"
RK=$(curl -s -m 15 "$BASE/api/ranking?limit=5")
echo "$RK"
check "ranking total_santri 3" "3" "$(echo "$RK" | python3 -c "import sys,json; print(json.load(sys.stdin)['total_santri'])")"

echo
echo "HASIL: PASS=$PASS FAIL=$FAIL"
echo "ID1=$ID1 ID2=$ID2 SES2=$SES2"

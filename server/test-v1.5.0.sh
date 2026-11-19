#!/usr/bin/env bash
# Tes end-to-end pustaka kitab v1.5.0 — dijalankan DI VPS.
# Semua endpoint kitab publik (tanpa token); regresi juga publik.
# Keluar 0 bila semua cek lolos, 1 bila ada yang gagal.
set -u
B="https://43-173-39-166.sslip.io"
PASS=0; FAIL=0
cek() { # cek <nama> <perintah...>
  local nama="$1"; shift
  if "$@" > /tmp/t15.out 2>&1; then PASS=$((PASS+1)); echo "LOLOS: $nama";
  else FAIL=$((FAIL+1)); echo "GAGAL: $nama"; cat /tmp/t15.out; fi
}
jget() { curl -s -m 20 "$1"; }

cek "health = 1.5.0" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/health',timeout=20))
assert d['version']=='1.5.0', d"

cek "daftar kitab: 1 kitab, Jurumiyah, dicek_ustadz false, atribusi" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/kitab',timeout=20))
assert d['total']==1, d
k=d['kitab'][0]
assert k['id']=='jurumiyah' and k['jumlah_bab']==25, k
assert k['dicek_ustadz'] is False, k
assert k['atribusi']=='Teks: OpenITI (CC BY-NC-SA 4.0)', k
assert d['atribusi']=='Teks: OpenITI (CC BY-NC-SA 4.0)'"

cek "bab 1 berisi pembuka matn Jurumiyah" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/kitab/jurumiyah?bab=1',timeout=20))
assert d['bab']['judul']=='مدخل', d['bab']
assert 'الكلام: هو اللفظ المركب المفيد بالوضع' in d['bab']['teks']
assert d['dicek_ustadz'] is False"

cek "bab 25 (terakhir) berakhir 'تم بحمد الله'" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/kitab/jurumiyah?bab=25',timeout=20))
assert d['bab']['judul']=='باب المخفوضات من الأسماء', d['bab']
assert d['bab']['teks'].rstrip().endswith('تم بحمد الله')"

cek "kitab utuh: 25 bab + metadata sumber" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/kitab/jurumiyah',timeout=20))
assert len(d['bab'])==25, len(d['bab'])
assert d['sumber'].startswith('OpenITI 0723IbnAjrum'), d['sumber']
assert d['lisensi']=='CC BY-NC-SA 4.0'"

cek "bab 99 -> 404" python3 -c "
import urllib.request,urllib.error
try:
    urllib.request.urlopen('$B/api/kitab/jurumiyah?bab=99',timeout=20); raise SystemExit(1)
except urllib.error.HTTPError as e: assert e.code==404, e.code"

cek "kitab tidak ada -> 404" python3 -c "
import urllib.request,urllib.error
try:
    urllib.request.urlopen('$B/api/kitab/tidakada',timeout=20); raise SystemExit(1)
except urllib.error.HTTPError as e: assert e.code==404, e.code"

cek "bab bukan angka -> 400" python3 -c "
import urllib.request,urllib.error
try:
    urllib.request.urlopen('$B/api/kitab/jurumiyah?bab=abc',timeout=20); raise SystemExit(1)
except urllib.error.HTTPError as e: assert e.code==400, e.code"

cek "regresi: ranking total 1 (PV-0001)" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/ranking?limit=5',timeout=20))
assert d['total_santri']==1 and d['ranking'][0]['id']=='PV-0001', d"

cek "regresi: verify PV-0001 found" python3 -c "
import json,urllib.request
req=urllib.request.Request('$B/api/santri/verify',data=b'{\"id\":\"PV-0001\"}',headers={'Content-Type':'application/json'})
d=json.load(urllib.request.urlopen(req,timeout=20))
assert d['found'] is True and d['id']=='PV-0001', d"

cek "regresi: lamaran/saya PV-0001 total 0" python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('$B/api/lamaran/saya?santri_id=PV-0001',timeout=20))
assert d['total']==0, d"

cek "regresi: login unknown -> found:false" python3 -c "
import json,urllib.request
req=urllib.request.Request('$B/api/santri/login',data=b'{\"ig_username\":\"tidak.ada\"}',headers={'Content-Type':'application/json'})
d=json.load(urllib.request.urlopen(req,timeout=20))
assert d['found'] is False, d"

echo "== $PASS lolos, $FAIL gagal =="
[ "$FAIL" -eq 0 ]

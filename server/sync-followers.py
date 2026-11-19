#!/usr/bin/env python3
"""Sinkronisasi follower @pesantren.verse -> santri (server Pesantren Universe).

Follow = jadi santri (keputusan Mas, 16 Nov 2026 ~12:51 WIB).
Instagram tidak memberi webhook follower baru ke pihak ketiga, jadi
sinkronisasi ini BERKALA (cron per jam), bukan real-time.

Alur per follower:
  1. POST /api/santri/login {ig_username} -> found:true = sudah santri, lewati.
  2. found:false -> POST /api/santri/register {nama, ig_username}
     (nama sementara = username IG; santri bisa melengkapi profil nanti
     saat ada endpoint ubah profil).
  Register + login PUBLIK di server v1.3.0 (tanpa X-PV-Token) -- token
  bersama TIDAK PERNAH dipakai di skrip ini.

Keluar: 0 = sukses (termasuk 0 santri baru), 1 = baca IG gagal
(tidak mendaftarkan apa pun), 2 = server tidak terjangkau.
Log: sync-followers.log di direktori yang sama.
"""
import json
import subprocess
import sys
import urllib.request
from datetime import datetime
from zoneinfo import ZoneInfo

WIB = ZoneInfo("Asia/Jakarta")

ACCOUNT_ID = "17841411153423227"  # @pesantren.verse (user_fbid)
API_BASE = "https://43-173-39-166.sslip.io"
CLI = "/opt/hatch/bin/instagram-cli"
LOG_PATH = "/home/hatch/workspace/pesantren-verse/server/sync-followers.log"
MAX_PAGES = 10
PAGE_SIZE = 100


def log(msg):
    line = f"{datetime.now(WIB).strftime('%Y-%m-%d %H:%M:%S WIB')} {msg}"
    print(line, flush=True)
    with open(LOG_PATH, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def api_post(path, payload):
    req = urllib.request.Request(
        API_BASE + path,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.status, json.loads(resp.read().decode("utf-8"))


def read_followers():
    """Baca semua follower @pesantren.verse (paginasi). Kembalikan list username."""
    usernames = []
    after = None
    seen_cursors = set()
    for _ in range(MAX_PAGES):
        cmd = [CLI, "followers", "--account-id", ACCOUNT_ID,
               "--sort-by", "recent", "--count", str(PAGE_SIZE)]
        if after:
            cmd += ["--after", after]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if res.returncode != 0:
            raise RuntimeError(f"instagram-cli gagal (exit {res.returncode}): {res.stderr.strip()[:300]}")
        data = json.loads(res.stdout)
        page = data.get("users") or []
        new = 0
        for u in page:
            name = (u.get("username") or u.get("user_name") or "").strip().lstrip("@").lower()
            if name and name not in usernames:
                usernames.append(name)
                new += 1
        if not data.get("has_more"):
            break
        nxt = data.get("next_max_id")
        if not nxt or nxt in seen_cursors or new == 0:
            break
        seen_cursors.add(nxt)
        after = nxt
    return usernames


def main():
    log("== sync follower -> santri: mulai ==")
    try:
        followers = read_followers()
    except Exception as e:
        log(f"GAGAL baca follower IG: {e}")
        return 1
    log(f"follower @pesantren.verse: {len(followers)}")
    baru = 0
    for uname in followers:
        try:
            status, body = api_post("/api/santri/login", {"ig_username": uname})
        except Exception as e:
            log(f"server tidak terjangkau saat cek {uname}: {e}")
            return 2
        if body.get("found"):
            continue
        try:
            status, body = api_post(
                "/api/santri/register", {"nama": uname, "ig_username": uname}
            )
        except Exception as e:
            log(f"gagal daftar {uname}: {e}")
            continue
        if status == 201:
            baru += 1
            log(f"santri baru: @{uname} -> {body.get('id')} (nama sementara = username IG)")
        elif status == 409:
            log(f"@{uname} sudah terdaftar (409), lewati")
        else:
            log(f"register @{uname} gagal: HTTP {status} {str(body)[:200]}")
    log(f"== selesai: {baru} santri baru dari {len(followers)} follower ==")
    return 0


if __name__ == "__main__":
    sys.exit(main())

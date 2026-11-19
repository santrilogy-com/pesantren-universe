#!/usr/bin/env python3
"""Pesantren Universe API — Fase 1: verifikasi ID + sinkron poin + ranking.

Stdlib Python saja (tanpa dependensi): http.server + sqlite3.
Dijalankan sebagai service systemd, di depan Caddy (HTTPS).

Endpoint:
  GET  /health                  -> status service
  GET  /                       -> daftar endpoint
  POST /api/santri/register     -> daftar santri baru, terbitkan ID PV-XXXX (PUBLIK,
                                  tanpa token); sistem TUNGGAL (tanpa jalur);
                                  ig_username WAJIB (identitas login),
                                  password/kota/email opsional
  POST /api/santri/login        -> login pakai ig_username (+ password bila sudah diset);
                                  login berhasil mengembalikan token sesi 1 jam
  POST /api/santri/set_password -> isi/ubah password sendiri (token sesi dari login,
                                  BUKAN token bersama X-PV-Token)
  POST /api/santri/realtime_ticket -> terbitkan tiket realtime (5 menit,
                                  sekali pakai) untuk handshake WebSocket;
                                  pakai token sesi login yang masih berlaku
                                  (token sesi TIDAK hangus karena ini)
  POST /api/santri/realtime_ticket/validate -> validasi + tandai terpakai
                                  tiket realtime (butuh X-PV-Token — hanya
                                  server realtime tepercaya di VPS yang sama)
  POST /api/santri/verify      -> verifikasi ID + nama, kembalikan status santri
  POST /api/santri/points      -> kirim poin misi, kembalikan total terbaru (butuh token)
  GET  /api/ranking?limit=N    -> leaderboard global
  POST /api/lamaran/kirim      -> kirim lamaran pengurus (publik, tanpa token)
  GET  /api/lamaran/saya       -> daftar lamaran satu santri (publik)
  GET  /api/lamaran/daftar     -> semua lamaran, filter ?status= (butuh token)
  POST /api/lamaran/rekomendasi -> rekomendasi musyrif (butuh token)
  POST /api/lamaran/keputusan  -> keputusan Pengasuh (butuh token)
  GET  /api/kitab             -> daftar kitab (publik)
  GET  /api/kitab/<id>?bab=N  -> isi kitab / satu bab (publik)

Auth: header X-PV-Token (shared secret, dari file .env) HANYA untuk
POST /api/santri/points (pemberian poin oleh game/server tepercaya).
POST /api/santri/register PUBLIK (pendaftaran terbuka, siapa pun boleh
daftar — rate limit 120/menit/IP tetap berlaku). POST /api/santri/login
publik dan mengembalikan token sesi (acak, 1 jam, satu sesi per santri,
hangus setelah dipakai); POST /api/santri/set_password memakai token sesi
itu (field "session" di body), BUKAN X-PV-Token — jadi token bersama tidak
pernah keluar dari server dan app cukup menyimpan token sesi santri.
Endpoint baca (verify, ranking, health) publik tapi dibatasi rate limit.
Lamaran (v1.4.0): kirim + saya publik (perbuatan santri sendiri);
rekomendasi, keputusan, dan daftar butuh X-PV-Token (musyrif/Pengasuh
lewat app — token dipegang server app, bukan klien).

Aturan yang disamakan dengan game Godot (scripts/save_data.gd):
  - ID format PV-XXXX (4 angka, huruf besar), berurutan dari nomor tertinggi.
  - Tier: >=100 Penjaga Lentera, >=50 Pembuka Peti, >=25 Penjelajah,
    sisanya Santri Baru.
  - Nama santri maks 30 huruf.
"""
import hashlib
import json
import os
import secrets
import re
import sqlite3
import threading
import time
from datetime import datetime, timedelta, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

VERSION = "1.5.2"
DB_PATH = os.environ.get("PV_DB", "/home/ubuntu/pesantren-verse-server/data/pesantren.db")
TOKEN = os.environ.get("PV_TOKEN", "")
PORT = int(os.environ.get("PV_PORT", "8790"))
HOST = os.environ.get("PV_HOST", "127.0.0.1")
MAX_BODY = 64 * 1024          # 64 KB
RATE_LIMIT = 120              # request per menit per IP
RATE_WINDOW = 60

ID_RE = re.compile(r"^PV-\d{4}$")
IG_RE = re.compile(r"^[a-z0-9._]{1,64}$")

# Password santri: DIISI SENDIRI oleh user (saat daftar atau lewat
# set_password), disimpan sebagai HASH format "sha256$<salt_hex>$<digest_hex>"
# — plaintext tidak pernah disimpan dan tidak pernah dikembalikan endpoint
# mana pun. Login: username IG saja bila belum ada password; bila sudah ada
# password, wajib cocok.


def hash_password(pw: str) -> str:
    salt = secrets.token_hex(8)
    digest = hashlib.sha256((salt + pw).encode("utf-8")).hexdigest()
    return f"sha256${salt}${digest}"


def cek_password(pw: str, stored) -> bool:
    """Cocokkan password dengan hash tersimpan (format sha256$salt$digest)."""
    if not stored or not isinstance(pw, str):
        return False
    try:
        _, salt, digest = stored.split("$")
    except ValueError:
        return False
    return hashlib.sha256((salt + pw).encode("utf-8")).hexdigest() == digest


def norm_ig_username(s) -> str:
    """Normalisasi username IG opsional: tanpa '@', huruf kecil."""
    if not isinstance(s, str):
        return ""
    return s.strip().lstrip("@").strip().lower()


def tier_for_points(poin: int) -> str:
    if poin >= 100:
        return "Penjaga Lentera"
    if poin >= 50:
        return "Pembuka Peti"
    if poin >= 25:
        return "Penjelajah"
    return "Santri Baru"


def norm_id(s) -> str:
    return s.strip().upper() if isinstance(s, str) else ""


# ---------------------------------------------------------------- DB
_db_lock = threading.Lock()
_conn = None


def db() -> sqlite3.Connection:
    global _conn
    if _conn is None:
        os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
        _conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        _conn.row_factory = sqlite3.Row
        _conn.execute("PRAGMA journal_mode=WAL")
        _conn.execute("PRAGMA synchronous=NORMAL")
        _conn.execute("PRAGMA foreign_keys=ON")
        _conn.executescript("""
            CREATE TABLE IF NOT EXISTS santri (
                id TEXT PRIMARY KEY,
                nama TEXT NOT NULL,
                jalur TEXT NOT NULL DEFAULT 'Misi',
                password_hash TEXT,
                ig_username TEXT,
                jenis_kelamin TEXT,
                kota TEXT,
                email TEXT,
                total_poin INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS points_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                misi TEXT NOT NULL,
                poin INTEGER NOT NULL,
                event_id TEXT UNIQUE,
                created_at TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_points_santri ON points_log(santri_id);
            CREATE TABLE IF NOT EXISTS sesi_login (
                token TEXT PRIMARY KEY,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                created_epoch INTEGER NOT NULL,
                expires_epoch INTEGER NOT NULL,
                used INTEGER NOT NULL DEFAULT 0
            );
            CREATE INDEX IF NOT EXISTS idx_sesi_santri ON sesi_login(santri_id);
            CREATE TABLE IF NOT EXISTS tiket_realtime (
                ticket TEXT PRIMARY KEY,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                created_epoch INTEGER NOT NULL,
                expires_epoch INTEGER NOT NULL,
                used INTEGER NOT NULL DEFAULT 0
            );
            CREATE INDEX IF NOT EXISTS idx_tiket_santri ON tiket_realtime(santri_id);
            CREATE INDEX IF NOT EXISTS idx_santri_poin ON santri(total_poin DESC);
            CREATE TABLE IF NOT EXISTS lamaran (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                santri_id TEXT NOT NULL REFERENCES santri(id),
                posisi TEXT NOT NULL,
                posisi_cadangan TEXT,
                alasan TEXT NOT NULL,
                pengalaman TEXT,
                status TEXT NOT NULL DEFAULT 'menunggu_musyrif',
                rekomendasi_musyrif TEXT,
                catatan_musyrif TEXT,
                keputusan TEXT,
                alasan_tolak TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                diputuskan_at TEXT
            );
            CREATE INDEX IF NOT EXISTS idx_lamaran_santri ON lamaran(santri_id);
            CREATE INDEX IF NOT EXISTS idx_lamaran_status ON lamaran(status);
        """)
        # Migrasi kolom baru (idempotent): DB lama belum punya kolom ini.
        cols = {r[1] for r in _conn.execute("PRAGMA table_info(santri)")}
        if "password_hash" not in cols:
            _conn.execute("ALTER TABLE santri ADD COLUMN password_hash TEXT")
        if "ig_username" not in cols:
            _conn.execute("ALTER TABLE santri ADD COLUMN ig_username TEXT")
        if "kota" not in cols:
            _conn.execute("ALTER TABLE santri ADD COLUMN kota TEXT")
        if "email" not in cols:
            _conn.execute("ALTER TABLE santri ADD COLUMN email TEXT")
        if "jenis_kelamin" not in cols:
            _conn.execute("ALTER TABLE santri ADD COLUMN jenis_kelamin TEXT")
        _conn.commit()
    return _conn


def now_iso() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def santri_view(row) -> dict:
    return {
        "id": row["id"],
        "nama": row["nama"],
        "jenis_kelamin": row["jenis_kelamin"],
        "jalur": row["jalur"],
        "total_poin": row["total_poin"],
        "tier": tier_for_points(row["total_poin"]),
        "created_at": row["created_at"],
    }


def misi_selesai(c, santri_id: str) -> int:
    r = c.execute("SELECT COUNT(DISTINCT misi) AS n FROM points_log WHERE santri_id=?",
                  (santri_id,)).fetchone()
    return r["n"] if r else 0


# ---------------------------------------------------------------- Lamaran pengurus (v1.4.0)
# Desain: DESAIN-LAMARAN-PENGURUS.md (ACC Mas 16 Nov 2026 ~15:55 WIB).
# Posisi: 5 (Kepala Kamar + Ketua Asrama lewat vote, bukan lamaran).
# Syarat: santri terdaftar + Misi M1 selesai. Misi berurutan (M1 dulu baru
# M2/M3), jadi misi_selesai >= 1 berarti M1 sudah selesai (asumsi v1.4.0).
# 1 santri = 1 lamaran aktif (menunggu_musyrif/menunggu_pengasuh); jeda
# 1 minggu setelah penolakan terakhir. Alur: menunggu_musyrif ->
# menunggu_pengasuh -> diterima/ditolak. Rekomendasi musyrif ("setuju"/
# "tidak") selalu meneruskan ke Pengasuh — keputusan akhir di Pengasuh.
POSISI_LAMARAN = ["Keamanan", "Ubudiyah", "Kebersihan", "Pendidikan", "Humas & Media"]
STATUS_LAMARAN = ["menunggu_musyrif", "menunggu_pengasuh", "diterima", "ditolak"]
JEDA_LAMAR_HARI = 7
# ---------------------------------------------------------------- Pustaka kitab (v1.5.0)
# Rak kitab interaktif (ACC Mas 16 Nov 2026 ~18:47 WIB): Arab saja, kitab
# pertama Jurumiyah dari OpenITI (CC BY-NC-SA 4.0). File-based:
# kitab/*.json di folder yang sama dengan server.py — tambah kitab =
# tambah file JSON (tanpa migrasi DB, tanpa ubah kode). Tiap kitab
# ditandai dicek_ustadz — teks BELUM dicek ustadz (false) tidak boleh
# ditampilkan pembaca game; pengecekan adalah langkah manusia (ustadz),
# bukan tugas server. Full MCP Shamela + terjemahan DITUNDA sampai ada
# gedung Perpustakaan (200 santri).
ATRIBUSI_KITAB = "Teks: OpenITI (CC BY-NC-SA 4.0)"
KITAB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kitab")
KITAB_ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$")
_kitab_cache = None


def _muat_kitab() -> dict:
    """Muat semua kitab/*.json sekali, cache di memori. File rusak /
    id tidak cocok nama file dilewati (tidak menggagalkan server)."""
    global _kitab_cache
    if _kitab_cache is not None:
        return _kitab_cache
    data = {}
    try:
        for nama in sorted(os.listdir(KITAB_DIR)):
            if not nama.endswith(".json"):
                continue
            kid = nama[:-5]
            if not KITAB_ID_RE.match(kid):
                continue
            try:
                with open(os.path.join(KITAB_DIR, nama), encoding="utf-8") as f:
                    d = json.load(f)
            except (OSError, ValueError):
                continue
            if not isinstance(d, dict) or d.get("id") != kid:
                continue
            data[kid] = d
    except OSError:
        pass
    _kitab_cache = data
    return data



# ---------------------------------------------------------------- Sesi login
# Token sesi: diterbitkan _login saat login berhasil. Acak (token_urlsafe),
# berlaku 1 jam, SATU sesi per santri (login baru menghapus sesi lama santri
# itu), hangus setelah dipakai untuk set_password (sekali pakai) atau
# kedaluwarsa. Dipakai _set_password sebagai pengganti token bersama
# X-PV-Token, supaya app bisa memakai server tanpa memegang token bersama.
SESI_TTL_DETIK = 3600  # 1 jam


def _buat_sesi(santri_id: str) -> str:
    token = secrets.token_urlsafe(32)
    now = int(time.time())
    with _db_lock:
        c = db()
        c.execute("DELETE FROM sesi_login WHERE santri_id=?", (santri_id,))
        # Bersihkan sesi kedaluwarsa yang sudah lama (housekeeping ringan).
        c.execute("DELETE FROM sesi_login WHERE expires_epoch < ?", (now - 86400,))
        c.execute("INSERT INTO sesi_login (token, santri_id, created_epoch, "
                  "expires_epoch, used) VALUES (?, ?, ?, ?, 0)",
                  (token, santri_id, now, now + SESI_TTL_DETIK))
        c.commit()
    return token


def _cek_sesi(token):
    """Validasi token sesi. Kembalikan (santri_id, None) bila valid,
    atau (None, pesan_error) bila tidak valid / sudah dipakai / kedaluwarsa."""
    if not isinstance(token, str) or not token:
        return None, "Token sesi tidak valid"
    with _db_lock:
        c = db()
        row = c.execute("SELECT * FROM sesi_login WHERE token=?",
                        (token,)).fetchone()
    if row is None:
        return None, "Token sesi tidak valid"
    if row["used"]:
        return None, "Token sesi sudah dipakai"
    if int(time.time()) > row["expires_epoch"]:
        return None, "Token sesi sudah kedaluwarsa"
    return row["santri_id"], None


# ---------------------------------------------------------------- Tiket realtime (v1.5.2)
# Tiket handshake WebSocket untuk server realtime (MULTIPLAYER-PLAN.md
# §1.3, keputusan Fase 0: cara (a)). Token sesi login TIDAK BOLEH dipakai
# langsung untuk handshake — token itu juga mengesahkan set_password, dan
# server realtime (Godot, tanpa driver sqlite) tidak bisa membaca tabel
# sesi_login. Jadi REST menerbitkan tiket khusus: acak, 5 menit, sekali
# pakai. Token sesi TIDAK hangus saat minta tiket (tetap berlaku untuk
# set_password dan untuk minta tiket lagi bila reconnect). Server realtime
# memvalidasi tiket lewat POST /api/santri/realtime_ticket/validate
# (wajib X-PV-Token, pola yang sama seperti /points) — validasi yang
# berhasil langsung menandai tiket terpakai, dan mengembalikan identitas
# dari DB supaya nama yang tampil ke pemain lain selalu dari DB, bukan
# dari klien. Tiket TIDAK PERNAH ditulis ke log (log hanya mencatat
# method + path + status, tanpa body).
TIKET_TTL_DETIK = 300  # 5 menit


def _buat_tiket_realtime(santri_id: str) -> str:
    ticket = secrets.token_urlsafe(32)
    now = int(time.time())
    with _db_lock:
        c = db()
        # Bersihkan tiket kedaluwarsa yang sudah lama (housekeeping ringan).
        c.execute("DELETE FROM tiket_realtime WHERE expires_epoch < ?", (now - 86400,))
        c.execute("INSERT INTO tiket_realtime (ticket, santri_id, created_epoch, "
                  "expires_epoch, used) VALUES (?, ?, ?, ?, 0)",
                  (ticket, santri_id, now, now + TIKET_TTL_DETIK))
        c.commit()
    return ticket


def _cek_tiket_realtime(ticket):
    """Validasi tiket realtime + tandai terpakai (sekali pakai).
    Kembalikan (santri_id, None) bila valid, atau (None, pesan_error)
    bila tidak valid / sudah dipakai / kedaluwarsa."""
    if not isinstance(ticket, str) or not ticket:
        return None, "Tiket realtime tidak valid"
    with _db_lock:
        c = db()
        try:
            c.execute("BEGIN IMMEDIATE")
            row = c.execute("SELECT * FROM tiket_realtime WHERE ticket=?",
                            (ticket,)).fetchone()
            if row is None:
                c.rollback()
                return None, "Tiket realtime tidak valid"
            if row["used"]:
                c.rollback()
                return None, "Tiket realtime sudah dipakai"
            if int(time.time()) > row["expires_epoch"]:
                c.rollback()
                return None, "Tiket realtime sudah kedaluwarsa"
            c.execute("UPDATE tiket_realtime SET used=1 WHERE ticket=?", (ticket,))
            c.commit()
        except sqlite3.Error:
            c.rollback()
            return None, "Tiket realtime tidak valid"
    return row["santri_id"], None


# ---------------------------------------------------------------- HTTP
class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    _hits = {}  # ip -> [timestamp, ...]

    # -- util ------------------------------------------------------
    def log_message(self, fmt, *args):
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {self.address_string()} {fmt % args}",
              flush=True)

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-PV-Token")

    def _send(self, status: int, obj: dict):
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self._cors()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _err(self, status: int, msg: str):
        self._send(status, {"ok": False, "error": msg})

    def _rate_ok(self) -> bool:
        ip = self.client_address[0]
        t = time.time()
        hits = [x for x in self._hits.get(ip, []) if t - x < RATE_WINDOW]
        hits.append(t)
        self._hits[ip] = hits
        return len(hits) <= RATE_LIMIT

    def _read_raw_body(self):
        """Baca body request sampai habis (wajib: kalau body tidak dibaca,
        sisanya akan dibaca sebagai request berikutnya di koneksi keep-alive
        yang dipakai ulang reverse proxy — merusak request selanjutnya)."""
        try:
            n = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            return None, "Content-Length tidak valid"
        if n < 0:
            return None, "Content-Length tidak valid"
        if n > MAX_BODY:
            return None, "Body terlalu besar"
        return self.rfile.read(n) if n else b"", None

    def _read_json(self):
        raw = getattr(self, "_body", b"")
        if not raw:
            return {}, None
        try:
            data = json.loads(raw.decode("utf-8"))
        except (ValueError, UnicodeDecodeError):
            return None, "Body harus JSON yang valid"
        if not isinstance(data, dict):
            return None, "Body harus objek JSON"
        return data, None

    def _need_token(self) -> bool:
        if not TOKEN:
            return True  # tanpa token terpasang, tolak tulis (fail closed)
        return self.headers.get("X-PV-Token") == TOKEN

    # -- verb ------------------------------------------------------
    def do_OPTIONS(self):
        if not self._rate_ok():
            self._send(429, {"ok": False, "error": "Terlalu banyak permintaan"})
            return
        self.send_response(204)
        self._cors()
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self):
        if not self._rate_ok():
            self._send(429, {"ok": False, "error": "Terlalu banyak permintaan"})
            return
        u = urlparse(self.path)
        if u.path == "/health":
            self._send(200, {"ok": True, "service": "pesantren-verse-api",
                             "version": VERSION, "time": now_iso()})
        elif u.path == "/":
            self._send(200, {"ok": True, "service": "pesantren-verse-api",
                             "version": VERSION, "endpoints": [
                                 "POST /api/santri/register (publik)",
                                 "POST /api/santri/verify",
                                 "POST /api/santri/login (token sesi)",
                                 "POST /api/santri/set_password (token sesi)",
                                 "POST /api/santri/realtime_ticket (token sesi)",
                                 "POST /api/santri/realtime_ticket/validate (token)",
                                 "POST /api/santri/points (token)",
                                 "GET  /api/ranking?limit=N",
                                 "POST /api/lamaran/kirim (publik)",
                                 "GET  /api/lamaran/saya?santri_id=PV-XXXX (publik)",
                                 "GET  /api/lamaran/daftar?status=... (token)",
                                 "POST /api/lamaran/rekomendasi (token)",
                                 "POST /api/lamaran/keputusan (token)",
                                 "GET  /api/kitab (publik)",
                                 "GET  /api/kitab/<id>?bab=N (publik)",
                                 "GET  /health"]})
        elif u.path == "/api/ranking":
            self._ranking(parse_qs(u.query))
        elif u.path == "/api/lamaran/saya":
            self._lamaran_saya(parse_qs(u.query))
        elif u.path == "/api/lamaran/daftar":
            self._lamaran_daftar(parse_qs(u.query))
        elif u.path == "/api/kitab":
            self._kitab_daftar()
        elif u.path.startswith("/api/kitab/"):
            self._kitab_baca(u.path[len("/api/kitab/"):], parse_qs(u.query))
        else:
            self._err(404, "Endpoint tidak dikenal")

    def do_POST(self):
        if not self._rate_ok():
            self._send(429, {"ok": False, "error": "Terlalu banyak permintaan"})
            return
        body, err = self._read_raw_body()
        if err:
            self._err(400, err)
            return
        self._body = body
        u = urlparse(self.path)
        if u.path == "/api/santri/register":
            self._register()
        elif u.path == "/api/santri/verify":
            self._verify()
        elif u.path == "/api/santri/login":
            self._login()
        elif u.path == "/api/santri/set_password":
            self._set_password()
        elif u.path == "/api/santri/realtime_ticket":
            self._realtime_ticket()
        elif u.path == "/api/santri/realtime_ticket/validate":
            self._realtime_ticket_validate()
        elif u.path == "/api/santri/points":
            self._points()
        elif u.path == "/api/lamaran/kirim":
            self._lamaran_kirim()
        elif u.path == "/api/lamaran/rekomendasi":
            self._lamaran_rekomendasi()
        elif u.path == "/api/lamaran/keputusan":
            self._lamaran_keputusan()
        else:
            self._err(404, "Endpoint tidak dikenal")

    # -- endpoint --------------------------------------------------
    def _ranking(self, qs):
        try:
            limit = int(qs.get("limit", ["10"])[0])
        except ValueError:
            limit = 10
        limit = max(1, min(50, limit))
        with _db_lock:
            c = db()
            rows = c.execute(
                "SELECT id, nama, jalur, total_poin, created_at FROM santri "
                "ORDER BY total_poin DESC, created_at ASC LIMIT ?", (limit,)).fetchall()
            total = c.execute("SELECT COUNT(*) AS n FROM santri").fetchone()["n"]
        ranking = []
        for i, r in enumerate(rows, 1):
            ranking.append({"rank": i, "id": r["id"], "nama": r["nama"],
                            "jalur": r["jalur"], "total_poin": r["total_poin"],
                            "tier": tier_for_points(r["total_poin"])})
        self._send(200, {"ok": True, "total_santri": total, "ranking": ranking})

    def _register(self):
        # PUBLIK (v1.3.0): pendaftaran terbuka, tanpa token. Rate limit
        # 120/menit/IP (di do_POST) tetap berlaku.
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        nama = (data.get("nama") or "").strip()
        # Sistem tunggal (keputusan 15 Nov 2026): tidak ada lagi pilihan
        # jalur — field "jalur" bila dikirim diabaikan, bukan error.
        # Login pakai ig_username (keputusan 16 Nov 2026): wajib + unik.
        ig_raw = data.get("ig_username")
        ig = norm_ig_username(ig_raw) if isinstance(ig_raw, str) else ""
        pw = data.get("password") or None
        kota = (data.get("kota") or "").strip() if isinstance(data.get("kota"), str) else ""
        email = (data.get("email") or "").strip() if isinstance(data.get("email"), str) else ""
        jk = (data.get("jenis_kelamin") or "").strip().lower() \
            if isinstance(data.get("jenis_kelamin"), str) else ""
        if not nama or len(nama) > 30:
            self._err(400, "Nama wajib diisi, maks 30 huruf")
            return
        if not ig or not IG_RE.match(ig):
            self._err(400, "ig_username wajib diisi (huruf/angka/titik/garis bawah, maks 64)")
            return
        if pw is not None and (not isinstance(pw, str) or not (6 <= len(pw) <= 64)):
            self._err(400, "Password minimal 6 karakter, maks 64")
            return
        if len(kota) > 64:
            self._err(400, "Kota maks 64 huruf")
            return
        if email and (len(email) > 128 or "@" not in email):
            self._err(400, "Email tidak valid")
            return
        if jk not in ("putra", "putri"):
            self._err(400, "jenis_kelamin wajib diisi: \"putra\" atau \"putri\"")
            return
        with _db_lock:
            c = db()
            try:
                c.execute("BEGIN IMMEDIATE")
                dup = c.execute("SELECT id FROM santri WHERE ig_username=?",
                                (ig,)).fetchone()
                if dup:
                    c.rollback()
                    self._err(409, "ig_username sudah terdaftar sebagai santri")
                    return
                r = c.execute("SELECT MAX(CAST(SUBSTR(id, 4) AS INTEGER)) AS m "
                              "FROM santri").fetchone()
                nxt = (r["m"] or 0) + 1
                new_id = f"PV-{nxt:04d}"
                t = now_iso()
                c.execute("INSERT INTO santri (id, nama, total_poin, password_hash, "
                          "ig_username, jenis_kelamin, kota, email, created_at, updated_at) "
                          "VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?, ?)",
                          (new_id, nama,
                           hash_password(pw) if pw else None,
                           ig, jk, kota or None, email or None, t, t))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        # Password TIDAK PERNAH dikembalikan (tidak ada yang perlu di-DM-kan).
        self._send(201, {"ok": True, "created": True, "id": new_id, "nama": nama,
                         "ig_username": ig, "jenis_kelamin": jk, "kota": kota or None,
                         "email": email or None,
                         "total_poin": 0, "tier": "Santri Baru"})

    def _verify(self):
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid = norm_id(data.get("id"))
        if not ID_RE.match(sid):
            self._err(400, "ID harus berformat PV-XXXX")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            if row is None:
                self._send(200, {"ok": True, "found": False, "id": sid})
                return
            n_misi = misi_selesai(c, sid)
        out = santri_view(row)
        out.update({"ok": True, "found": True, "misi_selesai": n_misi})
        self._send(200, out)

    def _login(self):
        """Login pakai ig_username. Bila santri belum punya password,
        username saja cukup; bila sudah punya, password wajib cocok.
        Login berhasil mengembalikan token sesi (field "session",
        berlaku 1 jam, satu sesi per santri) untuk set_password."""
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        ig = norm_ig_username(data.get("ig_username"))
        if not ig or not IG_RE.match(ig):
            self._err(400, "ig_username wajib diisi")
            return
        pw = data.get("password")
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM santri WHERE ig_username=?",
                            (ig,)).fetchone()
            if row is None:
                self._send(200, {"ok": True, "found": False, "ig_username": ig})
                return
            n_misi = misi_selesai(c, row["id"])
        if row["password_hash"]:
            if not isinstance(pw, str) or not cek_password(pw, row["password_hash"]):
                self._err(401, "Password salah")
                return
        # Login berhasil -> terbitkan token sesi (1 jam, satu sesi per santri).
        token_sesi = _buat_sesi(row["id"])
        out = santri_view(row)
        out.update({"ok": True, "found": True, "login": True,
                    "ig_username": row["ig_username"], "misi_selesai": n_misi,
                    "session": token_sesi, "session_expires_in": SESI_TTL_DETIK})
        self._send(200, out)

    def _set_password(self):
        """Isi/ubah password sendiri (token sesi dari login, BUKAN token
        bersama X-PV-Token). Token sesi hanya berlaku untuk santri pemiliknya
        dan hangus setelah dipakai (sekali pakai) atau kedaluwarsa (1 jam).
        Body: {"session": "<token>", "password": "<baru>"}; field "id"
        opsional — bila diisi harus sama dengan pemilik token."""
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid_sesi, err_sesi = _cek_sesi(data.get("session"))
        if err_sesi:
            self._err(401, err_sesi)
            return
        sid = norm_id(data.get("id")) if data.get("id") else sid_sesi
        if sid != sid_sesi:
            self._err(403, "Token sesi bukan milik santri ini")
            return
        pw = data.get("password")
        if not isinstance(pw, str) or not (6 <= len(pw) <= 64):
            self._err(400, "Password minimal 6 karakter, maks 64")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT id FROM santri WHERE id=?", (sid,)).fetchone()
            if row is None:
                self._err(404, "ID Santri tidak ditemukan")
                return
            try:
                c.execute("BEGIN IMMEDIATE")
                # Cek ulang di dalam transaksi (anti pakai-ganda bersamaan).
                srow = c.execute("SELECT used, expires_epoch FROM sesi_login "
                                 "WHERE token=?", (data.get("session"),)).fetchone()
                if srow is None or srow["used"] or int(time.time()) > srow["expires_epoch"]:
                    c.rollback()
                    self._err(401, "Token sesi sudah dipakai atau kedaluwarsa")
                    return
                c.execute("UPDATE santri SET password_hash=?, updated_at=? WHERE id=?",
                          (hash_password(pw), now_iso(), sid))
                # Token sesi hangus setelah dipakai (sekali pakai).
                c.execute("UPDATE sesi_login SET used=1 WHERE token=?",
                          (data.get("session"),))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "id": sid, "password_set": True})

    def _realtime_ticket(self):
        """Terbitkan tiket realtime (5 menit, sekali pakai) untuk handshake
        WebSocket server realtime. Body: {"session": "<token sesi login>"}.
        Token sesi TIDAK hangus — tetap berlaku untuk set_password dan
        untuk minta tiket lagi (reconnect)."""
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid_sesi, err_sesi = _cek_sesi(data.get("session"))
        if err_sesi:
            self._err(401, err_sesi)
            return
        ticket = _buat_tiket_realtime(sid_sesi)
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM santri WHERE id=?", (sid_sesi,)).fetchone()
        if row is None:
            self._err(404, "ID Santri tidak ditemukan")
            return
        self._send(200, {"ok": True, "ticket": ticket, "expires_in": TIKET_TTL_DETIK,
                         "id": row["id"], "nama": row["nama"],
                         "jenis_kelamin": row["jenis_kelamin"]})

    def _realtime_ticket_validate(self):
        """Validasi tiket realtime — HANYA untuk server realtime tepercaya
        di VPS yang sama (wajib X-PV-Token, pola yang sama seperti /points).
        Body: {"ticket": "<tiket>"}. Tiket yang valid langsung ditandai
        terpakai (sekali pakai); respons membawa identitas dari DB supaya
        nama yang tampil ke pemain lain selalu dari DB, bukan dari klien."""
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid, err_tiket = _cek_tiket_realtime(data.get("ticket"))
        if err_tiket:
            self._err(401, err_tiket)
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
        if row is None:
            self._err(404, "ID Santri tidak ditemukan")
            return
        self._send(200, {"ok": True, "id": row["id"], "nama": row["nama"],
                         "jenis_kelamin": row["jenis_kelamin"]})

    def _points(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid = norm_id(data.get("id"))
        misi = (data.get("misi") or "").strip()
        poin = data.get("poin")
        event_id = data.get("event_id")
        if not ID_RE.match(sid):
            self._err(400, "ID harus berformat PV-XXXX")
            return
        if not misi or len(misi) > 64:
            self._err(400, "Nama misi wajib diisi, maks 64 huruf")
            return
        if not isinstance(poin, int) or isinstance(poin, bool) or not (1 <= poin <= 100):
            self._err(400, "Poin harus bilangan bulat 1-100")
            return
        if event_id is not None and (not isinstance(event_id, str) or not (1 <= len(event_id) <= 64)):
            self._err(400, "event_id harus teks 1-64 karakter")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            if row is None:
                self._err(404, "ID Santri tidak ditemukan")
                return
            if event_id:
                dup = c.execute("SELECT id FROM points_log WHERE event_id=?",
                                (event_id,)).fetchone()
                if dup:
                    self._send(200, {"ok": True, "duplicate": True, "id": sid,
                                     "total_poin": row["total_poin"],
                                     "tier": tier_for_points(row["total_poin"]),
                                     "misi_selesai": misi_selesai(c, sid)})
                    return
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("INSERT INTO points_log (santri_id, misi, poin, event_id, created_at) "
                          "VALUES (?, ?, ?, ?, ?)", (sid, misi, poin, event_id, now_iso()))
                c.execute("UPDATE santri SET total_poin = total_poin + ?, updated_at=? WHERE id=?",
                          (poin, now_iso(), sid))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
            row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            n_misi = misi_selesai(c, sid)
        self._send(200, {"ok": True, "duplicate": False, "id": sid,
                         "total_poin": row["total_poin"],
                         "tier": tier_for_points(row["total_poin"]),
                         "misi_selesai": n_misi})


    # -- lamaran pengurus (v1.4.0) --------------------------------
    def _lamaran_view(self, row) -> dict:
        return {
            "lamaran_id": row["id"],
            "santri_id": row["santri_id"],
            "nama": row["nama"],
            "ig_username": row["ig_username"],
            "posisi": row["posisi"],
            "posisi_cadangan": row["posisi_cadangan"],
            "alasan": row["alasan"],
            "pengalaman": row["pengalaman"],
            "status": row["status"],
            "rekomendasi_musyrif": row["rekomendasi_musyrif"],
            "catatan_musyrif": row["catatan_musyrif"],
            "keputusan": row["keputusan"],
            "alasan_tolak": row["alasan_tolak"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
            "diputuskan_at": row["diputuskan_at"],
        }

    def _lamaran_kirim(self):
        # PUBLIK (v1.4.0): lamaran adalah perbuatan santri sendiri,
        # seperti register. Rate limit 120/menit/IP tetap berlaku.
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        sid = norm_id(data.get("id")) if data.get("id") else ""
        ig = norm_ig_username(data.get("ig_username")) if data.get("ig_username") else ""
        posisi = (data.get("posisi") or "").strip()
        posisi_cad = (data.get("posisi_cadangan") or "").strip() if isinstance(data.get("posisi_cadangan"), str) else ""
        alasan = (data.get("alasan") or "").strip() if isinstance(data.get("alasan"), str) else ""
        pengalaman = (data.get("pengalaman") or "").strip() if isinstance(data.get("pengalaman"), str) else ""
        if posisi not in POSISI_LAMARAN:
            self._err(400, "Posisi tidak valid (Keamanan, Ubudiyah, Kebersihan, Pendidikan, Humas & Media)")
            return
        if posisi_cad and (posisi_cad not in POSISI_LAMARAN or posisi_cad == posisi):
            self._err(400, "Posisi cadangan harus posisi lain yang valid")
            return
        if not alasan or len(alasan) > 200:
            self._err(400, "Alasan wajib diisi, maks 200 huruf")
            return
        if len(pengalaman) > 200:
            self._err(400, "Pengalaman maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = None
            if sid:
                if not ID_RE.match(sid):
                    self._err(400, "ID harus berformat PV-XXXX")
                    return
                row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            elif ig:
                row = c.execute("SELECT * FROM santri WHERE ig_username=?", (ig,)).fetchone()
            else:
                self._err(400, "ID Santri atau ig_username wajib diisi")
                return
            if row is None:
                self._err(404, "Santri tidak ditemukan")
                return
            sid = row["id"]
            # Syarat M1 (asumsi v1.4.0): misi berurutan, jadi
            # misi_selesai >= 1 berarti M1 sudah selesai.
            if misi_selesai(c, sid) < 1:
                self._err(400, "Syarat belum terpenuhi: selesaikan Misi M1 dulu")
                return
            aktif = c.execute(
                "SELECT id FROM lamaran WHERE santri_id=? AND status IN "
                "('menunggu_musyrif', 'menunggu_pengasuh')",
                (sid,)).fetchone()
            if aktif:
                self._err(409, "Masih ada lamaran aktif (lamaran_id %d)" % aktif["id"])
                return
            # Jeda 1 minggu setelah penolakan terakhir.
            tolak = c.execute(
                "SELECT diputuskan_at FROM lamaran WHERE santri_id=? AND status='ditolak' "
                "AND diputuskan_at IS NOT NULL ORDER BY diputuskan_at DESC LIMIT 1",
                (sid,)).fetchone()
            if tolak:
                try:
                    t_tolak = datetime.strptime(
                        tolak["diputuskan_at"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
                    bisa = t_tolak + timedelta(days=JEDA_LAMAR_HARI)
                    if datetime.now(timezone.utc) < bisa:
                        self._err(409, "Jeda 1 minggu setelah penolakan — bisa melamar lagi pada %s"
                                  % bisa.strftime("%Y-%m-%d"))
                        return
                except ValueError:
                    pass
            t = now_iso()
            try:
                c.execute("BEGIN IMMEDIATE")
                cur = c.execute(
                    "INSERT INTO lamaran (santri_id, posisi, posisi_cadangan, alasan, "
                    "pengalaman, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, "
                    "'menunggu_musyrif', ?, ?)",
                    (sid, posisi, posisi_cad or None, alasan, pengalaman or None, t, t))
                lamaran_id = cur.lastrowid
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(201, {"ok": True, "created": True, "lamaran_id": lamaran_id,
                         "santri_id": sid, "posisi": posisi,
                         "status": "menunggu_musyrif", "created_at": t})

    def _lamaran_saya(self, qs):
        sid = norm_id(qs.get("santri_id", [""])[0]) if qs.get("santri_id") else ""
        ig = norm_ig_username(qs.get("ig_username", [""])[0]) if qs.get("ig_username") else ""
        with _db_lock:
            c = db()
            row = None
            if sid:
                if not ID_RE.match(sid):
                    self._err(400, "ID harus berformat PV-XXXX")
                    return
                row = c.execute("SELECT * FROM santri WHERE id=?", (sid,)).fetchone()
            elif ig:
                row = c.execute("SELECT * FROM santri WHERE ig_username=?", (ig,)).fetchone()
            else:
                self._err(400, "santri_id atau ig_username wajib diisi")
                return
            if row is None:
                self._err(404, "Santri tidak ditemukan")
                return
            rows = c.execute(
                "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                "ON s.id = l.santri_id WHERE l.santri_id=? "
                "ORDER BY l.created_at DESC, l.id DESC", (row["id"],)).fetchall()
        self._send(200, {"ok": True, "santri_id": row["id"], "nama": row["nama"],
                         "total": len(rows),
                         "lamaran": [self._lamaran_view(r) for r in rows]})

    def _lamaran_daftar(self, qs):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        status = (qs.get("status", [""])[0] or "").strip()
        if status and status not in STATUS_LAMARAN:
            self._err(400, "Status tidak valid")
            return
        with _db_lock:
            c = db()
            if status:
                rows = c.execute(
                    "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                    "ON s.id = l.santri_id WHERE l.status=? "
                    "ORDER BY l.created_at DESC, l.id DESC", (status,)).fetchall()
            else:
                rows = c.execute(
                    "SELECT l.*, s.nama, s.ig_username FROM lamaran l JOIN santri s "
                    "ON s.id = l.santri_id ORDER BY l.created_at DESC, l.id DESC").fetchall()
        self._send(200, {"ok": True, "total": len(rows),
                         "lamaran": [self._lamaran_view(r) for r in rows]})

    def _lamaran_rekomendasi(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        lamaran_id = data.get("lamaran_id")
        rekom = (data.get("rekomendasi") or "").strip()
        catatan = (data.get("catatan") or "").strip() if isinstance(data.get("catatan"), str) else ""
        if not isinstance(lamaran_id, int) or isinstance(lamaran_id, bool):
            self._err(400, "lamaran_id wajib diisi (angka)")
            return
        if rekom not in ("setuju", "tidak"):
            self._err(400, 'rekomendasi harus "setuju" atau "tidak"')
            return
        if len(catatan) > 200:
            self._err(400, "Catatan maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM lamaran WHERE id=?", (lamaran_id,)).fetchone()
            if row is None:
                self._err(404, "Lamaran tidak ditemukan")
                return
            if row["status"] != "menunggu_musyrif":
                self._err(409, "Lamaran sudah melewati tahap musyrif (status: %s)" % row["status"])
                return
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("UPDATE lamaran SET rekomendasi_musyrif=?, catatan_musyrif=?, "
                          "status='menunggu_pengasuh', updated_at=? WHERE id=?",
                          (rekom, catatan or None, now_iso(), lamaran_id))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "rekomendasi_musyrif": rekom,
                         "status": "menunggu_pengasuh"})

    def _lamaran_keputusan(self):
        if not self._need_token():
            self._err(401, "Token tidak valid")
            return
        data, err = self._read_json()
        if err:
            self._err(400, err)
            return
        lamaran_id = data.get("lamaran_id")
        keput = (data.get("keputusan") or "").strip()
        alasan_tolak = (data.get("alasan_tolak") or "").strip() if isinstance(data.get("alasan_tolak"), str) else ""
        if not isinstance(lamaran_id, int) or isinstance(lamaran_id, bool):
            self._err(400, "lamaran_id wajib diisi (angka)")
            return
        if keput not in ("diterima", "ditolak"):
            self._err(400, 'keputusan harus "diterima" atau "ditolak"')
            return
        if keput == "ditolak" and not alasan_tolak:
            self._err(400, "alasan_tolak wajib diisi bila ditolak")
            return
        if len(alasan_tolak) > 200:
            self._err(400, "alasan_tolak maks 200 huruf")
            return
        with _db_lock:
            c = db()
            row = c.execute("SELECT * FROM lamaran WHERE id=?", (lamaran_id,)).fetchone()
            if row is None:
                self._err(404, "Lamaran tidak ditemukan")
                return
            if row["status"] != "menunggu_pengasuh":
                self._err(409, "Lamaran belum sampai tahap Pengasuh (status: %s)" % row["status"])
                return
            t = now_iso()
            try:
                c.execute("BEGIN IMMEDIATE")
                c.execute("UPDATE lamaran SET keputusan=?, alasan_tolak=?, status=?, "
                          "diputuskan_at=?, updated_at=? WHERE id=?",
                          (keput, alasan_tolak or None, keput, t, t, lamaran_id))
                c.commit()
            except sqlite3.Error as e:
                c.rollback()
                self._err(500, f"Gagal menyimpan: {e}")
                return
        self._send(200, {"ok": True, "lamaran_id": lamaran_id,
                         "keputusan": keput, "status": keput,
                         "diputuskan_at": t})

    # -- pustaka kitab (v1.5.0) ----------------------------------
    # PUBLIK (tanpa token): membaca adalah aktivitas santri, game/app
    # memanggil langsung. Tiap respons mencantumkan atribusi OpenITI.
    # dicek_ustadz=false berarti teks BELUM dicek ustadz — pembaca game
    # hanya menampilkan kitab yang dicek_ustadz=true.
    def _kitab_daftar(self):
        kitab = _muat_kitab()
        daftar = []
        for kid in sorted(kitab):
            d = kitab[kid]
            daftar.append({
                "id": d.get("id"), "judul": d.get("judul"),
                "judul_latin": d.get("judul_latin"),
                "pengarang": d.get("pengarang"),
                "pengarang_latin": d.get("pengarang_latin"),
                "jumlah_bab": d.get("jumlah_bab", len(d.get("bab", []))),
                "ukuran_karakter": d.get("ukuran_karakter"),
                "dicek_ustadz": bool(d.get("dicek_ustadz", False)),
                "atribusi": d.get("atribusi", ATRIBUSI_KITAB),
            })
        self._send(200, {"ok": True, "atribusi": ATRIBUSI_KITAB,
                         "total": len(daftar), "kitab": daftar})

    def _kitab_baca(self, kid, qs):
        if not kid or not KITAB_ID_RE.match(kid):
            self._err(404, "Kitab tidak ditemukan")
            return
        d = _muat_kitab().get(kid)
        if d is None:
            self._err(404, "Kitab tidak ditemukan")
            return
        meta = {"ok": True, "id": d["id"], "judul": d["judul"],
                "judul_latin": d.get("judul_latin"),
                "pengarang": d.get("pengarang"),
                "dicek_ustadz": bool(d.get("dicek_ustadz", False)),
                "atribusi": d.get("atribusi", ATRIBUSI_KITAB)}
        bab_q = qs.get("bab", [""])[0]
        if bab_q:
            try:
                n = int(bab_q)
            except ValueError:
                self._err(400, "bab harus angka")
                return
            bab = next((b for b in d.get("bab", [])
                        if b.get("nomor") == n), None)
            if bab is None:
                self._err(404, "Bab tidak ditemukan")
                return
            meta["bab"] = bab
            self._send(200, meta)
            return
        meta.update({
            "pengarang_latin": d.get("pengarang_latin"),
            "sumber": d.get("sumber"), "sumber_url": d.get("sumber_url"),
            "edisi": d.get("edisi"), "lisensi": d.get("lisensi"),
            "jumlah_bab": d.get("jumlah_bab"),
            "ukuran_karakter": d.get("ukuran_karakter"),
            "bab": d.get("bab", [])})
        self._send(200, meta)


def main():
    db()  # buat tabel saat start
    srv = ThreadingHTTPServer((HOST, PORT), Handler)
    srv.daemon_threads = True
    print(f"pesantren-verse-api v{VERSION} jalan di {HOST}:{PORT} (db: {DB_PATH})",
          flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

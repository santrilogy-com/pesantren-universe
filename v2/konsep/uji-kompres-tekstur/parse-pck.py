#!/usr/bin/env python3
"""Parse Godot 4 PCK (Godot 4.7.2).
Header 112 B: magic GDPC, version, engine 4.7.2, u64 data_start=112,
u64 dir_offset. Directory: tag "gl_compatibility" + u32 file_count,
lalu entri: [u32 len][field string: bytes + null, dipad 0 ke kelipatan 4]
[u64 offset][u64 size][16 md5][u32 flags].
Parser jalan MUNDUR dari EOF dan memvalidasi tiap entri.
"""
import struct, sys

def parse(p):
    d = open(p, 'rb').read()
    n = len(d)
    entries = []
    end = n
    while end > 40:
        flags, = struct.unpack_from('<I', d, end - 4)
        size, = struct.unpack_from('<Q', d, end - 28)
        off, = struct.unpack_from('<Q', d, end - 36)
        pend = end - 36  # akhir field string
        # lewati null terminator + padding nol
        j = pend
        while j > 0 and d[j - 1] == 0:
            j -= 1
        # j = posisi setelah karakter terakhir path
        k = j
        while k > 0 and 32 <= d[k - 1] <= 126:
            k -= 1
        path = d[k:j].decode('ascii', 'replace')
        if k < 4:
            break
        plen, = struct.unpack_from('<I', d, k - 4)
        field_len = pend - k
        if field_len != ((plen + 3) // 4) * 4:
            break
        if not path or len(path) > 300:
            break
        if off + size > n or size > n or flags > 16:
            break
        entries.append((path, off, size))
        end = k - 4
    entries.reverse()
    return n, entries

if __name__ == '__main__':
    p = sys.argv[1]
    total, entries = parse(p)
    print('pck: %d B, entri: %d' % (total, len(entries)))
    ctex = [(s, pa) for pa, o, s in entries if pa.endswith('.ctex')]
    ktx2 = [(s, pa) for pa, o, s in entries if pa.endswith('.ktx2')]
    print('ctex: %d file, %d B' % (len(ctex), sum(s for s, _ in ctex)))
    print('ktx2: %d file, %d B' % (len(ktx2), sum(s for s, _ in ktx2)))
    big = sorted(((s, pa) for pa, o, s in entries), reverse=True)
    print('10 file terbesar:')
    for s, pa in big[:10]:
        print('  %10d  %s' % (s, pa))
    print('tekstur di pck:')
    for s, pa in sorted(ktx2 + ctex, key=lambda x: -x[0]):
        print('  %10d  %s' % (s, pa))

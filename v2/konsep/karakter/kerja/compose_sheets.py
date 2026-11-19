from PIL import Image, ImageDraw, ImageFont
import numpy as np, glob, textwrap, os

BASE = '/home/hatch/workspace/pesantren-verse/v2/konsep/karakter'
KERJA = BASE + '/kerja'
CREAM = (242, 234, 214)      # #F2EAD6
EMERALD = (6, 95, 70)        # #065F46
GOLD = (201, 162, 39)        # #C9A227
TEAK = (123, 75, 42)         # #7B4B2A
INK = (43, 43, 43)

def find_font(bold=False):
    pats = ['/usr/share/fonts/**/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/**/DejaVuSans.ttf',
            '/usr/share/fonts/**/LiberationSans-Bold.ttf' if bold else '/usr/share/fonts/**/LiberationSans-Regular.ttf']
    for p in pats:
        hits = glob.glob(p, recursive=True)
        if hits: return hits[0]
    return None

FB = find_font(True); FR = find_font(False)
print('fonts:', FB, FR)
def font(sz, bold=False):
    p = FB if bold else FR
    return ImageFont.truetype(p, sz) if p else ImageFont.load_default()

def measure(path, prefix):
    im = Image.open(path).convert('RGB')
    a = np.asarray(im).astype(int)
    bg = np.array([255,244,230])
    mask = (np.abs(a - bg).sum(axis=2) > 60)
    W,H = im.size
    out = {}
    for name, x0, x1 in [('depan',0,W//3),('samping',W//3,2*W//3),('tiga-perempat',2*W//3,W)]:
        sub = mask[:, x0:x1]
        ys, xs = np.where(sub)
        top, bot = ys.min(), ys.max()
        widths = sub.sum(axis=1)
        span = bot-top
        lo, hi = top+int(span*0.25), top+int(span*0.55)
        neck_y = lo + int(np.argmin(widths[lo:hi]))
        head_h = neck_y - top; total_h = bot - top
        out[name] = total_h/head_h
        cx0 = max(0, x0+int(np.where(sub.any(axis=0))[0].min())-15)
        cx1 = min(W, x0+int(np.where(sub.any(axis=0))[0].max())+15)
        crop = im.crop((cx0, max(0,top-10), cx1, min(H,bot+10)))
        crop.save(f'{KERJA}/{prefix}_{name}.png')
    print(prefix, {k: round(v,2) for k,v in out.items()})
    return out

def sample(im, fx, fy):
    w,h = im.size
    px = im.getpixel((int(w*fx), int(h*fy)))
    return '#%02X%02X%02X' % px

def wrap(draw, text, fnt, maxw):
    words = text.split(); lines=[]; cur=''
    for w in words:
        t = (cur+' '+w).strip()
        if draw.textlength(t, font=fnt) <= maxw: cur = t
        else:
            lines.append(cur); cur = w
    if cur: lines.append(cur)
    return lines

def sheet(prefix, title, subtitle, heads, palette, materials, note, out_name, prop_note=None):
    # palette: list of (label, hex)
    crops = [Image.open(f'{KERJA}/{prefix}_{n}.png') for n in ['depan','samping','tiga-perempat']]
    # art background = corner pixel of first crop
    bgc = crops[0].getpixel((2,2))
    W, H = 1080, 1840
    im = Image.new('RGB', (W,H), bgc)
    d = ImageDraw.Draw(im)
    # header band
    d.rectangle([0,0,W,150], fill=EMERALD)
    d.text((48,28), title, font=font(58,True), fill=(255,244,230))
    d.text((48,96), subtitle, font=font(30), fill=(201,162,39))
    d.rectangle([0,150,W,158], fill=GOLD)
    # views row
    y0 = 200; vh = 740
    colw = (W-96)//3
    labels = ['DEPAN','SAMPING','TIGA-PEREMPAT']
    for i, c in enumerate(crops):
        sc = vh / c.size[1]
        nw = int(c.size[0]*sc)
        c2 = c.resize((nw, vh), Image.LANCZOS)
        x = 48 + i*colw + (colw-nw)//2
        im.paste(c2, (x, y0))
        lw = d.textlength(labels[i], font=font(30,True))
        d.text((48+i*colw+(colw-lw)//2, y0+vh+12), labels[i], font=font(30,True), fill=EMERALD)
    # divider
    d.line([48,1000,W-48,1000], fill=GOLD, width=3)
    # proporsi block
    y = 1030
    d.text((48,y), 'PROPORS', font=font(30,True), fill=EMERALD)
    # mini head-stack diagram (unit mengecil kalau kepala > 4 supaya tidak menabrak PALET)
    unit = 34 if heads <= 4 else max(20, int(130 / heads)); bx, by = 48, y+52
    total_units = heads
    bar_h = int(unit*total_units)
    d.rectangle([bx,by,bx+34,by+bar_h], outline=EMERALD, width=3)
    d.rectangle([bx,by,bx+34,by+unit], fill=EMERALD)
    for k in range(1, int(total_units)+1):
        d.line([bx,by+unit*k,bx+34,by+unit*k], fill=EMERALD, width=2)
        d.text((bx+46, by+unit*k-14), str(k), font=font(24), fill=INK)
    d.text((bx+46, by+bar_h-14), f'{heads:.1f}', font=font(24,True), fill=EMERALD)
    tx = 170
    ptxt = prop_note or f'Proporsi {heads:.1f} kepala — referensi 4,4 kepala. Kepala dibuat lebih besar (lebih chibi, lebih terbaca di HP).'
    lines = wrap(d, ptxt, font(28), W-48-tx)
    yy = y+44
    for ln in lines:
        d.text((tx,yy), ln, font=font(28), fill=INK); yy += 38
    # palette (posisi mengikuti tinggi diagram proporsi)
    y = max(1230, by + bar_h + 28)
    d.text((48,y), 'PALET', font=font(30,True), fill=EMERALD)
    y += 48
    sw = 150; gap = 18
    for i,(lab,hexv) in enumerate(palette):
        x = 48 + i*(sw+gap)
        rgb = tuple(int(hexv[j:j+2],16) for j in (1,3,5))
        d.rounded_rectangle([x,y,x+sw,y+64], radius=10, fill=rgb, outline=GOLD, width=2)
        d.text((x,y+72), lab, font=font(20,True), fill=INK)
        d.text((x,y+98), hexv, font=font(20), fill=INK)
    # materials (posisi mengikuti palet; font sedikit lebih kecil supaya 7 butir muat)
    y = y + 64 + 122 + 8
    d.text((48,y), 'MATERIAL / CATATAN', font=font(30,True), fill=EMERALD)
    y += 46
    for m in materials:
        d.ellipse([52,y+9,64,y+21], fill=GOLD)
        lines = wrap(d, m, font(25), W-48-84)
        for ln in lines:
            d.text((84,y), ln, font=font(25), fill=INK); y += 32
        y += 5
    d.text((48,H-52), 'KONSEP v2 — gambar saja, belum 3D. Dinilai Mas dulu sebelum dibangun.', font=font(24), fill=(120,110,95))
    im.save(f'{BASE}/{out_name}')
    print('saved', out_name, im.size)


# --- v2: 5 lembar (pengukuran kepala = puncak penutup kepala -> dagu/ujung jenggot) ---
sheet('putra', 'KONSEP KARAKTER v2', 'SANTRI PUTRA  ·  lembar 1 dari 5  ·  REVISI',
      3.0,
      [('Koko putih','#E8E8E8'),('Zamrud','#008062'),('Emas','#E2B955'),('Kulit','#FFC09F'),('Sandal coklat','#4A3226')],
      ['Peci putih berkubah, menempel di kepala.',
       'Rambut PENDEK RAPI ala santri — dahi terlihat, bukan poni lurus.',
       'Kacamata bundar besar hitam — mata titik kecil di dalamnya.',
       'Wajah datar lukis: senyum tipis tertutup, tanpa mulut merah.',
       'Koko putih (ganti polo kuning): kerah tegak (mandarin) + kancing depan.',
       'Sarung parang zamrud + emas — SATU lembar, tanpa belahan kaki.',
       'Sandal coklat gelap sederhana (ganti sepatu merah-putih).'],
      '', 'konsep-santri-putra.png',
      prop_note='Proporsi 3,0 kepala — diukur puncak peci ke dagu. Lembar lama 3,4 (metode leher); kepala di gambar baru ini sedikit lebih besar, tetap chibi dan terbaca di HP.')

sheet('putri', 'KONSEP KARAKTER v2', 'SANTRIWATI  ·  lembar 2 dari 5  ·  REVISI',
      2.5,
      [('Jilbab krem','#F5E4CC'),('Zamrud','#007A61'),('Emas','#E4B955'),('Kulit','#FFC09F'),('Sandal coklat','#4A3226')],
      ['Jilbab krem menutup rambut SEPENUHNYA — tanpa poni.',
       'Wajah sama dengan putra: kacamata besar, mata titik, senyum tipis.',
       'Abaya zamrud lengan panjang, hem emas motif parang.',
       'Sandal coklat gelap sederhana (ganti sepatu; kedua santri pakai sandal).',
       'Warna abaya & jilbab bisa diganti santriwati (Ganti Baju).'],
      '', 'konsep-santriwati.png',
      prop_note='Proporsi 2,5 kepala — diukur puncak jilbab ke dagu. Kepala+jilbab tampak LEBIH BESAR dari putra (3,0). Kalau mau seumuran, jilbab perlu dirampingkan sedikit.')

sheet('ustadz', 'KONSEP KARAKTER v2', 'USTADZ AQ SAL MURAD  ·  lembar 3 dari 5  ·  BARU',
      4.7,
      [('Koko krem','#F2EAD6'),('Surban krem','#F5F0E0'),('Sarung','#23282E'),('Kulit','#D59E78'),('Jenggot','#2B241D')],
      ['Kyai / pengasuh pesantren — Ust. Aqsal Murad (persona Mas).',
       'Surban krem melilit kepala; janggut beruban + kumis tipis.',
       'Koko krem kerah tegak, lengan panjang; sarung hitam.',
       'Wajah datar dewasa: mata titik, alis, senyum tipis. TANPA kacamata.',
       'Sandal gelap sederhana.',
       'Warna ikut v1 (OUTFIT_KYAI di mission_data.gd).'],
      '', 'konsep-ustadz.png',
      prop_note='Proporsi 4,7 kepala — dewasa, tinggi dan ramping, bukan chibi anak. Diukur puncak surban ke ujung jenggot. (Usulan awal 5,5–6; gambar ini 4,7 — masih satu keluarga gaya dengan santri.)')

sheet('ustadzah', 'KONSEP KARAKTER v2', 'USTADZAH MARIYAH  ·  lembar 4 dari 5  ·  BARU',
      5.1,
      [('Jilbab krem','#F2EAD6'),('Abaya zamrud','#065F46'),('Emas','#E4B955'),('Kulit','#FFC09F'),('Sandal coklat','#4A3226')],
      ['Pimpinan pesantren putri — Ustadzah Mariyah.',
       'Jilbab krem menutup rambut sepenuhnya, drape ke bahu.',
       'Abaya zamrud lengan panjang, hem emas motif parang.',
       'Wajah datar dewasa: mata titik, alis, senyum tipis. TANPA kacamata.',
       'Sandal gelap sederhana.',
       'Warna ikut v1 (OUTFIT_USTADZAH di mission_data.gd).'],
      '', 'konsep-ustadzah.png',
      prop_note='Proporsi 5,1 kepala — dewasa, tinggi dan ramping. Diukur puncak jilbab ke dagu. Paling mendekati usulan 5,5–6 di antara tiga dewasa.')

sheet('satpam', 'KONSEP KARAKTER v2', 'SATPAM  ·  lembar 5 dari 5  ·  BARU',
      3.8,
      [('Koko gelap','#2B3A4A'),('Songkok','#1A1A1A'),('Sarung','#2B2B2B'),('Kulit','#FFC09F'),('Emas lencana','#C9A227')],
      ['Penjaga gerbang (pos jaga) — diam di pos, tidak ikut sholat.',
       'Warna ikut v1 (OUTFIT_SATPAM): koko gelap, songkok, sarung hitam.',
       'Lencana emas di dada — terbaca sebagai petugas, bukan santri.',
       'Wajah datar dewasa: mata titik, alis, senyum tipis. TANPA kacamata.',
       'Sandal hitam sederhana (usulan — bisa diganti sepatu hitam).'],
      '', 'konsep-satpam.png',
      prop_note='Proporsi 3,8 kepala — dewasa, tegap dan lebih kekar dari Ustadz. Diukur puncak songkok ke dagu.')

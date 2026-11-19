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
    # mini head-stack diagram
    unit = 34; bx, by = 48, y+52
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
    # palette
    y = 1230
    d.text((48,y), 'PALET', font=font(30,True), fill=EMERALD)
    y += 48
    sw = 150; gap = 18
    for i,(lab,hexv) in enumerate(palette):
        x = 48 + i*(sw+gap)
        rgb = tuple(int(hexv[j:j+2],16) for j in (1,3,5))
        d.rounded_rectangle([x,y,x+sw,y+64], radius=10, fill=rgb, outline=GOLD, width=2)
        d.text((x,y+72), lab, font=font(22,True), fill=INK)
        d.text((x,y+98), hexv, font=font(22), fill=INK)
    # materials
    y = 1420
    d.text((48,y), 'MATERIAL / CATATAN', font=font(30,True), fill=EMERALD)
    y += 46
    for m in materials:
        d.ellipse([52,y+10,64,y+22], fill=GOLD)
        lines = wrap(d, m, font(27), W-48-84)
        for ln in lines:
            d.text((84,y), ln, font=font(27), fill=INK); y += 36
        y += 6
    d.text((48,H-52), 'KONSEP v2 — gambar saja, belum 3D. Dinilai Mas dulu sebelum dibangun.', font=font(24), fill=(120,110,95))
    im.save(f'{BASE}/{out_name}')
    print('saved', out_name, im.size)


# --- v2: 5 karakter (2 revisi + 3 baru) ---
RAW = {
 'putra':    'media-generation-konsep-v2-putra-ai-0-34e48424-0654-48d7-873f-25714ae904b5.png',
 'putri':    'media-generation-konsep-v2-putri-ai-0-3dbcc2c4-edfe-45c6-b602-84bb1013a887.png',
 'ustadz':   'media-generation-konsep-v2-ustadz-ai-0-61fc0ca6-b788-437a-9a5c-801d09c21423.png',
 'ustadzah': 'media-generation-konsep-v2-ustadzah-ai-0-7705f77b-a85b-4fbb-9e2d-e62842812c33.png',
 'satpam':   'media-generation-konsep-v2-satpam-ai-0-f1db8356-3a7e-4018-a4c2-de17ba0372e5.png',
}
heads = {}
for prefix, f in RAW.items():
    heads[prefix] = measure(KERJA + '/' + f, prefix)

def show(prefix, pts):
    im = Image.open(f'{KERJA}/{prefix}_depan.png').convert('RGB')
    print(prefix, 'depan:', {k: sample(im, fx, fy) for k, (fx, fy) in pts.items()})

show('putra',    {'koko': (.50,.50), 'sarung': (.50,.78), 'kulit': (.42,.28), 'sandal': (.30,.95), 'peci': (.50,.06)})
show('putri',    {'jilbab': (.20,.30), 'abaya': (.50,.65), 'kulit': (.42,.28), 'sandal': (.30,.95), 'hem': (.50,.88)})
show('ustadz',   {'koko': (.50,.45), 'sarung': (.50,.75), 'kulit': (.42,.20), 'sandal': (.30,.96), 'surban': (.50,.06), 'jenggot': (.50,.30)})
show('ustadzah', {'jilbab': (.20,.30), 'abaya': (.50,.60), 'kulit': (.42,.22), 'sandal': (.30,.96), 'hem': (.50,.88)})
show('satpam',   {'koko': (.50,.45), 'sarung': (.50,.75), 'kulit': (.42,.22), 'sandal': (.30,.96), 'songkok': (.50,.06), 'lencana': (.38,.42)})
print('HEADS:', {k: round(v['depan'], 2) for k, v in heads.items()})

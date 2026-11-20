// Server statis kecil DENGAN dukungan Range (untuk uji spike).
// python http.server TIDAK mendukung Range -> Chrome melaporkan
// video.seekable = [0,0] sehingga seek selalu dijepit ke 0.
// Server ini meniru perilaku hosting asli (Cloudflare Pages).
import http from 'http';
import fs from 'fs';
import path from 'path';

const ROOT = '/home/hatch/workspace/pesantren-verse/v2/spike-pemutar-video/web';
const PORT = 8932;
const MIME = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.wasm': 'application/wasm', '.pck': 'application/octet-stream',
  '.mp4': 'video/mp4', '.png': 'image/png', '.svg': 'image/svg+xml',
  '.css': 'text/css', '.json': 'application/json',
};

http.createServer((req, res) => {
  const urlPath = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  const file = path.join(ROOT, urlPath === '/' ? 'index.html' : urlPath);
  if (!file.startsWith(ROOT) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    res.writeHead(404); res.end('not found'); return;
  }
  const stat = fs.statSync(file);
  const type = MIME[path.extname(file)] || 'application/octet-stream';
  const range = req.headers.range;
  if (range) {
    const m = /bytes=(\d*)-(\d*)/.exec(range);
    const start = m[1] ? parseInt(m[1], 10) : 0;
    const end = m[2] ? parseInt(m[2], 10) : stat.size - 1;
    res.writeHead(206, {
      'Content-Type': type, 'Accept-Ranges': 'bytes',
      'Content-Range': `bytes ${start}-${end}/${stat.size}`,
      'Content-Length': end - start + 1,
    });
    fs.createReadStream(file, { start, end }).pipe(res);
  } else {
    res.writeHead(200, {
      'Content-Type': type, 'Accept-Ranges': 'bytes',
      'Content-Length': stat.size,
    });
    fs.createReadStream(file).pipe(res);
  }
}).listen(PORT, () => console.log('server Range di :' + PORT));

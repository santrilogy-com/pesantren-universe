#!/bin/bash
# Video contoh spike: 30 detik, 540x960 vertikal 9:16 (seperti episode),
# H.264 + AAC, timer detik dibakar ke gambar + latar berubah warna
# tiap detik (bukti visual frame benar-benar berjalan).
set -e
cd "$(dirname "$0")"
ffmpeg -y -v error \
  -f lavfi -i "color=c=0x065F46:s=540x960:d=30:r=30" \
  -f lavfi -i "sine=frequency=440:duration=30" \
  -vf "hue=h=t*36,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='SPIKE VIDEO':fontcolor=yellow:fontsize=34:x=(w-text_w)/2:y=300,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='%{pts\:hms}':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=380,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='DETIK %{eif\:t\:d} / 30':fontcolor=white:fontsize=36:x=(w-text_w)/2:y=480" \
  -c:v libx264 -pix_fmt yuv420p -r 30 -b:v 1200k -c:a aac -b:a 96k -shortest \
  episode-contoh.mp4
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height -of default=noprint_wrappers=1 episode-contoh.mp4
ls -la episode-contoh.mp4

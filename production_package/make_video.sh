#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./make_video.sh
# Optional:
#   FFMPEG_BIN=/absolute/path/to/ffmpeg ./make_video.sh
#   FFMPEG_BIN='C:\ffmpeg\bin\ffmpeg.exe' ./make_video.sh   # WSL/bash also supported
# Output (ffmpeg mode):
#   output/danjong_eomheungdo_10min.mp4
#   output/thumbnail_clickbait.png
# Output (fallback mode, no ffmpeg):
#   output/danjong_eomheungdo_preview.html

mkdir -p output

normalize_ffmpeg_path() {
  local p="${1:-}"
  [[ -z "$p" ]] && return 1
  if [[ "$p" =~ ^[A-Za-z]:\\ ]] || [[ "$p" =~ ^[A-Za-z]:/ ]]; then
    if command -v wslpath >/dev/null 2>&1; then
      p="$(wslpath -u "$p" 2>/dev/null || true)"
    fi
  fi
  [[ -n "$p" ]] && printf '%s\n' "$p"
}

resolve_ffmpeg() {
  local p=""
  p="$(normalize_ffmpeg_path "${FFMPEG_BIN:-}" || true)"
  if [[ -n "$p" && -x "$p" ]]; then
    echo "$p"; return 0
  fi
  if command -v ffmpeg >/dev/null 2>&1; then
    command -v ffmpeg; return 0
  fi
  if command -v where.exe >/dev/null 2>&1; then
    while IFS= read -r line; do
      p="$(normalize_ffmpeg_path "$line" || true)"
      if [[ -n "$p" && -x "$p" ]]; then
        echo "$p"; return 0
      fi
    done < <(where.exe ffmpeg 2>/dev/null || true)
  fi
  local candidates=(
    "$HOME/bin/ffmpeg" "$HOME/.local/bin/ffmpeg" "/usr/local/bin/ffmpeg" "/usr/bin/ffmpeg"
    "/opt/homebrew/bin/ffmpeg" "/opt/ffmpeg/bin/ffmpeg"
    "/mnt/c/ffmpeg/bin/ffmpeg.exe" "/mnt/c/Program Files/ffmpeg/bin/ffmpeg.exe" "/mnt/c/Program Files (x86)/ffmpeg/bin/ffmpeg.exe"
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -x "$c" ]] && { echo "$c"; return 0; }
  done
  return 1
}

generate_html_fallback() {
  cat > output/danjong_eomheungdo_preview.html <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><title>Danjong Preview</title>
<style>body{margin:0;background:#0b1020;color:#fff;font-family:sans-serif}#c{display:block;margin:0 auto;max-width:100vw;height:auto} .tip{padding:12px;text-align:center;color:#ddd}</style>
</head><body>
<canvas id="c" width="1280" height="720"></canvas>
<div class="tip">ffmpeg가 없어 HTML 미리보기로 생성됨 (재생 버튼 없이 자동 루프)</div>
<script>
const c=document.getElementById('c'),x=c.getContext('2d');
function draw(t){const s=t/1000,w=c.width,h=c.height;
const g=x.createLinearGradient(0,0,w,h);g.addColorStop(0,'#0b1020');g.addColorStop(1,'#301014');x.fillStyle=g;x.fillRect(0,0,w,h);
x.fillStyle='rgba(0,0,0,.3)';x.fillRect(0,0,w,100);x.fillRect(0,h-120,w,120);
x.fillStyle='#fff3d0';x.font='bold 76px sans-serif';x.textAlign='center';x.fillText('단종과 엄흥도',w/2,120);
x.fillStyle='#f14949';x.font='bold 44px sans-serif';x.fillText('지워진 왕, 금기를 깬 이름',w/2,180);
const line=s%15<5?'00:00-05:00 소년 왕의 추락 [실록 기반]':(s%15<10?'05:00-10:00 엄흥도의 결단 [전승 기반]':'10:00-15:00 기억은 왜 살아남았나');
x.fillStyle='rgba(15,19,38,.75)';x.fillRect(80,260,w-160,280);
x.fillStyle='#fff';x.font='bold 48px sans-serif';x.fillText(line,w/2,360);
x.fillStyle='#ffe9a8';x.font='bold 52px sans-serif';x.fillText('권력은 기억까지 지울 수 있는가',w/2,450);
const px=(s*180)%(w+300)-150;x.strokeStyle='rgba(255,80,80,.45)';x.lineWidth=6;x.beginPath();x.moveTo(px,220);x.lineTo(px+180,560);x.stroke();
requestAnimationFrame(draw)}requestAnimationFrame(draw);
</script></body></html>
HTML
  echo "[WARN] ffmpeg not found. Generated fallback preview: output/danjong_eomheungdo_preview.html"
}

if ! FFMPEG="$(resolve_ffmpeg)"; then
  generate_html_fallback
  exit 0
fi

FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
[[ -f "$FONT" ]] || FONT="/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"

echo "[INFO] Using ffmpeg: $FFMPEG"
"$FFMPEG" -y -f lavfi -i "color=c=0x0b1020:s=1920x1080:d=600,format=yuv420p" -vf "
noise=alls=8:allf=t,vignette=PI/4,eq=contrast=1.25:saturation=1.15:brightness=-0.03,
drawbox=x=0:y=0:w=iw:h=140:color=black@0.35:t=fill,drawbox=x=0:y=ih-160:w=iw:h=160:color=black@0.40:t=fill,
drawtext=fontfile=${FONT}:text='단종과 엄흥도':fontsize=96:fontcolor=0xfff3d0:x=(w-text_w)/2:y=52,
drawtext=fontfile=${FONT}:text='지워진 왕, 금기를 깬 이름':fontsize=54:fontcolor=0xf14949:x=(w-text_w)/2:y=170,
drawtext=fontfile=${FONT}:text='[실록 기반]과 [전승]을 분리해 보는 10분':fontsize=44:fontcolor=0xd8dde8:x=(w-text_w)/2:y=h-130,
drawtext=fontfile=${FONT}:text='00:00-03:20 소년 왕의 추락':fontsize=52:fontcolor=white:x=140:y=320:enable='between(t,0,200)',
drawtext=fontfile=${FONT}:text='03:20-05:20 단종의 최후 [실록 기반]':fontsize=52:fontcolor=0xffe3a5:x=140:y=320:enable='between(t,200,320)',
drawtext=fontfile=${FONT}:text='05:20-07:40 엄흥도의 결단 [전승 기반]':fontsize=52:fontcolor=0xff8f8f:x=140:y=320:enable='between(t,320,460)',
drawtext=fontfile=${FONT}:text='07:40-10:00 기억은 왜 살아남았나':fontsize=52:fontcolor=0xb7d0ff:x=140:y=320:enable='between(t,460,600)',
drawbox=x=120:y=420:w=1680:h=460:color=0x0f1326@0.65:t=fill,
drawtext=fontfile=${FONT}:text='권력은 사람을 지울 수 있어도, 기억까지 지울 수 있는가':fontsize=60:fontcolor=0xfff2cc:x=(w-text_w)/2:y=610:enable='between(t,15,595)'" -r 30 -c:v libx264 -pix_fmt yuv420p output/danjong_eomheungdo_10min.mp4

"$FFMPEG" -y -f lavfi -i "color=c=0x111627:s=1280x720:d=1" -vf "noise=alls=12:allf=t,eq=contrast=1.3:saturation=1.2,drawbox=x=0:y=0:w=iw/2:h=ih:color=0x20395f@0.8:t=fill,drawbox=x=iw/2:y=0:w=iw/2:h=ih:color=0x5f2020@0.8:t=fill,drawtext=fontfile=${FONT}:text='왕을 묻은 죄':fontsize=120:fontcolor=0xffeb99:x=(w-text_w)/2:y=220,drawtext=fontfile=${FONT}:text='17세 왕의 죽음':fontsize=68:fontcolor=white:x=(w-text_w)/2:y=360,drawtext=fontfile=${FONT}:text='단종 X 엄흥도':fontsize=64:fontcolor=0xff8f8f:x=(w-text_w)/2:y=460" -frames:v 1 output/thumbnail_clickbait.png

echo "[OK] Generated output/danjong_eomheungdo_10min.mp4"
echo "[OK] Generated output/thumbnail_clickbait.png"

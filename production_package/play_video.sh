#!/usr/bin/env bash
set -euo pipefail

VIDEO_PATH="${1:-}"

if [[ -z "$VIDEO_PATH" ]]; then
  if [[ -f output/danjong_eomheungdo_10min.mp4 ]]; then
    VIDEO_PATH="output/danjong_eomheungdo_10min.mp4"
  elif [[ -f output/danjong_eomheungdo_preview.html ]]; then
    VIDEO_PATH="output/danjong_eomheungdo_preview.html"
  else
    VIDEO_PATH="output/danjong_eomheungdo_preview.webm"
  fi
fi

if [[ ! -f "$VIDEO_PATH" ]]; then
  echo "[ERROR] Play target not found: $VIDEO_PATH" >&2
  echo "[HINT] Run ./make_video.sh first." >&2
  exit 1
fi

if [[ "$VIDEO_PATH" == *.html ]]; then
  if command -v xdg-open >/dev/null 2>&1; then exec xdg-open "$VIDEO_PATH"; fi
  if command -v open >/dev/null 2>&1; then exec open "$VIDEO_PATH"; fi
fi

if command -v ffplay >/dev/null 2>&1; then exec ffplay -autoexit "$VIDEO_PATH"; fi
if command -v mpv >/dev/null 2>&1; then exec mpv "$VIDEO_PATH"; fi
if command -v vlc >/dev/null 2>&1; then exec vlc "$VIDEO_PATH"; fi

case "$(uname -s)" in
  Darwin) exec open "$VIDEO_PATH" ;;
  Linux) command -v xdg-open >/dev/null 2>&1 && exec xdg-open "$VIDEO_PATH" ;;
  MINGW*|MSYS*|CYGWIN*) exec cmd.exe /c start "" "$(wslpath -w "$VIDEO_PATH" 2>/dev/null || echo "$VIDEO_PATH")" ;;
esac

echo "[WARN] No local opener found in this environment." >&2
echo "[INFO] Open this file manually: $VIDEO_PATH" >&2
exit 0

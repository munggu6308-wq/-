#!/usr/bin/env bash
set -euo pipefail

normalize_path() {
  local p="${1:-}"
  [[ -z "$p" ]] && return 1
  if [[ "$p" =~ ^[A-Za-z]:\\ ]] || [[ "$p" =~ ^[A-Za-z]:/ ]]; then
    if command -v wslpath >/dev/null 2>&1; then
      p="$(wslpath -u "$p" 2>/dev/null || true)"
    fi
  fi
  [[ -n "$p" ]] && printf '%s\n' "$p"
}

candidates=(
  "${FFMPEG_BIN:-}"
  "$(command -v ffmpeg 2>/dev/null || true)"
  "$HOME/bin/ffmpeg"
  "$HOME/.local/bin/ffmpeg"
  "/usr/local/bin/ffmpeg"
  "/usr/bin/ffmpeg"
  "/opt/homebrew/bin/ffmpeg"
  "/opt/ffmpeg/bin/ffmpeg"
  "/mnt/c/ffmpeg/bin/ffmpeg.exe"
  "/mnt/c/Program Files/ffmpeg/bin/ffmpeg.exe"
  "/mnt/c/Program Files (x86)/ffmpeg/bin/ffmpeg.exe"
)

if command -v where.exe >/dev/null 2>&1; then
  while IFS= read -r line; do
    candidates+=("$line")
  done < <(where.exe ffmpeg 2>/dev/null || true)
fi

found=""
for c in "${candidates[@]}"; do
  p="$(normalize_path "$c" || true)"
  if [[ -n "$p" && -x "$p" ]]; then
    found="$p"
    break
  fi
done

if [[ -z "$found" ]]; then
  echo "[FAIL] ffmpeg not found." >&2
  echo "[NEXT] 실행 순서:" >&2
  echo "  1) where.exe ffmpeg" >&2
  echo "  2) export FFMPEG_BIN='C:\\ffmpeg\\bin\\ffmpeg.exe'" >&2
  echo "  3) ./make_video.sh" >&2
  echo "[OR] find / -type f \( -name ffmpeg -o -name ffmpeg.exe \) 2>/dev/null | head -n 20" >&2
  exit 1
fi

echo "[OK] ffmpeg found: $found"
echo "[NEXT] 실행 명령:"
echo "  cd production_package && FFMPEG_BIN='$found' ./make_video.sh"

mkdir -p "$HOME/.local/bin"
ln -sf "$found" "$HOME/.local/bin/ffmpeg" || true
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "[HINT] PATH에 추가: export PATH=\"$HOME/.local/bin:$PATH\""
fi

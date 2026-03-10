#!/usr/bin/env bash
set -euo pipefail

# Compress production_package/output into a single downloadable archive.
# Usage:
#   ./package_output.sh
# Optional:
#   ./package_output.sh my_output_bundle.tar.gz

ARCHIVE_NAME="${1:-output_bundle.tar.gz}"

if [[ ! -d output ]]; then
  echo "[ERROR] output directory not found. Run ./make_video.sh first." >&2
  exit 1
fi

if [[ -z "$(ls -A output 2>/dev/null)" ]]; then
  echo "[ERROR] output directory is empty. Run ./make_video.sh first." >&2
  exit 1
fi

tar -czf "$ARCHIVE_NAME" output

echo "[OK] Created archive: $(pwd)/$ARCHIVE_NAME"
echo "[INFO] Preview HTML path: $(pwd)/output/danjong_eomheungdo_preview.html"

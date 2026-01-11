#!/usr/bin/env bash
# Log Rotator: Compress and archive logs older than N days.
# Requires: bash, find, gzip, mkdir, date
# Usage: log-rotator.sh --path DIR [--days N] [--archive-dir DIR] [--pattern PATTERN] [--remove] [--truncate]
# Examples:
#   log-rotator.sh --path /var/log --days 7 --archive-dir /var/log/archive
#   log-rotator.sh --path ./logs --days 30 --pattern "*.log" --archive-dir ./archive --remove
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: log-rotator.sh --path DIR [--days N] [--archive-dir DIR] [--pattern PATTERN] [--remove] [--truncate]

Options:
  --path         Directory containing logs (required)
  --days         Rotate files older than N days (default: 7)
  --archive-dir  Destination directory to store compressed archives (default: ./archive)
  --pattern      Glob pattern to match (default: *.log)
  --remove       Remove original files after archiving
  --truncate     Truncate original files (zero-length) after archiving

Note: Use either --remove or --truncate if you want to alter originals.
EOF
}

PATH_DIR=""
DAYS=7
ARCHIVE_DIR="./archive"
PATTERN="*.log"
REMOVE=false
TRUNCATE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) PATH_DIR=${2:-}; shift 2;;
    --days) DAYS=${2:-7}; shift 2;;
    --archive-dir) ARCHIVE_DIR=${2:-./archive}; shift 2;;
    --pattern) PATTERN=${2:-"*.log"}; shift 2;;
    --remove) REMOVE=true; shift;;
    --truncate) TRUNCATE=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$PATH_DIR" || ! -d "$PATH_DIR" ]]; then
  echo "Error: --path must point to an existing directory" 1>&2
  exit 2
fi

if ! command -v find >/dev/null 2>&1 || ! command -v gzip >/dev/null 2>&1; then
  echo "Error: find/gzip required" 1>&2
  exit 3
fi

STAMP_DIR="$ARCHIVE_DIR/$(date +%F)"
mkdir -p "$STAMP_DIR"

# Use null-delimited list for safe filenames
while IFS= read -r -d '' file; do
  base=$(basename "$file")
  ts=$(date +%s)
  out="$STAMP_DIR/$base.$ts.gz"
  echo "Archiving $file -> $out"
  gzip -c "$file" > "$out"
  if [[ "$REMOVE" == true && "$TRUNCATE" == false ]]; then
    rm -f "$file"
  elif [[ "$TRUNCATE" == true && "$REMOVE" == false ]]; then
    : > "$file"
  fi
done < <(find "$PATH_DIR" -type f -name "$PATTERN" -mtime +"$DAYS" -print0)

echo "Log rotation complete. Archives in: $STAMP_DIR"

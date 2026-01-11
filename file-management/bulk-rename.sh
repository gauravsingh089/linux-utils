#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: bulk-rename.sh --dir PATH --pattern REGEX --replace STRING [--dry-run]

Options:
  --dir       Directory containing files to rename (required)
  --pattern   POSIX regex to match in filenames (required)
  --replace   Replacement string (required)
  --dry-run   Show planned renames without changing files

Examples:
  bulk-rename.sh --dir ./photos --pattern ' ' --replace '_' --dry-run
  bulk-rename.sh --dir ./logs --pattern '2025' --replace '2026'
EOF
}

DIR=""
PATTERN=""
REPLACE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) DIR=${2:-}; shift 2;;
    --pattern) PATTERN=${2:-}; shift 2;;
    --replace) REPLACE=${2:-}; shift 2;;
    --dry-run) DRY_RUN=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$DIR" || -z "$PATTERN" || -z "$REPLACE" ]]; then
  echo "Error: --dir, --pattern and --replace are required" 1>&2
  usage
  exit 2
fi

if [[ ! -d "$DIR" ]]; then
  echo "Error: Directory not found: $DIR" 1>&2
  exit 2
fi

shopt -s nullglob
for path in "$DIR"/*; do
  base=$(basename "$path")
  if echo "$base" | grep -E -q "$PATTERN"; then
    newbase=$(echo "$base" | sed -E "s/$PATTERN/$REPLACE/g")
    newpath="$(dirname "$path")/$newbase"
    if [[ "$DRY_RUN" == true ]]; then
      echo "Would rename: $path -> $newpath"
    else
      mv -v "$path" "$newpath"
    fi
  fi
done

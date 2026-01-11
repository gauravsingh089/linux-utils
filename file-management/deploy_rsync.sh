#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: deploy_rsync.sh --src <PATH> --dest <HOST:PATH> [--delete] [--checksum] [--exclude-file <FILE>] [--dry-run]

Options:
  --src           Source directory (required)
  --dest          Destination spec (e.g., user@host:/path) (required)
  --delete        Delete extraneous files from destination
  --checksum      Use checksums to skip files (slower but safer)
  --exclude-file  Path to file containing exclude patterns
  --dry-run       Show actions without making changes

Examples:
  deploy_rsync.sh --src ./site --dest user@server:/var/www/site --delete --checksum
  deploy_rsync.sh --src ./build --dest /mnt/backup --exclude-file .rsyncignore
EOF
}

SRC=""
DEST=""
DELETE=false
CHECKSUM=false
EXCLUDE_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --src) SRC=${2:-}; shift 2;;
    --dest) DEST=${2:-}; shift 2;;
    --delete) DELETE=true; shift;;
    --checksum) CHECKSUM=true; shift;;
    --exclude-file) EXCLUDE_FILE=${2:-}; shift 2;;
    --dry-run) DRY_RUN=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$SRC" || -z "$DEST" ]]; then
  echo "Error: --src and --dest are required" 1>&2
  usage
  exit 2
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "Error: rsync not found. Please install rsync." 1>&2
  exit 3
fi

ARGS=("-az")
$DELETE && ARGS+=("--delete")
$CHECKSUM && ARGS+=("--checksum")
[[ -n "$EXCLUDE_FILE" ]] && ARGS+=("--exclude-from=$EXCLUDE_FILE")
$DRY_RUN && ARGS+=("--dry-run")

set -x
rsync "${ARGS[@]}" "$SRC/" "$DEST/"
set +x

echo "Deploy complete: $SRC -> $DEST"

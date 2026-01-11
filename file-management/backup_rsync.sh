#!/usr/bin/env bash
# Backup Script: rsync wrapper to backup a directory locally or to remote.
# Requires: rsync
# Usage: backup_rsync.sh --src DIR --dest HOST:DIR [--snapshot] [--delete] [--checksum] [--exclude-file FILE] [--dry-run]
# Examples:
#   backup_rsync.sh --src ./data --dest user@server:/backups/data --snapshot --exclude-file .rsyncignore
#   backup_rsync.sh --src ./project --dest /mnt/backup --delete --checksum
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: backup_rsync.sh --src DIR --dest HOST:DIR [--snapshot] [--delete] [--checksum] [--exclude-file FILE] [--dry-run]

Options:
  --src           Source directory (required)
  --dest          Destination spec (local path or user@host:/path) (required)
  --snapshot      Create timestamped subdirectory at destination (e.g., /path/YYYY-MM-DD_HHMMSS)
  --delete        Delete extraneous files from destination
  --checksum      Use checksums to determine changes (slower)
  --exclude-file  Path to file containing exclude patterns
  --dry-run       Show actions without making changes
EOF
}

SRC=""
DEST=""
SNAPSHOT=false
DELETE=false
CHECKSUM=false
EXCLUDE_FILE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --src) SRC=${2:-}; shift 2;;
    --dest) DEST=${2:-}; shift 2;;
    --snapshot) SNAPSHOT=true; shift;;
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

DEST_PATH="$DEST"
if [[ "$SNAPSHOT" == true ]]; then
  ts=$(date +%F_%H%M%S)
  DEST_PATH="$DEST/$ts"
fi

ARGS=("-aHAX" "--numeric-ids" "--partial" "--progress")
$DELETE && ARGS+=("--delete")
$CHECKSUM && ARGS+=("--checksum")
[[ -n "$EXCLUDE_FILE" ]] && ARGS+=("--exclude-from=$EXCLUDE_FILE")
$DRY_RUN && ARGS+=("--dry-run")

set -x
rsync "${ARGS[@]}" "$SRC/" "$DEST_PATH/"
set +x

echo "Backup complete: $SRC -> $DEST_PATH"

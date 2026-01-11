#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: check-disk-space.sh [--path PATH] [--threshold PERCENT]

Options:
  --path       Filesystem path to check (default: /)
  --threshold  Alert threshold percentage (default: 80)

Exits with non-zero if usage >= threshold.
Examples:
  check-disk-space.sh --path /var --threshold 90
EOF
}

PATH_TO_CHECK="/"
THRESHOLD=80

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) PATH_TO_CHECK=${2:-/}; shift 2;;
    --threshold) THRESHOLD=${2:-80}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if ! command -v df >/dev/null 2>&1; then
  echo "Error: df command not found" 1>&2
  exit 3
fi

USED=$(df -P "$PATH_TO_CHECK" | awk 'NR==2 {print $5}' | tr -d '%')
if [[ -z "$USED" ]]; then
  echo "Could not determine disk usage for $PATH_TO_CHECK" 1>&2
  exit 3
fi

echo "Usage for $PATH_TO_CHECK: ${USED}%"
if (( USED >= THRESHOLD )); then
  echo "ALERT: usage ${USED}% >= threshold ${THRESHOLD}%" 1>&2
  exit 1
fi

echo "OK: usage below threshold"

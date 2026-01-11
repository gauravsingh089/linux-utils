#!/usr/bin/env bash
# System Health Check: Summary of CPU load, memory usage, and disk usage.
# Requires: bash, uptime, free|/proc/meminfo, df
# Usage: system-health-check.sh [--disk-path PATH]
# Example:
#   system-health-check.sh --disk-path /
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: system-health-check.sh [--disk-path PATH]

Options:
  --disk-path   Path to report disk usage for (default: /)
EOF
}

DISK_PATH="/"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk-path) DISK_PATH=${2:-/}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

echo "=== System Health Check ==="
echo "Host: $(hostname)"

echo "-- CPU Load --"
uptime || true

echo "-- Memory --"
if command -v free >/dev/null 2>&1; then
  free -h || free -m || true
else
  echo "free not available; showing /proc/meminfo"
  head -n 5 /proc/meminfo 2>/dev/null || true
fi

echo "-- Disk --"
df -h "$DISK_PATH" || df -h || true

echo "Health summary complete"

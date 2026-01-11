#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: disk_usage_report.sh [--path PATH] [--depth N] [--top N]

Options:
  --path   Root path to analyze (default: /)
  --depth  Max directory depth (default: 1)
  --top    Show top N entries (default: 20)

Examples:
  disk_usage_report.sh --path /var --depth 1 --top 15
  disk_usage_report.sh --path /home --depth 2
EOF
}

PATH_ROOT="/"
DEPTH=1
TOPN=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) PATH_ROOT=${2:-/}; shift 2;;
    --depth) DEPTH=${2:-1}; shift 2;;
    --top) TOPN=${2:-20}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if ! command -v du >/dev/null 2>&1; then
  echo "Error: du not found." 1>&2
  exit 3
fi

if ! command -v sort >/dev/null 2>&1; then
  echo "Error: sort not found." 1>&2
  exit 3
fi

set -o pipefail
sudo -n true 2>/dev/null || true

du -h --max-depth="$DEPTH" "$PATH_ROOT" 2>/dev/null | sort -hr | head -n "$TOPN"

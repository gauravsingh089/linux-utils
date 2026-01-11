#!/usr/bin/env bash
set -euo pipefail

COUNT=10

usage() {
  cat 1>&2 <<'EOF'
Usage: top_mem_processes.sh [--count N]

Options:
  --count   Number of processes to display (default: 10)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)
      COUNT=${2:-}; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

ps aux --sort=-%mem | head -n "$COUNT"

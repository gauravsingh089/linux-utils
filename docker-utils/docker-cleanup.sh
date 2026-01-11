#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: docker-cleanup.sh [--prune-all] [--remove-dangling] [--remove-stopped]

Options:
  --prune-all        Prune unused images, containers, networks, volumes (dangerous)
  --remove-dangling  Remove dangling images
  --remove-stopped   Remove stopped containers

Examples:
  docker-cleanup.sh --remove-dangling --remove-stopped
  docker-cleanup.sh --prune-all
EOF
}

PRUNE_ALL=false
REMOVE_DANGLING=false
REMOVE_STOPPED=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prune-all) PRUNE_ALL=true; shift;;
    --remove-dangling) REMOVE_DANGLING=true; shift;;
    --remove-stopped) REMOVE_STOPPED=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker CLI not found" 1>&2
  exit 3
fi

set -x
$REMOVE_STOPPED && docker container prune -f
$REMOVE_DANGLING && docker image prune -f
$PRUNE_ALL && docker system prune -a -f --volumes
set +x

echo "Docker cleanup complete"

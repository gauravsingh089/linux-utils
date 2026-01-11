#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: service_restart.sh --name <SERVICE> [--check-path <URL|CMD>]

Options:
  --name        systemd service name (required)
  --check-path  Optional health check: URL (http/https) or shell command

Examples:
  service_restart.sh --name nginx --check-path https://localhost/healthz
  service_restart.sh --name myapp --check-path "curl --fail http://localhost:3000/health"
EOF
}

SVC=""
CHECK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) SVC=${2:-}; shift 2;;
    --check-path) CHECK=${2:-}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$SVC" ]]; then
  echo "Error: --name is required" 1>&2
  usage
  exit 2
fi

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl restart "$SVC"
  sudo systemctl is-active --quiet "$SVC" && echo "Service '$SVC' is active" || { echo "Service '$SVC' failed to start" 1>&2; exit 1; }
else
  echo "systemctl not found; attempting legacy 'service' command" 1>&2
  sudo service "$SVC" restart || { echo "Service '$SVC' restart failed" 1>&2; exit 1; }
fi

if [[ -n "$CHECK" ]]; then
  echo "Running post-restart check: $CHECK"
  if [[ "$CHECK" =~ ^https?:// ]]; then
    if ! command -v curl >/dev/null 2>&1; then
      echo "curl not found; cannot check URL" 1>&2
      exit 1
    fi
    curl --fail --silent --show-error "$CHECK" > /dev/null && echo "Health check OK" || { echo "Health check failed" 1>&2; exit 1; }
  else
    bash -c "$CHECK" && echo "Check command OK" || { echo "Check command failed" 1>&2; exit 1; }
  fi
fi

echo "Service '$SVC' restart completed"

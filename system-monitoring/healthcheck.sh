#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: healthcheck.sh --url <URL> [--retries N] [--interval S] [--timeout S]

Options:
  --url        Target URL to check (required)
  --retries    Number of retries on failure (default: 5)
  --interval   Seconds to wait between retries (default: 2)
  --timeout    Curl timeout in seconds (default: 5)

Examples:
  healthcheck.sh --url https://example.com/healthz
  healthcheck.sh --url http://localhost:8080/health --retries 10 --interval 1
EOF
}

URL=""
RETRIES=5
INTERVAL=2
TIMEOUT=5

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL=${2:-}; shift 2;;
    --retries)
      RETRIES=${2:-}; shift 2;;
    --interval)
      INTERVAL=${2:-}; shift 2;;
    --timeout)
      TIMEOUT=${2:-}; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$URL" ]]; then
  echo "Error: --url is required" 1>&2
  usage
  exit 2
fi

attempt=1
while (( attempt <= RETRIES )); do
  if curl --fail --silent --show-error --max-time "$TIMEOUT" "$URL" > /dev/null; then
    echo "OK: $URL responded successfully"
    exit 0
  fi
  echo "Attempt $attempt/$RETRIES failed; retrying in ${INTERVAL}s..." 1>&2
  sleep "$INTERVAL"
  ((attempt++))
done

echo "ERROR: Healthcheck failed for $URL after $RETRIES attempts" 1>&2
exit 1

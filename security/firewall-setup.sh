#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: firewall-setup.sh [--allow PORT[/proto]]... [--deny PORT[/proto]]... [--policy incoming|outgoing allow|deny] [--enable]

Notes:
  - Prefers UFW if available; falls back to iptables (basic rules).
  - Requires sudo privileges.

Examples:
  firewall-setup.sh --enable --allow 22/tcp --allow 80/tcp --allow 443/tcp
  firewall-setup.sh --deny 23/tcp --policy incoming deny
EOF
}

ALLOWS=()
DENIES=()
POLICY_INCOMING=""
POLICY_OUTGOING=""
ENABLE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow) ALLOWS+=("${2:-}"); shift 2;;
    --deny) DENIES+=("${2:-}"); shift 2;;
    --policy)
      case "${2:-}" in
        incoming) POLICY_INCOMING=${3:-}; shift 3;;
        outgoing) POLICY_OUTGOING=${3:-}; shift 3;;
        *) echo "Unknown policy target: ${2:-}" 1>&2; usage; exit 2;;
      esac;;
    --enable) ENABLE=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if command -v ufw >/dev/null 2>&1; then
  sudo ufw --force disable || true
  for a in "${ALLOWS[@]}"; do sudo ufw allow "$a"; done
  for d in "${DENIES[@]}"; do sudo ufw deny "$d"; done
  [[ -n "$POLICY_INCOMING" ]] && sudo ufw default "$POLICY_INCOMING" incoming
  [[ -n "$POLICY_OUTGOING" ]] && sudo ufw default "$POLICY_OUTGOING" outgoing
  $ENABLE && sudo ufw --force enable
  sudo ufw status verbose
elif command -v iptables >/dev/null 2>&1; then
  echo "Using iptables (basic rules)"
  sudo iptables -P INPUT ACCEPT
  sudo iptables -F INPUT
  if [[ -n "$POLICY_INCOMING" ]]; then
    case "$POLICY_INCOMING" in
      allow) sudo iptables -P INPUT ACCEPT;;
      deny) sudo iptables -P INPUT DROP;;
      *) echo "Unknown incoming policy: $POLICY_INCOMING" 1>&2; exit 2;;
    esac
  fi
  for a in "${ALLOWS[@]}"; do
    PORT=${a%/*}; PROTO=${a#*/}; [[ "$PORT" == "$PROTO" ]] && PROTO=tcp
    sudo iptables -A INPUT -p "$PROTO" --dport "$PORT" -j ACCEPT
  done
  for d in "${DENIES[@]}"; do
    PORT=${d%/*}; PROTO=${d#*/}; [[ "$PORT" == "$PROTO" ]] && PROTO=tcp
    sudo iptables -A INPUT -p "$PROTO" --dport "$PORT" -j DROP
  done
  sudo iptables -L -n -v
else
  echo "No supported firewall tool found (ufw or iptables)." 1>&2
  exit 3
fi

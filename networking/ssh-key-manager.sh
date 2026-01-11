#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: ssh-key-manager.sh [add|list|remove] [--key-file PATH] [--comment COMMENT]

Commands:
  add       Add public key to ~/.ssh/authorized_keys
  list      List entries in ~/.ssh/authorized_keys
  remove    Remove entries matching COMMENT from authorized_keys

Options:
  --key-file  Path to public key file (default: ~/.ssh/id_rsa.pub)
  --comment   Comment to identify/remove (default: current user@host)

Examples:
  ssh-key-manager.sh add --key-file ~/.ssh/id_ed25519.pub --comment "deploy@server"
  ssh-key-manager.sh list
  ssh-key-manager.sh remove --comment "deploy@server"
EOF
}

CMD=${1:-}
KEY_FILE=${2:-}
COMMENT="${USER}@$(hostname)"

# Parse long options after command
shift || true
KEY_FILE_DEFAULT="$HOME/.ssh/id_rsa.pub"
KEY_FILE=${KEY_FILE:-$KEY_FILE_DEFAULT}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --key-file) KEY_FILE=${2:-$KEY_FILE_DEFAULT}; shift 2;;
    --comment) COMMENT=${2:-$COMMENT}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

AUTH_KEYS="$HOME/.ssh/authorized_keys"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

case "$CMD" in
  add)
    if [[ ! -f "$KEY_FILE" ]]; then
      echo "Error: Key file not found: $KEY_FILE" 1>&2
      exit 2
    fi
    KEY_CONTENT=$(cat "$KEY_FILE")
    if grep -q "$KEY_CONTENT" "$AUTH_KEYS"; then
      echo "Key already present"
    else
      echo "$KEY_CONTENT $COMMENT" >> "$AUTH_KEYS"
      echo "Key added with comment: $COMMENT"
    fi
    ;;
  list)
    nl -ba "$AUTH_KEYS"
    ;;
  remove)
    if grep -q "$COMMENT" "$AUTH_KEYS"; then
      grep -v "$COMMENT" "$AUTH_KEYS" > "$AUTH_KEYS.tmp"
      mv "$AUTH_KEYS.tmp" "$AUTH_KEYS"
      echo "Removed entries with comment: $COMMENT"
    else
      echo "No entries matching comment: $COMMENT"
    fi
    ;;
  *)
    usage; exit 2;;
esac

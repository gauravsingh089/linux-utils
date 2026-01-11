#!/usr/bin/env bash
# User Creator: Create a user, assign groups, and set up SSH keys.
# Requires: sudo privileges, useradd/adduser, mkdir, chmod
# Usage: user_creator.sh --user NAME [--groups g1,g2] [--key-file FILE|--pubkey STRING] [--shell SHELL] [--home DIR]
# Examples:
#   user_creator.sh --user deploy --groups sudo,www-data --key-file ./deploy.pub
#   user_creator.sh --user ci --pubkey "ssh-ed25519 AAAA... user@host" --shell /bin/bash
set -euo pipefail

usage() {
  cat 1>&2 <<'EOF'
Usage: user_creator.sh --user NAME [--groups g1,g2] [--key-file FILE|--pubkey STRING] [--shell SHELL] [--home DIR]

Options:
  --user      Username to create (required)
  --groups    Comma-separated supplemental groups
  --key-file  Path to public key file (mutually exclusive with --pubkey)
  --pubkey    Public key string (mutually exclusive with --key-file)
  --shell     Login shell (default: /bin/bash)
  --home      Home directory (default: /home/USER)

Notes:
  - Requires sudo privileges.
EOF
}

USER_NAME=""
GROUPS=""
KEY_FILE=""
PUBKEY=""
SHELL_PATH="/bin/bash"
HOME_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) USER_NAME=${2:-}; shift 2;;
    --groups) GROUPS=${2:-}; shift 2;;
    --key-file) KEY_FILE=${2:-}; shift 2;;
    --pubkey) PUBKEY=${2:-}; shift 2;;
    --shell) SHELL_PATH=${2:-/bin/bash}; shift 2;;
    --home) HOME_DIR=${2:-}; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" 1>&2; usage; exit 2;;
  esac
done

if [[ -z "$USER_NAME" ]]; then
  echo "Error: --user is required" 1>&2
  usage
  exit 2
fi

if [[ -n "$KEY_FILE" && -n "$PUBKEY" ]]; then
  echo "Error: Use either --key-file or --pubkey, not both" 1>&2
  exit 2
fi

# Determine home dir if not provided
HOME_DIR=${HOME_DIR:-/home/$USER_NAME}

# Create user if not exists
if id -u "$USER_NAME" >/dev/null 2>&1; then
  echo "User '$USER_NAME' already exists"
else
  if command -v useradd >/dev/null 2>&1; then
    sudo useradd -m -d "$HOME_DIR" -s "$SHELL_PATH" "$USER_NAME"
  elif command -v adduser >/dev/null 2>&1; then
    sudo adduser --home "$HOME_DIR" --shell "$SHELL_PATH" --disabled-password --gecos "" "$USER_NAME"
  else
    echo "Error: No useradd/adduser available" 1>&2
    exit 3
  fi
  echo "Created user '$USER_NAME'"
fi

# Assign groups
if [[ -n "$GROUPS" ]]; then
  IFS=',' read -r -a grp <<< "$GROUPS"
  for g in "${grp[@]}"; do
    sudo usermod -a -G "$g" "$USER_NAME" || echo "Warning: Failed to add to group '$g'" 1>&2
  done
  echo "Assigned groups: $GROUPS"
fi

# Setup SSH keys
SSH_DIR="$HOME_DIR/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"
sudo touch "$AUTH_KEYS"
sudo chmod 600 "$AUTH_KEYS"
sudo chown -R "$USER_NAME":"$USER_NAME" "$SSH_DIR"

if [[ -n "$KEY_FILE" ]]; then
  if [[ ! -f "$KEY_FILE" ]]; then
    echo "Error: Key file not found: $KEY_FILE" 1>&2
    exit 2
  fi
  sudo bash -c "cat '$KEY_FILE' >> '$AUTH_KEYS'"
  echo "Added key from file: $KEY_FILE"
elif [[ -n "$PUBKEY" ]]; then
  sudo bash -c "echo '$PUBKEY' >> '$AUTH_KEYS'"
  echo "Added provided public key"
else
  echo "No key provided; SSH key setup skipped"
fi

echo "User setup complete for '$USER_NAME'"

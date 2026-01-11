#!/usr/bin/env bash
set -euo pipefail

if [[ $(uname -s) != "Linux" ]]; then
  echo "This script is intended for Linux (Ubuntu/Debian)." 1>&2
  exit 2
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script targets Debian/Ubuntu." 1>&2
  exit 2
fi

sudo apt-get update -y
sudo apt-get upgrade -y

PACKAGES=(
  curl wget git vim htop net-tools build-essential ufw
)

sudo apt-get install -y "${PACKAGES[@]}"

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable

sudo timedatectl set-timezone UTC || true

cat <<'MOTD' | sudo tee /etc/motd >/dev/null
Welcome! Base tools installed.
Firewall enabled with UFW.
System timezone set to UTC.
MOTD

echo "Post-install completed. Reboot recommended."

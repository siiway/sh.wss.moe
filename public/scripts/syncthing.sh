#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/syncthing.help

echo "=== Syncthing Installation ==="
echo "Help: curl https://sh.wss.moe/syncthing.help"
echo "Contact: https://wyf9.top/c"
echo ""

if ! command -v apt >/dev/null || ! grep -qE "(ID_LIKE.*debian|ID.*(debian|ubuntu))" /etc/os-release 2>/dev/null; then
  echo "This script requires a Debian-based system (Ubuntu, Debian, etc.)."
  echo "For other systems, please refer to the official Syncthing installation guide: https://docs.syncthing.net/intro/getting-started.html"
  exit 1
fi

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt update
sudo apt install -y syncthing

echo "Done."

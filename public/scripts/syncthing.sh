#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/syncthing.help

echo "=== Syncthing Installation ==="
echo "Help: curl sh.wss.moe/syncthing.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt update
sudo apt install -y syncthing

echo "Done."

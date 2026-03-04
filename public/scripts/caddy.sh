#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/caddy.help

echo "=== Caddy Web Server ==="
echo "Help: curl https://sh.wss.moe/caddy.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

echo "Done."

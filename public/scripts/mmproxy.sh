#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/mmproxy.help

echo "=== mmproxy Installation ==="
echo "Help: curl https://sh.wss.moe/mmproxy.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v wget >/dev/null || command -v curl >/dev/null || { echo "Missing wget or curl, please install one of them first."; exit 1; }

if command -v wget >/dev/null; then
  sudo wget https://github.com/cloudflare/mmproxy/releases/latest/download/mmproxy-linux-amd64 -O /usr/local/bin/mmproxy
else
  sudo curl -L https://github.com/cloudflare/mmproxy/releases/latest/download/mmproxy-linux-amd64 -o /usr/local/bin/mmproxy
fi
sudo chmod +x /usr/local/bin/mmproxy

echo "Done."
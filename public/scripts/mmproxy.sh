#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/mmproxy.help

echo "=== mmproxy Installation ==="
echo "Help: curl https://sh.wss.moe/mmproxy.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
mkdir mmproxy
cd mmproxy
curl -sSL -o mmproxy https://github.com/SiiWay/mmproxy/releases/latest/download/mmproxy

sudo mv mmproxy /usr/local/bin/mmproxy
sudo chmod +x /usr/local/bin/mmproxy

echo "Done."

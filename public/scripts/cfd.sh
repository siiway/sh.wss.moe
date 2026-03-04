#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/cfd.help

echo "=== Cloudflared Installation ==="
echo "Help: curl sh.wss.moe/cfd.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

SKIP_FIX=${1:-""}

if [[ "$SKIP_FIX" != "--skip-fix" ]]; then
  echo "net.core.rmem_max=7500000" | sudo tee -a /etc/sysctl.conf >/dev/null
  echo "net.core.wmem_max=7500000" | sudo tee -a /etc/sysctl.conf >/dev/null
  echo "net.ipv4.ping_group_range=0 114514" | sudo tee -a /etc/sysctl.conf >/dev/null
  sudo sysctl -p
fi

sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update
sudo apt-get install -y cloudflared

cloudflared --version

echo "Done."

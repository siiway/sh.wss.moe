#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/cfd.help

echo "=== Cloudflared Installation ==="
echo "Help: curl https://sh.wss.moe/cfd.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

SKIP_FIX=${1:-""}

SYSCTL_FILE="/etc/sysctl.conf"

if [[ "$SKIP_FIX" != "--skip-fix" ]]; then
  echo "Applying network optimizations (only if supported in this environment)..."

  # net.core.rmem_max
  if [ -f /proc/sys/net/core/rmem_max ]; then
    if grep -qE "^[[:space:]]*net\.core\.rmem_max[[:space:]]*=.*" "$SYSCTL_FILE" 2>/dev/null; then
      echo "  net.core.rmem_max already set, skipping."
    else
      echo "  Setting net.core.rmem_max = 7500000"
      echo "net.core.rmem_max = 7500000" | sudo tee -a "$SYSCTL_FILE" >/dev/null
    fi
  else
    echo "  net.core.rmem_max not available, skipping."
  fi

  # net.core.wmem_max
  if [ -f /proc/sys/net/core/wmem_max ]; then
    if grep -qE "^[[:space:]]*net\.core\.wmem_max[[:space:]]*=.*" "$SYSCTL_FILE" 2>/dev/null; then
      echo "  net.core.wmem_max already set, skipping."
    else
      echo "  Setting net.core.wmem_max = 7500000"
      echo "net.core.wmem_max = 7500000" | sudo tee -a "$SYSCTL_FILE" >/dev/null
    fi
  else
    echo "  net.core.wmem_max not available, skipping."
  fi

  # net.ipv4.ping_group_range
  if grep -qE "^[[:space:]]*net\.ipv4\.ping_group_range[[:space:]]*=.*" "$SYSCTL_FILE" 2>/dev/null; then
    echo "  net.ipv4.ping_group_range already set, skipping."
  else
    echo "  Setting net.ipv4.ping_group_range = 0 114514"
    echo "net.ipv4.ping_group_range = 0 114514" | sudo tee -a "$SYSCTL_FILE" >/dev/null
  fi

  # Apply config
  sudo sysctl -p 2>/dev/null || true
else
  echo "Skipping network fixes as requested."
fi

echo "Adding Cloudflare repository..."
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update
sudo apt-get install -y cloudflared

cloudflared --version

echo "Done."

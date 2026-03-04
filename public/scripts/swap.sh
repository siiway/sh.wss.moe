#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/swap.help

echo "=== Add / Resize Swapfile ==="
echo "Help: curl https://sh.wss.moe/swap.help"
echo "Contact: https://wyf9.top/c"
echo ""

SIZE=${1:-4G}
SWAPFILE=${2:-/swapfile}
SWAPPINESS=${3:-20}

if [[ -f "$SWAPFILE" ]]; then
  sudo swapoff "$SWAPFILE" 2>/dev/null || true
fi

sudo fallocate -l "$SIZE" "$SWAPFILE"
sudo chmod 600 "$SWAPFILE"
sudo mkswap "$SWAPFILE"
sudo swapon "$SWAPFILE"

if ! grep -q "^$SWAPFILE" /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

echo "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf >/dev/null
sudo sysctl -p

sudo swapon --show

echo "Done."

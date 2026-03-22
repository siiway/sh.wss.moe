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

echo "Size: $SIZE   File: $SWAPFILE   Swappiness: $SWAPPINESS"

if [[ -f "$SWAPFILE" ]]; then
  sudo swapoff "$SWAPFILE" 2>/dev/null || true
  rm -f "$SWAPFILE" 2>/dev/null || true
fi

sudo fallocate -l "$SIZE" "$SWAPFILE"
sudo chmod 600 "$SWAPFILE"
sudo mkswap "$SWAPFILE"
sudo swapon "$SWAPFILE"

if ! grep -q "^$SWAPFILE" /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

SYSCTL_FILE="/etc/sysctl.conf"
KEY="vm.swappiness"

if grep -qE "^[[:space:]]*$KEY[[:space:]]*=.*" "$SYSCTL_FILE" 2>/dev/null; then
  echo "vm.swappiness already set, skipping."
else
  echo "Setting vm.swappiness = $SWAPPINESS"
  echo "vm.swappiness=$SWAPPINESS" | sudo tee -a "$SYSCTL_FILE" >/dev/null
fi

sudo sysctl -p || true

sudo swapon --show

echo "Done."

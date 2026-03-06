#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/hostname.help

echo "=== Change Hostname ==="
echo "Help: curl https://sh.wss.moe/hostname.help"
echo "Contact: https://wyf9.top/c"
echo ""

if [ $# -eq 0 ]; then
  echo "Usage:"
  echo "  curl https://sh.wss.moe/hostname | sudo bash new-hostname"
  echo "  curl https://sh.wss.moe/hostname | sudo bash new-hostname --temp   # temporary change only (lost after reboot)"
  echo ""
  echo "Examples:"
  echo "  curl https://sh.wss.moe/hostname | sudo bash my-server-01"
  exit 1
fi

NEW_HOSTNAME="$1"
MODE="${2:-permanent}"  # default: permanent

# Basic validation: alphanumeric + hyphen, no leading/trailing hyphen
if [[ ! "$NEW_HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$ ]]; then
  echo "Error: Invalid hostname"
  echo "Suggestion: Use lowercase letters, numbers, hyphens (-). Length 2-63 chars, no leading/trailing hyphen."
  exit 1
fi

echo "Changing hostname to: $NEW_HOSTNAME"
echo "Mode: ${MODE}"
echo ""

# Backup files
[ -f /etc/hostname ] && sudo cp /etc/hostname /etc/hostname.bak-$(date +%Y%m%d-%H%M%S)
[ -f /etc/hosts ] && sudo cp /etc/hosts /etc/hosts.bak-$(date +%Y%m%d-%H%M%S)

if [ "$MODE" = "--temp" ] || [ "$MODE" = "temp" ]; then
  # Temporary change
  echo "Applying temporary change (reboot will revert)..."
  sudo hostname "$NEW_HOSTNAME"
else
  # Permanent change (recommended)
  echo "Writing to /etc/hostname..."
  echo "$NEW_HOSTNAME" | sudo tee /etc/hostname >/dev/null

  echo "Updating /etc/hosts for 127.0.1.1 entry..."
  if grep -q "^127\.0\.1\.1" /etc/hosts; then
    sudo sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts
  else
    echo -e "\n127.0.1.1\t$NEW_HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
  fi

  # Apply immediately
  sudo hostname -F /etc/hostname
fi

echo ""
echo "Change completed. Current hostname: $(hostname)"
echo ""

if [ "$MODE" != "--temp" ] && [ "$MODE" != "temp" ]; then
  echo "Permanent change written to files. Reboot for full effect."
  echo "To apply immediately:"
  echo "  source /etc/profile   or open a new terminal"
  echo "  or reboot: sudo reboot"
else
  echo "This is a temporary change. It will revert after reboot."
fi

echo "Done."

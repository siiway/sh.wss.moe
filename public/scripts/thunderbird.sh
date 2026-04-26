#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/thunderbird.help

echo "=== Thunderbird from Mozilla PPA ==="
echo "Help: curl https://sh.wss.moe/thunderbird.help"
echo "Contact: https://wyf9.top/c"
echo ""

if ! command -v apt >/dev/null || ! grep -qE "(ID_LIKE.*debian|ID.*(debian|ubuntu))" /etc/os-release 2>/dev/null; then
  echo "This script requires a Debian-based system (Ubuntu, Debian, etc.)."
  echo "For other systems, please refer to the official Thunderbird installation guide: https://www.thunderbird.net/"
  exit 1
fi

PPA_LIST="/etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -cs).list"
PREF_FILE="/etc/apt/preferences.d/mozillateamppa.pref"

if [[ -f "$PPA_LIST" && -f "$PREF_FILE" ]]; then
  echo "Mozilla PPA already configured, skipping setup."
else
  sudo add-apt-repository ppa:mozillateam/ppa -y

  cat <<EOF | sudo tee "$PREF_FILE" >/dev/null
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 32767

Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 32767
EOF
fi

sudo apt update

sudo apt install -y thunderbird

GNOME_SUPPORT=${1:-""}
if [[ "$GNOME_SUPPORT" != "--no-gnome" ]]; then
  sudo apt install -y thunderbird-gnome-support || true
  echo "Installed GNOME integration (if available)."
else
  echo "Skipped GNOME support."
fi

echo "Done."

#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/thunderbird.help

echo "=== Thunderbird from Mozilla PPA ==="
echo "Help: curl sh.wss.moe/thunderbird.help"
echo "Contact: https://wyf9.top/c"
echo ""

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

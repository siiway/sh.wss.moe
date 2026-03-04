#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/flatpak.help

echo "=== Flatpak + Flathub Setup ==="
echo "Help: curl https://sh.wss.moe/flatpak.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Done."

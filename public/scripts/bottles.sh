#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/bottles.help

echo "=== Bottles Flatpak Installation & Permissions ==="
echo "Help: curl https://sh.wss.moe/bottles.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v flatpak >/dev/null || { echo "Missing flatpak. Please install it first (e.g., sudo apt install flatpak)."; exit 1; }

echo "Installing Bottles from Flathub (if not already installed)..."
flatpak install -y flathub com.usebottles.bottles

echo ""
echo "Applying required permissions overrides..."

# Desktop entries support
flatpak override --user com.usebottles.bottles --filesystem=xdg-data/applications

# Steam integration (native Steam)
flatpak override --user com.usebottles.bottles --filesystem=~/.local/share/Steam

# Steam Flatpak data path (if Steam is also Flatpak)
flatpak override --user com.usebottles.bottles --filesystem=~/.var/app/com.valvesoftware.Steam/data/Steam

# Optional: full home access (uncomment if needed for other files)
# flatpak override --user com.usebottles.bottles --filesystem=home

echo ""
echo "Done. Bottles should now work properly with desktop shortcuts and Steam integration."
echo "Launch Bottles: flatpak run com.usebottles.bottles"
echo "If issues persist, try Flatseal GUI to manage permissions."

echo "Done."

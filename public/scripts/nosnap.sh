#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/nosnap.help

echo "=== Remove and Block Snapd ==="
echo "Help: curl https://sh.wss.moe/nosnap.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt purge snapd -y
sudo apt autoremove -y

cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref >/dev/null
Package: snapd
Pin: release a=*
Pin-Priority: -10

Package: *snap*
Pin: release a=*
Pin-Priority: -10
EOF

echo "Done."

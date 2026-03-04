#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/fuse.help

echo "=== AppImage FUSE Support ==="
echo "Help: curl sh.wss.moe/fuse.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt update
sudo apt install -y libfuse2t64

echo "Done."

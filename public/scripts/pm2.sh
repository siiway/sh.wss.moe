#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/pm2.help

echo "=== PM2 Global Install ==="
echo "Help: curl sh.wss.moe/pm2.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v pnpm >/dev/null || { echo "Missing pnpm."; exit 1; }

pnpm install -g pm2

echo "Done."
echo "For startup: pm2 startup   (may need sudo)"

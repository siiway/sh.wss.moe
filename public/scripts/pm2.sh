#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/pm2.help

echo "=== PM2 User Install ==="
echo "Help: curl https://sh.wss.moe/pm2.help"
echo "Contact: https://wyf9.top/c"
echo ""

# Try package managers in order: bun, pnpm, npm
if command -v bun >/dev/null; then
  echo "Using bun to install PM2..."
  bun install -g pm2
elif command -v pnpm >/dev/null; then
  echo "Using pnpm to install PM2..."
  pnpm install -g pm2
elif command -v npm >/dev/null; then
  echo "Using npm to install PM2..."
  npm install -g pm2
else
  echo "Missing bun, pnpm, or npm. Please install one of them first."
  exit 1
fi

echo "Done."
echo 'For startup:
pm2 startup
(may need sudo)'

#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/pnpm.help

echo "=== pnpm Global Install ==="
echo "Help: curl sh.wss.moe/pnpm.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v npm >/dev/null || { echo "Missing npm (install node first)."; exit 1; }

npm install -g pnpm

MIRROR=${1:-""}
if [[ "$MIRROR" != "--no-mirror" ]]; then
  pnpm config set registry https://registry.npmmirror.com
  echo "Set npmmirror registry (China acceleration)."
else
  echo "Skipped registry mirror."
fi

echo "Done."

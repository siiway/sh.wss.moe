#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/node.help

echo "=== Node.js via nvm ==="
echo "Help: curl sh.wss.moe/node.help"
echo "Contact: https://wyf9.top/c"
echo ""

if ! command -v apt >/dev/null || ! grep -qE "(ID_LIKE.*debian|ID.*(debian|ubuntu))" /etc/os-release 2>/dev/null; then
  echo "This script requires a Debian-based system (Ubuntu, Debian, etc.) for libatomic1 installation."
  echo "For other systems, please refer to the official Node.js installation guide: https://nodejs.org/"
  echo "NVM official script: https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"
  exit 1
fi

VERSION=${1:-25}
echo "Node version: $VERSION"

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

bash <(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
else
  echo "nvm install finished but $NVM_DIR/nvm.sh was not found."
  exit 1
fi

nvm install "$VERSION"
nvm use "$VERSION"
nvm alias default "$VERSION"

sudo apt install libatomic1 -y || true

echo "Run this to apply environment in your current shell:"
echo "source ~/.bashrc"
echo "Done."

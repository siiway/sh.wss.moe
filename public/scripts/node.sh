#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/node.help

echo "=== Node.js via nvm ==="
echo "Help: curl https://sh.wss.moe/node.help"
echo "Contact: https://wyf9.top/c"
echo ""

VERSION=${1:-25}

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

curl https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install "$VERSION"
nvm use "$VERSION"
nvm alias default "$VERSION"

sudo apt install libatomic1 -y || true

echo "Done."
echo "Restart terminal or source profile"

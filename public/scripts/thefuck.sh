#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/thefuck.help

echo "=== thefuck Installation ==="
echo "Help: curl sh.wss.moe/thefuck.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt install -y thefuck

if ! grep -q "thefuck --alias" ~/.bashrc; then
  echo 'eval $(thefuck --alias)' >> ~/.bashrc
fi

echo "Done."
echo "Run: source ~/.bashrc"

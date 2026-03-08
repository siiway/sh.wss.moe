#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/uv.help

echo "=== uv Installation ==="
echo "Help: curl https://sh.wss.moe/uv.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

PYTHON_VERSION="${1:-}"

echo "Installing uv..."

curl -LsSf https://astral.sh/uv/install.sh | sh

export PATH="$HOME/.local/bin:$PATH"

if [ -n "$PYTHON_VERSION" ]; then
  echo "Installing Python $PYTHON_VERSION..."
  uv python install "$PYTHON_VERSION"
else
  echo "Python installation skipped (execute this if you want: uv python install 3.13)"
fi

echo ""
echo "Done."
echo "uv is now available. Restart terminal or source your profile if PATH not updated."
if [ -n "$PYTHON_VERSION" ]; then
  echo "Python $PYTHON_VERSION has been installed via uv."
fi

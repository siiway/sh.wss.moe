#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/uv.help

echo "=== uv Installation ==="
echo "Help: curl sh.wss.moe/uv.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

PYTHON_VERSION="${1:-}"

echo "Installing uv..."

curl -LsSf https://astral.sh/uv/install.sh | sh

UV_BIN="$HOME/.local/bin/uv"

if [ -n "$PYTHON_VERSION" ]; then
  echo "Installing Python $PYTHON_VERSION..."
  "$UV_BIN" python install "$PYTHON_VERSION"
else
  echo "Python installation skipped (execute this if you want: uv python install 3.13)"
fi

echo "Run this to apply environment in your current shell:"
echo "source ~/.bashrc"
echo ""
echo "Done."

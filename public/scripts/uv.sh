#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/uv.help

echo "=== uv + Python Installation ==="
echo "Help: curl https://sh.wss.moe/uv.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

PYTHON_VERSION=${1:-3.13}

echo "Installing uv and Python ${PYTHON_VERSION}..."

curl -LsSf https://astral.sh/uv/install.sh | sh

export PATH="$HOME/.local/bin:$PATH"

uv python install "${PYTHON_VERSION}"

echo "Done."
echo "Restart terminal or source your profile if PATH not updated"

#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/thefuck.help

echo "=== thefuck Installation ==="
echo "Help: curl https://sh.wss.moe/thefuck.help"
echo "Contact: https://wyf9.top/c"
echo ""

if ! command -v apt >/dev/null || ! grep -qE "(ID_LIKE.*debian|ID.*(debian|ubuntu))" /etc/os-release 2>/dev/null; then
  echo "This script requires a Debian-based system (Ubuntu, Debian, etc.)."
  echo "For other systems, please refer to the official thefuck installation guide: https://github.com/nvbn/thefuck#installation"
  exit 1
fi

sudo apt install -y thefuck

BASHRC="$HOME/.bashrc"
WSSMOE_DIR="$HOME/.wssmoe"
ENV_FILE="$WSSMOE_DIR/thefuck.env"
SOURCE_LINE='[ -f "$HOME/.wssmoe/thefuck.env" ] && . "$HOME/.wssmoe/thefuck.env"'

mkdir -p "$WSSMOE_DIR"
cat > "$ENV_FILE" <<'EOF'
eval "$(thefuck --alias)"
EOF

touch "$BASHRC"
if ! grep -Fqx "$SOURCE_LINE" "$BASHRC"; then
  echo "$SOURCE_LINE" >> "$BASHRC"
fi

eval "$(thefuck --alias)"

echo "Done."

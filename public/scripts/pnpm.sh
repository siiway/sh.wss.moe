#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/pnpm.help

echo "=== pnpm User Install ==="
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

pnpm setup

if [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
elif [ -d "$HOME/.pnpm" ]; then
  export PNPM_HOME="$HOME/.pnpm"
fi

if [ -n "${PNPM_HOME:-}" ]; then
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
  echo "Applied PNPM_HOME for current session: $PNPM_HOME"
fi

echo "Done."

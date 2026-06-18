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

MIRROR=1
VERSION=25

for arg in "$@"; do
case "$arg" in
--mirror) MIRROR=1 ;;
--no-mirror) MIRROR=0 ;;
*) VERSION="$arg" ;;
esac
done

echo "Node version: $VERSION"
echo "Mirror: $([[ $MIRROR -eq 1 ]] && echo on || echo off)"
echo ""

command -v curl >/dev/null || { echo "Missing curl."; exit 1; }

NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"

INSTALL_SH=""
if [[ $MIRROR -eq 1 ]]; then
  echo "Downloading nvm install script (mirror)..."
  INSTALL_SH="$(curl -fsSL --retry 3 --retry-delay 2 "https://gh.1s.fan/${NVM_INSTALL_URL}")" || INSTALL_SH=""
fi
if [[ -z "$INSTALL_SH" ]]; then
  echo "Downloading nvm install script..."
  INSTALL_SH="$(curl -fsSL --retry 3 --retry-delay 2 "$NVM_INSTALL_URL")" || { echo "ERROR: Failed to download nvm install script."; exit 1; }
fi

if [[ $MIRROR -eq 1 ]]; then
  # Inject reverse proxy in front of github clone/raw URLs (gh.1s.fan supports the prefix style)
  INSTALL_SH="${INSTALL_SH//https:\/\/github.com\//https:\/\/gh.1s.fan\/https:\/\/github.com\/}"
  INSTALL_SH="${INSTALL_SH//https:\/\/raw.githubusercontent.com\//https:\/\/gh.1s.fan\/https:\/\/raw.githubusercontent.com\/}"
fi

bash -c "$INSTALL_SH"

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

#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/mmproxy.help

echo "=== mmproxy Installation ==="
echo "Help: curl https://sh.wss.moe/mmproxy.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v git >/dev/null || { echo "Missing git, please install it first."; exit 1; }
command -v make >/dev/null || { echo "Missing make, please install it first."; exit 1; }

if command -v clang >/dev/null; then
  CC=clang
elif command -v gcc >/dev/null; then
  CC=gcc
else
  if command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y git build-essential clang autoconf automake libtool pkg-config
  fi
  if command -v clang >/dev/null; then
    CC=clang
  elif command -v gcc >/dev/null; then
    CC=gcc
  else
    echo "Missing C compiler (clang or gcc)."
    exit 1
  fi
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"
git clone --depth 1 https://github.com/cloudflare/mmproxy.git
cd mmproxy
git submodule update --init --recursive --depth 1
CC="$CC" make

sudo install -m 755 mmproxy /usr/local/bin/mmproxy

echo "Done."
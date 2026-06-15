#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/mmproxy.help

echo "=== mmproxy Installation ==="
echo "Help: curl sh.wss.moe/mmproxy.help"
echo "Contact: https://wyf9.top/c"
echo ""

MIRROR=1
for arg in "$@"; do
case "$arg" in
--mirror) MIRROR=1 ;;
--no-mirror) MIRROR=0 ;;
esac
done

echo "Mirror: $([[ $MIRROR -eq 1 ]] && echo on || echo off)"

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"

download() {
local url="$1"
local out="$2"
local desc="$3"
curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out" 2>/dev/null && return 0
return 1
}

URL="https://github.com/SiiWay/mmproxy/releases/latest/download/mmproxy"
MIRROR_URL="https://release-assets.gh.1s.fan/SiiWay/mmproxy/releases/latest/download/mmproxy"

echo "Downloading mmproxy..."

if ! download "$URL" mmproxy "mmproxy"; then
if [[ $MIRROR -eq 1 ]]; then
echo "Official failed, trying mirror..."
if ! download "$MIRROR_URL" mmproxy "mmproxy (mirror)"; then
echo "ERROR: Failed to download mmproxy."
exit 1
fi
else
echo "ERROR: Failed to download mmproxy."
exit 1
fi
fi

sudo mv mmproxy /usr/local/bin/mmproxy
sudo chmod +x /usr/local/bin/mmproxy

echo "Done."

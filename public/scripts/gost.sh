#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/gost.help

echo "=== gost Installer (Linux) ==="
echo "Help: curl sh.wss.moe/gost.help"
echo "Contact: https://wyf9.top/c"
echo ""

MIRROR=1
ARCH_MODE="auto"
VERIFY_MODE="--verify"

for arg in "$@"; do
case "$arg" in
--mirror) MIRROR=1 ;;
--no-mirror) MIRROR=0 ;;
--verify|--no-verify) VERIFY_MODE="$arg" ;;
--*) echo "Unknown option: $arg"; exit 1 ;;
*) ARCH_MODE="$arg" ;;
esac
done

echo "Mirror: $([[ $MIRROR -eq 1 ]] && echo on || echo off)"
echo "Arch mode: $ARCH_MODE"
echo "Verify mode: $VERIFY_MODE"

if [[ "$(uname -s)" != "Linux" ]]; then
echo "This script supports Linux only."
exit 1
fi

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }
command -v tar >/dev/null || { echo "Missing tar, please install it first."; exit 1; }
command -v sha256sum >/dev/null || { echo "Missing sha256sum, please install it first."; exit 1; }
command -v sudo >/dev/null || { echo "Missing sudo, please install it first."; exit 1; }
command -v uname >/dev/null || { echo "Missing uname, please install it first."; exit 1; }

if [[ "$ARCH_MODE" == "auto" ]]; then
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
x86_64) ASSET_ARCH="amd64" ;;
i386|i486|i586|i686) ASSET_ARCH="386" ;;
aarch64|arm64) ASSET_ARCH="arm64" ;;
armv7l|armv7*) ASSET_ARCH="armv7" ;;
armv6l|armv6*) ASSET_ARCH="armv6" ;;
armv5l|armv5*) ASSET_ARCH="armv5" ;;
riscv64) ASSET_ARCH="riscv64" ;;
s390x) ASSET_ARCH="s390x" ;;
loongarch64) ASSET_ARCH="loong64" ;;
mips64el) ASSET_ARCH="mips64le_hardfloat" ;;
mips64) ASSET_ARCH="mips64_hardfloat" ;;
mipsel) ASSET_ARCH="mipsle_hardfloat" ;;
mips) ASSET_ARCH="mips_hardfloat" ;;
*)
echo "Unsupported architecture from uname -m: $ARCH_RAW"
echo "Use manual arch mode, for example:"
echo "sudo bash <(curl -fsSL sh.wss.moe/gost) amd64"
exit 1
;;
esac
else
ASSET_ARCH="$ARCH_MODE"
fi

echo "Resolved asset arch: $ASSET_ARCH"

fetch_json() {
local url="$1"
local mirror_url="$2"
local desc="$3"
local max_retries=3
local retry=0
local output=""
while [[ $retry -lt $max_retries ]]; do
output="$(curl -fsSL "$url" 2>/dev/null)" && break
retry=$((retry + 1))
if [[ $retry -lt $max_retries ]]; then
echo "Retry $retry/$max_retries: $desc ..."
sleep 2
fi
done
if [[ -n "$output" ]]; then
printf '%s\n' "$output"
return 0
fi
if [[ $MIRROR -eq 1 && -n "$mirror_url" ]]; then
echo "Official API failed, trying mirror..."
retry=0
while [[ $retry -lt $max_retries ]]; do
output="$(curl -fsSL "$mirror_url" 2>/dev/null)" && break
retry=$((retry + 1))
if [[ $retry -lt $max_retries ]]; then
echo "Retry $retry/$max_retries: $desc (mirror) ..."
sleep 2
fi
done
if [[ -n "$output" ]]; then
printf '%s\n' "$output"
return 0
fi
fi
echo "ERROR: Failed to fetch $desc after all attempts."
exit 1
}

LATEST_JSON="$(fetch_json \
"https://api.github.com/repos/go-gost/gost/releases/latest" \
"https://api.gh.1s.fan/repos/go-gost/gost/releases/latest" \
"latest release info")"
TAG="$(printf '%s\n' "$LATEST_JSON" | awk -F'"' '/"tag_name":/ { print $4; exit }')"

if [[ -z "$TAG" || "${TAG#v}" == "$TAG" ]]; then
echo "ERROR: Failed to parse latest stable tag from GitHub API response."
exit 1
fi

VERSION="${TAG#v}"
FILE="gost_${VERSION}_linux_${ASSET_ARCH}.tar.gz"
RELEASE_JSON="$(fetch_json \
"https://api.github.com/repos/go-gost/gost/releases/tags/${TAG}" \
"https://api.gh.1s.fan/repos/go-gost/gost/releases/tags/${TAG}" \
"release tag $TAG")"

URL="$(printf '%s\n' "$RELEASE_JSON" | awk -v file="$FILE" -F'"' '/"browser_download_url":/ { if (index($4, file) > 0) { print $4; exit } }')"
CHECKSUMS_URL="$(printf '%s\n' "$RELEASE_JSON" | awk -F'"' '/"browser_download_url":/ { if (index($4, "/checksums.txt") > 0) { print $4; exit } }')"

if [[ -z "$URL" ]]; then
echo "No matching asset found for $FILE in $TAG."
exit 1
fi

if [[ "$VERIFY_MODE" == "--verify" && -z "$CHECKSUMS_URL" ]]; then
echo "No checksums.txt found for $TAG, cannot verify."
exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Latest stable tag: $TAG"
echo "Downloading: $URL"

download() {
local url="$1"
local out="$2"
local desc="$3"
curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out" && return 0
return 1
}

if ! download "$URL" "$TMP_DIR/$FILE" "gost binary"; then
if [[ $MIRROR -eq 1 ]]; then
MIRROR_URL="$(echo "$URL" | sed 's|https://github\.com/|https://release-assets.gh.1s.fan/|')"
echo "Official download failed, trying mirror: $MIRROR_URL"
if ! download "$MIRROR_URL" "$TMP_DIR/$FILE" "gost binary (mirror)"; then
echo "ERROR: Failed to download gost binary."
exit 1
fi
else
echo "ERROR: Failed to download gost binary."
exit 1
fi
fi

if [[ "$VERIFY_MODE" == "--verify" ]]; then
if ! download "$CHECKSUMS_URL" "$TMP_DIR/checksums.txt" "checksums"; then
if [[ $MIRROR -eq 1 ]]; then
MIRROR_CHECKSUMS="$(echo "$CHECKSUMS_URL" | sed 's|https://github\.com/|https://release-assets.gh.1s.fan/|')"
echo "Official checksums failed, trying mirror..."
if ! download "$MIRROR_CHECKSUMS" "$TMP_DIR/checksums.txt" "checksums (mirror)"; then
echo "ERROR: Failed to download checksums."
exit 1
fi
else
echo "ERROR: Failed to download checksums."
exit 1
fi
fi
EXPECTED_SHA256="$(awk -v file="$FILE" '$2 == file { print $1; exit }' "$TMP_DIR/checksums.txt")"
if [[ -z "$EXPECTED_SHA256" ]]; then
echo "Checksum entry not found for $FILE."
exit 1
fi
echo "${EXPECTED_SHA256}  $TMP_DIR/$FILE" | sha256sum -c -
else
echo "Checksum verification skipped."
fi

sudo tar -xzf "$TMP_DIR/$FILE" -C /usr/local/bin gost
sudo chmod +x /usr/local/bin/gost

echo "Done."

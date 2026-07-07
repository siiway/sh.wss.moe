#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/mihomo.help

echo "=== mihomo Installer (Linux) ==="
echo "Help: curl sh.wss.moe/mihomo.help"
echo "Contact: https://wyf9.top/c"
echo ""

MIRROR=1
ARCH_MODE="auto"
FLAVOR_MODE="compatible"
VERSION_TAG=""

while [[ $# -gt 0 ]]; do
case "$1" in
--mirror) MIRROR=1 ;;
--no-mirror) MIRROR=0 ;;
--compatible) FLAVOR_MODE="compatible" ;;
--alpha) FLAVOR_MODE="alpha" ;;
--version)
if [[ $# -lt 2 ]]; then
echo "Missing value for --version"
exit 1
fi
VERSION_TAG="$2"
shift
;;
--*) echo "Unknown option: $1"; exit 1 ;;
*) ARCH_MODE="$1" ;;
esac
shift
done

echo "Mirror: $([[ $MIRROR -eq 1 ]] && echo on || echo off)"
echo "Arch mode: $ARCH_MODE"
echo "Flavor: $FLAVOR_MODE"
echo "Version tag: ${VERSION_TAG:-latest stable}"

if [[ "$(uname -s)" != "Linux" ]]; then
echo "This script supports Linux only."
exit 1
fi

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }
command -v gzip >/dev/null || { echo "Missing gzip, please install it first."; exit 1; }
command -v mkdir >/dev/null || { echo "Missing mkdir, please install it first."; exit 1; }
command -v install >/dev/null || { echo "Missing install, please install it first."; exit 1; }
command -v mktemp >/dev/null || { echo "Missing mktemp, please install it first."; exit 1; }
command -v sudo >/dev/null || { echo "Missing sudo, please install it first."; exit 1; }
command -v uname >/dev/null || { echo "Missing uname, please install it first."; exit 1; }

detect_pkg() {
if command -v apt-get >/dev/null 2>&1; then
echo "deb"
elif command -v dnf >/dev/null 2>&1; then
echo "rpm"
elif command -v yum >/dev/null 2>&1; then
echo "rpm"
elif command -v pacman >/dev/null 2>&1; then
echo "pkg.tar.zst"
else
echo "gz"
fi
}

if [[ "$ARCH_MODE" == "auto" ]]; then
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
x86_64) ASSET_ARCH="amd64" ;;
i386|i486|i586|i686) ASSET_ARCH="386" ;;
aarch64|arm64) ASSET_ARCH="arm64-v8" ;;
armv7l|armv7*) ASSET_ARCH="armv7" ;;
*)
echo "Unsupported architecture from uname -m: $ARCH_RAW"
echo "Use manual arch mode, for example:"
echo "sudo bash <(curl -fsSL sh.wss.moe/mihomo) amd64"
exit 1
;;
esac
else
ASSET_ARCH="$ARCH_MODE"
fi

echo "Resolved asset arch: $ASSET_ARCH"

PKG_TYPE="$(detect_pkg)"
echo "Package type: $PKG_TYPE"

RELEASE_TAG=""
VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/latest/download/version.txt"

if [[ -n "$VERSION_TAG" ]]; then
RELEASE_TAG="$VERSION_TAG"
VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/version.txt"
elif [[ "$FLAVOR_MODE" == "alpha" ]]; then
RELEASE_TAG="Prerelease-Alpha"
VERSION_URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/version.txt"
fi

download() {
local url="$1"
local out="$2"
local desc="$3"
curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out" && return 0
echo "ERROR: Failed to download ${desc}."
return 1
}

mirror_url() {
local url="$1"
printf '%s\n' "${url/https:\/\/github.com\//https:\/\/gh.1s.fan\/}"
}

VERSION=""
if VERSION="$(curl -fsSL --retry 3 --retry-delay 2 "$VERSION_URL" 2>/dev/null)"; then
:
elif [[ $MIRROR -eq 1 ]]; then
echo "Official version.txt failed, trying mirror..."
VERSION="$(curl -fsSL --retry 3 --retry-delay 2 "$(mirror_url "$VERSION_URL")" 2>/dev/null)" || true
fi

if [[ -z "$VERSION" ]]; then
echo "ERROR: Failed to fetch version.txt."
exit 1
fi

VERSION="${VERSION//$'\r'/}"
VERSION="${VERSION//$'\n'/}"

if [[ -z "$VERSION" ]]; then
echo "ERROR: version.txt is empty."
exit 1
fi

echo "Version: $VERSION"

if [[ -z "$RELEASE_TAG" ]]; then
RELEASE_TAG="$VERSION"
fi

echo "Release tag: $RELEASE_TAG"

FILE="mihomo-linux-${ASSET_ARCH}-${FLAVOR_MODE}-${VERSION}.gz"
URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/${FILE}"

if [[ "$PKG_TYPE" == "deb" ]]; then
FILE="mihomo-linux-${ASSET_ARCH}-${FLAVOR_MODE}-${VERSION}.deb"
URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/${FILE}"
elif [[ "$PKG_TYPE" == "rpm" ]]; then
FILE="mihomo-linux-${ASSET_ARCH}-${FLAVOR_MODE}-${VERSION}.rpm"
URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/${FILE}"
elif [[ "$PKG_TYPE" == "pkg.tar.zst" ]]; then
FILE="mihomo-linux-${ASSET_ARCH}-${FLAVOR_MODE}-${VERSION}.pkg.tar.zst"
URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/${FILE}"
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading: $FILE"
if ! download "$URL" "$TMP_DIR/$FILE" "mihomo archive"; then
if [[ "$PKG_TYPE" != "gz" ]]; then
echo "Package asset not available, falling back to raw binary..."
FILE="mihomo-linux-${ASSET_ARCH}-${FLAVOR_MODE}-${VERSION}.gz"
URL="https://github.com/MetaCubeX/mihomo/releases/download/${RELEASE_TAG}/${FILE}"
if ! download "$URL" "$TMP_DIR/$FILE" "mihomo archive"; then
if [[ $MIRROR -eq 1 ]]; then
MIRROR_URL="$(mirror_url "$URL")"
echo "Official download failed, trying mirror..."
download "$MIRROR_URL" "$TMP_DIR/$FILE" "mihomo archive (mirror)" || exit 1
else
exit 1
fi
fi
else
if [[ $MIRROR -eq 1 ]]; then
MIRROR_URL="$(mirror_url "$URL")"
echo "Official download failed, trying mirror..."
download "$MIRROR_URL" "$TMP_DIR/$FILE" "mihomo archive (mirror)" || exit 1
else
exit 1
fi
fi
fi

SERVICE_WRITTEN=0

case "$FILE" in
*.deb)
sudo dpkg -i "$TMP_DIR/$FILE"
;;
*.rpm)
if command -v dnf >/dev/null 2>&1; then
sudo dnf install -y "$TMP_DIR/$FILE"
else
sudo yum install -y "$TMP_DIR/$FILE"
fi
;;
*.pkg.tar.zst)
sudo pacman -U --noconfirm "$TMP_DIR/$FILE"
;;
*.gz)
gzip -dc "$TMP_DIR/$FILE" > "$TMP_DIR/mihomo"
chmod +x "$TMP_DIR/mihomo"
sudo install -m 0755 "$TMP_DIR/mihomo" /usr/local/bin/mihomo
if [[ -d /usr/lib/systemd/system ]]; then
sudo tee /usr/lib/systemd/system/mihomo.service >/dev/null <<'EOF'
[Unit]
Description=mihomo Daemon, Another Clash Kernel.
Documentation=https://wiki.metacubex.one
After=network.target nss-lookup.target network-online.target

[Service]
Type=simple
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_TIME CAP_SYS_PTRACE CAP_DAC_READ_SEARCH CAP_DAC_OVERRIDE
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
sudo mkdir -p /etc/mihomo
sudo systemctl daemon-reload || true
SERVICE_WRITTEN=1
fi
;;
esac

if [[ "$FILE" == *.gz ]]; then
echo "Installed to /usr/local/bin/mihomo"
else
echo "Installed package: $FILE"
fi
if [[ $SERVICE_WRITTEN -eq 1 ]]; then
echo "Installed systemd service to /usr/lib/systemd/system/mihomo.service"
fi
echo "Done."

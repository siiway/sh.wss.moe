#!/usr/bin/env bash
set -euo pipefail
# Help: curl sh.wss.moe/dae.help

echo "=== dae Installer ==="
echo "Help: curl sh.wss.moe/dae.help"
echo "Contact: https://wyf9.top/c"
echo ""

MIRROR=1
ARCH_MODE="auto"

for arg in "$@"; do
case "$arg" in
--mirror) MIRROR=1 ;;
--no-mirror) MIRROR=0 ;;
*) ARCH_MODE="$arg" ;;
esac
done

echo "Mirror: $([[ $MIRROR -eq 1 ]] && echo on || echo off)"
echo "Arch mode: ${ARCH_MODE}"

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }
command -v tar >/dev/null || { echo "Missing tar, please install it first."; exit 1; }
command -v sudo >/dev/null || { echo "Missing sudo, please install it first."; exit 1; }

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
echo "tar.xz"
fi
}

detect_arch() {
local arch_raw
arch_raw="$(uname -m)"
case "$arch_raw" in
x86_64)
if grep -q avx2 /proc/cpuinfo 2>/dev/null; then
echo "x86_64_v3_avx2"
elif grep -q sse4_2 /proc/cpuinfo 2>/dev/null; then
echo "x86_64_v2_sse"
else
echo "x86_64"
fi
;;
i386|i486|i586|i686)
echo "x86_32"
;;
aarch64|arm64)
echo "arm64"
;;
armv7l|armv7*)
echo "armv7"
;;
armv6l|armv6*)
echo "armv6"
;;
armv5l|armv5*)
echo "armv5"
;;
riscv64)
echo "riscv64"
;;
s390x)
echo "s390x"
;;
loongarch64)
echo "loongarch64"
;;
mips)
echo "mips32"
;;
mipsel)
echo "mips32le"
;;
mips64)
echo "mips64"
;;
mips64el)
echo "mips64le"
;;
ppc64)
echo "powerpc64"
;;
ppc64le)
echo "powerpc64le"
;;
*)
echo ""
;;
esac
}

PKG_TYPE="$(detect_pkg)"
echo "Package type: ${PKG_TYPE}"

if [[ "$ARCH_MODE" == "auto" ]]; then
DAE_ARCH="$(detect_arch)"
else
DAE_ARCH="$ARCH_MODE"
fi

if [[ -z "$DAE_ARCH" ]]; then
echo "Unsupported architecture: $(uname -m)"
echo "Use manual arch mode: sudo bash <(curl -fsSL sh.wss.moe/dae) arm64"
exit 1
fi

echo "Arch: ${DAE_ARCH}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

dl() {
local url="$1"
local out="$2"
local desc="$3"
curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out" && return 0
return 1
}

ASSET_NAME=""
for ext in "${PKG_TYPE}" "tar.xz"; do
file="dae-linux-${DAE_ARCH}.${ext}"
url="https://github.com/daeuniverse/dae/releases/latest/download/${file}"
mirror_url="https://gh.1s.fan/daeuniverse/dae/releases/latest/download/${file}"

echo "Trying: ${file} ..."
if dl "$url" "$TMP_DIR/$file" "$file"; then
ASSET_NAME="$file"
break
fi
if [[ $MIRROR -eq 1 ]]; then
echo "Official failed, trying mirror..."
if dl "$mirror_url" "$TMP_DIR/$file" "$file (mirror)"; then
ASSET_NAME="$file"
break
fi
fi
done

if [[ -z "$ASSET_NAME" ]]; then
echo "ERROR: Failed to download dae for ${DAE_ARCH}."
echo "Available archs: x86_64[_v2_sse|_v3_avx2] x86_32 arm64 armv7 armv6 armv5 riscv64 loongarch64 mips32[le] mips64[le] powerpc64[le] s390x"
exit 1
fi

echo "Installing ${ASSET_NAME}..."
case "$ASSET_NAME" in
*.deb)
sudo dpkg -i "$TMP_DIR/$ASSET_NAME"
;;
*.rpm)
if command -v dnf >/dev/null 2>&1; then
sudo dnf install -y "$TMP_DIR/$ASSET_NAME"
else
sudo yum install -y "$TMP_DIR/$ASSET_NAME"
fi
;;
*.pkg.tar.zst)
sudo pacman -U --noconfirm "$TMP_DIR/$ASSET_NAME"
;;
*.tar.xz)
sudo tar -xJf "$TMP_DIR/$ASSET_NAME" -C /usr/local/bin dae
sudo chmod +x /usr/local/bin/dae
echo "Installed dae to /usr/local/bin/dae"
;;
esac

echo "Done."

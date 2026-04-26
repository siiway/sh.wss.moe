#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/gost.help

echo "=== gost Installer (Linux) ==="
echo "Help: curl https://sh.wss.moe/gost.help"
echo "Contact: https://wyf9.top/c"
echo ""

ARCH_MODE=${1:-auto}
VERIFY_MODE=${2:---verify}

if [[ "$ARCH_MODE" == "--no-verify" || "$ARCH_MODE" == "--verify" ]]; then
  VERIFY_MODE="$ARCH_MODE"
  ARCH_MODE="auto"
fi

echo "Arch mode: $ARCH_MODE"
echo "Verify mode: $VERIFY_MODE"

if [[ "$VERIFY_MODE" != "--verify" && "$VERIFY_MODE" != "--no-verify" ]]; then
  echo "Unsupported option: $VERIFY_MODE"
  exit 1
fi

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
    x86_64)
      ASSET_ARCH="amd64"
      ;;
    i386|i486|i586|i686)
      ASSET_ARCH="386"
      ;;
    aarch64|arm64)
      ASSET_ARCH="arm64"
      ;;
    armv7l|armv7*)
      ASSET_ARCH="armv7"
      ;;
    armv6l|armv6*)
      ASSET_ARCH="armv6"
      ;;
    armv5l|armv5*)
      ASSET_ARCH="armv5"
      ;;
    riscv64)
      ASSET_ARCH="riscv64"
      ;;
    s390x)
      ASSET_ARCH="s390x"
      ;;
    loongarch64)
      ASSET_ARCH="loong64"
      ;;
    mips64el)
      ASSET_ARCH="mips64le_hardfloat"
      ;;
    mips64)
      ASSET_ARCH="mips64_hardfloat"
      ;;
    mipsel)
      ASSET_ARCH="mipsle_hardfloat"
      ;;
    mips)
      ASSET_ARCH="mips_hardfloat"
      ;;
    *)
      echo "Unsupported architecture from uname -m: $ARCH_RAW"
      echo "Use manual arch mode, for example:"
      echo "sudo bash <(curl -fsS https://sh.wss.moe/gost) amd64"
      exit 1
      ;;
  esac
else
  ASSET_ARCH="$ARCH_MODE"
fi

echo "Resolved asset arch: $ASSET_ARCH"

LATEST_API_URL="https://api.github.com/repos/go-gost/gost/releases/latest"
LATEST_JSON="$(curl -fsSL "$LATEST_API_URL")"
TAG="$(printf '%s\n' "$LATEST_JSON" | awk -F'"' '/"tag_name":/ { print $4; exit }')"

if [[ -z "$TAG" || "${TAG#v}" == "$TAG" ]]; then
  echo "Failed to get latest stable tag from GitHub API."
  exit 1
fi

VERSION="${TAG#v}"
FILE="gost_${VERSION}_linux_${ASSET_ARCH}.tar.gz"
RELEASE_API_URL="https://api.github.com/repos/go-gost/gost/releases/tags/${TAG}"
RELEASE_JSON="$(curl -fsSL "$RELEASE_API_URL")"

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
curl -fsSL "$URL" -o "$TMP_DIR/$FILE"

if [[ "$VERIFY_MODE" == "--verify" ]]; then
  curl -fsSL "$CHECKSUMS_URL" -o "$TMP_DIR/checksums.txt"
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

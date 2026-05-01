#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/v.help

echo "=== v.sh installer ==="
echo "Help: curl https://sh.wss.moe/v.help"
echo "Ref: https://wyf9.top/p/virtual-sink"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }
command -v pactl >/dev/null || { echo "Missing pactl, please install it first."; exit 1; }

install_dir="${1:-/usr/local/bin}"
echo "Install dir: ${install_dir}"
mkdir -p "${install_dir}"

install_path="${install_dir}/v.sh"

curl -fsS https://gist.githubusercontent.com/wyf9/ff12240ae023da0a068f2466968e3681/raw/v.sh > "${install_path}"

chmod +x "${install_path}"
echo "Installed v.sh to ${install_path}."
echo "Run:"
echo "- ${install_path} sink NAME"
echo "- ${install_path} mic NAME"
echo "- ${install_path} del NAME"
echo "- ${install_path} rm NAME"
echo "Done."

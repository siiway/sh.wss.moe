#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/bbr.help

echo "=== Enable TCP BBR with Auto Buffer Tuning ==="
echo "Help: curl https://sh.wss.moe/bbr.help"
echo "Contact: https://wyf9.top/c"
echo ""

BBR_ONLY=0

# parse args
for arg in "$@"; do
  case "$arg" in
    --bbr-only) BBR_ONLY=1 ;;
    --help|-h)
      echo "Usage: curl https://sh.wss.moe/bbr | sudo bash [options]"
      echo "Options:"
      echo "  --bbr-only     Only enable core BBR (fq + bbr), skip buffer and other tunings"
      echo "  --help         Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $arg (use --help for usage)"; exit 1 ;;
  esac
done

SYSCTL_FILE="/etc/sysctl.conf"

# get total mem (mb, /proc/meminfo 1st)
get_total_memory_mb() {
  if [ -f /proc/meminfo ]; then
    local kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    if [ -n "$kb" ] && [ "$kb" -gt 0 ]; then
      echo $(( kb / 1024 ))
      return 0
    fi
  fi

  local mb=$(free -m | awk 'NR==2 {print $2}' 2>/dev/null)
  if [ -n "$mb" ] && [ "$mb" -gt 0 ]; then
    echo "$mb"
    return 0
  fi

  echo "Error: Cannot detect total memory" >&2
  return 1
}

# calc mem buffer
if [ "$BBR_ONLY" -eq 0 ]; then
  MEM_TOTAL=$(get_total_memory_mb) || { echo "Failed to get memory size."; exit 1; }

  if [ "$MEM_TOTAL" -le 4096 ]; then
    MAX_BUFFER=4194304   # 4MB
  elif [ "$MEM_TOTAL" -le 16384 ]; then
    MAX_BUFFER=8388608   # 8MB
  else
    MAX_BUFFER=16777216  # 16MB
  fi

  echo "Detected memory: ${MEM_TOTAL}MB, using max buffer: ${MAX_BUFFER} bytes"
else
  echo "Running in --bbr-only mode (only core BBR enabled)"
fi

# select parameters by mode
if [ "$BBR_ONLY" -eq 1 ]; then
  declare -A SYSCTL_SETTINGS=(
    ["net.core.default_qdisc"]="fq"
    ["net.ipv4.tcp_congestion_control"]="bbr"
  )
else
  declare -A SYSCTL_SETTINGS=(
    ["net.core.default_qdisc"]="fq"
    ["net.ipv4.tcp_congestion_control"]="bbr"
    ["net.ipv4.tcp_fastopen"]="3"
    ["net.core.rmem_max"]="$MAX_BUFFER"
    ["net.core.wmem_max"]="$MAX_BUFFER"
    ["net.ipv4.tcp_rmem"]="4096 87380 $MAX_BUFFER"
    ["net.ipv4.tcp_wmem"]="4096 65536 $MAX_BUFFER"
    ["net.ipv4.tcp_window_scaling"]="1"
    ["net.ipv4.tcp_sack"]="1"
  )
fi

for key in "${!SYSCTL_SETTINGS[@]}"; do
  value="${SYSCTL_SETTINGS[$key]}"

  if grep -qE "^[[:space:]]*$key[[:space:]]*=.*" "$SYSCTL_FILE" 2>/dev/null; then
    echo "  $key already set, skipping."
  else
    echo "  Setting $key = $value"
    echo "$key = $value" | sudo tee -a "$SYSCTL_FILE" >/dev/null
  fi
done

# apply config
sudo sysctl -p 2>/dev/null || true

echo ""
echo "Configuration applied."
echo "To verify:"
echo "  sysctl net.ipv4.tcp_congestion_control   # should be bbr"
if [ "$BBR_ONLY" -eq 0 ]; then
  echo "  sysctl net.core.rmem_max                 # should show buffer size"
fi
echo "Reboot recommended for full effect."

echo "Done."

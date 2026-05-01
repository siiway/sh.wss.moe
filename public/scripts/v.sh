#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/v.help

echo "=== v.sh installer ==="
echo "Help: curl https://sh.wss.moe/v.help"
echo "Contact: https://wyf9.top/c"
echo ""

command -v curl >/dev/null || { echo "Missing curl, please install it first."; exit 1; }
command -v pactl >/dev/null || { echo "Missing pactl, please install it first."; exit 1; }

install_dir="${1:-/usr/local/bin}"
echo "Install dir: ${install_dir}"
mkdir -p "${install_dir}"

install_path="${install_dir}/v.sh"

cat > "${install_path}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

LOCKDIR="/tmp/viraudio"
mkdir -p "${LOCKDIR}"

usage() {
  cat <<USAGE
Usage:
  $0 sink NAME
  $0 mic NAME
  $0 del NAME
  $0 rm NAME
USAGE
  exit 1
}

die() {
  echo "$*" >&2
  exit 1
}

lock_file() {
  local type="$1"
  local name="$2"
  printf '%s/viraudio-%s-%s.lock' "${LOCKDIR}" "${name}" "${type}"
}

exists_name() {
  local name="$1"
  [[ -f "$(lock_file sink "${name}")" || -f "$(lock_file mic "${name}")" ]]
}

create_sink() {
  local name="$1"

  if exists_name "${name}"; then
    die "Virtual device '${name}' already exists."
  fi

  local module_index
  module_index=$(
    pactl load-module module-null-sink \
      media.class=Audio/Sink \
      sink_name="${name}" \
      sink_properties=device.description="${name}"
  )

  printf '%s\n' "${module_index}" > "$(lock_file sink "${name}")"
  echo "Created virtual sink '${name}' (module ${module_index})."
}

create_mic() {
  local name="$1"

  if exists_name "${name}"; then
    die "Virtual device '${name}' already exists."
  fi

  local module_index
  module_index=$(
    pactl load-module module-null-source \
      media.class=Audio/Source/Virtual \
      source_name="${name}" \
      source_properties=device.description="${name}"
  )

  printf '%s\n' "${module_index}" > "$(lock_file mic "${name}")"
  echo "Created virtual mic '${name}' (module ${module_index})."
}

remove_name() {
  local name="$1"
  local removed=0

  for type in sink mic; do
    local lf
    lf="$(lock_file "${type}" "${name}")"

    if [[ -f "${lf}" ]]; then
      local module_index
      module_index="$(<"${lf}")"
      pactl unload-module "${module_index}"
      rm -f "${lf}"
      echo "Removed virtual ${type} '${name}'."
      removed=$((removed + 1))
    fi
  done

  if [[ ${removed} -eq 0 ]]; then
    die "No virtual sink or mic named '${name}' found."
  fi
}

if [[ $# -ne 2 ]]; then
  usage
fi

cmd="$1"
name="$2"

case "${cmd}" in
  sink)
    create_sink "${name}"
    ;;
  mic)
    create_mic "${name}"
    ;;
  del|rm)
    remove_name "${name}"
    ;;
  *)
    usage
    ;;
esac
EOF

chmod +x "${install_path}"
echo "Installed v.sh to ${install_path}."
echo "Run: ${install_path} sink NAME"
echo "Run: ${install_path} mic NAME"
echo "Run: ${install_path} del NAME"
echo "Done."

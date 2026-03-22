#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/ps1.help

echo "=== Custom PS1 Prompt Setup ==="
echo "Help: curl https://sh.wss.moe/ps1.help"
echo "Contact: https://wyf9.top/c"
echo ""

# Parse args
USE_GIT=0
USE_NEWLINE=1

for arg in "$@"; do
  case "$arg" in
    --git)          USE_GIT=1 ;;
    --no-newline)   USE_NEWLINE=0 ;;
    --help|-h)
      echo "Usage: curl https://sh.wss.moe/ps1 | bash [-s -- <OPTIONS>]"
      echo "Options:"
      echo "  --git          Enable Git branch and status in prompt"
      echo "  --no-newline   Use single-line prompt (no newline before \$)"
      echo "  --help         Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $arg (use --help for usage)"; exit 1 ;;
  esac
done

BASHRC="$HOME/.bashrc"

# Stable Git parse function
GIT_PARSE_FUNC='
parse_git_status() {
  git rev-parse --git-dir >/dev/null 2>&1 || return 0

  local git_status branch ab status=""
  git_status=$(git status --porcelain --branch 2>/dev/null)

  # untracked files
  [[ $git_status =~ ^\?\? ]] && status+="%"

  # dirty (modified/deleted/etc in worktree)
  [[ $git_status =~ ^.[MD] ]] && status+="*"

  # staged changes
  [[ $git_status =~ ^[MADR] ]] && status+="+"

  # ahead/behind count
  ab=$(echo "$git_status" | grep -o "\[.*\]" || true)
  [[ $ab =~ ahead\ ([0-9]+) ]] && status+=">${BASH_REMATCH[1]}"
  [[ $ab =~ behind\ ([0-9]+) ]] && status+="<${BASH_REMATCH[1]}"

  branch=$(git branch --show-current 2>/dev/null)
  [[ -z "$branch" ]] && branch=$(git rev-parse --short HEAD 2>/dev/null | sed "s/^/detached@/" || echo "")

  [[ -n "$branch" ]] && echo " ($branch${status:+ $status})"
}
'

# Generate PS1
if [ "$USE_NEWLINE" -eq 1 ]; then
  # Multi-line
  if [ "$USE_GIT" -eq 1 ]; then
    PS1_VALUE='  ${debian_chroot:+($debian_chroot) }\[\e[1;32m\]$(date +"%Y-%m-%d %H:%M:%S") \[\e[1;33m\]\u\[\e[35m\]@\h\[\e[1;31m\] \w \[\e[1;34m\]$(parse_git_status)\[\e[0m\]\n\$ '
  else
    PS1_VALUE='  ${debian_chroot:+($debian_chroot) }\[\e[1;32m\]$(date +"%Y-%m-%d %H:%M:%S") \[\e[1;33m\]\u\[\e[35m\]@\h\[\e[1;31m\] \w\[\e[0m\]\n\$ '
  fi
else
  # Single-line
  if [ "$USE_GIT" -eq 1 ]; then
    PS1_VALUE='${debian_chroot:+($debian_chroot) }\[\e[1;32m\]$(date +"%Y-%m-%d %H:%M:%S") \[\e[1;33m\]\u\[\e[35m\]@\h\[\e[1;31m\] \w \[\e[1;34m\]$(parse_git_status)\[\e[0m\] \$ '
  else
    PS1_VALUE='${debian_chroot:+($debian_chroot) }\[\e[1;32m\]$(date +"%Y-%m-%d %H:%M:%S") \[\e[1;33m\]\u\[\e[35m\]@\h\[\e[1;31m\] \w\[\e[0m\] \$ '
  fi
fi

# Backup .bashrc
if [ -f "$BASHRC" ]; then
  cp "$BASHRC" "${BASHRC}.bak-$(date +%Y%m%d-%H%M%S)"
  echo "Backed up $BASHRC to ${BASHRC}.bak-$(date +%Y%m%d-%H%M%S)"
fi

# Append new config
{
  echo ""
  echo "# Custom PS1 added by https://sh.wss.moe/ps1 (stable git parse)"
  if [ "$USE_GIT" -eq 1 ]; then
    echo "$GIT_PARSE_FUNC"
  fi
  echo "PS1='$PS1_VALUE'"
} >> "$BASHRC"

echo "PS1 has been updated in ~/.bashrc"
echo "To apply immediately:"
echo "  source ~/.bashrc"
echo "  or open a new terminal."
echo ""
echo "Current mode: $( [ "$USE_NEWLINE" -eq 1 ] && echo "multi-line" || echo "single-line" ) + $( [ "$USE_GIT" -eq 1 ] && echo "with Git" || echo "no Git" )"
echo "Done."

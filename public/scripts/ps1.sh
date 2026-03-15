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
      echo "  --no-newline   Use single-line prompt (no newline before $)"
      echo "  --help         Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $arg (use --help for usage)"; exit 1 ;;
  esac
done

BASHRC="$HOME/.bashrc"

# Git parse function (only if --git is used)
GIT_PARSE_FUNC='
parse_git_status() {
  local branch dirty untracked ahead behind
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  [ -z "$branch" ] && return

  untracked=$(git status --porcelain 2>/dev/null | grep -c "^??" || echo 0)
  dirty=$(git diff --name-only --diff-filter=ACMRT 2>/dev/null | wc -l)
  staged=$(git diff --cached --name-only --diff-filter=ACMRT 2>/dev/null | wc -l)
  ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

  local status=""
  [ "$untracked" -gt 0 ] && status="${status}%"
  [ "$dirty" -gt 0 ]     && status="${status}*"
  [ "$staged" -gt 0 ]    && status="${status}+"
  [ "$ahead" -gt 0 ]     && status="${status}>"
  [ "$behind" -gt 0 ]    && status="${status}<"

  echo "($branch${status:+ $status})"
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
  cp "$BASHRC" "${BASHRC}.bak"
  echo "Backuped $BASHRC to ${BASHRC}.bak"
fi

# Append new config
{
  echo ""
  echo "# Custom PS1 added by https://sh.wss.moe/ps1"
  if [ "$USE_GIT" -eq 1 ]; then
    echo "$GIT_PARSE_FUNC"
  fi
  echo "PS1='$PS1_VALUE'"
} >> "$BASHRC"

echo "PS1 has been updated in ~/.bashrc"
echo 'To apply immediately:
source ~/.bashrc
or open a new terminal.'
echo "Current mode: $( [ "$USE_NEWLINE" -eq 1 ] && echo "multi-line" || echo "single-line" ) + $( [ "$USE_GIT" -eq 1 ] && echo "with Git" || echo "no Git" )"

echo "Done."

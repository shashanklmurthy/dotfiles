#!/usr/bin/env bash
# Shared helpers sourced by the module install/validate scripts.
# Intentionally POSIX-leaning; keep dependencies minimal.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
HIGHLIGHT='\033[7m'
RESET='\033[0m'

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

hr() {
  echo "--------------------------------------------------------------------------"
}

hr2() {
  echo "=========================================================================="
}

section() {
  hr
  echo "$*"
  hr
}

info()  { printf "${BLUE}-->${RESET} %s\n" "$*"; }
ok()    { printf "${GREEN}===> GOOD:${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}???? INFO:${RESET} %s\n" "$*"; }
err()   { printf "${RED}XXXX ERROR:${RESET} %s\n" "$*"; }

confirm() {
  # confirm "<action phrase>" -> returns 0 on yes, 1 on no
  local prompt="$1"
  if [ -n "${DOTFILES_ASSUME_YES:-}" ]; then
    return 0
  fi
  while true; do
    printf "   Do you want to %s? (${GREEN}y${RESET}/${RED}n${RESET})? " "$prompt"
    read -r yn
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer YES (y) or NO (n)" ;;
    esac
  done
}

create_with_backup() {
  # Copy $DOTFILES/<src_rel> to $HOME/<dst_basename>, backing up any existing file.
  local src_rel="$1"
  local dst_name="${2:-$(basename "$src_rel")}"
  local src="$DOTFILES/$src_rel"
  local dst="$HOME/$dst_name"

  if [ ! -f "$src" ]; then
    err "source missing: $src"
    return 1
  fi

  if [ -f "$dst" ] && ! cmp -s "$src" "$dst"; then
    info "Backing up existing $dst -> $dst.backup"
    mv "$dst" "$dst.backup"
  fi

  info "Installing $dst"
  cp "$src" "$dst"
}

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

have() {
  command -v "$1" >/dev/null 2>&1
}

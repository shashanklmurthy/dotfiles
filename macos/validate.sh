#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating macOS setup"

if ! is_macos; then
  warn "Not running on macOS; skipping."
  return 0 2>/dev/null || exit 0
fi

if xcode-select -p >/dev/null 2>&1; then
  ok "xcode-select installed at $(xcode-select -p)"
else
  err "Xcode Command Line Tools not installed"
fi

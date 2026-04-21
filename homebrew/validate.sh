#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating Homebrew installation"

if have brew; then
  ok "brew installed: $(brew --version | head -n 1)"
else
  err "brew not installed"
  return 0 2>/dev/null || exit 0
fi

if have git; then
  ok "git     installed: $(git --version)"
else
  err "git not installed"
fi

BREWFILE="$DOTFILES/Brewfile"
if [ -f "$BREWFILE" ]; then
  info "Running 'brew bundle check' against $BREWFILE (non-fatal)"
  brew bundle check --file "$BREWFILE" || warn "Some entries from Brewfile are missing"
else
  warn "No Brewfile at $BREWFILE"
fi

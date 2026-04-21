#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating nvm / Node"

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if command -v nvm >/dev/null 2>&1; then
  ok "nvm installed"
else
  warn "nvm not installed (optional)"
fi

if have node; then ok "node installed: $(node -v)"; else err "node not installed"; fi
if have npm;  then ok "npm  installed: $(npm -v)";  else err "npm not installed";  fi

#!/usr/bin/env bash
# Install nvm and a recent Node LTS. We keep nvm primary because it's the
# de-facto way most JS projects pin Node versions.

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Installing nvm + Node"

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export NVM_DIR

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  info "Installing nvm..."
  PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
  info "Skipping nvm, already installed"
fi

# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if command -v nvm >/dev/null 2>&1; then
  info "Installing Node LTS via nvm..."
  nvm install --lts
  nvm alias default 'lts/*'
else
  err "nvm is not available in this shell; open a new terminal and re-run this step."
fi

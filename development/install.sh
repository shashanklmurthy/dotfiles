#!/usr/bin/env bash
# Extra developer tooling that isn't strictly a brew formula:
#   - AWS CLI v2 (installer pkg, not brew, per AWS recommendation on macOS)
#   - pipx (for user-level Python CLI tools)

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Installing developer tools"

if is_macos && ! have aws; then
  if confirm "install AWS CLI v2 (official .pkg installer)"; then
    tmp="$(mktemp -d)"
    info "Downloading AWSCLIV2.pkg..."
    curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "$tmp/AWSCLIV2.pkg"
    info "Installing AWSCLIV2.pkg (requires sudo)..."
    sudo installer -pkg "$tmp/AWSCLIV2.pkg" -target /
    rm -rf "$tmp"
  fi
else
  have aws && info "Skipping AWS CLI, already installed ($(aws --version 2>&1))"
fi

if have brew && ! have pipx; then
  info "Installing pipx..."
  brew install pipx
  pipx ensurepath || true
fi

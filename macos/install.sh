#!/usr/bin/env bash
# macOS prerequisites: Xcode Command Line Tools + (optionally) sensible defaults.

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Setting up macOS prerequisites..."

if ! is_macos; then
  warn "Not running on macOS; skipping macOS-specific setup."
  return 0 2>/dev/null || exit 0
fi

if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install || true
else
  info "Skipping Xcode Command Line Tools, already installed"
fi

# Apply sensible macOS defaults on request.
# The curated defaults live in the repo's .macos file (Mathias Bynens'd).
if [ -f "$DOTFILES/.macos" ]; then
  if confirm "apply the curated macOS defaults from .macos now (requires logout/restart for some settings)"; then
    info "Applying macOS defaults from $DOTFILES/.macos"
    bash "$DOTFILES/.macos" || warn ".macos exited non-zero"
  else
    info "Skipping macOS defaults (run 'bash $DOTFILES/.macos' later if you change your mind)"
  fi
fi

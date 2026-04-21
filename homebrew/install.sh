#!/usr/bin/env bash
# Install Homebrew, then run `brew bundle` against the repo's Brewfile.

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Installing Homebrew..."

if ! have brew; then
  if is_macos; then
    info "Installing Homebrew for macOS..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  elif is_linux; then
    info "Installing Homebrew for Linux..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    err "Unsupported platform for Homebrew install: $(uname -s)"
    return 1 2>/dev/null || exit 1
  fi
else
  info "Skipping brew, already installed ($(brew --version | head -n 1))"
fi

# Put brew on PATH for the rest of this script regardless of shell rc state.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

info "Updating brew metadata..."
brew update || warn "brew update failed, continuing"

section "Installing software via 'brew bundle'..."
BREWFILE="$DOTFILES/Brewfile"
if [ ! -f "$BREWFILE" ]; then
  err "No Brewfile at $BREWFILE"
  return 1 2>/dev/null || exit 1
fi

info "Using $BREWFILE"
if ! brew bundle --no-upgrade --file "$BREWFILE"; then
  err "brew bundle reported failures — review the output above."
fi

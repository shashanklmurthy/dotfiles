#!/usr/bin/env bash
# Sync the tracked dotfiles to $HOME.
# After this runs you can optionally run ./install.sh to set up tools.

set -u

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

if [ -d .git ]; then
  git pull --ff-only origin main || true
fi

doIt() {
  rsync \
    --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude ".macos" \
    --exclude "Brewfile" \
    --exclude "bootstrap.sh" \
    --exclude "install.sh" \
    --exclude "validate.sh" \
    --exclude "brew.sh" \
    --exclude "README.md" \
    --exclude "LICENSE-MIT.txt" \
    --exclude "lib/" \
    --exclude "macos/" \
    --exclude "homebrew/" \
    --exclude "git/" \
    --exclude "zsh/" \
    --exclude "node/" \
    --exclude "java/" \
    --exclude "development/" \
    --exclude "init/" \
    -avh --no-perms . ~
  # Reload shell profile if present.
  if [ -f "$HOME/.bash_profile" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.bash_profile"
  fi
}

if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then
  doIt
else
  read -r -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1 REPLY
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi

echo ""
echo "Dotfiles synced to \$HOME."
echo "To install tools and configure the shell, run:"
echo "    ./install.sh"
echo "Then validate with:"
echo "    ./validate.sh"

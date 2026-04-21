#!/usr/bin/env bash
# Top-level installer. Runs each module's install.sh in a sensible order.
#
# Usage:
#   ./install.sh                     # prompts per step
#   DOTFILES_ASSUME_YES=1 ./install.sh   # non-interactive (say yes to all)
#
# You can also run an individual module directly, e.g.:
#   ./homebrew/install.sh

set -u

cd "$(dirname "$0")"
export DOTFILES="${DOTFILES:-$PWD}"

# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

hr2
echo "Setting up your machine from $DOTFILES"
hr2

. "$DOTFILES/macos/install.sh"
. "$DOTFILES/homebrew/install.sh"
. "$DOTFILES/git/install.sh"
. "$DOTFILES/zsh/install.sh"
. "$DOTFILES/node/install.sh"
. "$DOTFILES/java/install.sh"
. "$DOTFILES/development/install.sh"

hr2
echo "Done. Run './validate.sh' to sanity-check the installation."
hr2

#!/usr/bin/env bash
# Top-level validator. Runs every module's validate.sh.

set -u

cd "$(dirname "$0")"
export DOTFILES="${DOTFILES:-$PWD}"

# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

hr2
echo "Validating installation from $DOTFILES"
hr2

. "$DOTFILES/macos/validate.sh"
. "$DOTFILES/homebrew/validate.sh"
. "$DOTFILES/git/validate.sh"
. "$DOTFILES/zsh/validate.sh"
. "$DOTFILES/node/validate.sh"
. "$DOTFILES/java/validate.sh"
. "$DOTFILES/development/validate.sh"

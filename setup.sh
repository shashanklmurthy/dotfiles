#!/usr/bin/env bash
# One-shot, idempotent entry point.
#
# Usage:
#   ./setup.sh                         # interactive (prompts for confirmation,
#                                      # primary email, GPG key choice)
#   ./setup.sh -y                      # non-interactive: auto-approves every
#                                      # confirm(), reuses existing git
#                                      # identity / signing key, does NOT
#                                      # auto-generate a new GPG key
#   DOTFILES_ASSUME_YES=1 ./setup.sh   # same as -y
#
# Safe to re-run at any time. Every step it calls is idempotent.

set -u

cd "$(dirname "$0")"
export DOTFILES="${DOTFILES:-$PWD}"

# -y / --yes is a convenience for DOTFILES_ASSUME_YES=1.
for arg in "$@"; do
  case "$arg" in
    -y|--yes) export DOTFILES_ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed -E 's/^#( |$)//'
      exit 0
      ;;
  esac
done

# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

hr2
echo "Dotfiles setup — $DOTFILES"
if [ -n "${DOTFILES_ASSUME_YES:-}" ]; then
  echo "Mode: non-interactive (DOTFILES_ASSUME_YES=1)"
else
  echo "Mode: interactive"
fi
hr2

rc=0

info "Step 1/3 — bootstrap.sh (sync tracked files into \$HOME)"
if ! bash "$DOTFILES/bootstrap.sh" -f; then
  err "bootstrap.sh failed"
  rc=1
fi

info "Step 2/3 — install.sh (macos, homebrew, git, zsh, node, java, development)"
if ! bash "$DOTFILES/install.sh"; then
  err "install.sh reported a failure"
  rc=1
fi

info "Step 3/3 — validate.sh"
# Validators report both OK and ERROR markers; we still run all of them
# regardless of individual status, and don't treat that as a setup failure.
bash "$DOTFILES/validate.sh" || true

hr2
if [ "$rc" -eq 0 ]; then
  ok "Setup finished. Open a new shell to pick up PATH/completion changes."
else
  warn "Setup finished with errors above. See logs, fix, and re-run: ./setup.sh"
fi
hr2

exit "$rc"

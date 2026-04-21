#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating Java toolchain"

if have jenv; then
  ok "jenv installed"
else
  warn "jenv not installed (optional)"
fi

if have java; then
  ok "java installed: $(java -version 2>&1 | head -n 1)"
else
  warn "java not installed (optional)"
fi

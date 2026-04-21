#!/usr/bin/env bash
# Configure jenv and wire up any Temurin / OpenJDK installs that may be on disk.

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Configuring Java toolchain"

if ! have jenv; then
  if have brew; then
    info "Installing jenv via Homebrew..."
    brew install jenv
  else
    err "Neither jenv nor brew found; install brew first."
    return 1 2>/dev/null || exit 1
  fi
else
  info "Skipping jenv, already installed"
fi

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
jenv enable-plugin export  >/dev/null 2>&1 || true
jenv enable-plugin maven   >/dev/null 2>&1 || true
jenv enable-plugin gradle  >/dev/null 2>&1 || true

info "Registering any JDKs found under /Library/Java/JavaVirtualMachines"
if [ -d /Library/Java/JavaVirtualMachines ]; then
  for jdk in /Library/Java/JavaVirtualMachines/*/Contents/Home; do
    [ -d "$jdk" ] || continue
    jenv add "$jdk" >/dev/null 2>&1 && info "Added $jdk to jenv" || true
  done
fi

jenv versions 2>/dev/null || true

#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating git config"

for key in user.name user.email core.autocrlf pull.ff init.defaultBranch; do
  val=$(git config --global "$key" || true)
  if [ -n "$val" ]; then
    ok "$(printf '%-24s' "$key") set: $val"
  else
    err "$key not set"
  fi
done

# Credential helpers (prefer `gh` helper on github.com).
gh_helper=$(git config --global --get-all credential.https://github.com.helper 2>/dev/null | tail -n 1)
if [ -n "$gh_helper" ] && echo "$gh_helper" | grep -q 'gh auth git-credential'; then
  ok "credential.https://github.com.helper configured via gh"
else
  warn "github.com credential helper not using gh (current: ${gh_helper:-<unset>})"
fi

if is_macos; then
  helper=$(git config --global credential.helper || true)
  if [ "$helper" = "osxkeychain" ]; then
    ok "credential.helper        set: osxkeychain"
  else
    warn "credential.helper not set to osxkeychain (current: ${helper:-<unset>})"
  fi
fi

# GPG signing.
signkey=$(git config --global user.signingkey || true)
gpgsign=$(git config --global commit.gpgsign || true)
if [ -n "$signkey" ] && [ "$gpgsign" = "true" ]; then
  ok "commit signing          enabled with key $signkey"
  if have gpg; then
    if gpg --list-secret-keys "$signkey" >/dev/null 2>&1; then
      ok "signing key present in gpg keyring"
    else
      err "signing key $signkey not found in gpg keyring"
    fi
  else
    err "gpg not installed, but commit.gpgsign is true"
  fi
else
  warn "commit signing not enabled (user.signingkey='${signkey:-}', commit.gpgsign='${gpgsign:-}')"
fi

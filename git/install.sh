#!/usr/bin/env bash
# Configure global git: identity, credential helper, signed commits (GPG),
# URL rewrites and handy defaults.
#
# Safe to re-run. Reuses existing values where sensible, prompts otherwise.

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Configuring git..."

if ! have git; then
  err "git is not installed; run the homebrew step first."
  return 1 2>/dev/null || exit 1
fi

###############################################################################
# 1. Identity: user.name + primary GitHub email
###############################################################################

current_name=$(git config --global user.name || true)
current_email=$(git config --global user.email || true)

if [ -n "$current_name" ]; then
  info "git user.name already set: $current_name"
  if [ -z "${DOTFILES_ASSUME_YES:-}" ]; then
    if ! confirm "keep '$current_name' as your git user.name"; then
      read -r -p "   Enter new git user.name: " username
      [ -n "$username" ] && git config --global user.name "$username"
    fi
  fi
else
  if [ -n "${DOTFILES_ASSUME_YES:-}" ]; then
    err "user.name is not set and DOTFILES_ASSUME_YES=1; cannot prompt. Set it"
    err "manually with: git config --global user.name 'First Last'"
  else
    read -r -p "   Enter your git user.name (e.g. First Last): " username
    [ -n "$username" ] && git config --global user.name "$username"
  fi
fi

# Build a short menu of candidate primary emails.
declare -a email_candidates=()
add_email() {
  local e="$1"
  [ -z "$e" ] && return
  if [ "${#email_candidates[@]}" -gt 0 ]; then
    for existing in "${email_candidates[@]}"; do
      [ "$existing" = "$e" ] && return
    done
  fi
  email_candidates+=("$e")
}

add_email "$current_email"

# If `gh` is logged in, offer the emails it knows about.
if have gh && gh auth status >/dev/null 2>&1; then
  while IFS= read -r e; do add_email "$e"; done < <(
    gh api user/emails --jq '.[].email' 2>/dev/null || true
  )
fi

if [ -n "${DOTFILES_ASSUME_YES:-}" ]; then
  # Non-interactive: reuse the current email if set; otherwise take the first
  # candidate (typically from `gh`); otherwise bail out without prompting.
  if [ -n "$current_email" ]; then
    chosen_email="$current_email"
    info "Non-interactive: keeping existing user.email = $chosen_email"
  elif [ "${#email_candidates[@]}" -gt 0 ]; then
    chosen_email="${email_candidates[0]}"
    info "Non-interactive: using first candidate email = $chosen_email"
  else
    chosen_email=""
    err "No email available and DOTFILES_ASSUME_YES=1; cannot prompt. Set it"
    err "manually with: git config --global user.email 'you@example.com'"
  fi
else
  echo ""
  info "Pick the primary email to use for git / GitHub commits:"
  local_idx=1
  if [ "${#email_candidates[@]}" -gt 0 ]; then
    for e in "${email_candidates[@]}"; do
      printf "     %d) %s\n" "$local_idx" "$e"
      local_idx=$((local_idx + 1))
    done
  fi
  printf "     %d) (enter another email manually)\n" "$local_idx"

  read -r -p "   Choice [1]: " email_choice
  email_choice="${email_choice:-1}"

  if [ "${#email_candidates[@]}" -eq 0 ] || [ "$email_choice" = "$local_idx" ]; then
    read -r -p "   Enter email: " chosen_email
  else
    idx=$((email_choice - 1))
    chosen_email="${email_candidates[$idx]:-${email_candidates[0]}}"
  fi
fi

if [ -n "$chosen_email" ]; then
  git config --global user.email "$chosen_email"
  info "Set git user.email = $chosen_email"
else
  err "No email chosen; skipping user.email"
fi

###############################################################################
# 2. Sensible defaults
###############################################################################

info "Applying sensible git defaults"
git config --global core.autocrlf input
git config --global pull.ff only
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global rebase.autosquash true
git config --global rerere.enabled true
git config --global push.followTags true
git config --global push.default simple
git config --global pager.branch false
git config --global pager.config false
git config --global color.ui auto
git config --global branch.sort -committerdate

###############################################################################
# 3. Credential helper
#    Prefer `gh` as a GitHub-only helper (OAuth, 2FA-aware, no plaintext token
#    on disk). Fall back to the macOS keychain for non-GitHub hosts.
###############################################################################

if have gh; then
  if ! gh auth status >/dev/null 2>&1; then
    warn "gh is installed but not authenticated. Run 'gh auth login' after this"
    warn "script finishes to enable the gh-backed credential helper."
  fi
  info "Configuring 'gh' as the GitHub credential helper"
  # Clear any previous helper values so we start clean.
  git config --global --unset-all credential.https://github.com.helper 2>/dev/null || true
  git config --global --unset-all credential.https://gist.github.com.helper 2>/dev/null || true

  # Leading empty value clears any system/global defaults; then append gh.
  git config --global --add credential.https://github.com.helper ""
  git config --global --add credential.https://github.com.helper "!$(command -v gh) auth git-credential"
  git config --global --add credential.https://gist.github.com.helper ""
  git config --global --add credential.https://gist.github.com.helper "!$(command -v gh) auth git-credential"
fi

if is_macos; then
  # Non-GitHub hosts still benefit from the keychain.
  git config --global credential.helper osxkeychain
fi

###############################################################################
# 4. URL rewrites (optional)
#    Force HTTPS for github.com so that `git clone git@github.com:...` works
#    even when you don't have SSH keys set up on a new machine.
###############################################################################

if confirm "rewrite git@github.com URLs to https (recommended when using gh auth)"; then
  git config --global url.https://github.com/.insteadOf git@github.com:
else
  git config --global --unset url.https://github.com/.insteadOf 2>/dev/null || true
fi

###############################################################################
# 5. Handy aliases (in addition to ~/.gitconfig ones synced by bootstrap.sh)
###############################################################################

info "Installing quick-reference log aliases"
git config --global alias.lo  'log --oneline'
git config --global alias.lod 'log --oneline --graph --decorate'
git config --global alias.lola 'log --oneline --graph --decorate --all'

###############################################################################
# 6. Editor / diff / merge tool wiring (optional)
###############################################################################

if have code && confirm "use VS Code as your git core editor / diff / merge tool"; then
  git config --global core.editor 'code --wait'
  git config --global diff.tool vscode
  git config --global difftool.vscode.cmd 'code --wait --diff "$LOCAL" "$REMOTE"'
  git config --global merge.tool vscode
  git config --global mergetool.vscode.cmd 'code --wait "$MERGED"'
elif have cursor && confirm "use Cursor as your git core editor / diff / merge tool"; then
  git config --global core.editor 'cursor --wait'
  git config --global diff.tool cursor
  git config --global difftool.cursor.cmd 'cursor --wait --diff "$LOCAL" "$REMOTE"'
  git config --global merge.tool cursor
  git config --global mergetool.cursor.cmd 'cursor --wait "$MERGED"'
fi

###############################################################################
# 7. GPG signing for commits and tags
###############################################################################

hr
info "Setting up GPG commit signing"
hr

if ! have gpg; then
  if have brew; then
    info "Installing gnupg via Homebrew..."
    brew install gnupg
  else
    err "gpg is not installed and brew is unavailable; skipping GPG setup."
    return 0 2>/dev/null || exit 0
  fi
fi

# On macOS, wire up pinentry-mac so passphrase prompts work in any TTY/GUI.
if is_macos && have pinentry-mac; then
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  conf="$HOME/.gnupg/gpg-agent.conf"
  pinentry_path="$(command -v pinentry-mac)"
  if ! grep -q "^pinentry-program $pinentry_path" "$conf" 2>/dev/null; then
    info "Pointing gpg-agent at $pinentry_path"
    {
      grep -v '^pinentry-program' "$conf" 2>/dev/null || true
      echo "pinentry-program $pinentry_path"
    } > "$conf.tmp" && mv "$conf.tmp" "$conf"
    gpgconf --kill gpg-agent 2>/dev/null || true
  fi
fi

# Find existing secret keys, optionally scoped to the chosen email.
list_keys() {
  local filter="${1:-}"
  if [ -n "$filter" ]; then
    gpg --list-secret-keys --keyid-format=long --with-colons "$filter" 2>/dev/null
  else
    gpg --list-secret-keys --keyid-format=long --with-colons 2>/dev/null
  fi
}

# Produce pairs of "LONGKEYID<TAB>uid" for display + selection.
list_key_pairs() {
  local filter="${1:-}"
  list_keys "$filter" | awk -F: '
    $1=="sec" { kid=$5; next }
    $1=="uid" && kid!="" { print kid "\t" $10; kid="" }
  '
}

declare -a key_ids=()
declare -a key_uids=()

fill_key_arrays() {
  key_ids=()
  key_uids=()
  while IFS=$'\t' read -r kid uid; do
    [ -z "$kid" ] && continue
    key_ids+=("$kid")
    key_uids+=("$uid")
  done < <(list_key_pairs "${1:-}")
}

generate_new_gpg_key() {
  local name="$1"
  local email="$2"
  info "Generating a new RSA 4096-bit GPG key for $name <$email>"
  info "You will be prompted for a passphrase (leave blank for no passphrase, but a passphrase is strongly recommended)."
  if ! gpg --quick-generate-key "$name <$email>" rsa4096 sign 2y; then
    err "GPG key generation failed."
    return 1
  fi
}

# Prefer keys matching the chosen email.
fill_key_arrays "$chosen_email"
if [ "${#key_ids[@]}" -eq 0 ]; then
  # Nothing scoped to this email — show all keys instead.
  fill_key_arrays ""
fi

current_signkey=$(git config --global user.signingkey || true)

chosen_key=""

if [ -n "${DOTFILES_ASSUME_YES:-}" ]; then
  # Non-interactive: never auto-generate a new key (the passphrase prompt
  # would block). Just reuse whatever is already configured.
  if [ -n "$current_signkey" ] && have gpg && gpg --list-secret-keys "$current_signkey" >/dev/null 2>&1; then
    chosen_key="$current_signkey"
    info "Non-interactive: keeping existing signingkey = $chosen_key"
  elif [ "${#key_ids[@]}" -gt 0 ]; then
    chosen_key="${key_ids[0]}"
    info "Non-interactive: picking first available GPG key = $chosen_key"
  else
    warn "Non-interactive: no GPG key to use; skipping signing setup."
    warn "Run ./git/install.sh interactively to generate one."
  fi
else
  echo ""
  if [ "${#key_ids[@]}" -gt 0 ]; then
    info "GPG secret keys found on this machine:"
    i=1
    for kid in "${key_ids[@]}"; do
      marker=""
      [ "$kid" = "$current_signkey" ] && marker=" (current git signingkey)"
      printf "     %d) %s  %s%s\n" "$i" "$kid" "${key_uids[$((i-1))]}" "$marker"
      i=$((i + 1))
    done
    printf "     %d) generate a new GPG key for %s\n" "$i" "${chosen_email:-<no-email>}"
    printf "     %d) skip GPG signing setup\n" "$((i+1))"

    read -r -p "   Choice [1]: " gpg_choice
    gpg_choice="${gpg_choice:-1}"

    if [ "$gpg_choice" = "$i" ]; then
      name_for_key="$(git config --global user.name)"
      generate_new_gpg_key "$name_for_key" "$chosen_email" || true
      fill_key_arrays "$chosen_email"
      [ "${#key_ids[@]}" -gt 0 ] && chosen_key="${key_ids[0]}"
    elif [ "$gpg_choice" = "$((i+1))" ]; then
      chosen_key=""
    else
      idx=$((gpg_choice - 1))
      chosen_key="${key_ids[$idx]:-${key_ids[0]}}"
    fi
  else
    warn "No GPG secret keys found on this machine."
    if confirm "generate a new GPG key for ${chosen_email:-this account}"; then
      name_for_key="$(git config --global user.name)"
      generate_new_gpg_key "$name_for_key" "$chosen_email" || true
      fill_key_arrays "$chosen_email"
      [ "${#key_ids[@]}" -gt 0 ] && chosen_key="${key_ids[0]}"
    fi
  fi
fi

if [ -n "${chosen_key:-}" ]; then
  git config --global user.signingkey "$chosen_key"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  git config --global gpg.program "$(command -v gpg)"
  ok "Commits will be signed with GPG key $chosen_key"

  # Export public key and copy to clipboard so the user can paste into
  # https://github.com/settings/gpg/new
  tmp_pub="$(mktemp)"
  gpg --armor --export "$chosen_key" > "$tmp_pub" 2>/dev/null || true
  if [ -s "$tmp_pub" ]; then
    if is_macos && have pbcopy; then
      pbcopy < "$tmp_pub"
      info "Public key copied to clipboard."
    else
      info "Public key written to $tmp_pub"
    fi
    echo ""
    echo "Next step: add this GPG key to GitHub:"
    echo "  https://github.com/settings/gpg/new"
    if have gh && gh auth status >/dev/null 2>&1; then
      if confirm "upload this key to GitHub now via 'gh gpg-key add'"; then
        gh gpg-key add "$tmp_pub" || warn "gh gpg-key add failed"
      fi
    fi
    rm -f "$tmp_pub"
  fi
else
  warn "No signing key selected; leaving commit.gpgsign at its previous value."
fi

###############################################################################
# 6. Per-host override file
#    The tracked .gitconfig has `[include] path = ~/.gitconfig.local`, so any
#    setting written there wins over the tracked defaults. This is the right
#    place for a work email / signingkey on a specific machine. Not tracked.
###############################################################################

if [ ! -f "$HOME/.gitconfig.local" ]; then
  cat > "$HOME/.gitconfig.local" <<'EOF'
# Per-host git overrides. This file is NOT tracked. Anything set here wins
# over ~/.gitconfig. Example (uncomment and edit as needed):
#
# [user]
#     email = you@work.example.com
#     signingkey = ABCDEF0123456789
#
# [http]
#     proxy = http://proxy.example.com:8080
EOF
  info "Created $HOME/.gitconfig.local (stub, not tracked)"
else
  info "$HOME/.gitconfig.local already exists; leaving it alone"
fi

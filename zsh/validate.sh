#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating Z shell customizations"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

if [ -d "$ZSH_DIR" ]; then
  ok "oh-my-zsh installed at $ZSH_DIR"
else
  warn "oh-my-zsh not installed (optional)"
fi

for p in themes/powerlevel10k plugins/zsh-autosuggestions plugins/zsh-syntax-highlighting; do
  if [ -d "$ZSH_CUSTOM_DIR/$p" ]; then
    ok "$p installed"
  else
    warn "$p not installed (optional)"
  fi
done

for f in "$HOME/.zshrc" "$HOME/.p10k.zsh"; do
  if [ -f "$f" ]; then
    ok "$(basename "$f") present"
  else
    err "missing $f"
  fi
done

if ls "$HOME"/.vim/colors/*.vim >/dev/null 2>&1; then
  ok "$HOME/.vim/colors/ contains theme files"
else
  warn "no .vim color files in $HOME/.vim/colors/"
fi

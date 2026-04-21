#!/usr/bin/env bash
# Install Oh My Zsh, Powerlevel10k, and zsh plugins, and drop in the personal
# .zshrc / .p10k.zsh shipped in this repo (with backups).

set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Installing Z shell customizations..."

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

if confirm "install oh-my-zsh (if missing) and plugins"; then
  if [ ! -d "$ZSH_DIR" ]; then
    info "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes /bin/sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended
  else
    info "Skipping oh-my-zsh, already installed"
  fi

  mkdir -p "$ZSH_CUSTOM_DIR/themes" "$ZSH_CUSTOM_DIR/plugins"

  if [ ! -d "$ZSH_CUSTOM_DIR/themes/powerlevel10k" ]; then
    info "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
  else
    info "Skipping powerlevel10k, already installed"
  fi

  if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  else
    info "Skipping zsh-autosuggestions, already installed"
  fi

  if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  else
    info "Skipping zsh-syntax-highlighting, already installed"
  fi
else
  info "Skipping oh-my-zsh"
fi

# Drop in the personal shell rc files (bootstrap.sh also does this; we do it
# defensively so `./install.sh` alone is enough).
for f in .zshrc .p10k.zsh .aliases .exports .functions .bash_profile .bash_prompt .bashrc .inputrc; do
  [ -f "$DOTFILES/$f" ] && create_with_backup "$f"
done

# vim colors
if [ -d "$DOTFILES/.vim/colors" ]; then
  info "Installing vim colors into $HOME/.vim/colors..."
  mkdir -p "$HOME/.vim/colors"
  cp -R "$DOTFILES"/.vim/colors/* "$HOME/.vim/colors/" 2>/dev/null || true
fi
[ -f "$DOTFILES/.vimrc" ] && create_with_backup ".vimrc"

# Ensure a private zsh file exists for secrets / per-machine overrides.
touch "$HOME/.private.zsh"
info "Ensured $HOME/.private.zsh exists (not tracked by git)"

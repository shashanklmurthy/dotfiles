# ---------------------------------------------------------------------------
# Personal .zshrc
#
# Secrets, API tokens and machine-specific paths do NOT belong here.
# Put them in ~/.private.zsh (sourced near the bottom of this file).
# ---------------------------------------------------------------------------

# Powerlevel10k instant prompt. Keep near the top; anything above this block
# that can prompt (password, [y/n], etc.) will break it.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Standard Oh My Zsh behavior toggles. Uncomment as desired.
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# zstyle ':omz:update' mode auto       # update OMZ automatically

# Plugins — keep this list lean. Each one adds to shell startup time.
# A mix of OMZ built-ins (git, kubectl, docker, aws, terraform, helm, etc.)
# plus the two classic community plugins installed by zsh/install.sh.
plugins=(
  git
  gh
  docker
  docker-compose
  kubectl
  kubectx
  helm
  minikube
  aws
  terraform
  gcloud
  golang
  node
  npm
  pip
  python
  brew
  macos
  vscode
  fzf
  sudo
  history
  dirhistory
  copybuffer
  copyfile
  web-search
  emoji
  encode64
  jsontools
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k user config.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
# Personal bin dir
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"

# User-local installs (pipx, npm --prefix, etc.)
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Go / Rust
[ -d "$HOME/go/bin" ]    && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# krew (kubectl plugin manager)
[ -d "$HOME/.krew/bin" ] && export PATH="$PATH:$HOME/.krew/bin"

# jenv
if [ -d "$HOME/.jenv" ]; then
  export PATH="$HOME/.jenv/bin:$PATH"
  command -v jenv >/dev/null 2>&1 && eval "$(jenv init -)"
fi

# pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
  command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - zsh)"
fi

# GNU tool replacements (homebrew-installed). Prefer GNU over BSD versions.
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  for pkg in coreutils findutils gnu-sed gnu-tar grep gawk make libtool ed; do
    [ -d "$BREW_PREFIX/opt/$pkg/libexec/gnubin" ] \
      && export PATH="$BREW_PREFIX/opt/$pkg/libexec/gnubin:$PATH"
  done
  unset BREW_PREFIX
fi

# ---------------------------------------------------------------------------
# Version managers / lazy-loaded things
# ---------------------------------------------------------------------------
# NVM — lazy load for much faster shell startup. Only the `nvm`, `node`, `npm`,
# `npx`, and `yarn` commands trigger the real load.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_load() {
    unset -f nvm node npm npx yarn _nvm_load
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  }
  nvm()  { _nvm_load && nvm "$@"; }
  node() { _nvm_load && node "$@"; }
  npm()  { _nvm_load && npm "$@"; }
  npx()  { _nvm_load && npx "$@"; }
  yarn() { _nvm_load && yarn "$@"; }
fi

# GVM (Go version manager) — only if installed.
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# ---------------------------------------------------------------------------
# User config / exports / functions / aliases
# ---------------------------------------------------------------------------
[ -f "$HOME/.exports" ]   && source "$HOME/.exports"
[ -f "$HOME/.functions" ] && source "$HOME/.functions"
[ -f "$HOME/.aliases" ]   && source "$HOME/.aliases"

# ---------------------------------------------------------------------------
# Completions (load once per shell). Requires the relevant tools to be on PATH.
# ---------------------------------------------------------------------------
autoload -Uz compinit && compinit -C

command -v kubectl      >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v helm         >/dev/null 2>&1 && source <(helm completion zsh)
command -v argocd       >/dev/null 2>&1 && source <(argocd completion zsh)
command -v flux         >/dev/null 2>&1 && source <(flux completion zsh)
command -v kind         >/dev/null 2>&1 && source <(kind completion zsh)
command -v k9s          >/dev/null 2>&1 && source <(k9s completion zsh)
command -v stern        >/dev/null 2>&1 && source <(stern --completion=zsh)
command -v minikube     >/dev/null 2>&1 && source <(minikube completion zsh)
command -v gh           >/dev/null 2>&1 && eval "$(gh completion -s zsh)"
command -v kubectl-argo-rollouts >/dev/null 2>&1 && source <(kubectl-argo-rollouts completion zsh)

# operator-sdk emits completion to fpath (needs to run before compinit in a
# fresh shell; handled by keeping it below with the others for idempotency).
if command -v operator-sdk >/dev/null 2>&1 && [ -n "${fpath[1]:-}" ]; then
  operator-sdk completion zsh > "${fpath[1]}/_operator-sdk" 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Evals (slowish; put them last)
# ---------------------------------------------------------------------------
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# ---------------------------------------------------------------------------
# SSH agent (quiet-add if running)
# ---------------------------------------------------------------------------
ssh-add &> /dev/null || true

# ---------------------------------------------------------------------------
# Private / per-machine configuration — not tracked in git. Use this for
# API tokens, credentials, corp-specific CA bundles, and anything machine-
# specific you don't want to commit.
# ---------------------------------------------------------------------------
[ -f "$HOME/.private.zsh" ] && source "$HOME/.private.zsh"

# ---------------------------------------------------------------------------
# Local-only extensions (e.g. Docker Desktop init script, IDE shell integrations).
# These are written by the tools themselves; keep them at the very bottom so
# they don't interfere with the rest of the shell setup.
# ---------------------------------------------------------------------------
[ -f "$HOME/.docker/init-zsh.sh" ] && source "$HOME/.docker/init-zsh.sh" 2>/dev/null

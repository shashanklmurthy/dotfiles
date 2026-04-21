#!/usr/bin/env bash
set -u

: "${DOTFILES:=$HOME/.dotfiles}"
# shellcheck disable=SC1091
. "$DOTFILES/lib/common.sh"

section "Validating developer tools"

if have aws;   then ok "AWS CLI installed: $(aws --version 2>&1)"; else warn "AWS CLI not installed (optional)"; fi
if have gh;    then ok "GitHub CLI installed: $(gh --version | head -n 1)"; else warn "gh not installed (optional)"; fi
if have code;  then ok "VS Code CLI installed";   else warn "code CLI not installed (optional)"; fi
if have cursor; then ok "Cursor CLI installed";   else warn "cursor CLI not installed (optional)"; fi
if have docker; then ok "docker installed: $(docker --version)"; else warn "docker not installed (optional)"; fi
if have kubectl; then ok "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"; else warn "kubectl not installed (optional)"; fi
if have terraform; then ok "terraform installed: $(terraform version | head -n 1)"; else warn "terraform not installed (optional)"; fi

# Personal Brewfile — single source of truth for CLI tools and GUI apps.
#
# Usage:
#   brew bundle --file=./Brewfile
#   brew bundle check --file=./Brewfile
#   brew bundle cleanup --file=./Brewfile   # preview what would be removed

###############################################################################
# Taps (all public / open source)
###############################################################################
tap "homebrew/bundle"             # required by `brew bundle` itself
tap "homebrew/services"           # `brew services` to manage launchd services

tap "hashicorp/tap"               # HashiCorp tools (packer, vault, consul, ...)
tap "argoproj/tap"                # Argo projects (kubectl-argo-rollouts, ...)
tap "datawire/blackbird"          # Ambassador / Telepresence
tap "derailed/popeye"             # Popeye — k8s cluster sanity scanner
tap "kudobuilder/tap"             # KUDO operator framework (kuttl, ...)
tap "warrensbox/tap"              # tgswitch (Terragrunt version switcher)
tap "romkatv/powerlevel10k"       # Powerlevel10k zsh theme
tap "ankitpokhrel/jira-cli"       # jira-cli — terminal Jira client
tap "snyk/tap"                    # Snyk security scanner CLI
tap "databricks/tap"              # Databricks CLI
tap "fluxcd/tap"                  # Flux CD GitOps CLI

# Optional public taps — uncomment if you use these tools.
# tap "atlassian/acli"            # Atlassian's official CLI (Jira/Confluence/Bitbucket)
# tap "dashlane/tap"              # Dashlane CLI
# tap "noovolari/brew"            # Leapp (OSS AWS SSO / identity manager)

###############################################################################
# Shell / GNU coreutils replacements
###############################################################################
brew "bash"                       # modern bash 5.x (macOS ships an ancient 3.2)
brew "coreutils"                  # GNU versions of ls, cp, mv, cat, etc.
brew "findutils"                  # GNU find/xargs/locate
brew "gawk"                       # GNU awk (more features than BSD awk)
brew "gnu-sed"                    # GNU sed (BSD sed lacks key flags like -i '')
brew "gnu-tar"                    # GNU tar (consistent flags across machines)
brew "grep"                       # GNU grep (BSD grep has fewer flags)
brew "make"                       # GNU make (macOS ships a very old make)
brew "rsync"                      # modern rsync (macOS ships an old, slow build)
brew "diffutils"                  # GNU diff/cmp/diff3
brew "ed"                         # classic line editor (sometimes a script dep)
brew "watch"                      # repeat-run a command to monitor output

###############################################################################
# Zsh / prompt
###############################################################################
brew "zsh-autosuggestions"        # fish-style history suggestions in zsh
brew "zsh-syntax-highlighting"    # syntax highlighting for the zsh command line
brew "zsh-async"                  # async job helper used by some prompts
brew "spaceship"                  # alternative zsh prompt (Powerlevel10k is default)

###############################################################################
# Networking / security / crypto
###############################################################################
brew "openssl@3"                  # OpenSSL 3.x — TLS library many tools depend on
brew "gnupg"                      # GnuPG (gpg) — commit signing, encryption
brew "pinentry"                   # gpg passphrase prompt backend
brew "pinentry-mac"               # macOS-native GUI passphrase dialog for gpg
brew "gnutls"                     # alternative TLS library (some tools require it)
brew "p11-kit"                    # PKCS#11 module loader (needed by gnutls)
brew "unbound"                    # validating DNS resolver (dep of gnutls on mac)
brew "nmap"                       # network scanner / port discovery
brew "ngrep"                      # grep for network traffic
brew "telnet"                     # raw TCP client for debugging
brew "wget"                       # non-interactive HTTP downloader

###############################################################################
# Everyday CLI ergonomics
###############################################################################
brew "bat"                        # `cat` with syntax highlighting and paging
brew "direnv"                     # auto-load .envrc when entering a directory
brew "fzf"                        # fuzzy finder (Ctrl-R / Ctrl-T integration)
brew "jq"                         # JSON query/transform tool
brew "yq"                         # YAML query/transform tool (jq-style)
brew "tldr"                       # concise, example-driven man-page alternative
brew "tree"                       # recursive directory listing
brew "tcptraceroute"              # traceroute over TCP (bypasses ICMP blocks)
brew "navi"                       # interactive cheatsheets in the terminal
brew "thefuck"                    # autocorrects the previous command
brew "figlet"                     # ASCII-art banners (fun in scripts/READMEs)
brew "cloc"                       # count lines of code by language
brew "mas"                        # Mac App Store CLI (install/update store apps)

###############################################################################
# Git & forge CLIs
###############################################################################
brew "git"                        # the VCS itself
brew "gh"                         # GitHub CLI (PRs, releases, gists, auth)
brew "glab"                       # GitLab CLI (MRs, pipelines)
brew "lab"                        # alternative GitLab CLI
brew "gitlab-runner"              # run GitLab CI jobs locally
brew "mercurial"                  # hg — occasionally needed for OSS projects
brew "ankitpokhrel/jira-cli/jira-cli"  # terminal Jira client

###############################################################################
# Languages & runtimes
###############################################################################
brew "python@3.11"                # Python 3.11 (pinned for tools that need it)
brew "python@3.12"                # Python 3.12 (default modern)
brew "node"                       # Node.js LTS (nvm still available for pinning)
brew "go"                         # Go toolchain
brew "rust"                       # Rust toolchain (rustc/cargo)
brew "ruby"                       # Ruby (newer than macOS's system ruby)
brew "brew-gem"                   # install ruby gems as brew formulas

# JDKs (brew-managed). Temurin casks live below for full Eclipse JDK builds.
brew "openjdk@11"                 # OpenJDK 11 LTS
brew "openjdk@17"                 # OpenJDK 17 LTS (default modern)
brew "maven"                      # Maven build tool
brew "gradle"                     # Gradle build tool

###############################################################################
# Version managers
###############################################################################
brew "nvm"                        # Node Version Manager (per-project Node)
brew "pyenv"                      # Python Version Manager (per-project Python)
brew "jenv"                       # Java Version Manager (per-project JDK)
brew "asdf"                       # polyglot version manager (fallback/optional)
brew "tfenv"                      # Terraform version manager
brew "tgenv"                      # Terragrunt version manager
brew "tgswitch"                   # Terragrunt version switcher (alternative)

###############################################################################
# Containers & virtualization
###############################################################################
brew "colima"                     # lightweight container runtime (Docker + k8s)
brew "docker"                     # Docker CLI (daemon comes from Colima/Rancher/DD)
brew "docker-compose"             # Compose v2 CLI
brew "docker-credential-helper"   # `docker login` keychain helper
brew "docker-completion"          # zsh/bash completions for docker
brew "dive"                       # explore Docker image layers interactively
brew "lima"                       # Linux VMs on macOS (used by Colima)
brew "qemu"                       # emulator / VM backend (used by Lima)

###############################################################################
# Kubernetes — core
###############################################################################
brew "kubernetes-cli"             # kubectl — the main K8s CLI
brew "helm"                       # K8s package manager (charts)
brew "k9s"                        # terminal UI for live cluster navigation
brew "kubectx"                    # `kubectx` + `kubens` context/namespace switcher
brew "kustomize"                  # YAML overlay tool for K8s manifests
brew "minikube"                   # local single-node K8s cluster on a VM
brew "kind"                       # Kubernetes IN Docker — disposable clusters
brew "stern"                      # multi-pod log tailer
brew "istioctl"                   # Istio service mesh CLI
brew "linkerd"                    # Linkerd service mesh CLI
brew "krew"                       # plugin manager for kubectl
brew "kube-ps1"                   # show current cluster/namespace in the prompt

###############################################################################
# Kubernetes — GitOps, operators, scanners, extras
###############################################################################
brew "argocd"                     # Argo CD CLI (GitOps for K8s)
brew "fluxcd/tap/flux"            # Flux CD CLI (GitOps for K8s)
brew "helmfile"                   # declaratively manage many Helm releases
brew "kubeseal"                   # Sealed Secrets — encrypt secrets for git
brew "kubeconform"                # fast K8s manifest schema validation
brew "kube-linter"                # static analysis for K8s configs
brew "skaffold"                   # inner-loop K8s dev (build/push/deploy)
brew "tilt"                       # multi-service K8s dev environment
brew "operator-sdk"               # build K8s operators
brew "kudobuilder/tap/kuttl-cli"  # declarative test framework for K8s
brew "argoproj/tap/kubectl-argo-rollouts"  # progressive delivery controller CLI
brew "derailed/popeye/popeye"     # cluster sanity scanner
brew "datawire/blackbird/telepresence"    # local dev against remote K8s services

###############################################################################
# Cloud / Serverless / IaC
###############################################################################
brew "awscli"                     # AWS CLI v2 (also installable via pkg)
brew "aws-sam-cli"                # AWS SAM — serverless app build/deploy/test
brew "azure-cli"                  # Azure CLI (az)
brew "hashicorp/tap/packer"       # build VM/container images from a config
brew "terraform_landscape"        # prettier terraform plan diffs
brew "warrensbox/tap/tgswitch"    # Terragrunt version switcher
brew "tflint"                     # Terraform linter
brew "checkov"                    # IaC security / misconfig scanner
brew "cfn-lint"                   # CloudFormation template linter
brew "actionlint"                 # static checker for GitHub Actions workflow files
brew "zizmor"                     # find security issues in GitHub Actions setups

###############################################################################
# Security scanners (open source)
###############################################################################
brew "snyk/tap/snyk"              # Snyk vulnerability scanner CLI

###############################################################################
# Data / databases
###############################################################################
brew "mysql"                      # MySQL client + optional local server
brew "sqlite"                     # SQLite (newer than macOS's system sqlite)
brew "protobuf"                   # protoc compiler + runtime libs

###############################################################################
# Graph / media support libs (often pulled in as deps, pinned explicitly)
###############################################################################
brew "graphviz"                   # `dot` graph renderer
brew "harfbuzz"                   # text shaping library (pango dep)
brew "pango"                      # text rendering library (graphviz dep)
brew "glib"                       # low-level C library used by many tools
brew "cairo"                      # 2D vector graphics library
brew "fontconfig"                 # font discovery library
brew "freetype"                   # font rendering library
brew "libyaml"                    # YAML parser library (needed by some gems)

###############################################################################
# Python helpers
###############################################################################
brew "pipx"                       # install Python CLI apps in isolated venvs
brew "virtualenv"                 # create isolated Python environments

###############################################################################
# Databricks
###############################################################################
brew "databricks/tap/databricks"  # Databricks CLI (jobs, workspace, clusters)

###############################################################################
# Casks (GUI apps)
###############################################################################
cask "iterm2"                     # terminal emulator (macOS Terminal alternative)
cask "visual-studio-code"         # VS Code editor
cask "cursor"                     # Cursor — AI-first code editor
cask "bruno"                      # API client (OSS alternative to Postman)
cask "meld"                       # visual diff/merge tool
cask "clipy"                      # Clipy — macOS clipboard extension (https://github.com/Clipy/Clipy)
cask "rancher"                    # Rancher Desktop — container runtime + K8s
cask "docker"                     # Docker Desktop (use Rancher OR Docker, not both)

# JDK distributions — all public / open source.
cask "temurin"                    # Eclipse Temurin JDK (latest LTS)
cask "temurin@11"                 # Temurin JDK 11
cask "temurin@17"                 # Temurin JDK 17
cask "temurin@21"                 # Temurin JDK 21
# cask "corretto"                 # Amazon Corretto — uncomment if you want it

# Optional public casks.
cask "leapp"                    # OSS AWS SSO / identity manager (Noovolari)
# cask "google-cloud-sdk"         # gcloud CLI + components

# Personal dotfiles

Based on Mathias Bynens' [dotfiles](https://github.com/mathiasbynens/dotfiles),
extended with a modular install/validate structure. Every module ships its
own `install.sh` and `validate.sh`, and the `Brewfile` is the single source
of truth for CLI tools and GUI casks.

## Layout

```
dotfiles/
  .zshrc, .bashrc, .vimrc, .gitconfig, .aliases, ...   # personal shell configs
  .macos                                               # macOS defaults script
  Brewfile                                             # single source of truth for brew
  setup.sh                                             # one-shot: bootstrap + install + validate
  bootstrap.sh                                         # sync dotfiles into $HOME
  install.sh                                           # run all module installers
  validate.sh                                          # run all module validators
  lib/
    common.sh                                          # shared helpers (confirm, info, ok, err)
  macos/        { install.sh, validate.sh }            # xcode CLT, macOS defaults
  homebrew/     { install.sh, validate.sh }            # brew + `brew bundle`
  git/          { install.sh, validate.sh }            # global git config + aliases
  zsh/          { install.sh, validate.sh }            # oh-my-zsh, p10k, plugins
  node/         { install.sh, validate.sh }            # nvm + Node LTS
  java/         { install.sh, validate.sh }            # jenv + JDK wiring
  development/  { install.sh, validate.sh }            # AWS CLI, pipx, etc.
```

## Quick start on a fresh Mac

```bash
git clone <your-fork-url> ~/.dotfiles
cd ~/.dotfiles
./setup.sh              # bootstrap + install + validate, in that order
```

Non-interactive (for provisioning scripts, CI, or repeat runs):

```bash
./setup.sh -y           # or: DOTFILES_ASSUME_YES=1 ./setup.sh
```

Re-running `./setup.sh` is always safe — every underlying step is idempotent.

## Running one module at a time

Every step is idempotent and standalone:

```bash
./homebrew/install.sh     # just install / update brew packages
./git/install.sh          # just configure git globals
./zsh/install.sh          # just (re)install oh-my-zsh + p10k + plugins
./java/install.sh         # just wire up jenv to installed JDKs
./validate.sh             # run every validator
```

## Brewfile

The `Brewfile` is the single source of truth for CLI tools and GUI casks.
Edit it and re-run:

```bash
brew bundle --file=./Brewfile
brew bundle check --file=./Brewfile
brew bundle cleanup --file=./Brewfile   # preview what is no longer listed
```

It is organized into sections: shell/coreutils, zsh/prompt, networking,
everyday CLI ergonomics, git/forge CLIs, languages/runtimes, version
managers, containers, Kubernetes core, Kubernetes/GitOps extras, cloud +
serverless + IaC, security scanners, data, python helpers, and casks.

## Aliases cheat sheet (see `.aliases` for the full set)

- `k`, `kgp`, `kd`, `kl`, `klf`, `kex`, `kpf` — kubectl shortcuts
- `kx`, `kns` — kubectx / kubens
- `k9` — k9s
- `h`, `hi`, `hui`, `hun`, `ht` — helm
- `acd`, `fx` — argocd / flux (GitOps)
- `d`, `dc`, `dcu`, `dcd`, `dcl` — docker / docker compose
- `tf`, `tfp`, `tfa`, `tff` — terraform (`tg*` for terragrunt)
- `samb`, `samd`, `saml` — AWS SAM
- `sls`, `slsd`, `slsl` — Serverless Framework
- `awsp`, `awswhoami`, `awsls` — AWS CLI
- `ghpr`, `ghrun` — GitHub CLI
- `gs`, `gl`, `glg`, `gla` — extra git helpers
- `brupd`, `brb`, `brbc` — Homebrew

## Adding machine-local / private settings

Nothing sensitive or machine-specific should live in the tracked repo. There
are four untracked override points, each loaded automatically when present:

| File | Loaded by | What to put there |
| ---- | --------- | ----------------- |
| `~/.private.zsh`     | `.zshrc` (last line) | Secrets: API tokens, `AWS_PROFILE` defaults, corp CA bundles, internal aliases. Created as empty by `zsh/install.sh`. |
| `~/.gitconfig.local` | tracked `.gitconfig` via `[include]` | Per-host git overrides: work email, work `signingkey`, `http.proxy`, custom `insteadOf` rules. Created with a commented stub by `git/install.sh`. |
| `~/.extra`           | `.bash_profile` / `.zshrc` | Shared shell config you don't want committed. Works for both bash and zsh. |
| `~/.path`            | `.bash_profile` / `.zshrc` | Extra `PATH` entries, sourced early so later config sees them. |

All four are `.gitignore`-safe by virtue of living in `$HOME`, not in the repo.

### Example `~/.private.zsh`

```bash
export GH_ORG_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
export AWS_PROFILE="work"
alias vpn-on="sudo /opt/corp/vpn connect"
```

### Example `~/.gitconfig.local`

```ini
[user]
    email = you@work.example.com
    signingkey = ABCDEF0123456789

[http]
    proxy = http://proxy.example.com:8080
```

Values in `~/.gitconfig.local` override anything set in the tracked
`~/.gitconfig` because the include comes last. Check what's actually in
effect with `git config --show-origin --get user.email`.

## Updating later

```bash
cd ~/.dotfiles
git pull
./setup.sh -y            # single command: sync + install + validate, no prompts
```

## Credits

- Original structure + many shell helpers: [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- Modular install/validate pattern inspired by Dries Vints, atomantic, and
  similar open-source dotfiles repositories.

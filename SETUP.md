# Setup guide

This document is a **how-to**, not a tour. If you want to understand how the
repo is laid out or why it exists, read `README.md`. This file answers two
questions: _what do I run?_ and _what do I edit?_

---

## 1. First-time setup (fresh machine)

**One command:**

```bash
git clone <your-fork-url> ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh` chains `bootstrap.sh → install.sh → validate.sh`. Re-running it
is safe; every step is idempotent.

### What that single command does — and why the steps exist

| Step (called by `setup.sh`) | Does                                                               | Why it's a separate script                                                           |
| --------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| `bootstrap.sh -f`           | `rsync`s `.zshrc`, `.gitconfig`, `.aliases`, `.vimrc`, etc. to `~` | Safe to re-run with no prompts; it's just file copy with backups.                   |
| `install.sh`                | Installs brew + bundles, sets up zsh/p10k, configures git+GPG      | This is the **interactive** part. Splitting lets you re-run one module in isolation. |
| `validate.sh`               | Runs every module's check script                                   | Pure read-only. Good first thing to run when something seems off.                    |

### Non-interactive mode (one command, zero prompts)

```bash
./setup.sh -y
# or equivalently
DOTFILES_ASSUME_YES=1 ./setup.sh
```

Under `-y`:

- Every `confirm()` prompt auto-answers "yes".
- `git/install.sh` **keeps** your existing `user.name` / `user.email` /
  `user.signingkey` rather than prompting for new ones.
- If no GPG key is set up yet, signing setup is **skipped** (it would block
  on a passphrase prompt). Re-run `./git/install.sh` interactively later to
  generate one.

Re-running `./setup.sh -y` on an already-configured machine is a true no-op
beyond updating brew packages and re-syncing any changed tracked files.

---

## 2. Re-running individual pieces

Every module is **idempotent** — safe to run by itself, multiple times.
Use these when you change only one area and don't want to wait on the others.

```bash
./homebrew/install.sh     # add/remove brew packages in the Brewfile, then run this
./git/install.sh          # change email, credential helper, or GPG key
./zsh/install.sh          # reinstall oh-my-zsh, p10k, plugins; refresh rc files
./node/install.sh         # install/update nvm + Node LTS
./java/install.sh         # (re)wire jenv to installed JDKs
./development/install.sh  # AWS CLI v2, pipx
./macos/install.sh        # Xcode CLT; optionally apply .macos defaults
./validate.sh             # run all validators
./git/validate.sh         # run just one validator
```

---

## 3. What to edit, by task

This is the whole point of the repo: you should rarely need to touch a
script. Almost all customization lives in these files.

### 3.1 Add or remove a brew package or cask

**Edit:** `Brewfile`

```bash
$EDITOR Brewfile
./homebrew/install.sh          # apply changes
# or, directly:
brew bundle --file=./Brewfile
```

**Why:** `Brewfile` is the single source of truth. The install scripts call
`brew bundle` — they don't hardcode package lists. Keeping every package
declaration in one annotated file makes diffs trivial to review and lets
you bring your exact toolchain to a new machine in one command.

### 3.2 Change shell aliases / functions / exports

**Edit one of:**

- `.aliases`   — one-liners (prefer this for new aliases)
- `.functions` — multi-line shell functions
- `.exports`   — environment variables that aren't secrets

These three are sourced by `.zshrc` in that order.

**Why:** Keeping aliases/functions/exports out of `.zshrc` makes `.zshrc`
focused on shell framework wiring (Oh My Zsh, completions, PATH), and lets
Bash users share the same three files without pulling in zsh-specific code.

### 3.3 Add or remove an Oh My Zsh plugin

**Edit:** `.zshrc`, the `plugins=(...)` array near the top of the file.

**Why:** Each plugin adds to shell startup latency, so the list should be
intentional. Keeping it in `.zshrc` also keeps it close to the `source
$ZSH/oh-my-zsh.sh` call that consumes it, so reordering is obvious.

### 3.4 Change your git identity / credential helper / GPG key

**Run:** `./git/install.sh`

Don't edit `~/.gitconfig` directly — the script is the source of truth for
_global_ git config. `~/.gitconfig` in this repo contains only the
tool-agnostic settings (aliases, pager, colors, URL rewrites for
`github.com`). Identity (`user.name`, `user.email`), credential helpers,
and signing keys are written at install time so you can re-run the flow
whenever you:

- switch primary GitHub email
- move to a new machine (need to pick/generate a new GPG key)
- re-authenticate `gh` and want it re-registered as the git credential helper

**What the script asks you:**

1. Confirm / change `user.name`.
2. Pick a primary email from a menu. The menu is built from your current
   `user.email` plus emails `gh` knows about for your account. You can
   also type one in.
3. Whether to use VS Code / Cursor as your editor + diff + merge tool.
4. Pick an existing GPG key (filtered to your chosen email) **or** generate
   a new RSA-4096 signing key with 2-year expiry. The script then sets
   `user.signingkey`, `commit.gpgsign=true`, and `tag.gpgsign=true`,
   copies the public key to your clipboard, and offers to upload it to
   GitHub via `gh gpg-key add`.

**Why prompt for email every time:** Many people have several GitHub
identities (personal, work, OSS). Picking explicitly prevents silently
committing under the wrong identity after a context switch.

**Why generate a new GPG key per machine:** Private keys should not be
copied between machines. Generating a fresh per-machine key is the
recommended workflow; GitHub accepts multiple keys on one account.

### 3.5 Change macOS defaults

**Edit:** `.macos`

Then either re-run `./macos/install.sh` (which will ask before applying),
or run `bash .macos` directly.

### 3.6 Add a machine-specific override that should NOT be committed

All four files below live in `$HOME`, never in this repo. Each is loaded
automatically when it exists, so you can create it and open a new shell.

| File | Loaded by | Purpose |
| ---- | --------- | ------- |
| `~/.private.zsh`     | `.zshrc` (last line)                    | Shell secrets, tokens, per-machine aliases. Created empty by `zsh/install.sh`. |
| `~/.gitconfig.local` | tracked `.gitconfig` via `[include]`    | Per-host git overrides (work email, work signingkey, `http.proxy`). Created as a commented stub by `git/install.sh`. |
| `~/.extra`           | `.bash_profile` / `.zshrc`              | Non-secret shell config you still want out of git. |
| `~/.path`            | `.bash_profile` / `.zshrc`              | Extra `PATH` entries; sourced early so later config sees them. |

**Example `~/.private.zsh`:**

```bash
export GH_ORG_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
export AWS_PROFILE="work"
export NODE_EXTRA_CA_CERTS="/etc/ssl/corp-ca.pem"
alias vpn-on="sudo /opt/corp/vpn connect"
```

**Example `~/.gitconfig.local`** (work laptop with a different email and
GPG key than the tracked `.gitconfig` defaults):

```ini
[user]
    email = you@work.example.com
    signingkey = ABCDEF0123456789

[http]
    proxy = http://proxy.example.com:8080
```

To verify which file is providing a given git setting after you edit it:

```bash
git config --show-origin --get user.email
git config --show-origin --get user.signingkey
```

**Why split instead of one file:**

- `~/.private.zsh` keeps shell secrets off disk-in-repo and out of screen
  shares; it's sourced *last* in `.zshrc` so it can override anything above.
- `~/.gitconfig.local` lets git itself layer per-host overrides via its
  native `[include]` directive — no shell tricks, no branch per machine.
- `~/.extra` / `~/.path` predate the others and exist only because bash
  (not just zsh) needs a hook too; leaving them in place keeps
  compatibility with Mathias Bynens' original dotfiles scripts.

### 3.7 Add a completely new module (say, Rust-specific setup)

1. Create `rust/install.sh` and `rust/validate.sh` (follow the existing
   modules as templates; source `$DOTFILES/lib/common.sh` for helpers).
2. Add two lines to `install.sh` and `validate.sh` at the repo root:
   ```bash
   . "$DOTFILES/rust/install.sh"
   . "$DOTFILES/rust/validate.sh"
   ```
3. Add any brew packages to the `Brewfile`.

**Why this shape:** Modules are just sourced shell files, so they share
`$DOTFILES`, logging helpers, and `confirm` prompts from `lib/common.sh`.
No plugin system, no framework — easy to read end-to-end.

---

## 4. Updating an existing machine

```bash
cd ~/.dotfiles
git pull
./bootstrap.sh -f        # force-sync tracked files into $HOME (no prompt)
./install.sh             # pick up any new tooling added to modules / Brewfile
```

**Why `bootstrap.sh -f` is safe:** It `rsync`s only tracked dotfiles
(`.zshrc`, `.aliases`, etc.) into `$HOME`. It excludes the install scripts,
`Brewfile`, `README.md`, and all the module directories, so those stay in
the repo where they belong and don't litter `$HOME`.

---

## 5. Troubleshooting quick reference

| Symptom                             | First thing to check                                               |
| ----------------------------------- | ------------------------------------------------------------------ |
| Shell feels slow                    | `.zshrc` plugin list — each plugin adds startup time               |
| `brew bundle` keeps reinstalling    | Run `brew bundle check --file=./Brewfile` to see what's missing    |
| `gh` not authenticating commits     | Re-run `gh auth login`, then `./git/install.sh` to re-wire helpers |
| "gpg: signing failed: Inappropriate ioctl for device" | `export GPG_TTY=$(tty)` — already set in `.exports`, open a new shell |
| New command not found after install | Open a new shell; `PATH` updates don't apply to existing sessions  |
| `./validate.sh` flags something     | Re-run just that module's install, e.g. `./git/install.sh`         |

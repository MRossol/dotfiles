# dotfiles

Terminal and git config for a new machine. Symlinked into `$HOME` via `bootstrap.sh`; packages and Oh My Zsh via `install.sh`.

## Quick start

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
./bootstrap.sh
```

Restart the terminal (or `exec zsh -l`).

### Linux (Debian/Ubuntu, Chromebook Crostini)

`install.sh` uses `apt` for packages. If zsh is not your login shell yet:

```bash
chsh -s "$(command -v zsh)"
```

### macOS

`install.sh` installs [Homebrew](https://brew.sh/) if needed, CLI tools, iTerm2, JetBrains Mono Nerd Font, and a shallow clone of [iTerm2 color schemes](https://github.com/mbadolato/iTerm2-Color-Schemes) under `~/.config/iterm2-color-schemes`. Day-to-day colors come from the **MRossol** Dynamic Profile (`iterm-profile.json`).

## Secrets

Create `~/.config/.exports.local` on each machine (not committed). Put API tokens and machine-specific paths there. It is sourced from [`.exports`](.exports) when present.

## What gets linked

`bootstrap.sh` symlinks zsh config, git config, pre-commit config, bat/ruff/conda settings, and (on macOS) the iTerm Dynamic Profile. When `~/.claude` exists, it also runs [`link-agent-skills.sh`](link-agent-skills.sh) to publish Claude-installed skills (and compatible plugins) into Codex and Antigravity via symlinks. See [`AGENTS.md`](AGENTS.md) for conventions when editing this repo.

## Optional

- **Miniconda**: paths in `.exports` assume `$HOME/miniconda3`.
- **NVM / pnpm**: loaded from `.exports` when installed.
- **Pre-commit**: `pip install pre-commit` then `pre-commit install` in a project that uses `~/.pre-commit-config.yaml`.

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

`bootstrap.sh` symlinks zsh config, git config, pre-commit config, bat/ruff/conda settings, and (on macOS) the iTerm Dynamic Profile. **Agent skills:** if Claude already has plugins installed, it runs [`link-agent-skills.sh`](link-agent-skills.sh) to symlink them into Codex and Antigravity. On a fresh machine (no `~/.claude/plugins/installed_plugins.json` yet), it runs [`install-agent-skills.sh`](install-agent-skills.sh) with [`agent-skills.txt`](agent-skills.txt) via `gh skill install`. CrossnoKaye-only skills live in [`agent-skills.ck.txt`](agent-skills.ck.txt) and are installed manually once `gh` can reach private repos. See [`AGENTS.md`](AGENTS.md) for conventions when editing this repo.

## Optional

- **Miniconda**: paths in `.exports` assume `$HOME/miniconda3`.
- **NVM / pnpm**: loaded from `.exports` when installed.
- **Pre-commit**: `pip install pre-commit` then `pre-commit install` in a project that uses `~/.pre-commit-config.yaml`.

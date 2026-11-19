# Agent notes (dotfiles)

This repo boots a **zsh + git** environment on **macOS (Apple Silicon)** or **Debian/Ubuntu Linux** (including Chromebook Crostini). Humans run `./install.sh` then `./bootstrap.sh`.

## Install split

| Script | Role |
|--------|------|
| `install.sh` | OS-specific packages, Oh My Zsh (`--unattended` so it does not replace `.zshrc`), zsh plugins, powerlevel10k |
| `bootstrap.sh` | Symlinks repo files into `$HOME` (and iTerm Dynamic Profile on Darwin only); links Claude skills or runs `install-agent-skills.sh` on a fresh machine |

`install.sh` branches on `uname -s`. Do not merge Mac and Linux package lists: Mac uses **Homebrew formula/cask names**; Linux uses **apt** package names.

## Platform-specific install behavior

- **Mac only**: Homebrew GNU userland formulae, `iterm2` cask, nerd font, shallow clone of `mbadolato/iTerm2-Color-Schemes` → `~/.config/iterm2-color-schemes`.
- **Linux**: `apt` for `zsh`, `ripgrep`, `bat`, `neovim`, `fzf`, etc. `eza` from apt when available, else latest GitHub release into `~/.local/bin`. If Debian ships `batcat` only, symlink `~/.local/bin/bat` → `batcat`.

## Shell layout

- `.zshrc` — Oh My Zsh, p10k, fzf keybindings (first hit among Homebrew `/opt/homebrew/opt/fzf/shell`, `/usr/share/fzf`, `/usr/share/doc/fzf/examples`), then `~/.config/.aliases` and `~/.config/.exports`.
- `.zprofile` — intentionally minimal; do not `source ~/.zshrc` here (avoids double init).
- Machine-only tools must be **guarded** (`command -v`, `[[ -f path ]]`) so Linux shells still start: `kubectl`, `ckutil`, gcloud SDK, `it`, antigravity, `/opt/homebrew`.

## Secrets

`~/.config/.exports.local` is **gitignored**, **not** symlinked by bootstrap. Document new secret vars there, not in `.exports`.

## Claude → Codex / Antigravity skills

- **`agent-skills.txt`** / **`agent-skills.ck.txt`**: committed snapshots for `gh skill install` (public vs CrossnoKaye). Update when you add or remove Claude plugins with skills; do not use `anthropics/claude-plugins-official --all` in the public file (that installs the whole marketplace).
- **`install-agent-skills.sh`**: reads a catalog; targets `claude-code`, `codex`, and `antigravity2.0` at user scope; no-ops if `gh` or `gh skill` is missing.
- **`link-agent-skills.sh`**: when `~/.claude/plugins/installed_plugins.json` lists plugins, bootstrap symlinks into `~/.codex/skills`, `~/.gemini/config/skills`, and compatible `~/.gemini/config/plugins`. Skips real dirs (e.g. Antigravity `egm`, `superpowers`).

## Do not re-vendor

- iTerm color schemes (246 files): clone on Mac during `install.sh`.
- Legacy bash/base16/fzf dotfiles: dropped; zsh is the target shell.

## Editing checklist

1. If you add a bootstrap symlink, the source file must exist in the repo.
2. If you add a PATH or `eval` in `.exports` / `.zshrc`, guard it for the other OS.
3. Oh My Zsh install must stay `--unattended`.
4. Keep `README.md` in sync with install steps; keep this file for non-obvious conventions only.

# Agent notes (dotfiles)

This repo boots a **zsh + git** environment on **macOS (Apple Silicon)** or **Debian/Ubuntu Linux** (including Chromebook Crostini). Humans run `./install.sh` then `./bootstrap.sh`.

## Install split

| Script | Role |
|--------|------|
| `install.sh` | OS-specific packages, Oh My Zsh (`--unattended` so it does not replace `.zshrc`), zsh plugins, powerlevel10k |
| `bootstrap.sh` | Symlinks repo files into `$HOME` (and iTerm Dynamic Profile on Darwin only); runs `link-agent-skills.sh` when present |

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

`link-agent-skills.sh` (from `bootstrap.sh`) symlinks skills from the local Claude install into `~/.codex/skills` and `~/.gemini/config/skills`, and symlinks Antigravity-compatible Claude plugin trees into `~/.gemini/config/plugins`. It no-ops without `~/.claude`. It only replaces destinations that are already symlinks into `~/.claude`; real directories (e.g. Antigravity-installed `egm`, `superpowers`) are left alone.

## Do not re-vendor

- iTerm color schemes (246 files): clone on Mac during `install.sh`.
- Legacy bash/base16/fzf dotfiles: dropped; zsh is the target shell.

## Editing checklist

1. If you add a bootstrap symlink, the source file must exist in the repo.
2. If you add a PATH or `eval` in `.exports` / `.zshrc`, guard it for the other OS.
3. Oh My Zsh install must stay `--unattended`.
4. Keep `README.md` in sync with install steps; keep this file for non-obvious conventions only.

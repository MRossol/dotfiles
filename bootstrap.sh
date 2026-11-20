#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src=$1 dest=$2
  local parent
  parent="$(dirname "$dest")"
  mkdir -p "$parent"
  if [[ -e "$parent" ]] && [[ ! -O "$parent" ]]; then
    echo "$parent is not owned by you; fixing ownership (sudo)..."
    sudo chown -R "$(id -un):$(id -gn)" "$parent"
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -d "$dest" && ! -L "$dest" ]]; then
      rm -rf "$dest"
    else
      rm -f "$dest"
    fi
  fi
  ln -s "$src" "$dest"
}

echo "Symlinking files from $DOTFILES_DIR"
mkdir -p ~/.config/bat ~/.git-templates/hooks

link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
link "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/.condarc" "$HOME/.condarc"
link "$DOTFILES_DIR/.ruff.toml" "$HOME/.ruff.toml"
link "$DOTFILES_DIR/.exports" "$HOME/.config/.exports"
link "$DOTFILES_DIR/.aliases" "$HOME/.config/.aliases"
link "$DOTFILES_DIR/.batconfig" "$HOME/.config/bat/config"
link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/.gitignore" "$HOME/.gitignore"
link "$DOTFILES_DIR/.pre-commit-config.yaml" "$HOME/.pre-commit-config.yaml"
link "$DOTFILES_DIR/.git-templates/hooks/pre-commit" "$HOME/.git-templates/hooks/pre-commit"
chmod +x "$DOTFILES_DIR/.git-templates/hooks/pre-commit"

if [[ -d "$DOTFILES_DIR/.git/hooks" ]]; then
  link "$DOTFILES_DIR/.git-templates/hooks/pre-commit" "$DOTFILES_DIR/.git/hooks/pre-commit"
fi

if [[ "$(uname -s)" == Darwin ]] && [[ -f "$DOTFILES_DIR/iterm-profile.json" ]]; then
  ITERM_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$ITERM_DIR"
  WRAPPED="$DOTFILES_DIR/.iterm-dynamic-profile.json"
  if [[ ! -f "$WRAPPED" ]] || [[ "$DOTFILES_DIR/iterm-profile.json" -nt "$WRAPPED" ]]; then
    printf '{"Profiles":[' > "$WRAPPED"
    cat "$DOTFILES_DIR/iterm-profile.json" >> "$WRAPPED"
    printf ']}\n' >> "$WRAPPED"
  fi
  link "$WRAPPED" "$ITERM_DIR/MRossol.json"
fi

if [[ -d "$DOTFILES_DIR/skills" ]]; then
  mkdir -p "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.gemini/config/skills"
  for skill_dir in "$DOTFILES_DIR"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    link "$skill_dir" "$HOME/.claude/skills/$skill_name"
    link "$skill_dir" "$HOME/.codex/skills/$skill_name"
    link "$skill_dir" "$HOME/.gemini/config/skills/$skill_name"
  done
fi

claude_plugins_installed() {
  local f="$HOME/.claude/plugins/installed_plugins.json"
  [[ -f "$f" ]] || return 1
  python3 -c 'import json, sys; d=json.load(open(sys.argv[1])); sys.exit(0 if d.get("plugins") else 1)' "$f"
}

if claude_plugins_installed && [[ -x "$DOTFILES_DIR/link-agent-skills.sh" ]]; then
  "$DOTFILES_DIR/link-agent-skills.sh"
elif [[ -x "$DOTFILES_DIR/install-agent-skills.sh" ]]; then
  "$DOTFILES_DIR/install-agent-skills.sh"
fi

#!/usr/bin/env bash
# Install agent skills from agent-skills.txt via `gh skill install` (multi-host user scope).
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="${1:-$DOTFILES_DIR/agent-skills.txt}"

AGENTS=(claude-code codex antigravity2.0)
CLAUDE_SKILLS="$HOME/.claude/skills"

if [[ ! -f "$CATALOG" ]]; then
  echo "No catalog at $CATALOG"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh not found; skipping agent skill install (install GitHub CLI and re-run)."
  exit 0
fi

if ! gh skill install --help >/dev/null 2>&1; then
  echo "gh skill not available; upgrade GitHub CLI and re-run."
  exit 0
fi

skill_present() {
  local name=$1
  [[ -e "$CLAUDE_SKILLS/$name" || -L "$CLAUDE_SKILLS/$name" ]]
}

install_line() {
  local repo=$1
  shift
  local -a skills=("$@")

  if ((${#skills[@]} == 1)) && [[ "${skills[0]}" == "--all" ]]; then
    echo "gh skill install $repo --all ..."
    gh skill install "$repo" --all \
      --agent "${AGENTS[0]}" --agent "${AGENTS[1]}" --agent "${AGENTS[2]}" \
      --scope user -f
    return 0
  fi

  local -a to_install=()
  local s
  for s in "${skills[@]}"; do
    if skill_present "$s"; then
      echo "skip $s (already in $CLAUDE_SKILLS)"
    else
      to_install+=("$s")
    fi
  done

  ((${#to_install[@]} == 0)) && return 0

  echo "gh skill install $repo ${to_install[*]} ..."
  gh skill install "$repo" "${to_install[@]}" \
    --agent "${AGENTS[0]}" --agent "${AGENTS[1]}" --agent "${AGENTS[2]}" \
    --scope user -f
}

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"
  [[ -z "$line" ]] && continue
  # shellcheck disable=SC2206
  parts=($line)
  repo="${parts[0]}"
  install_line "$repo" "${parts[@]:1}"
done <"$CATALOG"

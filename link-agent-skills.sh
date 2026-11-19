#!/usr/bin/env bash
# Symlink Claude-installed skills (and compatible plugins) for Codex and Antigravity.
# Claude remains the source of truth for installs; this script only publishes links.
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CODEX_SKILLS="$HOME/.codex/skills"
GEMINI_SKILLS="$HOME/.gemini/config/skills"
GEMINI_PLUGINS="$HOME/.gemini/config/plugins"

if [[ ! -d "$CLAUDE_HOME" ]]; then
  echo "No $CLAUDE_HOME; skipping agent skill links."
  exit 0
fi

abs_path() {
  python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

under_claude() {
  local target resolved claude_real
  target=$1
  [[ -L "$target" || -e "$target" ]] || return 1
  resolved="$(abs_path "$target")"
  claude_real="$(abs_path "$CLAUDE_HOME")"
  [[ "$resolved" == "$claude_real" || "$resolved" == "$claude_real"/* ]]
}

our_claude_symlink() {
  local dest=$1
  [[ -L "$dest" ]] || return 1
  under_claude "$(readlink "$dest")"
}

emit() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "would: $*"
  else
    echo "$@"
  fi
}

link_symlink() {
  local src=$1 dest=$2
  local parent src_abs
  src_abs="$(abs_path "$src")"
  parent="$(dirname "$dest")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    emit "ln -s $src_abs -> $dest"
    return 0
  fi
  mkdir -p "$parent"
  if [[ -L "$dest" ]]; then
    local cur
    cur="$(abs_path "$dest")"
    if [[ "$cur" == "$src_abs" ]]; then
      return 0
    fi
    if our_claude_symlink "$dest"; then
      rm -f "$dest"
    else
      emit "skip $dest (symlink not managed by this script)"
      return 0
    fi
  elif [[ -e "$dest" ]]; then
    emit "skip $dest (exists and is not our symlink)"
    return 0
  fi
  ln -s "$src_abs" "$dest"
  emit "ln -s $src_abs -> $dest"
}

remove_stale_symlink() {
  local dest=$1
  [[ -L "$dest" ]] || return 0
  our_claude_symlink "$dest" || return 0
  if [[ "$DRY_RUN" -eq 1 ]]; then
    emit "rm -f $dest"
  else
    rm -f "$dest"
    emit "rm -f $dest"
  fi
}

declare -a WANT_CODEX_SKILL=()
declare -a WANT_GEMINI_SKILL=()
declare -a WANT_AGY_PLUGIN=()

while IFS= read -r line; do
  kind="${line%%$'\t'*}"
  rest="${line#*$'\t'}"
  case "$kind" in
    AGY_PLUGIN)
      name="${rest%%$'\t'*}"
      src="${rest#*$'\t'}"
      link_symlink "$src" "$GEMINI_PLUGINS/$name"
      WANT_AGY_PLUGIN+=("$name")
      ;;
    SKILL)
      IFS=$'\t' read -r dest src gemini_flat <<<"$rest"
      link_symlink "$src" "$CODEX_SKILLS/$dest"
      WANT_CODEX_SKILL+=("$dest")
      if [[ "$gemini_flat" == "1" ]]; then
        link_symlink "$src" "$GEMINI_SKILLS/$dest"
        WANT_GEMINI_SKILL+=("$dest")
      fi
      ;;
  esac
done < <(python3 - "$CLAUDE_HOME" <<'PY'
import json
import sys
from pathlib import Path

claude_home = Path(sys.argv[1]).expanduser().resolve()
plugins_json = claude_home / "plugins" / "installed_plugins.json"

SKIP_AGY_PLUGIN = {"egm", "superpowers"}


def skill_dirs(root: Path):
    if not root.is_dir():
        return
    for child in sorted(root.iterdir()):
        if child.is_dir() and (child / "SKILL.md").is_file():
            yield child.resolve()


def latest_install(records):
    if not records:
        return None
    return max(records, key=lambda r: r.get("lastUpdated", ""))


def plugin_name(key: str) -> str:
    return key.split("@", 1)[0]


def agy_compatible(install_path: Path) -> bool:
    return (install_path / "plugin.json").is_file() or (
        install_path / ".antigravity-plugin" / "plugin.json"
    ).is_file()


plugins = {}
if plugins_json.is_file():
    data = json.loads(plugins_json.read_text())
    for key, records in data.get("plugins", {}).items():
        inst = latest_install(records)
        if not inst:
            continue
        path = Path(inst["installPath"]).expanduser().resolve()
        if path.is_dir():
            plugins[plugin_name(key)] = path

used_skill_names = set()
skill_links = []
agy_plugin_links = []
gemini_skip_flat_plugins = set(SKIP_AGY_PLUGIN)

skills_root = claude_home / "skills"
if skills_root.is_dir():
    for child in sorted(skills_root.iterdir()):
        if child.name == "synced":
            continue
        if child.is_dir() and (child / "SKILL.md").is_file():
            name = child.name
            used_skill_names.add(name)
            skill_links.append((name, child.resolve(), True))
        elif child.is_symlink():
            resolved = child.resolve()
            if resolved.is_dir() and (resolved / "SKILL.md").is_file():
                name = child.name
                used_skill_names.add(name)
                skill_links.append((name, resolved, True))

synced_root = skills_root / "synced"
if synced_root.is_dir():
    for bundle in sorted(synced_root.iterdir()):
        if not bundle.is_dir():
            continue
        for skill in skill_dirs(bundle):
            name = skill.name
            if name in used_skill_names:
                dest = f"{bundle.name[:8]}--{name}"
            else:
                dest = name
                used_skill_names.add(name)
            skill_links.append((dest, skill, True))

for pname, install_path in sorted(plugins.items()):
    if agy_compatible(install_path):
        if pname not in SKIP_AGY_PLUGIN:
            agy_plugin_links.append((pname, install_path))
        gemini_skip_flat_plugins.add(pname)

    skills_dir = install_path / "skills"
    if not skills_dir.is_dir():
        continue
    for skill in skill_dirs(skills_dir):
        name = skill.name
        if name in used_skill_names:
            dest = f"{pname}--{name}"
        else:
            dest = name
            used_skill_names.add(name)
        gemini_flat = pname not in gemini_skip_flat_plugins
        skill_links.append((dest, skill, gemini_flat))

for pname, path in agy_plugin_links:
    print(f"AGY_PLUGIN\t{pname}\t{path}")
for dest, src, gemini_flat in skill_links:
    print(f"SKILL\t{dest}\t{src}\t{1 if gemini_flat else 0}")
PY
)

want_member() {
  local needle=$1
  shift
  local x
  for x in "$@"; do
    [[ "$x" == "$needle" ]] && return 0
  done
  return 1
}

prune_stale() {
  local dir=$1
  shift
  local -a want=("$@")
  [[ -d "$dir" ]] || return 0
  local entry base
  for entry in "$dir"/*; do
    [[ -e "$entry" || -L "$entry" ]] || continue
    base="$(basename "$entry")"
    if [[ "$base" == ".system" ]]; then
      continue
    fi
    if want_member "$base" "${want[@]}"; then
      continue
    fi
    remove_stale_symlink "$entry"
  done
}

prune_stale "$CODEX_SKILLS" "${WANT_CODEX_SKILL[@]}"
prune_stale "$GEMINI_SKILLS" "${WANT_GEMINI_SKILL[@]}"
prune_stale "$GEMINI_PLUGINS" "${WANT_AGY_PLUGIN[@]}"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "dry-run complete ($((${#WANT_CODEX_SKILL[@]})) codex skills, $((${#WANT_GEMINI_SKILL[@]})) gemini skills, $((${#WANT_AGY_PLUGIN[@]})) gemini plugins)"
fi

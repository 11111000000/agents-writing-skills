#!/usr/bin/env bash
# install.sh — install skills and prompts from agents-writing-skills repo
# Usage:
#   ./install.sh opencode           # install all skills to opencode
#   ./install.sh pi                 # install all skills + prompts to pi
#   ./install.sh all                # install everywhere
#   ./install.sh skill <name>       # install single skill
#   ./install.sh prompt <name>      # install single prompt
#   ./install.sh list               # list available skills/prompts
#   ./install.sh uninstall opencode # remove skills from opencode
#   ./install.sh uninstall pi       # remove skills + prompts from pi

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PROMPTS_DIR="$REPO_ROOT/prompts"

OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
PI_SKILLS_DIR="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"
PI_PROMPTS_DIR="${PI_PROMPTS_DIR:-$HOME/.pi/agent/prompts}"

log() { printf '\033[1;34m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31m[err]\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  opencode             Install all skills to $OPENCODE_SKILLS_DIR
  pi                   Install all skills + prompts to pi
  all                  Install everywhere
  skill <name>         Install single skill to both opencode and pi
  prompt <name>        Install single prompt to pi
  list                 List available skills and prompts
  uninstall opencode   Remove installed skills from opencode
  uninstall pi         Remove installed skills and prompts from pi

Environment:
  OPENCODE_SKILLS_DIR   default: $HOME/.config/opencode/skills
  PI_SKILLS_DIR         default: $HOME/.pi/agent/skills
  PI_PROMPTS_DIR        default: $HOME/.pi/agent/prompts

Examples:
  $0 opencode
  $0 pi
  $0 skill humanize-writer
  $0 list
EOF
}

install_skill() {
  local name="$1"
  local src="$SKILLS_DIR/$name"
  if [[ ! -d "$src" ]]; then
    err "Skill not found: $name (in $SKILLS_DIR)"
    return 1
  fi
  if [[ ! -f "$src/SKILL.md" ]]; then
    err "Missing SKILL.md in $src"
    return 1
  fi
  # opencode
  if [[ -d "$OPENCODE_SKILLS_DIR" ]] || mkdir -p "$OPENCODE_SKILLS_DIR" 2>/dev/null; then
    cp -R "$src" "$OPENCODE_SKILLS_DIR/$name"
    ok "opencode: $name → $OPENCODE_SKILLS_DIR/$name"
  else
    warn "Skipped opencode (no write access)"
  fi
  # pi
  if [[ -d "$PI_SKILLS_DIR" ]] || mkdir -p "$PI_SKILLS_DIR" 2>/dev/null; then
    cp -R "$src" "$PI_SKILLS_DIR/$name"
    ok "pi: $name → $PI_SKILLS_DIR/$name"
  else
    warn "Skipped pi (no write access)"
  fi
}

install_prompt() {
  local name="$1"
  local src="$PROMPTS_DIR/$name.md"
  if [[ ! -f "$src" ]]; then
    err "Prompt not found: $name (in $PROMPTS_DIR)"
    return 1
  fi
  if [[ -d "$PI_PROMPTS_DIR" ]] || mkdir -p "$PI_PROMPTS_DIR" 2>/dev/null; then
    cp "$src" "$PI_PROMPTS_DIR/$name.md"
    ok "pi: prompt $name → $PI_PROMPTS_DIR/$name.md"
  else
    warn "Skipped pi (no write access)"
  fi
}

install_all_skills() {
  log "Installing all skills to opencode and pi..."
  local count=0
  for skill_dir in "$SKILLS_DIR"/*/; do
    [[ "$(basename "$skill_dir")" == "template-skill" ]] && continue
    local name
    name="$(basename "$skill_dir")"
    if install_skill "$name"; then
      ((count++))
    fi
  done
  ok "Installed $count skills"
}

install_all_prompts() {
  log "Installing all prompts to pi..."
  local count=0
  for prompt_file in "$PROMPTS_DIR"/*.md; do
    local name
    name="$(basename "$prompt_file" .md)"
    if install_prompt "$name"; then
      ((count++))
    fi
  done
  ok "Installed $count prompts"
}

uninstall_opencode() {
  log "Removing our skills from opencode..."
  for skill_dir in "$SKILLS_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ -d "$OPENCODE_SKILLS_DIR/$name" ]] && rm -rf "$OPENCODE_SKILLS_DIR/$name" && ok "removed $name"
  done
}

uninstall_pi() {
  log "Removing our skills and prompts from pi..."
  for skill_dir in "$SKILLS_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    [[ -d "$PI_SKILLS_DIR/$name" ]] && rm -rf "$PI_SKILLS_DIR/$name" && ok "removed skill $name"
  done
  for prompt_file in "$PROMPTS_DIR"/*.md; do
    local name
    name="$(basename "$prompt_file" .md)"
    [[ -f "$PI_PROMPTS_DIR/$name.md" ]] && rm "$PI_PROMPTS_DIR/$name.md" && ok "removed prompt $name"
  done
}

list_items() {
  log "Available skills:"
  for skill_dir in "$SKILLS_DIR"/*/; do
    local name
    name="$(basename "$skill_dir")"
    local desc
    desc="$(grep -m1 '^description:' "$skill_dir/SKILL.md" 2>/dev/null | sed 's/^description:[[:space:]]*//')"
    printf '  %s\n    %s\n' "$name" "$desc"
  done
  log "Available prompts (pi):"
  for prompt_file in "$PROMPTS_DIR"/*.md; do
    local name
    name="$(basename "$prompt_file" .md)"
    local desc
    desc="$(grep -m1 '^description:' "$prompt_file" 2>/dev/null | sed 's/^description:[[:space:]]*//')"
    printf '  %s\n    %s\n' "$name" "$desc"
  done
}

main() {
  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    opencode)
      install_all_skills
      ;;
    pi)
      install_all_skills
      install_all_prompts
      ;;
    all)
      install_all_skills
      install_all_prompts
      ;;
    skill)
      [[ $# -lt 2 ]] && { err "Usage: $0 skill <name>"; exit 1; }
      install_skill "$2"
      ;;
    prompt)
      [[ $# -lt 2 ]] && { err "Usage: $0 prompt <name>"; exit 1; }
      install_prompt "$2"
      ;;
    list)
      list_items
      ;;
    uninstall)
      [[ $# -lt 2 ]] && { err "Usage: $0 uninstall {opencode|pi}"; exit 1; }
      case "$2" in
        opencode) uninstall_opencode ;;
        pi) uninstall_pi ;;
        *) err "Unknown uninstall target: $2"; exit 1 ;;
      esac
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      err "Unknown command: $cmd"
      usage
      exit 1
      ;;
  esac
}

main "$@"
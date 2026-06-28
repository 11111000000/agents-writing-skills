#!/usr/bin/env bash
# sync-obsidian.sh — sync local Obsidian vault with knowledge/ in this repo
# Usage: ./scripts/sync-obsidian.sh [direction]
#   direction: pull (default) — copy knowledge/ → ~/Desktop/AgentWritingBase/Obsidian/
#             push            — copy ~/Desktop/AgentWritingBase/Obsidian/ → knowledge/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"
OBSIDIAN_DIR="${OBSIDIAN_DIR:-$HOME/Desktop/AgentWritingBase/Obsidian}"
DIRECTION="${1:-pull}"

log() { printf '\033[1;34m[sync]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }

if [[ ! -d "$OBSIDIAN_DIR" ]]; then
  warn "Obsidian vault not found at $OBSIDIAN_DIR"
  warn "Set OBSIDIAN_DIR environment variable to override."
  exit 1
fi

case "$DIRECTION" in
  pull)
    log "Pulling from $KNOWLEDGE_DIR → $OBSIDIAN_DIR"
    rsync -av --delete \
      --exclude='.obsidian' \
      --exclude='*.swp' \
      "$KNOWLEDGE_DIR/" "$OBSIDIAN_DIR/"
    log "Done. Open $OBSIDIAN_DIR in Obsidian."
    ;;
  push)
    log "Pushing from $OBSIDIAN_DIR → $KNOWLEDGE_DIR"
    if [[ -d "$KNOWLEDGE_DIR/.git" ]] || git -C "$REPO_ROOT" ls-files --error-unmatch "$KNOWLEDGE_DIR" >/dev/null 2>&1; then
      warn "knowledge/ is tracked by git. Commit local changes first or use git pull --rebase."
    fi
    rsync -av --delete \
      --exclude='.obsidian' \
      --exclude='*.swp' \
      "$OBSIDIAN_DIR/" "$KNOWLEDGE_DIR/"
    log "Done. Review with 'git diff' before committing."
    ;;
  *)
    echo "Usage: $0 [pull|push]" >&2
    exit 1
    ;;
esac
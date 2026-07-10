#!/usr/bin/env bash
# scripts/install-knowledge.sh
# Устанавливает knowledge base (Obsidian vault) для скилов agents-writing-skills.
# Без него ссылки в SKILL.md работают только при наличии интернета.
#
# Использование:
#   ./scripts/install-knowledge.sh                 # clone в ~/.cache/agents-writing-skills/
#   ./scripts/install-knowledge.sh /custom/path    # clone в произвольный путь
#   ./scripts/install-knowledge.sh --update        # обновить существующую копию
#
# После установки все SKILL.md ссылки ~/Desktop/AgentWritingBase/... не нужны —
# используйте GitHub URLs (по умолчанию) или экспортируйте KNOWLEDGE_PATH.

set -euo pipefail

REPO_URL="https://github.com/11111000000/agents-writing-skills.git"
DEFAULT_PATH="${HOME}/.cache/agents-writing-skills-knowledge"

# Parse args
TARGET_PATH="${DEFAULT_PATH}"
ACTION="install"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --update) ACTION="update"; shift ;;
    --help|-h)
      cat <<EOF
Usage: $0 [path] [--update]

Path:    Where to clone the knowledge base (default: $DEFAULT_PATH)
--update: git pull in an existing clone instead of cloning fresh

Examples:
  $0                       # install to ~/.cache/agents-writing-skills-knowledge
  $0 /opt/agent-kb         # install to /opt/agent-kb
  $0 --update              # update existing install in default location
  $0 /opt/agent-kb --update # update existing custom install
EOF
      exit 0
      ;;
    *) TARGET_PATH="$1"; shift ;;
  esac
done

# Action
if [[ "$ACTION" == "update" ]]; then
  if [[ -d "$TARGET_PATH/.git" ]]; then
    echo "Updating knowledge base at $TARGET_PATH..."
    git -C "$TARGET_PATH" pull --ff-only
  else
    echo "Error: $TARGET_PATH is not a git repo. Run without --update to clone fresh."
    exit 1
  fi
else
  if [[ -d "$TARGET_PATH" ]]; then
    echo "Error: $TARGET_PATH already exists. Use --update to refresh."
    exit 1
  fi
  echo "Cloning knowledge base to $TARGET_PATH..."
  git clone --depth 1 "$REPO_URL" "$TARGET_PATH"
fi

KB_PATH="$TARGET_PATH/knowledge"
if [[ ! -d "$KB_PATH" ]]; then
  echo "Error: knowledge/ directory not found at $KB_PATH"
  exit 1
fi

cat <<EOF

✓ Knowledge base installed at: $KB_PATH

Usage in agent scripts (when offline access is needed):

  # Option 1: environment variable
  export KNOWLEDGE_PATH="$KB_PATH"
  cat "\$KNOWLEDGE_PATH/02-Techniques/russian-brevity-grammar.md"

  # Option 2: relative symlinks
  ln -s "$KB_PATH" "\$HOME/.cache/agent-knowledge"

  # Option 3 (default): use GitHub URLs from SKILL.md
  # The skills are already configured to point to GitHub blob URLs.
  # This script is only needed for offline operation.

EOF
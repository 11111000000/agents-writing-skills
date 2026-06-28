#!/usr/bin/env bash
# build-site.sh — build Quartz v5 static site for GitHub Pages
# Usage: ./scripts/build-site.sh [output-dir]
#
# Requirements: Node.js >= 22, npm >= 10.9.2
#
# What it does:
#   1. Clones Quartz v5 to a temp directory
#   2. Runs `npx quartz create` to initialize (creates .quartz/ cache)
#   3. Copies knowledge/ into content/
#   4. Installs plugins from config
#   5. Builds site to output directory

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Convert relative output path to absolute
OUTPUT_DIR="${1:-$REPO_ROOT/public}"
if [[ "$OUTPUT_DIR" != /* ]]; then
  OUTPUT_DIR="$REPO_ROOT/$OUTPUT_DIR"
fi
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"
LANDING_SRC="$REPO_ROOT/docs/index.md"
TEMP_QUARTZ=$(mktemp -d)

log() { printf '\033[1;34m[build]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31m[err]\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

cleanup() {
  log "Cleaning up temporary files..."
  rm -rf "$TEMP_QUARTZ"
}
trap cleanup EXIT

# Check Node.js version
if ! command -v node >/dev/null 2>&1; then
  err "Node.js not found. Install Node.js >= 22 from https://nodejs.org/"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/^v//' | cut -d. -f1)
if [[ "$NODE_VERSION" -lt 22 ]]; then
  err "Node.js >= 22 required (found $(node -v)). Install from https://nodejs.org/"
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  err "npm not found."
  exit 1
fi

# Clone Quartz v5
log "Cloning Quartz v5..."
git clone --depth 1 --branch v5 https://github.com/jackyzha0/quartz.git "$TEMP_QUARTZ"

# Verify Quartz version
if [[ ! -f "$TEMP_QUARTZ/package.json" ]] || ! grep -q '"@jackyzha0/quartz"' "$TEMP_QUARTZ/package.json"; then
  err "Quartz v5 not found at $TEMP_QUARTZ"
  exit 1
fi

# Install dependencies
log "Installing Quartz dependencies (this may take a few minutes)..."
(cd "$TEMP_QUARTZ" && npm ci --ignore-scripts)

# Set up content directory in the Quartz repo
log "Setting up content directory..."
rm -rf "$TEMP_QUARTZ/content"
mkdir -p "$TEMP_QUARTZ/content"

# Copy knowledge base into content
cp -R "$KNOWLEDGE_DIR/." "$TEMP_QUARTZ/content/"

# Add landing page as index.md
if [[ -f "$LANDING_SRC" ]]; then
  log "Adding landing page..."
  cp "$LANDING_SRC" "$TEMP_QUARTZ/content/index.md"
  ok "Landing page → content/index.md"
fi

# Initialize Quartz (non-interactive)
log "Initializing Quartz..."
(cd "$TEMP_QUARTZ" && npx quartz create \
  --template obsidian \
  --strategy copy \
  --source "$TEMP_QUARTZ/content" \
  --directory content \
  --links shortest \
  --baseUrl "agents-writing-skills" \
  --no-open 2>&1) || warn "Quartz create may have warnings (non-fatal)"

# Install plugins from config
log "Installing plugins..."
(cd "$TEMP_QUARTZ" && npx quartz plugin install --from-config 2>&1) || warn "Plugin install may have warnings (non-fatal)"

# Build
log "Building Quartz site..."
mkdir -p "$OUTPUT_DIR"
(cd "$TEMP_QUARTZ" && npx quartz build -d content -o "$OUTPUT_DIR")

ok "Site built at $OUTPUT_DIR"
log "Files: $(find "$OUTPUT_DIR" -type f | wc -l)"
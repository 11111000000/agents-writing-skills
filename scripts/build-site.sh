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
  if [[ -n "${TEMP_QUARTZ:-}" && -d "$TEMP_QUARTZ" ]]; then
    rm -rf "$TEMP_QUARTZ"
  fi
}
trap cleanup EXIT INT TERM

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

# Add landing page as index.md (EN)
if [[ -f "$LANDING_SRC" ]]; then
  log "Adding EN landing page..."
  cp "$LANDING_SRC" "$TEMP_QUARTZ/content/index.md"
  ok "Landing page → content/index.md"
fi

# Add Russian landing page as ru/index.md (under folder-per-route convention)
RU_LANDING_SRC="$REPO_ROOT/docs/ru/index.md"
if [[ -f "$RU_LANDING_SRC" ]]; then
  log "Adding RU landing page..."
  mkdir -p "$TEMP_QUARTZ/content/ru"
  cp "$RU_LANDING_SRC" "$TEMP_QUARTZ/content/ru/index.md"
  ok "RU landing page → content/ru/index.md"
fi

log "Quartz content prepared"

# Install plugins from config
log "Installing plugins..."
(cd "$TEMP_QUARTZ" && npx quartz plugin install --from-config 2>&1) || warn "Plugin install may have warnings (non-fatal)"

# Install Mermaid support (rendered via obsidian-flavored-markdown in Quartz v5)
OFM_LINE=$(grep -n "source: github:quartz-community/obsidian-flavored-markdown" "$TEMP_QUARTZ/quartz.config.default.yaml" | head -1 | cut -d: -f1)
if [[ -n "$OFM_LINE" ]]; then
  ENABLED_LINE=$((OFM_LINE + 1))
  if ! grep -q "^      mermaid: true" <(sed -n "${ENABLED_LINE},$((OFM+8))p" "$TEMP_QUARTZ/quartz.config.default.yaml" 2>/dev/null); then
    OFM_OPT=$((OFM_LINE + 2))
    if ! grep -q "^    options:" <(sed -n "${OFM_OPT}p" "$TEMP_QUARTZ/quartz.config.default.yaml"); then
      sed -i "${ENABLED_LINE}a\\    options:\n      mermaid: true" "$TEMP_QUARTZ/quartz.config.default.yaml"
    else
      sed -i "${OFM_OPT}a\\      mermaid: true" "$TEMP_QUARTZ/quartz.config.default.yaml"
    fi
  fi
fi

# Customize Quartz config (site title, base URL, offline-safe emitters)
log "Customizing Quartz config..."
if [[ -f "$TEMP_QUARTZ/quartz.config.default.yaml" ]]; then
  sed -i "s|pageTitle: Quartz 5|pageTitle: Agents Writing Skills|" "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i "s|baseUrl: quartz.jzhao.xyz|baseUrl: 11111000000.github.io/agents-writing-skills|" "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i "s|fontOrigin: googleFonts|fontOrigin: local|" "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i 's|defaultDateType: modified|defaultDateType: filesystem|' "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i '/source: github:quartz-community\/og-image/{n;s/enabled: true/enabled: false/;}' "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i '/source: github:quartz-community\/encrypted-pages/{n;s/enabled: true/enabled: false/;}' "$TEMP_QUARTZ/quartz.config.default.yaml"
  sed -i "s|GitHub: https://github.com/jackyzha0/quartz|GitHub: https://github.com/11111000000/agents-writing-skills|" "$TEMP_QUARTZ/quartz.config.default.yaml"
  ok "Quartz config customized"
fi

# Build
log "Building Quartz site..."
mkdir -p "$OUTPUT_DIR"
(cd "$TEMP_QUARTZ" && npx quartz build -d content -o "$OUTPUT_DIR")

# Post-process: set data-basepath to absolute path (with leading /) so explorer builds correct URLs
log "Fixing data-basepath to absolute path..."
find "$OUTPUT_DIR" -name "*.html" -exec sed -i 's|data-basepath[^>]*>|data-basepath="/agents-writing-skills">|g' {} +

# Post-process: replace default 'Quartz 5' site title with our title
log "Replacing default site title..."
find "$OUTPUT_DIR" -name "*.html" -exec sed -i 's|Quartz 5|Agents Writing Skills|g' {} +

ok "Site built at $OUTPUT_DIR"
log "Files: $(find "$OUTPUT_DIR" -type f | wc -l)"
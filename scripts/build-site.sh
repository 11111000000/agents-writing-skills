#!/usr/bin/env bash
# build-site.sh — build Quartz v5 static site for GitHub Pages
# Usage: ./scripts/build-site.sh [output-dir]
#
# Requirements: Node.js >= 22, npm >= 10.9.2
#
# What it does:
#   1. Clones Quartz v5 to quartz-src/ (if not present)
#   2. Sets up content directory with knowledge base + landing page
#   3. Writes Quartz config (quartz.config.yaml)
#   4. Builds site to output directory
#
# Directory structure expected by Quartz v5:
#   ./
#   ├── quartz/           # Quartz source (symlink → quartz-src/quartz)
#   ├── .quartz-cache/    # Build cache
#   ├── content/          # Your content
#   ├── quartz.config.yaml
#   ├── plugins.json
#   └── package.json

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT/public}"
QUARTZ_SRC="$REPO_ROOT/quartz-src"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"
LANDING_SRC="$REPO_ROOT/docs/index.md"
CONTENT_DIR="$REPO_ROOT/content"

log() { printf '\033[1;34m[build]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31m[err]\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

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

# Clone Quartz v5 (shallow clone for speed)
if [[ ! -d "$QUARTZ_SRC" ]]; then
  log "Cloning Quartz v5..."
  git clone --depth 1 --branch v5 https://github.com/jackyzha0/quartz.git "$QUARTZ_SRC"
fi

# Verify Quartz version
if [[ ! -f "$QUARTZ_SRC/package.json" ]] || ! grep -q '"@jackyzha0/quartz"' "$QUARTZ_SRC/package.json"; then
  err "Quartz v5 not found at $QUARTZ_SRC"
  exit 1
fi

# Install dependencies if needed
if [[ ! -d "$QUARTZ_SRC/node_modules" ]]; then
  log "Installing Quartz dependencies (this may take a few minutes)..."
  (cd "$QUARTZ_SRC" && npm ci --ignore-scripts)
fi

# Set up content directory: knowledge + landing page
log "Setting up content directory..."
rm -rf "$CONTENT_DIR"
mkdir -p "$CONTENT_DIR"

# Copy knowledge base into content
cp -R "$KNOWLEDGE_DIR/." "$CONTENT_DIR/"

# Add landing page as index.md
if [[ -f "$LANDING_SRC" ]]; then
  log "Adding landing page..."
  cp "$LANDING_SRC" "$CONTENT_DIR/index.md"
  ok "Landing page → content/index.md"
fi

# Set up Quartz directory structure at repo root
# Quartz expects: quartz/ .quartz-cache/ content/ quartz.config.yaml plugins.json
log "Setting up Quartz directory structure..."

# Remove old quartz directory if it exists (but not quartz-src)
if [[ -d "$REPO_ROOT/quartz" ]] && [[ ! -L "$REPO_ROOT/quartz" ]]; then
  rm -rf "$REPO_ROOT/quartz"
fi

# Create symlinks for Quartz source
ln -sfn "$QUARTZ_SRC/quartz" "$REPO_ROOT/quartz"
ln -sfn "$QUARTZ_SRC/node_modules" "$REPO_ROOT/node_modules"
ln -sfn "$QUARTZ_SRC/package.json" "$REPO_ROOT/package.json"
ln -sfn "$QUARTZ_SRC/package-lock.json" "$REPO_ROOT/package-lock.json"

# Create cache directory
mkdir -p "$REPO_ROOT/.quartz-cache"

# Write Quartz config
log "Writing Quartz config..."
cat > "$REPO_ROOT/quartz.config.yaml" <<'EOF'
pageTitle: "Agents Writing Skills"
enableSPA: true
enablePopovers: true
analytics: null
baseUrl: "agents-writing-skills"
ignorePatterns:
  - private
  - templates
  - ".obsidian"
  - "06-Sources"
generateSocialImages: false
enableSiteMap: true
enableRSS: true
enableJsonLd: true
defaultDateType: "modified"
prettyLinks: true
showLineNumbers: false
showBacklinks: true
showExplorer: true
showGraph: true
showTableOfContents: true
enableToc: true
tocDepth: 3
enableCategoryTags: true
enableTagPreview: true
enablePopover: true

plugins:
  transformers:
    - FrontMatter
    - CreatedModifiedDate
    - SyntaxHighlighting
    - ObsidianFlavoredMarkdown
    - Latex
  filters:
    - RemoveDrafts
    - IgnorePatterns
  emitters:
    - AliasRedirects
    - ComponentResources
    - ContentPage
    - FolderPage
    - ContentMetadata
    - RSS
    - Assets
    - Static
EOF

# Write plugins.json (Quartz v5 uses JSON config for plugins)
cat > "$REPO_ROOT/plugins.json" <<'PLUGINS'
{
  "plugins": {
    "transformers": [
      { "name": "FrontMatter" },
      { "name": "CreatedModifiedDate", "options": { "priority": ["frontmatter", "filesystem"] } },
      { "name": "SyntaxHighlighting" },
      { "name": "ObsidianFlavoredMarkdown" },
      { "name": "Latex" }
    ],
    "filters": [
      { "name": "RemoveDrafts" },
      { "name": "IgnorePatterns" }
    ],
    "emitters": [
      { "name": "AliasRedirects" },
      { "name": "ComponentResources" },
      { "name": "ContentPage" },
      { "name": "FolderPage" },
      { "name": "ContentMetadata" },
      { "name": "RSS" },
      { "name": "Assets" },
      { "name": "Static" }
    ]
  }
}
PLUGINS

# Build
log "Building Quartz site..."
mkdir -p "$OUTPUT_DIR"
(cd "$REPO_ROOT" && node quartz/bootstrap-cli.mjs build -d content -o "$OUTPUT_DIR")

ok "Site built at $OUTPUT_DIR"
log "Files: $(find "$OUTPUT_DIR" -type f | wc -l)"

# Cleanup symlinks (but keep content for caching)
log "Cleaning up symlinks..."
rm -f "$REPO_ROOT/quartz" "$REPO_ROOT/node_modules" "$REPO_ROOT/package.json" "$REPO_ROOT/package-lock.json"
ok "Done"
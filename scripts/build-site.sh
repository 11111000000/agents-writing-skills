#!/usr/bin/env bash
# build-site.sh — build Quartz v5 static site for GitHub Pages
# Usage: ./scripts/build-site.sh [output-dir]
#
# Requirements: Node.js >= 22, npm >= 10.9.2
#
# What it does:
#   1. Clones Quartz v5 to a temp directory
#   2. Copies necessary files to repo root (matching Quartz expected structure)
#   3. Sets up content directory with knowledge base + landing page
#   4. Builds site to output directory
#   5. Cleans up copied files

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT/public}"
QUARTZ_CACHE="$REPO_ROOT/.quartz-cache"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"
LANDING_SRC="$REPO_ROOT/docs/index.md"
CONTENT_DIR="$REPO_ROOT/content"
TEMP_QUARTZ=$(mktemp -d)

log() { printf '\033[1;34m[build]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err() { printf '\033[1;31m[err]\033[0m %s\n' "$*" >&2; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

# Cleanup function
cleanup() {
  log "Cleaning up temporary files..."
  rm -rf "$TEMP_QUARTZ"
  # Remove copied Quartz files from repo root
  rm -rf "$REPO_ROOT/quartz" "$REPO_ROOT/node_modules" "$REPO_ROOT/package.json" "$REPO_ROOT/package-lock.json"
  rm -f "$REPO_ROOT/quartz.config.ts"
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

# Clone Quartz v5 to temp directory
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

# Copy necessary files to repo root
log "Copying Quartz files to repo root..."
cp -R "$TEMP_QUARTZ/quartz" "$REPO_ROOT/"
cp "$TEMP_QUARTZ/package.json" "$REPO_ROOT/"
cp "$TEMP_QUARTZ/package-lock.json" "$REPO_ROOT/"
cp -R "$TEMP_QUARTZ/node_modules" "$REPO_ROOT/"

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

# Write Quartz config
log "Writing Quartz config..."
cat > "$REPO_ROOT/quartz.config.ts" <<'EOF'
import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

const config: QuartzConfig = {
  configuration: {
    pageTitle: "Agents Writing Skills",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    baseUrl: "agents-writing-skills",
    ignorePatterns: ["private", "templates", ".obsidian", "06-Sources"],
    generateSocialImages: false,
    enableAutoLightHouse: false,
    enableSiteMap: true,
    enableRSS: true,
    enableJsonLd: true,
    defaultDateType: "modified",
    spaRefreshInterval: 1000000000,
    prettyLinks: true,
    showLineNumbers: false,
    showBacklinks: true,
    showExplorer: true,
    showGraph: true,
    showTableOfContents: true,
    enableToc: true,
    tocDepth: 3,
    enableCategoryTags: true,
    enableTagPreview: true,
    enablePopover: true,
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({ priority: ["frontmatter", "filesystem"] }),
      Plugin.SyntaxHighlighting(),
      Plugin.ObsidianFlavoredMarkdown(),
      Plugin.Latex(),
    ],
    filters: [
      Plugin.RemoveDrafts(),
      Plugin.IgnorePatterns(),
    ],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.ContentMetadata(),
      Plugin.RSS(),
      Plugin.Assets(),
      Plugin.Static(),
    ],
  },
}
export default config
EOF

# Create cache directory
mkdir -p "$QUARTZ_CACHE"

# Build
log "Building Quartz site..."
mkdir -p "$OUTPUT_DIR"
(cd "$REPO_ROOT" && node quartz/bootstrap-cli.mjs build -d content -o "$OUTPUT_DIR")

ok "Site built at $OUTPUT_DIR"
log "Files: $(find "$OUTPUT_DIR" -type f | wc -l)"
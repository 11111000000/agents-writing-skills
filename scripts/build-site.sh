#!/usr/bin/env bash
# build-site.sh — build Quartz v5 static site for GitHub Pages
# Usage: ./scripts/build-site.sh [output-dir]
#
# Requirements: Node.js >= 22, npm >= 10.9.2
#
# What it does:
#   1. Clones Quartz v5 to .quartz/ (if not present)
#   2. Symlinks knowledge/ → .quartz/content/
#   3. Adds landing page (docs/index.md) to .quartz/content/index.md
#   4. Builds site to ./public/ (or specified output dir)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT/public}"
QUARTZ_DIR="$REPO_ROOT/.quartz"
KNOWLEDGE_DIR="$REPO_ROOT/knowledge"
LANDING_SRC="$REPO_ROOT/docs/index.md"

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
if [[ ! -d "$QUARTZ_DIR" ]]; then
  log "Cloning Quartz v5..."
  git clone --depth 1 --branch v5 https://github.com/jackyzha0/quartz.git "$QUARTZ_DIR"
fi

# Verify Quartz version
if [[ ! -f "$QUARTZ_DIR/package.json" ]] || ! grep -q '"@jackyzha0/quartz"' "$QUARTZ_DIR/package.json"; then
  err "Quartz v5 not found at $QUARTZ_DIR"
  exit 1
fi

# Install dependencies if needed
if [[ ! -d "$QUARTZ_DIR/node_modules" ]]; then
  log "Installing Quartz dependencies (this may take a few minutes)..."
  (cd "$QUARTZ_DIR" && npm ci)
fi

# Set up content directory: link knowledge + add landing
log "Setting up content directory..."
rm -rf "$QUARTZ_DIR/content"
mkdir -p "$QUARTZ_DIR/content"

# Copy knowledge base into content
cp -R "$KNOWLEDGE_DIR/." "$QUARTZ_DIR/content/"

# Add landing page as index.md
if [[ -f "$LANDING_SRC" ]]; then
  log "Adding landing page..."
  cp "$LANDING_SRC" "$QUARTZ_DIR/content/index.md"
  ok "Landing page → content/index.md"
fi

# Configure Quartz
log "Writing Quartz config..."
cat > "$QUARTZ_DIR/quartz.config.ts" <<'EOF'
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
      Plugin.OxHugo(),
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

# Build
log "Building Quartz site..."
mkdir -p "$OUTPUT_DIR"
(cd "$QUARTZ_DIR" && npx quartz build --output "$OUTPUT_DIR" --serve false)

ok "Site built at $OUTPUT_DIR"
log "Next: git add $OUTPUT_DIR && git commit (or use GitHub Actions)"
log "Files: $(find "$OUTPUT_DIR" -type f | wc -l)"
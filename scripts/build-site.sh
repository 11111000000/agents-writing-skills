#!/usr/bin/env bash
# build-site.sh — build Quartz static site for GitHub Pages
# Usage: ./scripts/build-site.sh [output-dir]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT/site}"
QUARTZ_DIR="$REPO_ROOT/.quartz"

# Quartz requires Node.js and npm
if ! command -v node >/dev/null 2>&1; then
  echo "[err] Node.js is required. Install from https://nodejs.org/" >&2
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "[err] npm is required." >&2
  exit 1
fi

# Clone Quartz if not present
if [[ ! -d "$QUARTZ_DIR" ]]; then
  echo "[install] Cloning Quartz v4..."
  git clone --depth 1 https://github.com/jackyzha0/quartz.git "$QUARTZ_DIR"
fi

# Symlink knowledge into Quartz content directory
mkdir -p "$QUARTZ_DIR/content"
rm -rf "$QUARTZ_DIR/content"/* 2>/dev/null || true
cp -R "$REPO_ROOT/knowledge/." "$QUARTZ_DIR/content/"

# Configure Quartz (use Obsidian-compatible settings)
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
    ignorePatterns: ["private", "templates", ".obsidian"],
    generateSocialImages: false,
    enableAutoLightHouse: false,
    enableSiteMap: true,
    enableRSS: true,
    enableJsonLd: true,
    defaultDateType: "modified",
    analytics: { provider: "plausible" },
    spaRefreshInterval: 1000000000,
  },
  plugins: {
    transformers: {
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({ priority: ["frontmatter", "filesystem"] }),
      Plugin.SyntaxHighlighting(),
      Plugin.ObsidianFlavoredMarkdown(),
      Plugin.OxHugo(),
      Plugin.Latex(),
    },
    filters: {
      Plugin.RemoveDrafts(),
      Plugin.IgnorePatterns(),
    },
    emitters: {
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.ContentMetadata(),
      Plugin.RSS(),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.CustomResources(),
    },
  },
}
export default config
EOF

# Install dependencies if needed
if [[ ! -d "$QUARTZ_DIR/node_modules" ]]; then
  echo "[install] Installing Quartz dependencies..."
  (cd "$QUARTZ_DIR" && npm install)
fi

# Build
echo "[build] Building Quartz site..."
(cd "$QUARTZ_DIR" && npx quartz build --output "$OUTPUT_DIR" --serve false)

echo "[ok] Site built at $OUTPUT_DIR"
echo "[next] Commit $OUTPUT_DIR to gh-pages branch, or push to enable GitHub Pages."
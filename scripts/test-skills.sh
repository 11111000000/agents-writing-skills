#!/usr/bin/env bash
# test-skills.sh — Validate skill structure and content
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "ERROR: skills/ directory not found"
  exit 1
fi

ERRORS=0
WARNINGS=0

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  
  echo "=== $skill_name ==="
  
  # Check SKILL.md exists
  if [[ ! -f "$skill_file" ]]; then
    echo "  ERROR: SKILL.md not found"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  
  # Check required frontmatter fields
  for field in name description version license compatibility; do
    if ! grep -q "^${field}:" "$skill_file"; then
      echo "  ERROR: Missing required field '$field' in frontmatter"
      ERRORS=$((ERRORS + 1))
    fi
  done
  
  # Check version format (semver)
  version=$(grep "^version:" "$skill_file" | head -1 | sed 's/^version: *//')
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "  ERROR: Invalid version format '$version' (expected semver: X.Y.Z)"
    ERRORS=$((ERRORS + 1))
  fi
  
  # Check for required sections
  for section in "When to load" "When NOT to load" "Workflow"; do
    if ! grep -qi "## .*${section}" "$skill_file"; then
      echo "  WARNING: Missing section containing '$section'"
      WARNINGS=$((WARNINGS + 1))
    fi
  done
  
  # Check lexicon reference for humanize-writer
  if [[ "$skill_name" == "humanize-writer" ]]; then
    if [[ ! -f "$skill_dir/references/lexicon.md" ]]; then
      echo "  WARNING: humanize-writer should have references/lexicon.md"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
  
  echo "  OK: $skill_name v$version"
done

echo ""
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
  exit 1
fi

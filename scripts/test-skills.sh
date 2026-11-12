#!/usr/bin/env bash
# test-skills.sh — Validate skill structure and content
#
# Real SKILL.md schema in this repo:
#   frontmatter: name, description, license, compatibility (top level)
#   version:     metadata.version (integer, e.g. 6) for real skills;
#                top-level semver (1.0.0) only in template-skill
# See scripts/validate-skills.sh for the CI frontmatter validator.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "ERROR: skills/ directory not found"
  exit 1
fi

ERRORS=0
WARNINGS=0

# Extract a top-level frontmatter field (frontmatter = first --- ... --- block).
fm_field() {
  awk -v f="$2" '/^---$/{c++; next} c==1 && $0 ~ "^" f ":" {sub("^" f ":[[:space:]]*", ""); print; exit}' "$1"
}

# Extract an indented key inside the metadata block.
fm_meta_field() {
  awk -v f="$2" '/^---$/{c++; next} c==1 && /^metadata:/{inm=1; next} c==1 && inm && /^[A-Za-z]/{inm=0} c==1 && inm && $0 ~ "^[[:space:]]+" f ":" {sub("^[[:space:]]*" f ":[[:space:]]*", ""); print; exit}' "$1"
}

# Extract metadata.version (indented key inside the metadata block).
fm_meta_version() {
  fm_meta_field "$1" "version"
}

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

  # Frontmatter must exist
  if ! head -1 "$skill_file" | grep -q '^---$'; then
    echo "  ERROR: missing YAML frontmatter"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Required top-level frontmatter fields
  for field in name description license compatibility; do
    if [[ -z "$(fm_field "$skill_file" "$field")" ]]; then
      if [[ "$field" == "compatibility" && "$(fm_meta_field "$skill_file" "status")" == "template" ]]; then
        echo "  WARNING: template skill without 'compatibility'"
        WARNINGS=$((WARNINGS + 1))
      else
        echo "  ERROR: Missing required field '$field' in frontmatter"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done

  # Version: metadata.version (real skills) or top-level version (template).
  version=$(fm_meta_version "$skill_file")
  if [[ -z "$version" ]]; then
    version=$(fm_field "$skill_file" "version")
  fi
  if [[ -z "$version" ]]; then
    echo "  ERROR: Missing version (expected metadata.version)"
    ERRORS=$((ERRORS + 1))
  elif [[ ! "$version" =~ ^[0-9]+$ && ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "  ERROR: Invalid version format '$version' (expected integer or semver X.Y.Z)"
    ERRORS=$((ERRORS + 1))
  fi

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

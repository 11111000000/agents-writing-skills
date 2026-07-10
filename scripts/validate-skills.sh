#!/usr/bin/env bash
# validate-skills.sh — validate SKILL.md frontmatter and structure
# Usage: ./scripts/validate-skills.sh [path-to-skill-or-repo]

set -euo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SKILLS_DIR="$REPO_ROOT/skills"
PROMPTS_DIR="$REPO_ROOT/prompts"

errors=0
warnings=0

err() { printf '\033[1;31m[err]\033[0m %s\n' "$*"; ((errors++)); }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; ((warnings++)); }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

check_skill_file() {
  local file="$1"
  local name
  name="$(basename "$(dirname "$file")")"

  # YAML frontmatter must exist
  if ! head -1 "$file" | grep -q '^---$'; then
    err "$file: missing YAML frontmatter"
    return
  fi

  # Required fields
  local name_in_fm desc_in_fm license_in_fm
  name_in_fm="$(awk '/^---$/{c++;next}c==1 && /^name:/{print;exit}' "$file" | sed 's/^name:[[:space:]]*//')"
  desc_in_fm="$(awk '/^---$/{c++;next}c==1 && /^description:/{print;exit}' "$file" | sed 's/^description:[[:space:]]*//')"
  license_in_fm="$(awk '/^---$/{c++;next}c==1 && /^license:/{print;exit}' "$file" | sed 's/^license:[[:space:]]*//')"

  # name: required, kebab-case, matches dir
  if [[ -z "$name_in_fm" ]]; then
    err "$file: missing 'name' in frontmatter"
  elif [[ ! "$name_in_fm" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    err "$file: name '$name_in_fm' is not kebab-case (must match ^[a-z0-9]+(-[a-z0-9]+)*$)"
  elif [[ "$name_in_fm" != "$name" ]]; then
    err "$file: name '$name_in_fm' doesn't match directory '$name'"
  else
    ok "name: $name_in_fm"
  fi

  # description: required, ≤1024 chars
  if [[ -z "$desc_in_fm" ]]; then
    err "$file: missing 'description' in frontmatter"
  elif [[ ${#desc_in_fm} -gt 1024 ]]; then
    err "$file: description is ${#desc_in_fm} chars (max 1024)"
  else
    ok "description: ${#desc_in_fm} chars"
  fi

  # license: recommended
  if [[ -z "$license_in_fm" ]]; then
    warn "$file: missing 'license' in frontmatter (recommended: MIT or Apache-2.0)"
  fi
}

check_prompt_file() {
  local file="$1"
  local name
  name="$(basename "$file" .md)"

  if ! head -1 "$file" | grep -q '^---$'; then
    err "$file: missing YAML frontmatter"
    return
  fi

  local desc_in_fm
  desc_in_fm="$(awk '/^---$/{c++;next}c==1 && /^description:/{print;exit}' "$file" | sed 's/^description:[[:space:]]*//')"

  if [[ -z "$desc_in_fm" ]]; then
    err "$file: missing 'description' in frontmatter"
  else
    ok "prompt $name: ${#desc_in_fm} chars"
  fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
  echo "=== Validating skills ==="
  if [[ -d "$SKILLS_DIR" ]]; then
    for skill_dir in "$SKILLS_DIR"/*/; do
      local name
      name="$(basename "$skill_dir")"
      local file="$skill_dir/SKILL.md"
      if [[ ! -f "$file" ]]; then
        err "$skill_dir: missing SKILL.md"
        continue
      fi
      check_skill_file "$file"
    done
  fi

  echo ""
  echo "=== Validating prompts ==="
  if [[ -d "$PROMPTS_DIR" ]]; then
    for prompt_file in "$PROMPTS_DIR"/*.md; do
      check_prompt_file "$prompt_file"
    done
  fi

  echo ""
  echo "=== Validating benchmark script ==="
  if [[ -x "$SCRIPT_DIR/test-benchmark.sh" ]]; then
    if bash "$SCRIPT_DIR/test-benchmark.sh" > /tmp/test-benchmark.log 2>&1; then
      ok "benchmark smoke tests passed"
    else
      err "benchmark smoke tests failed (see /tmp/test-benchmark.log)"
    fi
  fi

  echo ""
  if [[ $errors -eq 0 ]]; then
    ok "All checks passed ($warnings warnings)"
    exit 0
  else
    err "Validation failed: $errors errors, $warnings warnings"
    exit 1
  fi
}

main
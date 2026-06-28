#!/usr/bin/env bash
# validate-manifest.sh — Check that all paths in manifest.json exist
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO_ROOT/manifest.json"

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: manifest.json not found at $MANIFEST"
  exit 1
fi

ERRORS=0

# Extract all paths from manifest.json and check each one
while IFS= read -r path; do
  full_path="$REPO_ROOT/$path"
  if [[ ! -f "$full_path" ]]; then
    echo "MISSING: $path"
    ERRORS=$((ERRORS + 1))
  fi
done < <(python3 -c "
import json, sys
with open('$MANIFEST') as f:
    data = json.load(f)
for s in data.get('skills', []):
    print(s['path'])
    for r in s.get('references', []):
        print(r)
for p in data.get('prompts', []):
    print(p['path'])
")

if [[ $ERRORS -eq 0 ]]; then
  echo "OK: All manifest paths exist"
  exit 0
else
  echo "ERROR: $ERRORS missing file(s)"
  exit 1
fi

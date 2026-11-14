#!/usr/bin/env bash
# scripts/check-manifest-versions.sh
# The manifest is the index of the project: if it advertises a skill version
# that the SKILL.md does not declare, agents and docs read different realities.
# This check compares manifest.skills[].version with the skill's own
# metadata.version (falling back to a top-level `version:`).
#
# Usage: ./scripts/check-manifest-versions.sh
# Exit: 0 = versions agree, 1 = mismatch, 2 = usage error.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO_ROOT/manifest.json"

[[ -f "$MANIFEST" ]] || { echo "ERROR: manifest.json not found" >&2; exit 2; }

python3 - "$MANIFEST" "$REPO_ROOT" <<'PYEOF'
import json, os, re, sys

manifest_path, root = sys.argv[1], sys.argv[2]
manifest = json.load(open(manifest_path, encoding="utf-8"))

fail = 0
for skill in manifest.get("skills", []):
    rel = skill.get("path", "")
    declared = skill.get("version")
    full = os.path.join(root, rel)
    if not os.path.isfile(full):
        print(f"FAIL {rel}: file declared in manifest does not exist")
        fail = 1
        continue
    text = open(full, encoding="utf-8").read()
    fm = text.split("---", 2)
    front = fm[1] if len(fm) > 2 else ""
    m = re.search(r"^\s*version:\s*(\S+)\s*$", front, re.M)
    actual = None
    if m:
        actual = m.group(1)
    else:
        m = re.search(r"^\s{2,}version:\s*(\S+)\s*$", front, re.M)
        if m:
            actual = m.group(1)
    if actual is None:
        print(f"FAIL {rel}: no version declared in SKILL.md frontmatter")
        fail = 1
        continue
    def norm(v):
        parts = str(v).split(".")
        while len(parts) < 3:
            parts.append("0")
        return tuple(p for p in parts[:3])
    if norm(declared) != norm(actual):
        print(f"FAIL {rel}: manifest says {declared}, SKILL.md says {actual}")
        fail = 1
    else:
        print(f"ok {rel}: {actual} (manifest {declared})")

sys.exit(fail)
PYEOF

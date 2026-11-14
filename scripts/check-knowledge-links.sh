#!/usr/bin/env bash
# scripts/check-knowledge-links.sh
# Every Obsidian wikilink [[...]] inside knowledge/ must resolve to a file
# that exists in the vault. Resolution rules:
#   - [[note]], [[dir/note]], [[../../dir/note]] with a path separator resolve
#     relative to the vault root (any extension; covers 06-Sources raw files)
#   - bare [[note]] resolves by basename against knowledge/**/*.md
#   - aliases [[note\|alias]] (escaped pipe inside tables) are stripped
# templates/ is excluded: its links are fill-in placeholders, not references.
#
# Usage: ./scripts/check-knowledge-links.sh
# Exit: 0 = all links resolve, 1 = broken links found, 2 = usage error.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="$REPO_ROOT/knowledge"

[[ -d "$VAULT" ]] || { echo "ERROR: knowledge/ not found" >&2; exit 2; }

python3 - "$VAULT" <<'PYEOF'
import os, re, sys

vault = sys.argv[1]

md_notes = set()
all_files = set()
for root, dirs, files in os.walk(vault):
    if "templates" in dirs:
        dirs.remove("templates")
    for f in files:
        full = os.path.join(root, f)
        rel = os.path.relpath(full, vault)
        all_files.add(rel)
        all_files.add(os.path.splitext(rel)[0])
        if f.endswith(".md"):
            md_notes.add(os.path.splitext(f)[0])

LINK = re.compile(r"\[\[((?:\\[\|\]]|[^\]\|#])+?)(?:\\?\|[^\]]*)?(?:#[^\]]*)?\]\]")

fail = 0
for root, dirs, files in os.walk(vault):
    if "templates" in dirs:
        dirs.remove("templates")
    for f in sorted(files):
        if not f.endswith(".md"):
            continue
        path = os.path.join(root, f)
        text = open(path, encoding="utf-8").read()
        # Wikilinks inside inline code are mentions of the syntax, not links.
        text = re.sub(r"`[^`\n]*`", "", text)
        for m in LINK.finditer(text):
            raw = m.group(1).replace("\\|", "|").replace("\\]", "]").strip()
            target = raw.rstrip("/")
            norm = os.path.normpath(target)
            if "/" in norm:
                ok = norm in all_files or os.path.basename(norm) in md_notes
            else:
                ok = norm in md_notes
            if not ok:
                rel = os.path.relpath(path, vault)
                print(f"FAIL {rel}: broken wikilink [[{raw}]]")
                fail = 1

sys.exit(fail)
PYEOF

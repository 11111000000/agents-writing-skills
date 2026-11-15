#!/usr/bin/env bash
# scripts/check-knowledge-links.sh
# Every Obsidian wikilink [[...]] inside knowledge/ must resolve to a file
# that exists in the vault. Resolution rules:
#   - [[dir/note]] with a path separator resolves either relative to the note's
#     own folder (how Quartz renders it on the site) or relative to the vault
#     root (how Obsidian resolves it). Both are accepted; a link that resolves
#     under neither is broken in at least one reader and is reported.
#   - bare [[note]] resolves by basename against knowledge/**/*.md
#   - aliases [[note\|alias]] (escaped pipe inside tables) are stripped
# templates/ is excluded: its links are fill-in placeholders, not references.
#
# The previous rule accepted any link whose *basename* existed, which let a
# link with a wrong directory ([[../rhetorical/x]] from 01-Patterns/) pass
# while rendering as a dead href on the site.
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
        rel = os.path.relpath(path, vault)
        text = open(path, encoding="utf-8").read()
        # Wikilinks inside inline code are mentions of the syntax, not links.
        text = re.sub(r"`[^`\n]*`", "", text)
        for m in LINK.finditer(text):
            raw = m.group(1).replace("\\|", "|").replace("\\]", "]").strip()
            target = raw.rstrip("/")
            norm = os.path.normpath(target)
            if "/" in norm:
                # Quartz resolves a wikilink by matching the target as a suffix of a
                # real slug; a "../" prefix makes that match impossible, and the
                # link then renders as a dead href on the site. Require the
                # vault-root-relative form, which resolves in Obsidian and on the site.
                root_rel = os.path.normpath(target)
                while root_rel.startswith("../"):
                    root_rel = root_rel[3:]
                ok = root_rel in all_files or os.path.splitext(root_rel)[0] in all_files
            else:
                ok = norm in md_notes
            if not ok:
                print(f"FAIL {rel}: broken wikilink [[{raw}]]")
                fail = 1

sys.exit(fail)
PYEOF

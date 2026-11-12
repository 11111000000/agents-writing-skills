#!/usr/bin/env bash
# scripts/check-examples-facts.sh
# Meaning-contract invariant for knowledge/04-Examples/: every number that
# appears in a "✅ После" (after) block must already exist in the matching
# "❌ До" (before) block. Illustration tables marked with the v7 warning
# callout ("Иллюстрации с вымышленными данными") are excluded — they show
# technique, not text to copy.
#
# Usage: ./scripts/check-examples-facts.sh [file.md ...]
# Exit: 0 = all example pairs clean, 1 = invented numbers found, 2 = usage error.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -gt 0 ]]; then
  FILES=("$@")
else
  FILES=(
    "$REPO_ROOT/knowledge/04-Examples/before-after.md"
    "$REPO_ROOT/knowledge/04-Examples/before-after-ru-advanced.md"
  )
fi

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || { echo "ERROR: file not found: $f" >&2; exit 2; }
done

python3 - "${FILES[@]}" <<'PYEOF'
import re, sys

fail = 0
for path in sys.argv[1:]:
    text = open(path, encoding="utf-8").read()

    # Drop illustration sections explicitly marked as fictional.
    text = re.split(r"Иллюстрации с вымышленными данными", text)[0] \
        if "Иллюстрации с вымышленными данными" in text else text

    # Pair up ❌ До / ✅ После blocks in order. Any other ### header
    # (e.g. "### Что изменилось") closes the current block.
    tokens = re.split(r"(###[^\n]*)", text)
    current_label, current_body, pairs, pending = None, [], [], None
    sections = []
    for tok in tokens:
        if tok.startswith("###"):
            if current_label:
                sections.append((current_label, "\n".join(current_body)))
            current_label, current_body = tok, []
        elif current_label:
            current_body.append(tok)
    if current_label:
        sections.append((current_label, "\n".join(current_body)))

    for label, body in sections:
        if "❌" in label:
            pending = body
        elif "✅" in label and pending is not None:
            before_nums = set(re.findall(r"\d+(?:[.,]\d+)?", pending))
            after_nums = set(re.findall(r"\d+(?:[.,]\d+)?", body))
            invented = sorted(after_nums - before_nums)
            if invented:
                print(f"FAIL {path}: invented numbers in '{label.strip()}': {invented}")
                fail = 1
            pending = None

sys.exit(fail)
PYEOF

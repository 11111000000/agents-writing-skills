#!/usr/bin/env bash
# scripts/check-examples-facts.sh
# Meaning-contract invariant for knowledge/04-Examples/: every number that
# appears in an "after" block must already exist in the matching "before"
# block. All markdown files under knowledge/04-Examples/ are checked
# recursively.
#
# Recognised block shapes:
#   ### ❌ До …      / ### ✅ После …
#   ### ❌ …         / ### ✅ …          (emoji without the words "До"/"После")
#   ## Пример …     + inline "До:" / "После:" blocks (no emoji at all)
#
# Numbers are counted exactly as before (\d+ with a comma or a dot), except
# that square-bracket markers — [P3], [нужен факт: ...], [[wiki links]] —
# are ignored: they are requests to the author, not assertions.
#
# Sections explicitly marked as illustrations (callout about fictional data,
# e.g. "> [!warning] Иллюстрации с вымышленными данными") are skipped, and
# the skip is reported instead of staying silent.
#
# Usage: ./scripts/check-examples-facts.sh [file.md ...]
# Exit: 0 = all example pairs clean, 1 = invented numbers found, 2 = usage error.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLES_DIR="$REPO_ROOT/knowledge/04-Examples"

if [[ $# -gt 0 ]]; then
  FILES=("$@")
else
  FILES=()
  while IFS= read -r f; do
    FILES+=("$f")
  done < <(find "$EXAMPLES_DIR" -type f -name '*.md' 2>/dev/null | LC_ALL=C sort)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "ERROR: no markdown files found under $EXAMPLES_DIR" >&2
  exit 2
fi

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || { echo "ERROR: file not found: $f" >&2; exit 2; }
done

python3 - "${FILES[@]}" <<'PYEOF'
import re
import sys

NUMBER_RE = re.compile(r"\d+(?:[.,]\d+)?")
BRACKET_RE = re.compile(r"\[[^\[\]]*\]")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*$")
FENCE_RE = re.compile(r"^\s*(?:```|~~~)")
CALLOUT_RE = re.compile(r"^>\s*\[!(\w+)\]\s*(.*)$")
ILLUSTRATION_RE = re.compile(
    r"иллюстрац"
    r"|(?:вымышленн|выдуманн|придуманн|нереальн|условн|фиктивн)\w*\s+"
    r"(?:данн|числ|цифр|значен|факт)\w*"
    r"|(?:fictional|illustrative|made-up|fake)\s+(?:data|numbers|figures)",
    re.IGNORECASE,
)
MARKER_RE = re.compile(
    r"^\s*(?:>\s*)?(?:[-*+]\s+)?(?:#{1,6}\s*)?(?:\*\*|__|\*|_)?\s*"
    r"(до|после|before|after)\s*(?:\*\*|__|\*|_)?\s*[:.]?\s*"
    r"(?:\([^()]{0,80}\))?\s*(?:\*\*|__|\*|_)?\s*$",
    re.IGNORECASE,
)
BEFORE_WORD_RE = re.compile(r"(?<!\w)до(?!\w)", re.IGNORECASE)
AFTER_WORD_RE = re.compile(r"(?<!\w)после(?!\w)", re.IGNORECASE)

BEFORE, AFTER = "before", "after"


def strip_brackets(text):
    """Drop square-bracket markers: [P3], [нужен факт: ...], [[wiki links]]."""
    previous = None
    while previous != text:
        previous = text
        text = BRACKET_RE.sub(" ", text)
    return text


def numbers(text):
    return set(NUMBER_RE.findall(strip_brackets(text)))


def heading_role(title):
    """Role of a heading: 'before', 'after' or None."""
    head = title.strip(" \t*_#-—–:·.()[]❌✅")
    first = re.split(r"[\s,;:—–-]+", head, maxsplit=1)[0].lower() if head else ""
    if first in ("до", "before"):
        return BEFORE
    if first in ("после", "after"):
        return AFTER
    if "✅" in title:
        return AFTER
    if "❌" in title:
        return BEFORE
    if AFTER_WORD_RE.search(title):
        return AFTER
    if BEFORE_WORD_RE.search(title):
        return BEFORE
    return None


def marker_role(line):
    """Role of a standalone inline marker line: 'До:' / '**После**' / ..."""
    match = MARKER_RE.match(line)
    if not match:
        return None
    return BEFORE if match.group(1).lower() in ("до", "before") else AFTER


def parse_document(lines):
    """Split the document into sections: heading text, body lines, ancestry."""
    sections = []
    stack = []
    current = None
    in_fence = False
    for offset, line in enumerate(lines):
        lineno = offset + 1
        if FENCE_RE.match(line):
            in_fence = not in_fence
            if current is not None:
                current["body"].append((lineno, line))
            continue
        match = None if in_fence else HEADING_RE.match(line)
        if match:
            level = len(match.group(1))
            while stack and sections[stack[-1]]["level"] >= level:
                stack.pop()
            current = {
                "level": level,
                "title": match.group(2).strip(),
                "body": [],
                "line": lineno,
                "parents": list(stack),
                "idx": len(sections),
            }
            sections.append(current)
            stack.append(len(sections) - 1)
            continue
        if current is not None:
            current["body"].append((lineno, line))
    return sections


def illustration_callout(body):
    """Line number of a callout whose title marks the section as fictional."""
    index = 0
    while index < len(body):
        lineno, line = body[index]
        match = CALLOUT_RE.match(line.strip())
        if match:
            title = match.group(2).strip()
            index += 1
            first_line = title
            if not first_line:
                while index < len(body) and body[index][1].lstrip().startswith(">"):
                    candidate = body[index][1].lstrip().lstrip(">").strip()
                    index += 1
                    if candidate:
                        first_line = candidate
                        break
            if ILLUSTRATION_RE.search(first_line):
                return lineno
            continue
        index += 1
    return None


def role_blocks(section):
    """Blocks of one section: (role, text, lineno, label)."""
    role = heading_role(section["title"])
    body = section["body"]
    if role:
        text = "\n".join(line for _, line in body)
        yield role, text, section["line"], section["title"]
        return

    blocks = []
    current_role = None
    current_lines = []
    current_line = None
    label = ""
    in_fence = False
    for lineno, line in body:
        if FENCE_RE.match(line):
            in_fence = not in_fence
            if current_role is not None:
                current_lines.append(line)
            continue
        marker = None if in_fence else marker_role(line)
        if marker:
            if current_role is not None:
                blocks.append((current_role, "\n".join(current_lines), current_line, label))
            current_role = marker
            current_lines = []
            current_line = lineno
            label = line.strip()
            continue
        if current_role is not None:
            current_lines.append(line)
    if current_role is not None:
        blocks.append((current_role, "\n".join(current_lines), current_line, label))
    for block in blocks:
        yield block


def in_scope(outer, inner):
    """True if a block under `outer` may be paired with a block under `inner`."""
    return len(outer) <= len(inner) and inner[: len(outer)] == outer


fail = 0
for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().split("\n")
    sections = parse_document(lines)

    illustrations = {}
    for section in sections:
        lineno = illustration_callout(section["body"])
        if lineno is not None:
            illustrations[section["idx"]] = lineno
            print(
                f"INFO {path}:{lineno}: skipped illustration section "
                f"'{section['title']}' (marked as fictional data)"
            )

    excluded = set()
    for section in sections:
        if section["idx"] in illustrations or any(
            parent in illustrations for parent in section["parents"]
        ):
            excluded.add(section["idx"])

    blocks = []
    for section in sections:
        if section["idx"] in excluded:
            continue
        for role, text, lineno, label in role_blocks(section):
            blocks.append(
                {
                    "role": role,
                    "text": text,
                    "line": lineno,
                    "label": label,
                    "scope": section["parents"],
                }
            )

    pending = None
    for block in blocks:
        if pending is not None and not in_scope(pending["scope"], block["scope"]):
            pending = None
        if block["role"] == BEFORE:
            pending = block
        elif block["role"] == AFTER and pending is not None:
            invented = sorted(numbers(block["text"]) - numbers(pending["text"]))
            if invented:
                print(
                    f"FAIL {path}:{block['line']}: invented numbers in "
                    f"'{block['label']}': {invented}"
                )
                fail = 1
            pending = None

sys.exit(fail)
PYEOF

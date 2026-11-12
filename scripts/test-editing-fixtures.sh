#!/usr/bin/env bash
# Structural validator for tests/fixtures/editing/*.md (no LLM calls).
# Checks frontmatter fields, Source/Gold edit sections, edit_mode values,
# number preservation, and near-identity of already-good fixtures.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES="${SCRIPT_DIR}/tests/fixtures/editing"

PASS=0
FAIL=0

pass() {
    echo "  PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "  FAIL: $1"
    FAIL=$((FAIL + 1))
}

# Print frontmatter (lines between the first and second --- markers).
frontmatter() {
    awk '/^---[[:space:]]*$/{c++; if (c==2) exit; next} c==1' "$1"
}

# Print body of a section: everything after "## <name>" up to the next "## "
# heading or end of file.
section_body() {
    local file="$1"
    local name="$2"
    awk -v hdr="## ${name}" '
        $0 == hdr {f=1; next}
        /^## / && f {f=0}
        f
    ' "$file"
}

nonempty() {
    [[ -n "$(tr -d '[:space:]' <<< "$1")" ]]
}

# Word-level similarity ratio (0..1) between two texts, via python3.
word_overlap() {
    local src="$1"
    local gold="$2"
    SRC_TEXT="$src" GOLD_TEXT="$gold" python3 - <<'PYEOF'
import os, re, difflib
ws = re.findall(r"\w+", os.environ["SRC_TEXT"].lower())
wg = re.findall(r"\w+", os.environ["GOLD_TEXT"].lower())
if not ws or not wg:
    print("0")
else:
    print("%.4f" % difflib.SequenceMatcher(None, ws, wg).ratio())
PYEOF
}

if [[ ! -d "$FIXTURES" ]]; then
    echo "FAIL: fixtures directory not found: $FIXTURES"
    exit 1
fi

shopt -s nullglob
files=("$FIXTURES"/*.md)
shopt -u nullglob

echo "Editing fixtures validation"
echo "Directory: $FIXTURES"
echo ""

# --- Per-file structural checks ---
for f in "${files[@]}"; do
    base="$(basename "$f" .md)"
    echo "Fixture: $base"

    fm="$(frontmatter "$f")"
    if nonempty "$fm"; then
        pass "$base: frontmatter present"
    else
        fail "$base: frontmatter missing or empty"
        continue
    fi

    # Required top-level fields
    missing=""
    for field in id language genre edit_mode required_preservation forbidden_additions; do
        if ! grep -qE "^${field}:" <<< "$fm"; then
            missing="$missing $field"
        fi
    done
    if [[ -z "$missing" ]]; then
        pass "$base: required frontmatter fields present"
    else
        fail "$base: missing frontmatter fields:$missing"
    fi

    # id matches filename
    id_val="$(grep -E '^id:' <<< "$fm" | head -1 | sed -E 's/^id:[[:space:]]*//; s/[[:space:]]*$//')"
    if [[ "$id_val" == "$base" ]]; then
        pass "$base: id matches filename"
    else
        fail "$base: id '$id_val' does not match filename"
    fi

    # edit_mode in allowed set
    mode="$(grep -E '^edit_mode:' <<< "$fm" | head -1 | sed -E 's/^edit_mode:[[:space:]]*//; s/[[:space:]]*$//')"
    case "$mode" in
        proofread|light|style|deep)
            pass "$base: edit_mode '$mode' is valid"
            ;;
        *)
            fail "$base: edit_mode '$mode' not in {proofread, light, style, deep}"
            ;;
    esac

    # Sections exist and are non-empty
    src="$(section_body "$f" "Source")"
    gold="$(section_body "$f" "Gold edit")"
    if nonempty "$src"; then
        pass "$base: Source section non-empty"
    else
        fail "$base: Source section missing or empty"
    fi
    if nonempty "$gold"; then
        pass "$base: Gold edit section non-empty"
    else
        fail "$base: Gold edit section missing or empty"
    fi

    # Number preservation: every number token from Source must appear in
    # Gold edit, unless frontmatter sets allow_number_drop: true.
    if nonempty "$src" && nonempty "$gold"; then
        if grep -qE '^allow_number_drop:[[:space:]]*true' <<< "$fm"; then
            pass "$base: number check skipped (allow_number_drop: true)"
        else
            dropped=""
            while IFS= read -r num; do
                [[ -z "$num" ]] && continue
                if ! grep -qF "$num" <<< "$gold"; then
                    dropped="$dropped $num"
                fi
            done < <(grep -oE '[0-9]+([.,][0-9]+)?' <<< "$src" | sort -u)
            if [[ -z "$dropped" ]]; then
                pass "$base: all numbers from Source present in Gold edit"
            else
                fail "$base: numbers dropped in Gold edit:$dropped"
            fi
        fi
    fi

    # already-good: gold must be >= 80% similar to source at word level
    genre="$(grep -E '^genre:' <<< "$fm" | head -1 | sed -E 's/^genre:[[:space:]]*//; s/[[:space:]]*$//')"
    if [[ "$genre" == "already-good" ]] && nonempty "$src" && nonempty "$gold"; then
        ratio="$(word_overlap "$src" "$gold")"
        ok="$(RATIO="$ratio" python3 -c 'import os,sys; sys.exit(0 if float(os.environ["RATIO"]) >= 0.8 else 1)'; echo $?)"
        if [[ "$ok" == "0" ]]; then
            pass "$base: already-good gold edit is ${ratio} similar to source (>= 0.80)"
        else
            fail "$base: already-good gold edit similarity ${ratio} < 0.80"
        fi
    fi

    echo ""
done

# --- Corpus-level checks ---
total=${#files[@]}
echo "Corpus checks"
if [[ "$total" -ge 24 ]]; then
    pass "at least 24 fixtures (found $total)"
else
    fail "only $total fixtures, need at least 24"
fi

for cat in formal-email readme tech-instruction tutorial expert-post fiction scientific-hedged already-good; do
    n=0
    for f in "${files[@]}"; do
        case "$(basename "$f")" in
            "$cat"-[0-9]*.md) n=$((n + 1)) ;;
        esac
    done
    if [[ "$n" -ge 3 ]]; then
        pass "category $cat has $n fixtures (>= 3)"
    else
        fail "category $cat has $n fixtures, need at least 3"
    fi
done

echo ""
echo "=================================================="
echo "Editing fixtures summary"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "=================================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi
exit 0

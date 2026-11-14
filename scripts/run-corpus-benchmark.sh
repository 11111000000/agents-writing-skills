#!/usr/bin/env bash
# scripts/run-corpus-benchmark.sh
# Run benchmark-skill.sh across a labeled corpus and emit per-file JSONL
# for downstream analysis.
#
# Usage:
#   ./scripts/run-corpus-benchmark.sh [output.jsonl]
#
# Walks tests/fixtures/{hc3,raid,ru-corpus,en-corpus}/ and emits one JSON
# object per line, with frontmatter-derived labels and benchmark metrics.
#
# Metadata resolution
# -------------------
# Every fixture carries YAML-ish frontmatter. When a file has frontmatter, its
# values win over the defaults derived from the corpus layout / file name:
#
#   label, language, domain, model, source
#
# A missing (or empty) key falls back to the previous default, so fixtures
# without frontmatter keep producing exactly the same records as before.
#
# Two fields are always present:
#
#   corpus     - which corpus the file came from (hc3-human, hc3-chatgpt,
#                raid-human, raid-ai, ru-corpus, en-corpus). This is what
#                "source" used to encode, so grouping by corpus still works.
#   provenance - synthetic | real | unknown, derived from frontmatter:
#                  * explicit `provenance: real|synthetic` wins;
#                  * `source: synthetic` (or a source starting with it)
#                    -> synthetic;
#                  * `source: real` or a source marking an LLM generation
#                    ("llm-generation", "gigachat-api", ...) -> real;
#                  * no frontmatter, or a source with no generation marker
#                    ("HC3", "RAID", "Wikisource", ...) -> unknown.
#                "unknown" is never silently counted as "real": a corpus may
#                only be called real when the metadata says so.
#
# The "file" field keeps the path of the source file.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCH="$REPO_ROOT/scripts/benchmark-skill.sh"
OUTPUT="${1:-$REPO_ROOT/tests/results/corpus-benchmark.jsonl}"

mkdir -p "$(dirname "$OUTPUT")"
# Truncate output to avoid duplicate records on re-run
: > "$OUTPUT"

emit() {
    local file="$1"
    local corpus="$2"       # hc3-human, hc3-chatgpt, raid-human, raid-ai, ru-corpus, en-corpus
    local ground_label="$3"  # human | ai
    local language="$4"
    local domain="$5"
    local model="${6:-n/a}"
    local attack="${7:-n/a}"

    # Run benchmark, capture json. Exit code 1 = "targets fail" (normal for AI
    # text and bad human text), only treat >2 as actual error.
    local json
    local bench_rc
    json=$(bash "$BENCH" "$file" --json 2>/dev/null)
    bench_rc=$?
    if [[ $bench_rc -gt 2 ]]; then
        echo "[skip] benchmark errored (rc=$bench_rc) for $file" >&2
        return
    fi
    if [[ -z "$json" ]]; then
        echo "[skip] benchmark returned empty json for $file" >&2
        return
    fi

    # Merge frontmatter metadata with the defaults, then wrap in one JSON.
    python3 - "$json" "$file" "$corpus" "$ground_label" "$language" "$domain" "$model" "$attack" >> "$OUTPUT" <<'PYEOF'
import json
import re
import sys

FM_RE = re.compile(r"\A---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\Z)", re.S)
KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_.-]*)\s*:\s*(.*)$")
# Substrings that mark a source as a real LLM generation run.
REAL_MARKERS = ("llm", "api", "generation")


def parse_frontmatter(path):
    """Мини-YAML frontmatter (key: value). None, если блока нет."""
    try:
        with open(path, "r", encoding="utf-8-sig", errors="replace") as fh:
            text = fh.read(1 << 20)
    except OSError:
        return None
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    m = FM_RE.match(text)
    if not m:
        return None
    meta = {}
    for line in m.group(1).split("\n"):
        km = KEY_RE.match(line.strip())
        if not km:
            continue
        value = km.group(2).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        if value:
            meta[km.group(1).lower()] = value
    return meta


def derive_provenance(meta):
    """synthetic | real | unknown. Unknown никогда не считается реальным."""
    if not meta:
        return "unknown"
    explicit = meta.get("provenance", "").strip().lower()
    if explicit:
        return explicit if explicit in ("real", "synthetic") else "unknown"
    src = meta.get("source", "").strip().lower()
    if not src:
        return "unknown"
    if src == "synthetic" or src.startswith("synthetic"):
        return "synthetic"
    if src == "real" or any(marker in src for marker in REAL_MARKERS):
        return "real"
    return "unknown"


bench_json, path, corpus, ground_label, language, domain, model, attack = sys.argv[1:9]

meta = parse_frontmatter(path)
if meta:
    fm_label = meta.get("label", "").strip().lower()
    if fm_label in ("human", "ai"):
        ground_label = fm_label
    language = meta.get("language") or language
    domain = meta.get("domain") or domain
    model = meta.get("model") or model
    source = meta.get("source") or corpus
else:
    source = corpus

out = {
    'file': path,
    'corpus': corpus,
    'source': source,
    'label': ground_label,
    'language': language,
    'domain': domain,
    'model': model,
    'attack': attack,
    'provenance': derive_provenance(meta),
}
try:
    b = json.loads(bench_json)
    out['metrics'] = b.get('metrics', {})
    out['targets_ok'] = b.get('targets_ok', None)
    # Default thresholds for individual metric classification
    m = out['metrics']
    flags = {
        'AP_high': m.get('AP', 0) > 1,
        'D_high': m.get('D', 0) > 7,
        'E_high': m.get('E', 0) > 3,
        'YapScore_critical': m.get('YapScore', 1) > 2.0,
        'YapScore_flag': m.get('YapScore', 1) > 1.5,
        'V_high': m.get('V', 0) > 5,
        'R_high': m.get('R', 0) > 10,
        'B_high': m.get('B', 0) > 5,
        'Burstiness_low': m.get('burstiness', {}).get('std', 10) < 3,
        'Specificity_low': m.get('specificity_facts_per_para', 1) < 0.5,
    }
    out['flags'] = flags
    out['n_flags'] = sum(1 for v in flags.values() if v)
    print(json.dumps(out, ensure_ascii=False))
except Exception as e:
    print(f'[error] {path}: {e}', file=sys.stderr)
    sys.exit(1)
PYEOF
}

# HC3
for kind in human chatgpt; do
    label=$([ "$kind" = "chatgpt" ] && echo "ai" || echo "human")
    for f in "$REPO_ROOT/tests/fixtures/hc3/$kind"/*.txt; do
        [[ -f "$f" ]] || continue
        domain=$(basename "$f" .txt | sed 's/-[0-9]*$//')
        emit "$f" "hc3-$kind" "$label" "en" "$domain" "gpt-3.5" "n/a"
    done
done

# RAID
for kind in human ai; do
    label=$([ "$kind" = "ai" ] && echo "ai" || echo "human")
    for f in "$REPO_ROOT/tests/fixtures/raid/$kind"/*.txt; do
        [[ -f "$f" ]] || continue
        # Parse filename: <domain>-<model>-<idx> for AI, <domain>-<idx> for human
        base=$(basename "$f" .txt)
        if [[ "$kind" == "ai" ]]; then
            domain=$(echo "$base" | cut -d'-' -f1)
            model=$(echo "$base" | cut -d'-' -f2)
        else
            domain="$base"
            domain=${domain%-*}
            model="n/a"
        fi
        emit "$f" "raid-$kind" "$label" "en" "$domain" "$model" "none"
    done
done

# RU corpus (human + ai). Metadata (label/language/domain/model/source) comes
# from the file frontmatter when it is there; the values below are only the
# fallback for fixtures without frontmatter.
for kind in human ai; do
    label=$([ "$kind" = "ai" ] && echo "ai" || echo "human")
    if [[ -d "$REPO_ROOT/tests/fixtures/ru-corpus/$kind" ]]; then
        for f in "$REPO_ROOT/tests/fixtures/ru-corpus/$kind"/*.txt; do
            [[ -f "$f" ]] || continue
            base=$(basename "$f" .txt)
            author=$(echo "$base" | cut -d'-' -f1)
            emit "$f" "ru-corpus" "$label" "ru" "$author" "synthetic" "n/a"
        done
    fi
done
# Also any unclassified ru-corpus files at the top level (legacy fixtures)
for f in "$REPO_ROOT/tests/fixtures/ru-corpus"/*.txt; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f" .txt)
    author=$(echo "$base" | cut -d'-' -f1)
    emit "$f" "ru-corpus" "human" "ru" "$author" "n/a" "n/a"
done

# EN synthetic corpus
for kind in human ai; do
    label=$([ "$kind" = "ai" ] && echo "ai" || echo "human")
    if [[ -d "$REPO_ROOT/tests/fixtures/en-corpus/$kind" ]]; then
        for f in "$REPO_ROOT/tests/fixtures/en-corpus/$kind"/*.txt; do
            [[ -f "$f" ]] || continue
            base=$(basename "$f" .txt)
            domain=$(basename "$f" .txt | sed 's/-[0-9]*$//')
            emit "$f" "en-corpus" "$label" "en" "$domain" "synthetic" "n/a"
        done
    fi
done

count=$(wc -l < "$OUTPUT" 2>/dev/null || echo 0)
echo ""
echo "Wrote $count records to $OUTPUT"

# Breakdown by provenance so a mixed corpus is visible at a glance.
python3 - "$OUTPUT" <<'PYEOF'
import json
import sys
from collections import Counter

ORDER = ("real", "synthetic", "unknown")

by_provenance = Counter()
by_corpus = Counter()
by_pair = Counter()
total = 0
try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except ValueError:
                continue
            total += 1
            prov = rec.get("provenance", "unknown")
            corpus = rec.get("corpus", "unknown")
            by_provenance[prov] += 1
            by_corpus[corpus] += 1
            by_pair[(corpus, prov)] += 1
except OSError as exc:
    print(f"[error] cannot read {sys.argv[1]}: {exc}", file=sys.stderr)
    sys.exit(1)

if not total:
    sys.exit(0)

print("")
print("Records by provenance:")
for prov in ORDER:
    print(f"  {prov}: {by_provenance.get(prov, 0)}")
extra = [p for p in by_provenance if p not in ORDER]
for prov in sorted(extra):
    print(f"  {prov}: {by_provenance[prov]}")

print("")
print("Records by corpus:")
for corpus in sorted(by_corpus):
    parts = [f"{p}={by_pair[(corpus, p)]}" for p in ORDER if by_pair[(corpus, p)]]
    print(f"  {corpus}: {by_corpus[corpus]} ({', '.join(parts)})")
PYEOF

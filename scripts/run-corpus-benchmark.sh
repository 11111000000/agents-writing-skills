#!/usr/bin/env bash
# scripts/run-corpus-benchmark.sh
# Run benchmark-skill.sh across a labeled corpus and emit per-file JSONL
# for downstream analysis.
#
# Usage:
#   ./scripts/run-corpus-benchmark.sh [output.jsonl]
#
# Walks tests/fixtures/{hc3,raid,ru-corpus}/ and emits one JSON object per
# line, with frontmatter-derived labels and benchmark metrics.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCH="$REPO_ROOT/scripts/benchmark-skill.sh"
OUTPUT="${1:-$REPO_ROOT/tests/results/corpus-benchmark.jsonl}"

mkdir -p "$(dirname "$OUTPUT")"
# Truncate output to avoid duplicate records on re-run
: > "$OUTPUT"

emit() {
    local file="$1"
    local source_label="$2"     # hc3-human, hc3-chatgpt, raid-human, raid-ai, ru-corpus
    local ground_label="$3"    # human | ai
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

    # Strip trailing recommendations list (we'll fill it later); wrap in one JSON
    python3 -c "
import json, sys, os
out = {
    'file': '$file',
    'source': '$source_label',
    'label': '$ground_label',
    'language': '$language',
    'domain': '$domain',
    'model': '$model',
    'attack': '$attack',
}
try:
    b = json.loads(sys.argv[1])
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
    print(f'[error] {sys.argv[2]}: {e}', file=sys.stderr)
    sys.exit(1)
" "$json" "$file" >> "$OUTPUT"
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

# RU corpus (human + ai)
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
            domain=$(echo "$base" | sed 's/-[0-9]*$//')
            emit "$f" "en-corpus" "$label" "en" "$domain" "synthetic" "n/a"
        done
    fi
done

count=$(wc -l < "$OUTPUT" 2>/dev/null || echo 0)
echo ""
echo "Wrote $count records to $OUTPUT"
#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH="${SCRIPT_DIR}/scripts/benchmark-skill.sh"
FIXTURES="${SCRIPT_DIR}/tests/fixtures"

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

require_file() {
    if [[ -f "$1" ]]; then
        pass "fixture exists: $1"
    else
        fail "missing fixture: $1"
    fi
}

run_exit_test() {
    local desc="$1"
    local fixture="$2"
    local expected_exit="$3"
    local expected_line="$4"
    local output
    local exit_code

    output=$(bash "$BENCH" "$fixture" 2>/dev/null)
    exit_code=$?

    echo ""
    echo "Test: $desc"

    if [[ "$exit_code" -ne "$expected_exit" ]]; then
        fail "exit code $exit_code, expected $expected_exit"
        return
    fi

    if ! grep -q "$expected_line" <<< "$output"; then
        fail "missing line: $expected_line"
        return
    fi

    pass "$desc"
}

run_no_crash_file() {
    local desc="$1"
    local fixture="$2"
    local output
    local exit_code

    output=$(bash "$BENCH" "$fixture" 2>/dev/null)
    exit_code=$?

    echo ""
    echo "Test: $desc"

    if [[ "$exit_code" -eq 0 ]] || [[ "$exit_code" -eq 1 ]]; then
        pass "$desc"
    else
        fail "unexpected exit $exit_code"
    fi
}

run_no_crash_stdin() {
    local desc="$1"
    local input="$2"
    local output
    local exit_code

    output=$(printf "%s" "$input" | bash "$BENCH" --stdin 2>/dev/null)
    exit_code=$?

    echo ""
    echo "Test: $desc"

    if [[ "$exit_code" -eq 0 ]] || [[ "$exit_code" -eq 1 ]]; then
        pass "$desc"
    else
        fail "unexpected exit $exit_code"
    fi
}

require_metrics() {
    local fixture="$1"
    local output
    local missed=0

    output=$(bash "$BENCH" "$fixture" 2>/dev/null)

    echo ""
    echo "Test: report contains required metrics"

    for metric in "AP (negative parallelism)" "D  (RU деепричастия)" "E  (em-dash)" "YapScore" "Burstiness" "Specificity"; do
        if ! grep -q "$metric" <<< "$output"; then
            echo "  Missing metric: $metric"
            missed=$((missed + 1))
        fi
    done

    if [[ "$missed" -eq 0 ]]; then
        pass "all required metrics present"
    else
        fail "$missed metrics missing"
    fi
}

json_assert() {
    local desc="$1"
    local fixture="$2"
    local expr="$3"
    local json

    json=$(bash "$BENCH" "$fixture" --json 2>/dev/null)

    echo ""
    echo "Test: $desc"

    if JSON_PAYLOAD="$json" JSON_EXPR="$expr" python3 -c 'import json, os, sys; d=json.loads(os.environ["JSON_PAYLOAD"]); sys.exit(0 if eval(os.environ["JSON_EXPR"], {"__builtins__": {}}, {"d": d}) else 1)'; then
        pass "$desc"
    else
        fail "$desc"
    fi
}

AI_FIXTURE="${FIXTURES}/ai-typical-readme.txt"
HUMAN_FIXTURE="${FIXTURES}/human-readme.txt"
RU_AI_FIXTURE="${FIXTURES}/ru-ai-typical.txt"
RU_HUMAN_FIXTURE="${FIXTURES}/ru-human-laconic.txt"

require_file "$AI_FIXTURE"
require_file "$HUMAN_FIXTURE"
require_file "$RU_AI_FIXTURE"
require_file "$RU_HUMAN_FIXTURE"

if [[ -f "$AI_FIXTURE" ]]; then
    run_exit_test "AI-typical README is flagged" "$AI_FIXTURE" 1 "FAIL"
    require_metrics "$AI_FIXTURE"
    json_assert "AI fixture has failing thresholds" "$AI_FIXTURE" 'd["targets_ok"] == False and d["metrics"]["YapScore"] > 1.5 and d["metrics"]["specificity_facts_per_para"] < 0.5'
fi

if [[ -f "$HUMAN_FIXTURE" ]]; then
    run_no_crash_file "human README runs" "$HUMAN_FIXTURE"
    json_assert "human fixture keeps factual density" "$HUMAN_FIXTURE" 'd["metrics"]["specificity_facts_per_para"] >= 0.5 and d["metrics"]["YapScore"] <= 1.5'
fi

if [[ -f "$RU_AI_FIXTURE" ]]; then
    json_assert "RU AI fixture is low-density" "$RU_AI_FIXTURE" 'd["targets_ok"] == False and d["metrics"]["specificity_facts_per_para"] < 0.5'
fi

if [[ -f "$RU_HUMAN_FIXTURE" ]]; then
    json_assert "RU laconic fixture is factual" "$RU_HUMAN_FIXTURE" 'd["metrics"]["specificity_facts_per_para"] >= 1.0 and d["metrics"]["YapScore"] <= 1.5'
fi

run_no_crash_stdin "empty stdin" ""

output=$(bash "$BENCH" missing-file.txt 2>/dev/null)
exit_code=$?
echo ""
echo "Test: missing file exits 2"
if [[ "$exit_code" -eq 2 ]]; then
    pass "missing file exits 2"
else
    fail "missing file exit $exit_code"
fi

echo ""
echo "=================================================="
echo "Benchmark tests summary"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "=================================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi
exit 0

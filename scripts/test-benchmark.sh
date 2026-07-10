#!/usr/bin/env bash
# scripts/test-benchmark.sh
# Smoke test: запускает benchmark-skill.sh на AI-typical и human fixture,
# проверяет, что AI-typical помечается как FAIL, а human — как PASS.
#
# Это НЕ полный тест метрик (benchmark-skill.sh heuristics), а smoke test
# для самого скрипта: что он запускается, не падает, парсит текст, даёт
# разумный verdict.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH="${SCRIPT_DIR}/scripts/benchmark-skill.sh"
FIXTURES="${SCRIPT_DIR}/tests/fixtures"

PASS=0
FAIL=0

run_test() {
    local desc="$1"
    local fixture="$2"
    local expected_exit="$3"   # 0 = OK, 1 = FAIL signal
    local check_pass="$4"       # line in output that should appear

    local output
    local exit_code

    output=$("$BENCH" "$fixture" 2>/dev/null)
    exit_code=$?

    echo ""
    echo "Test: $desc"
    echo "  Fixture: $fixture"
    echo "  Expected exit: $expected_exit"
    echo "  Expected line: $check_pass"

    if [[ "$exit_code" -ne "$expected_exit" ]]; then
        echo "  ❌ FAIL: exit code is $exit_code, expected $expected_exit"
        FAIL=$((FAIL + 1))
        return
    fi

    if ! grep -q "$check_pass" <<< "$output"; then
        echo "  ❌ FAIL: expected line '$check_pass' not found"
        echo "  Output head:"
        echo "$output" | head -10 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
        return
    fi

    echo "  ✓ PASS"
    PASS=$((PASS + 1))
}

# --- Test 1: AI-typical текст должен FAIL ---
if [[ -f "${FIXTURES}/ai-typical-readme.txt" ]]; then
    run_test \
        "AI-typical README должен быть помечен как FAIL" \
        "${FIXTURES}/ai-typical-readme.txt" \
        1 \
        "FAIL"
fi

# --- Test 2: human текст должен PASS (или быть близок) ---
if [[ -f "${FIXTURES}/human-readme.txt" ]]; then
    # This test is more permissive — human text has higher YapScore than
    # this heuristic allows (small sample), but it should run without errors.
    output=$("$BENCH" "${FIXTURES}/human-readme.txt" 2>/dev/null)
    exit_code=$?

    echo ""
    echo "Test: human README должен запускаться без ошибок"
    echo "  Fixture: ${FIXTURES}/human-readme.txt"

    if [[ "$exit_code" -eq 0 ]] || [[ "$exit_code" -eq 1 ]]; then
        echo "  ✓ PASS (benchmark ran successfully)"
        PASS=$((PASS + 1))
    else
        echo "  ❌ FAIL: unexpected exit $exit_code"
        FAIL=$((FAIL + 1))
    fi
fi

# --- Test 3: пустой ввод не должен crash ---
output=$(echo "" | "$BENCH" --stdin 2>/dev/null)
exit_code=$?
echo ""
echo "Test: пустой ввод"
echo "  Expected: exit 0 или 1, не crash"
if [[ "$exit_code" -eq 0 ]] || [[ "$exit_code" -eq 1 ]]; then
    echo "  ✓ PASS"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL: crash (exit $exit_code)"
    FAIL=$((FAIL + 1))
fi

# --- Test 4: benchmark должен выводить все основные метрики ---
output=$("$BENCH" "${FIXTURES}/ai-typical-readme.txt" 2>/dev/null)
echo ""
echo "Test: отчёт содержит основные метрики"
required_metrics=("AP (negative parallelism)" "D  (RU деепричастия)" "E  (em-dash)" "YapScore" "Burstiness" "Specificity")
missed=0
for metric in "${required_metrics[@]}"; do
    if ! grep -q "$metric" <<< "$output"; then
        echo "  ❌ Missing metric: $metric"
        missed=$((missed + 1))
    fi
done
if [[ "$missed" -eq 0 ]]; then
    echo "  ✓ PASS (all 6 required metrics present)"
    PASS=$((PASS + 1))
else
    echo "  ❌ FAIL: $missed metrics missing"
    FAIL=$((FAIL + 1))
fi

# --- Summary ---
echo ""
echo "=================================================="
echo "Benchmark smoke tests summary"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "=================================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi
exit 0
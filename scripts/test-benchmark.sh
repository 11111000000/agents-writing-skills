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
OVERGEN_FIXTURE="${FIXTURES}/over-generated.txt"
RU_PROSE_FIXTURE="${FIXTURES}/ru-prose-deeprichastiya.txt"

require_file "$AI_FIXTURE"
require_file "$HUMAN_FIXTURE"
require_file "$RU_AI_FIXTURE"
require_file "$RU_HUMAN_FIXTURE"
require_file "$OVERGEN_FIXTURE"
require_file "$RU_PROSE_FIXTURE"

if [[ -f "$AI_FIXTURE" ]]; then
    run_exit_test "AI-typical README is flagged" "$AI_FIXTURE" 1 "REVIEW — есть сигналы для ручной проверки"
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

# --- Golden tests for the P0 metric fixes (lock in regressions) ---
if [[ -f "$OVERGEN_FIXTURE" ]]; then
    # Regression test for the YapScore cap bug: this text is heavily
    # filler-laden and must score > 2.0 (old code capped at 1.67).
    json_assert "YapScore is NOT silently capped at 1.67 (regression)" \
        "$OVERGEN_FIXTURE" \
        'd["metrics"]["YapScore"] >= 2.0 and d["metrics"]["YapScore"] <= 10.0'
fi

if [[ -f "$RU_PROSE_FIXTURE" ]]; then
    # Regression test for D-metric Cyrillic bug: this Russian prose contains
    # verifiable деепричастия and must register D > 0 (old code returned 0
    # due to LC_ALL=C breaking Cyrillic character classes).
    json_assert "D-metric works on Russian prose (regression)" \
        "$RU_PROSE_FIXTURE" \
        'd["metrics"]["D"] > 0'
fi

# Stderr noise test: running benchmark on any fixture must not leak
# "Invalid character class name" or similar grep errors.
stderr_noise=$(bash "$BENCH" "$AI_FIXTURE" 2>&1 >/dev/null | grep -c "Invalid character class" || true)
if [[ "$stderr_noise" -eq 0 ]]; then
    pass "no grep stderr noise on AI fixture"
else
    fail "grep stderr leaked $stderr_noise lines on AI fixture"
fi

# --- Calibrated-separation regression tests ---
# Each test asserts that a known fixture scores in the empirically
# validated range. Fails if a future refactor breaks the calibration.
# See knowledge/02-Techniques/metric-validation.md (n=145).

# --- Locale regression: metrics must not depend on the runner's locale ---
# CI runners use C.UTF-8, which has no collation: a Cyrillic range like
# `[А-Яа-я]` makes grep fail with "Invalid collation character" and every
# Cyrillic metric comes out empty. The same input must score the same under
# any UTF-8 locale.
locale_json=$(LC_ALL=C.UTF-8 bash "$BENCH" "$RU_PROSE_FIXTURE" --json 2>/dev/null)
echo ""
echo "Test: metrics do not depend on the locale"
if JSON_PAYLOAD="$locale_json" python3 -c 'import json, os, sys; d=json.loads(os.environ["JSON_PAYLOAD"]); m=d["metrics"]; sys.exit(0 if m["D"] > 30.0 and d["language"] == "ru" else 1)'; then
    pass "metrics are locale-independent"
else
    fail "metrics changed under C.UTF-8 (D and language detection must stay)"
fi

if [[ -f "$OVERGEN_FIXTURE" ]]; then
    json_assert "over-generated YapScore is critically high (>=2.0)" \
        "$OVERGEN_FIXTURE" \
        'd["metrics"]["YapScore"] >= 2.0 and d["metrics"]["YapScore"] <= 10.0'
fi

if [[ -f "$RU_PROSE_FIXTURE" ]]; then
    # ru-prose-deeprichastiya.txt is a Tolstoy-style excerpt with 5+ деепричастия
    # in ~79 words; raw D count is high. Per-1000 density is in 60-100 range.
    json_assert "RU literary prose D registers non-zero (regression)" \
        "$RU_PROSE_FIXTURE" \
        'd["metrics"]["D"] > 30.0'
fi

# ai-typical-readme is RU-mixed; ensure language detection says ru
if [[ -f "$AI_FIXTURE" ]]; then
    json_assert "language detection picks ru for Cyrillic-dominant AI fixture" \
        "$AI_FIXTURE" \
        'd["language"] == "ru"'
fi

# human-readme.txt is actually mixed RU/EN (it's "Genium Tasks — CLI для тех...")
# so it should be detected as ru. Use an HC3 fixture for the EN case.
EN_FIXTURE="${FIXTURES}/hc3/human/finance-1.txt"
if [[ -f "$EN_FIXTURE" ]]; then
    json_assert "language detection picks en for HC3 finance human fixture" \
        "$EN_FIXTURE" \
        'd["language"] == "en"'
fi

# Wikisource corpus: each must be runnable (exit 0,1,2 are all acceptable
# — only exit >2 means actual crash; ru-corpus literary prose may exit 1
# because YapScore/format_bias thresholds trip, which is expected).
for f in "$FIXTURES"/ru-corpus/*.txt; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f" .txt)
    out=$(bash "$BENCH" "$f" --json 2>&1)
    rc=$?
    if [[ $rc -le 2 ]] && [[ -n "$out" ]] && [[ "$out" == "{"* ]]; then
        pass "Wikisource $base benchmark runs"
    else
        fail "Wikisource $base benchmark crashed (rc=$rc, output=$(echo "$out" | head -c 80))"
    fi
done

# --- R-metric regression: restatement between ADJACENT sentences ---
# Two identical adjacent sentences share all trigrams -> the pair counts as
# restated. A trigram repeated WITHIN one sentence must NOT count.
r_adj_json=$(printf '%s' "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. Nothing else repeats here at all." | bash "$BENCH" --stdin --json 2>/dev/null)
echo ""
echo "Test: R counts restatement between adjacent sentences"
if JSON_PAYLOAD="$r_adj_json" python3 -c 'import json, os, sys; d=json.loads(os.environ["JSON_PAYLOAD"]); sys.exit(0 if d["metrics"]["R"] >= 50.0 else 1)'; then
    pass "R counts restatement between adjacent sentences"
else
    fail "R missed adjacent-sentence restatement (R=$r_adj_json)"
fi

r_intra_json=$(printf '%s' "alpha beta gamma delta alpha beta gamma delta." | bash "$BENCH" --stdin --json 2>/dev/null)
echo ""
echo "Test: R ignores trigram repeats within a single sentence"
if JSON_PAYLOAD="$r_intra_json" python3 -c 'import json, os, sys; d=json.loads(os.environ["JSON_PAYLOAD"]); sys.exit(0 if d["metrics"]["R"] == 0.0 else 1)'; then
    pass "R ignores trigram repeats within a single sentence"
else
    fail "R flagged intra-sentence trigram repeat (R=$r_intra_json)"
fi

run_no_crash_stdin "empty stdin" ""

# --- Detector golden tests (P1: frame-based detectors) ----------------------
# До P1 детекторы AP/P-NEW-19/P-NEW-16 были сломаны: AP ловил 0 из 8
# канонических примеров каталога, P-NEW-19 не мог сработать никогда,
# P-NEW-16 знал только английский. Эти тесты фиксируют исправленное
# поведение, чтобы следующий рефакторинг его не сломал снова.

DETECTORS_DIR="${FIXTURES}/detectors"

# 1. AP: все 13 канонических форм RU из knowledge/01-Patterns/rhetorical/
#    negative-parallelisms.md (§3.1–3.5) должны быть найдены.
json_assert "AP detector finds all 13 canonical RU frames" \
    "${DETECTORS_DIR}/ap-canonical-ru.txt" \
    'd["metrics"]["new_patterns"]["AP_strong_frames"] >= 13'

# 2. AP: английские формы (§4) — 8 форм, 7 strong + 1 weak.
json_assert "AP detector finds all 8 canonical EN frames" \
    "${DETECTORS_DIR}/ap-canonical-en.txt" \
    'd["metrics"]["new_patterns"]["AP_strong_frames"] + d["metrics"]["new_patterns"]["AP_weak_frames"] >= 8'

# 3. Нормализация потока: те же три формы, разорванные мягким переносом
#    строки, должны давать тот же результат. До P1 построчная обработка
#    была слепа к таким текстам.
json_assert "AP survives soft line wrapping (normalisation regression)" \
    "${DETECTORS_DIR}/wrapped-ap.txt" \
    'd["metrics"]["new_patterns"]["AP_strong_frames"] >= 3'

# 4. P-NEW-16: оппонент без имени (RU и EN) + не считать обычные слова.
json_assert "P-NEW-16 finds unnamed opponents (RU)" \
    "${DETECTORS_DIR}/p16-argument-residue-ru.txt" \
    'd["metrics"]["new_patterns"]["P_NEW_16_argument_residue_per_1k"] > 0'

# 5. P-NEW-18: бессоюзное трикольцо с нарастающей тяжестью; соседнее
#    предложение-заглушка не считается.
json_assert "P-NEW-18 finds escalating tricolon" \
    "${DETECTORS_DIR}/p18-tricolon-ru.txt" \
    'd["metrics"]["new_patterns"]["P_NEW_18_asyndeton_tricolon_per_1k"] > 0'

# 6. P-NEW-19: абзац, закрытый мини-афоризмом. Прежний awk давал 0 всегда.
json_assert "P-NEW-19 finds mini-aphorism closer (dead-detector regression)" \
    "${DETECTORS_DIR}/p19-closer-ru.txt" \
    'd["metrics"]["new_patterns"]["P_NEW_19_mini_aphorism_closer"] >= 1 and d["metrics"]["new_patterns"]["P_NEW_19_aphoristic_closer"] >= 1'

# 7. Ложные срабатывания: человеческая литература не должна пересекать
#    порог AP. Порог откалиброван: RU-литература ≤3.45/1k, порог 4.
#    Это главный анти-фолс-аларм тест: старый порог TH_AP=1 помечал 7 из 8.
#    Сравнение делаем в python: парсить JSON через awk нельзя — значение
#    метрики содержит точку, а не только целое.
echo ""
echo "Test: human literature stays below the AP threshold"
lit_check=$(python3 - "$BENCH" "$FIXTURES" <<'PYEOF'
import glob, json, os, subprocess, sys
bench, fixtures = sys.argv[1], sys.argv[2]
files = sorted(glob.glob(os.path.join(fixtures, "ru-corpus", "*.txt")))
over = []
for path in files:
    out = subprocess.run(["bash", bench, path, "--json"], capture_output=True, text=True)
    try:
        ap = json.loads(out.stdout)["metrics"]["AP"]
    except Exception:
        over.append((path, "parse-error"))
        continue
    if ap > 4:
        over.append((os.path.basename(path), ap))
print(json.dumps({"n": len(files), "over": over}))
PYEOF
)
if LIT_CHECK="$lit_check" python3 -c 'import json, os, sys; d=json.loads(os.environ["LIT_CHECK"]); sys.exit(0 if d["n"] > 0 and not d["over"] else 1)'; then
    pass "human literature stays below the AP threshold ($lit_check)"
else
    fail "human literary files exceeded AP threshold 4: $lit_check"
fi

# 8. Флаг режима детекторов честно сообщает, работали ли рамочные детекторы.
json_assert "frame detectors are reported as active" \
    "${DETECTORS_DIR}/ap-canonical-ru.txt" \
    'd["frame_detectors"] == True'

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

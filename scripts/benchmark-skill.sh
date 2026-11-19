#!/usr/bin/env bash
# scripts/benchmark-skill.sh
# Замеряет метрики AI-текста на входе. Полезно для baseline перед запуском humanize-editor.
#
# Метрики:
#   - AP: negative parallelism density (per 1000 words)
#   - D:  деепричастия density (per 1000 words, RU only)
#   - E:  em-dash count (per 300 words)
#   - V:  vacuum-filling sentences (%)
#   - R:  restatement chains (% of adjacent sentence pairs sharing >50% trigrams)
#   - B:  bridging phrases at para starts (%)
#   - YapScore (filler-based heuristic: длина / (длина − взвешенные маркеры-пустышки))
#   - Burstiness: mean & std of sentence length
#   - Specificity: concrete facts per paragraph
#   - Format bias: emojis, bold, list density
#   - Voice: first-person, opinion
#
# Использование:
#   ./scripts/benchmark-skill.sh file.txt
#   ./scripts/benchmark-skill.sh file.txt --json   # вывод в JSON
#   ./scripts/benchmark-skill.sh *.txt            # несколько файлов
#   ./scripts/benchmark-skill.sh --stdin           # читать из stdin
#
# Возвращает:
#   exit 0 если все метрики в целевых диапазонах (диагностика, не оценка качества)
#   exit 1 если есть сигналы для ручной проверки
#   exit 2 если файл не найден

# NOTE: set -e disabled to allow graceful handling of grep returning non-zero
# (which happens when a pattern doesn't match — a normal case for metrics)

# --- Defaults ---
TEXT=""
JSON_MODE=false
STDIN_MODE=false
TARGETS_OK=true

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --stdin) STDIN_MODE=true; shift ;;
    --help|-h)
      cat <<EOF
Usage: $0 [file.txt...] [--json] [--stdin]

Examples:
  $0 input.txt
  $0 *.txt
  echo "text" | $0 --stdin
  $0 input.txt --json
EOF
      exit 0
      ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) TEXT="$1"; shift ;;
  esac
done

# --- Read input ---
if [[ "$STDIN_MODE" == "true" ]]; then
  INPUT=$(cat)
elif [[ -n "$TEXT" ]]; then
  if [[ ! -f "$TEXT" ]]; then
    echo "Error: file not found: $TEXT" >&2
    exit 2
  fi
  INPUT=$(cat "$TEXT")
else
  echo "Usage: $0 [file.txt] [--json] [--stdin]" >&2
  exit 2
fi

# --- Normalise the input stream ---
# Детекторы не должны зависеть от того, как текст нарезан на строки.
# Мягкий перенос внутри абзаца раньше делал паттерн невидимым: один и тот же
# текст давал AP 0.0 с переносом и 166.67 без него. Два рендера:
#   INPUT_NORM — абзац на строку (рамочные детекторы, метрики по абзацам);
#   INPUT_SENT — предложение на строку (shell-детекторы с якорем `^`).
# Если python3 недоступен, оба рендера = исходный текст: метрики не падают,
# а точность снижается — об этом честно говорит флаг frame_detectors.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_PY="$SCRIPT_DIR/patterns.py"
PYTHON_BIN=""
for _py in python3 python; do
  if command -v "$_py" >/dev/null 2>&1; then PYTHON_BIN="$_py"; break; fi
done

INPUT_NORM="$INPUT"
INPUT_SENT="$INPUT"
FRAME_DETECTORS=false
if [[ -n "$PYTHON_BIN" && -f "$PATTERNS_PY" ]]; then
  _norm=$(printf '%s' "$INPUT" | "$PYTHON_BIN" "$PATTERNS_PY" --normalize 2>/dev/null)
  if [[ -n "$_norm" ]]; then INPUT_NORM="$_norm"; fi
  _sent=$(printf '%s' "$INPUT" | "$PYTHON_BIN" "$PATTERNS_PY" --sentences 2>/dev/null)
  if [[ -n "$_sent" ]]; then INPUT_SENT="$_sent"; fi
  FRAME_DETECTORS=true
fi

# --- Helper functions ---
count_words() { echo "$1" | wc -w | tr -d ' '; }
count_chars() { echo "$1" | wc -c | tr -d ' '; }
count_sentences() {
  echo "$1" | grep -oE '[.!?]+' | wc -l | tr -d ' '
}
count_paragraphs() {
  echo "$1" | awk 'BEGIN{RS=""} {n++} END{print n+0}'
}
sentence_lengths() {
  echo "$1" | sed 's/[.!?]/\n/g' | awk '{n=NF; if(n>0) print n}' | sort -n
}

# Locale note: do NOT export LC_ALL=C globally — it breaks Cyrillic character
# classes. The Cyrillic ranges below are written as explicit letter lists rather
# than `[А-Яа-я]` ranges on purpose: a range needs a collation, and under
# `C.UTF-8` (the default on GitHub runners) grep rejects it with
# "Invalid collation character", which silently empties every Cyrillic metric.
# Set the locale per-call only where byte-level semantics are needed (emoji
# byte-range, count_sentences).

# --- Compute metrics ---
WORDS=$(count_words "$INPUT_NORM")
SENTENCES=$(count_sentences "$INPUT_NORM")
PARAS=$(count_paragraphs "$INPUT_NORM")
CHARS=$(count_chars "$INPUT_NORM")

# AP: negative parallelism (P9).
# Старый детектор ловил ОДИН лексический якорь («это не X, а Y») и находил
# 0 из 8 канонических примеров каталога: «Это» в начале фразы не матчилось.
# Новый меряет риторическую рамку во всех формах (A, A_graded, A_excl,
# кросс-предложная, иерархическая) и не теряет рамку, когда лечение убирает
# лексический якорь («нулевая связка»).
AP_STRONG=0
AP_WEAK=0
AP_STRONG_PER_1K=0
AP_WEAK_PER_1K=0
AP_FRAMES=""
if [[ "$FRAME_DETECTORS" == "true" ]]; then
  _frame_env=$(printf '%s' "$INPUT_NORM" | "$PYTHON_BIN" "$PATTERNS_PY" --env 2>/dev/null)
  if [[ -n "$_frame_env" ]]; then
    eval "$_frame_env"
    AP_STRONG="${AP_STRONG:-0}"
    AP_WEAK="${AP_WEAK:-0}"
    AP_STRONG_PER_1K="${AP_STRONG_PER_1K:-0}"
    AP_WEAK_PER_1K="${AP_WEAK_PER_1K:-0}"
  fi
fi
AP=$AP_STRONG_PER_1K
AP_TOTAL=$AP_STRONG

# D: деепричастия (RU) — heuristic on context + suffix.
# Real деепричастия in Russian prose are overwhelmingly comma- or
# period-prefixed (subordinate clauses). Common false positives on short
# -а/-я nouns («общества», «подхода») are reduced by requiring:
#   1. word length ≥ 4 chars (filters «Лев», «на»)
#   2. preceded by start-of-string, comma, period, semicolon, or colon
#   3. ends in genuine деепричастие suffix (-а, -я, -в, -вши, -ив)
# Caveat: деепричастие at start of a sentence without preceding comma
# is missed. Empirically this is <15% of real cases in literary prose.
# See knowledge/01-Patterns/structural/deeprichastnye-oboroty.md for
# discussion of false-positive rate.
D_RU=$(echo "$INPUT_SENT" | grep -oE '(^|[,.;:][[:space:]]+)([АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяёЁ]{4,}(ив|вши|а|в|я))(ся)?[[:space:]]' | wc -l | tr -d ' ')
D=$(awk "BEGIN {printf \"%.1f\", $D_RU * 1000 / $WORDS}")

# E: em-dash
E_COUNT=$(echo "$INPUT" | grep -o '—' | wc -l | tr -d ' ')
E=$(awk "BEGIN {printf \"%.1f\", $E_COUNT * 300 / $WORDS}")

# V: vacuum-filling openers
V_OPENER_RU=$(echo "$INPUT_SENT" | grep -coE '^(У нас в команде|В текущей работе|Стоит отметить|Необходимо подчеркнуть|В современном мире|В данной статье)' || true)
V_OPENER_EN=$(echo "$INPUT_SENT" | grep -coE '^(In today.s|It is worth noting|Let me explain|It.s important to)' || true)
V_OPENER_TOTAL=$((V_OPENER_RU + V_OPENER_EN))
if [[ $SENTENCES -gt 0 ]]; then
  V=$(awk "BEGIN {printf \"%.1f\", $V_OPENER_TOTAL * 100 / $SENTENCES}")
else
  V="0.0"
fi

# R: restatement chains — trigram overlap between ADJACENT sentences.
# A sentence pair (i-1, i) counts as "restated" when the two sentences share
# more than 50% of their trigrams (overlap coefficient over the smaller set).
# Normalization: lowercase, whitespace-split; sentence split on .!?
# R% = restated pairs / all adjacent pairs.
R=$(echo "$INPUT_NORM" | tr '\n' ' ' | sed 's/[.!?]\+/&\n/g' | awk '
  {
    sub(/^[[:space:]]+/, "")
    sub(/[[:space:]]+$/, "")
    if (length($0) == 0) next
    n = split(tolower($0), words, /[[:space:]]+/)
    delete cur
    cnt = 0
    for (i = 1; i <= n - 2; i++) {
      tri = words[i] " " words[i+1] " " words[i+2]
      if (!(tri in cur)) { cur[tri] = 1; cnt++ }
    }
    sentences++
    if (sentences > 1 && cnt > 0 && prev_cnt > 0) {
      common = 0
      for (t in cur) if (t in prev) common++
      denom = (cnt < prev_cnt ? cnt : prev_cnt)
      if (common / denom > 0.5) restated++
    }
    delete prev
    for (t in cur) prev[t] = 1
    prev_cnt = cnt
  }
  END {
    if (sentences <= 1) { printf "0.0"; exit }
    printf "%.1f", restated * 100 / (sentences - 1)
  }
')

# B: bridging phrases at para starts
B_RU=$(echo "$INPUT_NORM" | grep -coE '^(Как упоминалось выше|Это подводит нас к|В свою очередь|Кроме того)' || true)
B_EN=$(echo "$INPUT_NORM" | grep -coE '^(As mentioned above|This brings us to|In addition|Furthermore|Moreover)' || true)
B_TOTAL=$((B_RU + B_EN))
if [[ $PARAS -gt 0 ]]; then
  B=$(awk "BEGIN {printf \"%.1f\", $B_TOTAL * 100 / $PARAS}")
else
  B="0.0"
fi

# YapScore — filler-based heuristic, НЕ сравнение с минимально-достаточным
# baseline. Настоящий YapBench baseline (Borisov et al., 2026) требует
# эталонного «достаточного» ответа на тот же промпт; здесь его нет. Вместо
# этого: baseline = WORDS минус взвешенные маркеры-пустышки (vacuum openers,
# bridging, negative parallelism, лексические fillers). Значение ~1.0 означает
# «мало маркеров», а не «текст достаточной длины». Использовать только как
# сигнал over-generation, не как меру качества.
YAP_FILLER=$(echo "$INPUT_NORM" | grep -Eio '(современн(ое|ый|ая)|Стоит отметить|Более того|значительных результатов|эффективное решение|оптимизаци[яи]|интуитивн|продуманн|comprehensive|seamless|robust|cutting-edge|It is worth noting|In today.s|Moreover|Furthermore)' | wc -l | tr -d ' ')
YAP_REDUNDANT=$(( (V_OPENER_TOTAL + B_TOTAL) * 8 + AP_TOTAL * 6 + YAP_FILLER * 4 ))
if [[ $WORDS -gt 0 ]]; then
  # baseline = words minus weighted filler markers; floor at 10% of WORDS so a
  # text that is almost entirely markers cannot blow the ratio up to hundreds
  # (measured: over-generated fixture gave 310.0 before the floor). The floor
  # caps YapScore at 10 — a saturated value that still flags over-generation,
  # unlike the old 60% floor which silently capped it at 1.67 and made severe
  # over-generation undetectable.
  YAP_BASELINE=$(awk "BEGIN {b=$WORDS-$YAP_REDUNDANT; f=$WORDS*0.10; if (b<f) b=f; if (b<1) b=1; printf \"%d\", b}")
  YAP=$(awk "BEGIN {printf \"%.2f\", $WORDS / $YAP_BASELINE}")
else
  YAP="0.00"
fi

# Burstiness: mean & std of sentence length
LENGTHS=$(sentence_lengths "$INPUT_NORM")
if [[ -n "$LENGTHS" ]]; then
  BURST_MEAN=$(echo "$LENGTHS" | awk '{s+=$1; n++} END{printf "%.1f", s/n}')
  BURST_STD=$(echo "$LENGTHS" | awk -v mean="$BURST_MEAN" '{d=$1-mean; s+=d*d; n++} END{printf "%.1f", sqrt(s/n)}')
else
  BURST_MEAN="0.0"
  BURST_STD="0.0"
fi

# Specificity: concrete facts per paragraph
FACTS=$(echo "$INPUT_NORM" | grep -coE '\b[0-9]+(\.[0-9]+)?(%|ms|sec|req|GB|MB|KB|s|m|h)?\b' || true)
SPECIFICITY=$(awk "BEGIN {printf \"%.2f\", $FACTS / $PARAS}")

# Format bias
# Emoji heuristic: count chars in known emoji Unicode blocks.
# Earlier versions used `[^[:ascii:]]` (counted Cyrillic too — wrong) and
# also threw "Invalid character class name" on some grep versions.
EMOJI=$(echo "$INPUT_NORM" | grep -oP '[\x{1F000}-\x{1FFFF}\x{2600}-\x{27BF}\x{1F300}-\x{1F5FF}\x{1F600}-\x{1F64F}\x{1F680}-\x{1F6FF}\x{1F900}-\x{1F9FF}\x{2700}-\x{27BF}]' | wc -l | tr -d ' ')
BOLD=$(echo "$INPUT_NORM" | grep -coE '\*\*[^*]+\*\*' || true)
LISTS=$(echo "$INPUT_SENT" | grep -coE '^[[:space:]]*[-*][[:space:]]' || true)
EMOJI_PER_1K=$(awk "BEGIN {printf \"%.1f\", $EMOJI * 1000 / $WORDS}")
BOLD_PCT=$(awk "BEGIN {printf \"%.1f\", $BOLD * 100 / $WORDS}")
LISTS_PER_1K=$(awk "BEGIN {printf \"%.1f\", $LISTS * 1000 / $WORDS}")

# Voice
FIRST_PERSON=$(echo "$INPUT" | grep -coE '\b(я|мы|I|we)\b' || true)
OPINION=$(echo "$INPUT" | grep -coE '\b(считаю|думаю|полагаю|в моём мнении|I think|I believe|in my view)\b' || true)
FIRST_PERSON_PRESENT=$([ $FIRST_PERSON -gt 0 ] && echo "true" || echo "false")
OPINION_PRESENT=$([ $OPINION -gt 0 ] && echo "true" || echo "false")

# --- New patterns (P-NEW-13..20) from knowledge/01-Patterns/catalogue-update.md ---
# Lexical-realizable subset. Each emits density per 1000 words.

# P-NEW-13 False Agency: abstract subjects with volitional verbs
FALSE_AGENCY=$(echo "$INPUT_SENT" | grep -coEi '\b(market|system|algorithm|trend|security|performance|the (api|cli|app)|api|cli|architecture|design|data|model|policy|strategy)\s+(decides?|demands?|requires?|rewards?|says?|wants?|chooses?|drives?|forces?|rejects?|insists?)\b' || true)
P13=$(awk "BEGIN {printf \"%.2f\", $FALSE_AGENCY * 1000 / $WORDS}")

# P-NEW-16 Argument Residue: возражение позиции, которой в тексте нет.
# Старый детектор знал только английский и считал «два контрастивных
# коннектора в предложении». Новый ищет оппонента без имени (по каталогу:
# hypothetical opponents without named referents) — на RU и EN.
P16_UNNAMED=${P16_UNNAMED_OPPONENT:-0}
P16_DOUBLES=${P16_DOUBLE_CONNECTORS:-0}
P16=$(awk "BEGIN {printf \"%.2f\", $P16_UNNAMED * 1000 / $WORDS}")

# P-NEW-18 Asyndeton Tricolon: бессоюзное трикольцо с НАРАСТАЮЩЕЙ длиной
# членов. Прежняя реализация считала любую фразу с двумя запятыми: на
# «Даме с собакой» давала 47 срабатываний, на AI-тексте — 1. Разница в
# сигнале была нулевой, то есть метрика ничего не измеряла.
P18_TRICOLONS=${P18_TRICOLONS:-0}
P18=$(awk "BEGIN {printf \"%.2f\", $P18_TRICOLONS * 1000 / $WORDS}")

# P-NEW-19 Mini-Aphorism Closer: абзац заканчивается коротким предложением.
# Прежний awk не мог сработать никогда: /[.!?]+[^.!?]*$/ откатывался на
# последнюю точку, поэтому «closer» всегда оказывался пустым.
P19_CLOSERS=${P19_CLOSERS:-0}
P19_APHORISTIC=${P19_APHORISTIC:-0}
P19=$P19_CLOSERS

# P-NEW-20 Hedged-Enumeration Openers: "From X to Y, ..." or "Whether A or B, ..."
HEDGED_OPENER=$(echo "$INPUT_SENT" | grep -coEi '^[[:space:]]*(from[[:space:]]+[^.]+[[:space:]]+to[[:space:]]+[^,.]+,|whether[[:space:]]+[^.]+[[:space:]]+or[[:space:]]+[^,.]+,|as[[:space:]]+(both|well)|not[[:space:]]+just[[:space:]]+[^.]+,)' || true)
P20=$(awk "BEGIN {printf \"%.2f\", $HEDGED_OPENER * 1000 / $WORDS}")

# --- Language detection for calibrated thresholds ---
# Cyrillic ratio > 0.3 → RU mode (applies RU-specific thresholds).
CYR_COUNT=$(echo "$INPUT_NORM" | grep -oE '[АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяёЁ]' | wc -l | tr -d ' ')
LETTER_COUNT=$(echo "$INPUT_NORM" | grep -oE '[A-Za-zАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяёЁ]' | wc -l | tr -d ' ')
if [[ "$LETTER_COUNT" -gt 0 ]]; then
    CYR_RATIO=$(awk "BEGIN {printf \"%.3f\", $CYR_COUNT / $LETTER_COUNT}")
else
    CYR_RATIO="0.000"
fi
if awk "BEGIN {exit !($CYR_RATIO > 0.3)}"; then
    LANGUAGE="ru"
else
    LANGUAGE="en"
fi

# --- Calibrated thresholds ---
# See knowledge/02-Techniques/metric-validation.md for empirical derivation.
# Caveat: D (деепричастия density) discriminates AI vs conversational RU
# but Tolstoy-class literary prose (~30/1000) exceeds any useful threshold.
# Therefore D is a *soft* recommendation, not a hard fail.
#
# AP (negative parallelism) пере-калиброван на реальном LLM-корпусе
# (scripts/generate-llm-corpus.sh, n=24 RU + n=12 EN, модель MiniMax-M3):
#   RU: человек (n=8, литература) 0.40-3.45/1k; LLM 4.65-15.94/1k (медиана 5.5).
#       Порог 4 стоит между максимумом человека и минимумом LLM.
#   EN: человек (n=60) 0-2.36/1k; LLM 4.27-4.31/1k. Порог 3.
# Прежний порог TH_AP=1 был неверен: он помечал 7 из 8 человеческих
# литературных файлов и пропускал половину LLM-текстов.
if [[ "$LANGUAGE" == "ru" ]]; then
    TH_D_SOFT=18      # RU literary prose normal: 14-30/1000. AI: ~0-11. Soft warning.
    TH_E=1            # RU: humans use em-dash. AI uses 0. Threshold <1 flags AI.
    TH_V=2            # RU: humans 0%, AI marketing 6.7%. Threshold >2 flags AI.
    TH_BURST=8        # RU: humans 18.85, AI 6.51. Threshold <8 flags AI.
    TH_R=10
    TH_AP=4           # RU: humans ≤3.45, LLM ≥4.65. Порог 4 разделяет.
    TH_YAP=150        # YapScore*100.
else
    TH_D_SOFT=7
    TH_E=3            # EN: humans 0.05, AI 0. Threshold <3 (no signal here).
    TH_V=2            # EN: humans 0%, AI Q&A 1.7%. Threshold >2 flags over-gen.
    TH_BURST=3
    TH_R=10
    TH_AP=3           # EN: humans ≤2.36, LLM ≥4.27. Порог 3 разделяет.
    TH_YAP=150
fi

# --- Target checks (use simple integer comparisons to avoid heredoc issues) ---
AP_INT=$(awk "BEGIN {printf \"%d\", ($AP+0.5)}")
D_INT=$(awk "BEGIN {printf \"%d\", ($D+0.5)}")
E_INT=$(awk "BEGIN {printf \"%d\", ($E+0.5)}")
R_INT=$(awk "BEGIN {printf \"%d\", ($R+0.5)}")
V_INT=$(awk "BEGIN {printf \"%d\", ($V+0.5)}")
YAP_X100=$(awk "BEGIN {printf \"%d\", ($YAP*100)}")
BURST_INT=$(awk "BEGIN {printf \"%d\", ($BURST_STD+0.5)}")

[ "$AP_INT" -gt "$TH_AP" ] && TARGETS_OK=false
# D, E are soft for RU: high D is OK in literary prose (Tolstoy);
# low E (especially =0) suggests AI, but high E is also normal.
# Keep as recommendation, not fail.
D_HIGH=$([ "$D_INT" -gt "$TH_D_SOFT" ] && echo 1 || echo 0)
E_ZERO=$([ "$E_INT" -eq 0 ] && echo 1 || echo 0)
[ "$V_INT" -gt "$TH_V" ] && TARGETS_OK=false
[ "$R_INT" -gt "$TH_R" ] && TARGETS_OK=false
[ "$YAP_X100" -gt "$TH_YAP" ] && TARGETS_OK=false
[ "$BURST_INT" -lt "$TH_BURST" ] && TARGETS_OK=false

# --- Output ---
if [[ "$JSON_MODE" == "true" ]]; then
  cat <<EOF
{
  "language": "$LANGUAGE",
  "frame_detectors": $FRAME_DETECTORS,
  "thresholds": {
    "AP": $TH_AP,
    "D_soft": $TH_D_SOFT,
    "E": $TH_E,
    "V": $TH_V,
    "R": $TH_R,
    "YapScore_x100": $TH_YAP,
    "Burstiness_std": $TH_BURST
  },
  "metrics": {
    "words": $WORDS,
    "sentences": $SENTENCES,
    "paragraphs": $PARAS,
    "chars": $CHARS,
    "AP": $AP,
    "D": $D,
    "E": $E,
    "V": $V,
    "B": $B,
    "R": $R,
    "YapScore": $YAP,
    "burstiness": {
      "mean": $BURST_MEAN,
      "std": $BURST_STD
    },
    "specificity_facts_per_para": $SPECIFICITY,
    "format_bias": {
      "emojis_per_1k": $EMOJI_PER_1K,
      "bold_pct": $BOLD_PCT,
      "lists_per_1k": $LISTS_PER_1K
    },
    "voice": {
      "first_person": "$FIRST_PERSON_PRESENT",
      "opinion": "$OPINION_PRESENT"
    },
    "new_patterns": {
      "AP_strong_frames": $AP_STRONG,
      "AP_weak_frames": $AP_WEAK,
      "AP_strong_per_1k": $AP_STRONG_PER_1K,
      "AP_weak_per_1k": $AP_WEAK_PER_1K,
      "P_NEW_13_false_agency_per_1k": $P13,
      "P_NEW_16_argument_residue_per_1k": $P16,
      "P_NEW_16_double_connectors": $P16_DOUBLES,
      "P_NEW_18_asyndeton_tricolon_per_1k": $P18,
      "P_NEW_19_mini_aphorism_closer": $P19,
      "P_NEW_19_aphoristic_closer": $P19_APHORISTIC,
      "P_NEW_20_hedged_opener_per_1k": $P20
    }
  },
  "targets_ok": $TARGETS_OK,
  "recommendations": []
}
EOF
else
  cat <<EOF
╔════════════════════════════════════════════════════════════════╗
║              SKILL BENCHMARK REPORT ($LANGUAGE mode)              ║
╚════════════════════════════════════════════════════════════════╝

Volume:
  Words:       $WORDS
  Sentences:   $SENTENCES
  Paragraphs:  $PARAS
  Characters:  $CHARS

Density metrics:
  AP (negative parallelism):  $AP  per 1000 words   [target <$TH_AP]
                               strong frames: $AP_STRONG (weak: $AP_WEAK)
  D  (RU деепричастия):       $D   per 1000 words   [target <$TH_D_SOFT]
  E  (em-dash):               $E   per 300 words     [target <$TH_E]
  V  (vacuum-filling):        $V%                   [target <$TH_V%]
  B  (bridging):              $B%  of paragraphs    [target <5%]
  R  (restatement):           $R%  of sentences    [target <$TH_R%]
  YapScore (filler heuristic): $YAP                   [target 1.0-1.5; не мера качества]


Burstiness:
  Mean sentence length:       $BURST_MEAN words
  Std deviation:              $BURST_STD             [target >$TH_BURST]

Specificity:
  Concrete facts per para:    $SPECIFICITY           [target >0.5]

New patterns (P-NEW-13..20, per 1000 words):
  P-NEW-13 False Agency:     $P13   [target <2]
  P-NEW-16 Argument Residue:  $P16   [target <1]  (unnamed opponents: $P16_UNNAMED)
  P-NEW-18 Asyndeton:         $P18   [target <3]  (escalating tricolons)
  P-NEW-19 Mini-Aphorism:     $P19   total [target <2]  (aphoristic: $P19_APHORISTIC)
  P-NEW-20 Hedged Opener:     $P20   [target <1]

Format bias (Zhang 2024):
  Emojis per 1000 words:       $EMOJI_PER_1K
  Bold percentage:             $BOLD_PCT%
  Lists per 1000 words:        $LISTS_PER_1K

Voice:
  First-person present:       $FIRST_PERSON_PRESENT
  Opinion present:            $OPINION_PRESENT

─────────────────────────────────────────────────────────────────
Diagnostic verdict (НЕ оценка качества текста, только проверка метрик):
  $([ "$TARGETS_OK" = "true" ] && echo "OK — метрики в целевых диапазонах" || echo "REVIEW — есть сигналы для ручной проверки")

Recommendations:
EOF

  [ "$AP_INT" -gt "$TH_AP" ] && echo "  • AP > $TH_AP: убрать negative parallelisms (P9)"
  [ "$D_HIGH" = "1" ] && echo "  • D > $TH_D_SOFT: высокая плотность деепричастий (Tolstoy-class). Для conversational/technical — снизить."
  [ "$E_ZERO" = "1" ] && echo "  • E = 0 в RU: AI-сигнал (LLM не использует em-dash). Для RU-прозы добавить."
  [ "$V_INT" -gt "$TH_V" ] && echo "  • V > $TH_V%: удалить vacuum-filling предложения (P-NEW-1)"
  [ "$YAP_X100" -gt "$TH_YAP" ] && echo "  • YapScore > 1.5: применить Tighten pass (Lever 10)"
  [ "$BURST_INT" -lt "$TH_BURST" ] && echo "  • Burstiness std < $TH_BURST: варьировать длину предложений (Lever 2)"
  awk "BEGIN {exit !($SPECIFICITY < 0.5)}" && echo "  • Specificity < 0.5: добавить конкретики (Lever 5)"
  awk "BEGIN {exit !($R > $TH_R)}" && echo "  • R > $TH_R%: убрать restatement chains (P-NEW-2)"
  awk "BEGIN {exit !($P13 > 2)}" && echo "  • P-NEW-13 False Agency > 2/1k: concrete кто/что решает (см. catalogue-update)"
  awk "BEGIN {exit !($P16 > 1)}" && echo "  • P-NEW-16 Argument Residue > 1/1k: убрать rebuttal-to-nobody"
  awk "BEGIN {exit !($P20 > 1)}" && echo "  • P-NEW-20 Hedged Opener > 1/1k: убрать «From X to Y, …» openers"

  echo ""
  echo "См. также: 04-Examples/tightening/, 04-Examples/iceberg/, 04-Examples/russian-grammar/"
  echo "Калибровка порогов: knowledge/02-Techniques/metric-validation.md (n=145: HC3/RAID/Wikisource)"
fi

# --- Exit code ---
[ "$TARGETS_OK" = "true" ] && exit 0 || exit 1
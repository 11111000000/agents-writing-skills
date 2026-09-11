#!/usr/bin/env bash
# scripts/benchmark-skill.sh
# Замеряет метрики AI-текста на входе. Полезно для baseline перед запуском humanize-editor.
#
# Метрики:
#   - AP: negative parallelism density (per 1000 words)
#   - D:  деепричастия density (per 1000 words, RU only)
#   - E:  em-dash count (per 300 words)
#   - V:  vacuum-filling sentences (%)
#   - R:  restatement chains (%)
#   - B:  bridging phrases at para starts (%)
#   - YapScore estimate (длина / baseline, где baseline = 60% текущей длины)
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
#   exit 0 если текст OK (все метрики в target range)
#   exit 1 если есть проблемы
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
# classes (e.g. `[А-Яа-я]` becomes silent-no-match). Set it per-call only where
# byte-level semantics are needed (emoji byte-range, count_sentences).

# --- Compute metrics ---
WORDS=$(count_words "$INPUT")
SENTENCES=$(count_sentences "$INPUT")
PARAS=$(count_paragraphs "$INPUT")
CHARS=$(count_chars "$INPUT")

# AP: negative parallelism (RU)
AP_RU=$(echo "$INPUT" | grep -coE '(это|такое|так)\s+не\s+[[:alpha:]]+,?\s+(а|это|скорее)\s+[[:alpha:]]+' || true)
# AP: negative parallelism (EN)
AP_EN=$(echo "$INPUT" | grep -coE "it's not|this is not|that is not" || true)
AP_TOTAL=$((AP_RU + AP_EN))
if [[ $WORDS -gt 0 ]]; then
  AP=$(awk "BEGIN {printf \"%.2f\", $AP_TOTAL * 1000 / $WORDS}")
else
  AP="0.00"
fi

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
D_RU=$(echo "$INPUT" | grep -oE '(^|[,.;:][[:space:]]+)([А-Яа-яЁё]{4,}(ив|вши|а|в|я))(ся)?[[:space:]]' | wc -l | tr -d ' ')
D=$(awk "BEGIN {printf \"%.1f\", $D_RU * 1000 / $WORDS}")

# E: em-dash
E_COUNT=$(echo "$INPUT" | grep -o '—' | wc -l | tr -d ' ')
E=$(awk "BEGIN {printf \"%.1f\", $E_COUNT * 300 / $WORDS}")

# V: vacuum-filling openers
V_OPENER_RU=$(echo "$INPUT" | grep -coE '^(У нас в команде|В текущей работе|Стоит отметить|Необходимо подчеркнуть|В современном мире|В данной статье)' || true)
V_OPENER_EN=$(echo "$INPUT" | grep -coE '^(In today.s|It is worth noting|Let me explain|It.s important to)' || true)
V_OPENER_TOTAL=$((V_OPENER_RU + V_OPENER_EN))
if [[ $SENTENCES -gt 0 ]]; then
  V=$(awk "BEGIN {printf \"%.1f\", $V_OPENER_TOTAL * 100 / $SENTENCES}")
else
  V="0.0"
fi

# R: restatement chains (heuristic: trigram overlap between adjacent sentences)
R=$(echo "$INPUT" | awk '
  BEGIN { FS = ".!?\n"; }
  {
    sub(/^\s+|\s+$/, "")
    if (length($0) == 0) next
    n = split($0, words, /[[:space:]]+/)
    delete trie
    for (i = 1; i <= n - 2; i++) {
      tri = tolower(words[i] " " words[i+1] " " words[i+2])
      if (trie[tri]) { restated++; break }
      trie[tri] = 1
    }
    sentences++
  }
  END {
    if (sentences == 0) { print 0; exit }
    pct = restated * 100 / sentences
    printf "%.1f\n", pct
  }
')

# B: bridging phrases at para starts
B_RU=$(echo "$INPUT" | grep -coE '^(Как упоминалось выше|Это подводит нас к|В свою очередь|Кроме того)' || true)
B_EN=$(echo "$INPUT" | grep -coE '^(As mentioned above|This brings us to|In addition|Furthermore|Moreover)' || true)
B_TOTAL=$((B_RU + B_EN))
if [[ $PARAS -gt 0 ]]; then
  B=$(awk "BEGIN {printf \"%.1f\", $B_TOTAL * 100 / $PARAS}")
else
  B="0.0"
fi

YAP_FILLER=$(echo "$INPUT" | grep -Eio '(современн(ое|ый|ая)|Стоит отметить|Более того|значительных результатов|эффективное решение|оптимизаци[яи]|интуитивн|продуманн|comprehensive|seamless|robust|cutting-edge|It is worth noting|In today.s|Moreover|Furthermore)' | wc -l | tr -d ' ')
YAP_REDUNDANT=$(( (V_OPENER_TOTAL + B_TOTAL) * 8 + AP_TOTAL * 6 + YAP_FILLER * 4 ))
if [[ $WORDS -gt 0 ]]; then
  # baseline = non-redundant words; floor at 1 to avoid div-by-zero.
  # (previous formula floored at 60% of WORDS, which silently capped YapScore
  # at 1.67 — making it impossible to flag severely over-generated text.)
  YAP_BASELINE=$(awk "BEGIN {b=$WORDS-$YAP_REDUNDANT; if (b<1) b=1; printf \"%d\", b}")
  YAP=$(awk "BEGIN {printf \"%.2f\", $WORDS / $YAP_BASELINE}")
else
  YAP="0.00"
fi

# Burstiness: mean & std of sentence length
LENGTHS=$(sentence_lengths "$INPUT")
if [[ -n "$LENGTHS" ]]; then
  BURST_MEAN=$(echo "$LENGTHS" | awk '{s+=$1; n++} END{printf "%.1f", s/n}')
  BURST_STD=$(echo "$LENGTHS" | awk -v mean="$BURST_MEAN" '{d=$1-mean; s+=d*d; n++} END{printf "%.1f", sqrt(s/n)}')
else
  BURST_MEAN="0.0"
  BURST_STD="0.0"
fi

# Specificity: concrete facts per paragraph
FACTS=$(echo "$INPUT" | grep -coE '\b[0-9]+(\.[0-9]+)?(%|ms|sec|req|GB|MB|KB|s|m|h)?\b' || true)
SPECIFICITY=$(awk "BEGIN {printf \"%.2f\", $FACTS / $PARAS}")

# Format bias
# Emoji heuristic: count chars in known emoji Unicode blocks.
# Earlier versions used `[^[:ascii:]]` (counted Cyrillic too — wrong) and
# also threw "Invalid character class name" on some grep versions.
EMOJI=$(echo "$INPUT" | grep -oP '[\x{1F000}-\x{1FFFF}\x{2600}-\x{27BF}\x{1F300}-\x{1F5FF}\x{1F600}-\x{1F64F}\x{1F680}-\x{1F6FF}\x{1F900}-\x{1F9FF}\x{2700}-\x{27BF}]' | wc -l | tr -d ' ')
BOLD=$(echo "$INPUT" | grep -coE '\*\*[^*]+\*\*' || true)
LISTS=$(echo "$INPUT" | grep -coE '^[[:space:]]*[-*][[:space:]]' || true)
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
FALSE_AGENCY=$(echo "$INPUT" | grep -coEi '\b(market|system|algorithm|trend|security|performance|the (api|cli|app)|api|cli|architecture|design|data|model|policy|strategy)\s+(decides?|demands?|requires?|rewards?|says?|wants?|chooses?|drives?|forces?|rejects?|insists?)\b' || true)
P13=$(awk "BEGIN {printf \"%.2f\", $FALSE_AGENCY * 1000 / $WORDS}")

# P-NEW-16 Argument Residue: rebuttal-to-nobody chains
ARG_RESIDUE=$(echo "$INPUT" | grep -coEi '\b(however|though|yet|still|nonetheless),[^.]+\b(however|though|yet|still|nonetheless)\b' || true)
P16=$(awk "BEGIN {printf \"%.2f\", $ARG_RESIDUE * 1000 / $WORDS}")

# P-NEW-18 Asyndeton Tricolon: three 5+ word clauses joined by "," without conjunction
# Approximation: sentences containing two commas separating long phrases
ASYN_TRICOLON=$(echo "$INPUT" | grep -coE '[^.!?]{20,},[^.!?]{20,},[^.!?]{20,}[.!?]' || true)
P18=$(awk "BEGIN {printf \"%.2f\", $ASYN_TRICOLON * 1000 / $WORDS}")

# P-NEW-19 Mini-Aphorism Closer: last sentence ≤ 6 words and ends with period
# Compute via awk on sentences
P19=$(echo "$INPUT" | awk '
  BEGIN { last_short = 0 }
  {
    # Approximate sentence split
    n = gsub(/[.!?]+/, "&")
  }
  {
    sent = $0
    if (match(sent, /[.!?]+[^.!?]*$/)) {
      closer = substr(sent, RSTART)
      gsub(/[.!?]/, " ", closer)
      nwords = split(closer, w, /[[:space:]]+/); wc = 0
      for (i=1; i<=nwords; i++) if (length(w[i]) > 0) wc++
      if (wc > 0 && wc <= 6) last_short++
    }
  }
  END { printf "%d", last_short }
')

# P-NEW-20 Hedged-Enumeration Openers: "From X to Y, ..." or "Whether A or B, ..."
HEDGED_OPENER=$(echo "$INPUT" | grep -coEi '^[[:space:]]*(from[[:space:]]+[^.]+[[:space:]]+to[[:space:]]+[^,.]+,|whether[[:space:]]+[^.]+[[:space:]]+or[[:space:]]+[^,.]+,|as[[:space:]]+(both|well)|not[[:space:]]+just[[:space:]]+[^.]+,)' || true)
P20=$(awk "BEGIN {printf \"%.2f\", $HEDGED_OPENER * 1000 / $WORDS}")

# --- Language detection for calibrated thresholds ---
# Cyrillic ratio > 0.3 → RU mode (applies RU-specific thresholds).
CYR_COUNT=$(echo "$INPUT" | grep -oE '[А-Яа-яЁё]' | wc -l | tr -d ' ')
LETTER_COUNT=$(echo "$INPUT" | grep -oE '[A-Za-zА-Яа-яЁё]' | wc -l | tr -d ' ')
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

# --- Calibrated thresholds (validated on HC3/RAID/Wikisource, n=145) ---
# See knowledge/02-Techniques/metric-validation.md for empirical derivation.
# Caveat: D (деепричастия density) discriminates AI vs conversational RU
# but Tolstoy-class literary prose (~30/1000) exceeds any useful threshold.
# Therefore D is a *soft* recommendation, not a hard fail.
if [[ "$LANGUAGE" == "ru" ]]; then
    TH_D_SOFT=18      # RU literary prose normal: 14-30/1000. AI: ~0-11. Soft warning.
    TH_E=1            # RU: humans use em-dash. AI uses 0. Threshold <1 flags AI.
    TH_V=2            # RU: humans 0%, AI marketing 6.7%. Threshold >2 flags AI.
    TH_BURST=8        # RU: humans 18.85, AI 6.51. Threshold <8 flags AI.
    TH_R=10
    TH_AP=1
    TH_YAP=150        # YapScore*100.
else
    TH_D_SOFT=7
    TH_E=3            # EN: humans 0.05, AI 0. Threshold <3 (no signal here).
    TH_V=2            # EN: humans 0%, AI Q&A 1.7%. Threshold >2 flags over-gen.
    TH_BURST=3
    TH_R=10
    TH_AP=1
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
      "P_NEW_13_false_agency_per_1k": $P13,
      "P_NEW_16_argument_residue_per_1k": $P16,
      "P_NEW_18_asyndeton_tricolon_per_1k": $P18,
      "P_NEW_19_mini_aphorism_closer": $P19,
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
  D  (RU деепричастия):       $D   per 1000 words   [target <$TH_D]
  E  (em-dash):               $E   per 300 words     [target <$TH_E]
  V  (vacuum-filling):        $V%                   [target <$TH_V%]
  B  (bridging):              $B%  of paragraphs    [target <5%]
  R  (restatement):           $R%  of sentences    [target <$TH_R%]
  YapScore:                   $YAP                   [target 1.0-1.5]"


Burstiness:
  Mean sentence length:       $BURST_MEAN words
  Std deviation:              $BURST_STD             [target >$TH_BURST]

Specificity:
  Concrete facts per para:    $SPECIFICITY           [target >0.5]

New patterns (P-NEW-13..20, per 1000 words):
  P-NEW-13 False Agency:     $P13   [target <2]
  P-NEW-16 Argument Residue:  $P16   [target <1]
  P-NEW-18 Asyndeton:         $P18   [target <3]
  P-NEW-19 Mini-Aphorism:     $P19   total [target <2]
  P-NEW-20 Hedged Opener:     $P20   [target <1]

Format bias (Zhang 2024):
  Emojis per 1000 words:       $EMOJI_PER_1K
  Bold percentage:             $BOLD_PCT%
  Lists per 1000 words:        $LISTS_PER_1K

Voice:
  First-person present:       $FIRST_PERSON_PRESENT
  Opinion present:            $OPINION_PRESENT

─────────────────────────────────────────────────────────────────
Verdict: $([ "$TARGETS_OK" = "true" ] && echo "PASS (все метрики в target)" || echo "FAIL (есть проблемы)")

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
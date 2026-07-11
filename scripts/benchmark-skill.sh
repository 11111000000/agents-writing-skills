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

# Use LC_ALL=C for predictable regex (no locale issues with Cyrillic)
export LC_ALL=C

# --- Compute metrics ---
WORDS=$(count_words "$INPUT")
SENTENCES=$(count_sentences "$INPUT")
PARAS=$(count_paragraphs "$INPUT")
CHARS=$(count_chars "$INPUT")

# AP: negative parallelism (RU)
AP_RU=$(echo "$INPUT" | LC_ALL=C grep -coE '(это|такое|так)\s+не\s+[[:alpha:]]+,?\s+(а|это|скорее)\s+[[:alpha:]]+' || true)
# AP: negative parallelism (EN)
AP_EN=$(echo "$INPUT" | LC_ALL=C grep -coE "it's not|this is not|that is not" || true)
AP_TOTAL=$((AP_RU + AP_EN))
if [[ $WORDS -gt 0 ]]; then
  AP=$(awk "BEGIN {printf \"%.2f\", $AP_TOTAL * 1000 / $WORDS}")
else
  AP="0.00"
fi

# D: деепричастия (RU) — простая эвристика: окончания -а, -в, -вши, -я перед пробелом
D_RU=$(echo "$INPUT" | grep -coE '\b[А-Яа-я]+(ая|ую|ое|ые|ой|ых|ому|ыми|ем|ев|ив|ивши|вши|а|в|я)(ся)?\b' || true)
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
R=$(LC_ALL=C echo "$INPUT" | awk '
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
  YAP_BASELINE=$(awk "BEGIN {b=$WORDS-$YAP_REDUNDANT; floor=$WORDS*0.6; if (b<floor) b=floor; if (b<1) b=1; printf \"%d\", b}")
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
EMOJI=$(echo "$INPUT" | grep -coE '[[:cntrl:]]' || true)
# Use simpler emoji detection — count non-ASCII chars (rough proxy)
EMOJI=$(echo "$INPUT" | LC_ALL=C grep -oE '[^[:ascii:]]' | wc -l | tr -d ' ')
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

# --- Target checks (use simple integer comparisons to avoid heredoc issues) ---
AP_INT=$(awk "BEGIN {printf \"%d\", ($AP+0.5)}")
D_INT=$(awk "BEGIN {printf \"%d\", ($D+0.5)}")
E_INT=$(awk "BEGIN {printf \"%d\", ($E+0.5)}")
R_INT=$(awk "BEGIN {printf \"%d\", ($R+0.5)}")
YAP_X100=$(awk "BEGIN {printf \"%d\", ($YAP*100)}")
BURST_INT=$(awk "BEGIN {printf \"%d\", ($BURST_STD+0.5)}")

[ "$AP_INT" -gt 1 ] && TARGETS_OK=false
[ "$D_INT" -gt 7 ] && TARGETS_OK=false
[ "$E_INT" -gt 3 ] && TARGETS_OK=false
[ "$R_INT" -gt 10 ] && TARGETS_OK=false
[ "$YAP_X100" -gt 150 ] && TARGETS_OK=false
[ "$BURST_INT" -lt 3 ] && TARGETS_OK=false

# --- Output ---
if [[ "$JSON_MODE" == "true" ]]; then
  cat <<EOF
{
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
    }
  },
  "targets_ok": $TARGETS_OK,
  "recommendations": []
}
EOF
else
  cat <<EOF
╔════════════════════════════════════════════════════════════════╗
║              SKILL BENCHMARK REPORT                             ║
╚════════════════════════════════════════════════════════════════╝

Volume:
  Words:       $WORDS
  Sentences:   $SENTENCES
  Paragraphs:  $PARAS
  Characters:  $CHARS

Density metrics:
  AP (negative parallelism):  $AP  per 1000 words   [target <1]
  D  (RU деепричастия):       $D   per 1000 words   [target <7]
  E  (em-dash):               $E   per 300 words     [target <3]
  V  (vacuum-filling):        $V%                   [target <5%]
  B  (bridging):              $B%  of paragraphs    [target <5%]
  R  (restatement):           $R%  of sentences    [target <10%]
  YapScore:                   $YAP                   [target 1.0-1.5]"


Burstiness:
  Mean sentence length:       $BURST_MEAN words
  Std deviation:              $BURST_STD             [target >5]

Specificity:
  Concrete facts per para:    $SPECIFICITY           [target >0.5]

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

  [ "$AP_INT" -gt 1 ] && echo "  • AP > 1: убрать negative parallelisms (P9)"
  [ "$D_INT" -gt 7 ] && echo "  • D > 7: уменьшить деепричастия (RU)"
  [ "$E_INT" -gt 3 ] && echo "  • E > 3: убрать лишние em-dash"
  [ "$YAP_X100" -gt 150 ] && echo "  • YapScore > 1.5: применить Tighten pass (Lever 10)"
  [ "$BURST_INT" -lt 3 ] && echo "  • Burstiness std < 3: варьировать длину предложений (Lever 2)"
  awk "BEGIN {exit !($SPECIFICITY < 0.5)}" && echo "  • Specificity < 0.5: добавить конкретики (Lever 5)"
  awk "BEGIN {exit !($V > 5)}" && echo "  • V > 5%: удалить vacuum-filling предложения (P-NEW-1)"
  awk "BEGIN {exit !($B > 5)}" && echo "  • B > 5%: убрать bridging phrases (P-NEW-3)"
  awk "BEGIN {exit !($R > 10)}" && echo "  • R > 10%: убрать restatement chains (P-NEW-2)"

  echo ""
  echo "См. также: 04-Examples/tightening/, 04-Examples/iceberg/, 04-Examples/russian-grammar/"
fi

# --- Exit code ---
[ "$TARGETS_OK" = "true" ] && exit 0 || exit 1
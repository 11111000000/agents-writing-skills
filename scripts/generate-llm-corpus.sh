#!/usr/bin/env bash
# scripts/generate-llm-corpus.sh — генерация калибровочного корпуса реальных LLM-выводов.
#
# Зачем: калибровать пороги детекторов нужно на настоящем AI-стиле. Синтетический
# корпус tests/fixtures/ru-corpus/ai/ содержит одно слово «не» на 1523 слова и
# не содержит ни одной антитезы — по нему любой порог проходит (см.
# knowledge/02-Techniques/metric-validation.md, «смещение RU-AI корпуса»).
#
# Использование:
#   ./scripts/generate-llm-corpus.sh --lang ru --count 24
#   ./scripts/generate-llm-corpus.sh --lang en --count 12 --model minimax/MiniMax-M3.1-Flash
#
# Опции:
#   --lang ru|en        язык (по умолчанию ru)
#   --count N           сколько текстов сгенерировать (по умолчанию 24)
#   --model REF         модель provider/model (по умолчанию minimax/MiniMax-M3)
#   --model2 REF        вторая модель: половина текстов пишется ей, чтобы
#                       калибровка не зависела от одной семейства (по умолчанию
#                       minimax/MiniMax-M3.1-Flash)
#   --out DIR           каталог вывода (по умолчанию tests/fixtures/<lang>-corpus/ai)
#   --seed N            база для выбора промптов (по умолчанию 20261118)
#
# Промпты намеренно НЕ упоминают анти-паттерны: иначе корпус получится
# искусственно «чистым» и калибровка снова уедет.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LLM_CALL="${LLM_CALL:-$HOME/.minimax/.builtin-skills/llm-call/scripts/llm_call.py}"

LANG_CODE="ru"
COUNT=24
MODEL="minimax/MiniMax-M3"
MODEL2="minimax/MiniMax-M3.1-Flash"
OUT_DIR=""
SEED=20261118

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang)   LANG_CODE="$2"; shift 2 ;;
    --count)  COUNT="$2"; shift 2 ;;
    --model)  MODEL="$2"; shift 2 ;;
    --model2) MODEL2="$2"; shift 2 ;;
    --out)    OUT_DIR="$2"; shift 2 ;;
    --seed)   SEED="$2"; shift 2 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$LLM_CALL" ]]; then
  echo "error: llm_call.py not found at $LLM_CALL" >&2
  echo "       set LLM_CALL=/path/to/llm_call.py" >&2
  exit 2
fi

case "$LANG_CODE" in
  ru) OUT_DIR="${OUT_DIR:-$REPO_ROOT/tests/fixtures/ru-corpus/ai}" ;;
  en) OUT_DIR="${OUT_DIR:-$REPO_ROOT/tests/fixtures/en-corpus/ai}" ;;
  *)  echo "error: --lang must be ru or en" >&2; exit 2 ;;
esac

mkdir -p "$OUT_DIR"

# --- Конфиг для вызова -------------------------------------------------------
# llm_call.py читает провайдеров из секции `provider:`. В ~/.minimax/config.yaml
# секция `provider:` описывает шлюз Mavis (для него нужен сессионный токен, а
# не API-ключ), а рабочие ключи лежат в custom_provider: и в переменных
# окружения. Поэтому собираем временный конфиг: тот же формат, что ожидает
# llm_call.py, но с ключом из окружения.
TMPCFG="$(mktemp -t llm-corpus-XXXXXX.yaml)"
trap 'rm -f "$TMPCFG"' EXIT

API_KEY="${MINIMAX_API_KEY:-}"
BASE_URL="${MINIMAX_BASE_URL:-https://api.minimaxi.chat/anthropic/v1}"
if [[ -z "$API_KEY" ]]; then
  echo "error: MINIMAX_API_KEY is not set" >&2
  echo "       export MINIMAX_API_KEY=... (см. ~/.minimax/config.yaml)" >&2
  exit 2
fi

python3 - "$TMPCFG" "$API_KEY" "$BASE_URL" <<'PYEOF'
import sys
path, key, base = sys.argv[1], sys.argv[2], sys.argv[3]
cfg = {
    "provider": {
        "minimax": {
            "name": "MiniMax",
            "npm": "@ai-sdk/anthropic",
            "options": {"baseURL": base, "apiKey": key},
            "models": {
                "MiniMax-M3": {"name": "M3"},
                "MiniMax-M3.1-Flash": {"name": "M3.1-Flash"},
            },
        }
    }
}
try:
    import yaml
    with open(path, "w", encoding="utf-8") as fh:
        yaml.safe_dump(cfg, fh, allow_unicode=True)
except ImportError:
    # PyYAML нет — пишем минимальный YAML вручную (структура плоская).
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("provider:\n")
        fh.write("  minimax:\n")
        fh.write("    name: MiniMax\n")
        fh.write("    npm: '@ai-sdk/anthropic'\n")
        fh.write("    options:\n")
        fh.write(f"      baseURL: {base}\n")
        fh.write(f"      apiKey: {key}\n")
        fh.write("    models:\n")
        fh.write("      MiniMax-M3:\n        name: M3\n")
        fh.write("      MiniMax-M3.1-Flash:\n        name: M3.1-Flash\n")
PYEOF

if command -v uv >/dev/null 2>&1; then
  RUN_LLM=(uv run --with httpx --with pyyaml python3 "$LLM_CALL")
else
  RUN_LLM=(python3 "$LLM_CALL")
fi
LLM_ARGS=(--config "$TMPCFG")

# --- Промпты ----------------------------------------------------------------
# Обычные письменные задачи без подсказок про стиль: так корпус отражает то, что модель
# выдаёт «по умолчанию», а не то, чего от неё добились инструкцией.
read -r -d '' PROMPTS_RU <<'EOF'
Напиши связный текст на 180-250 слов о том, как устроена работа в распределённой команде разработчиков. Текст должен читаться как размышление практика, без списков и заголовков.
Опиши своими словами, что происходит в городе ранним утром, когда большинство людей ещё спит. 180-250 слов, обычная проза.
Расскажи, как человек принимает решение купить или не купить что-то дорогое. 180-250 слов, без заголовков и списков.
Напиши вводный текст для сервиса, который помогает людям находить книги по настроению. 180-250 слов, обычная проза, без маркетинговых восторгов.
Объясни, что такое медленная еда и почему вокруг неё столько разговоров. 180-250 слов, без заголовков.
Опиши один рабочий день человека, который занимается ремонтом старых книг. 180-250 слов, обычная проза.
Поговори о том, как город меняется за пять лет. 180-250 слов, без списков.
Расскажи, что человек узнаёт о себе, читая письма, написанные много лет назад. 180-250 слов.
Объясни, зачем проекту нужна документация, если код и так написан. 180-250 слов, спокойный тон.
Опиши поездку на электричке зимой. 180-250 слов, без заголовков, обычная проза.
Напиши о том, как изменилась работа программиста за последние двадцать лет. 180-250 слов.
Расскажи о бабушке, которая каждый год делает один и тот же пирог. 180-250 слов, обычная проза.
Объясни, как человек учится принимать решения, когда информации мало. 180-250 слов.
Опиши, что происходит в библиотеке вечером, когда читателей осталось немного. 180-250 слов.
Напиши о письме, которое долго не отправляли, а потом отправили. 180-250 слов.
Расскажи, зачем в проекте нужны тесты, если и так всё работает. 180-250 слов, без списков.
Опиши утро человека, который работает в ночную смену. 180-250 слов, обычная проза.
Поговори о том, почему людям нравится порядок в списке дел. 180-250 слов.
Опиши, как выглядит мастерская, где реставрируют старые фотоаппараты. 180-250 слов.
Напиши о том, как меняется язык, когда им пользуются разные поколения. 180-250 слов.
Расскажи о человеке, который ведёт переписку с незнакомым адресатом. 180-250 слов.
Объясни, что даёт проекту регулярный разбор ошибок. 180-250 слов, без заголовков.
Опиши вечер в редакции газеты перед сдачей номера. 180-250 слов, обычная проза.
Напиши о том, как человек понимает, что пора менять привычки. 180-250 слов.
EOF

read -r -d '' PROMPTS_EN <<'EOF'
Write a 180-250 word reflection on why people keep old letters and photographs. Plain prose, no headings, no lists.
Explain how a small software team decides what to build next. 180-250 words, plain prose.
Describe a city library late in the evening. 180-250 words, plain prose, no headings.
Write about what changes when a long-running project finally reaches its first release. 180-250 words, plain prose.
Explain why writing things down helps a person think. 180-250 words, plain prose.
Describe a long train journey in winter. 180-250 words, plain prose, no headings.
Talk about how people learn to make decisions with incomplete information. 180-250 words, plain prose.
Describe what it feels like to return to a place you left years ago. 180-250 words, plain prose.
Explain what a project log is good for. 180-250 words, plain prose.
Describe a reader who rereads the same book every few years. 180-250 words.
Write about how a hobby turns into a job without anyone planning it. 180-250 words.
Describe an old workshop where instruments are repaired. 180-250 words, plain prose.
EOF

if [[ "$LANG_CODE" == "ru" ]]; then
  PROMPTS="$PROMPTS_RU"
else
  PROMPTS="$PROMPTS_EN"
fi

mapfile -t PROMPT_LIST <<< "$PROMPTS"

echo "corpus dir : $OUT_DIR"
echo "texts      : $COUNT (model: $MODEL / $MODEL2)"
echo "prompts    : ${#PROMPT_LIST[@]} available, seed $SEED"
echo ""

made=0
failed=0
for ((i = 0; i < COUNT; i++)); do
  idx=$(( (i + SEED) % ${#PROMPT_LIST[@]} ))
  prompt="${PROMPT_LIST[$idx]}"
  if (( i % 2 == 1 )) && [[ -n "$MODEL2" && "$MODEL2" != "$MODEL" ]]; then
    use_model="$MODEL2"
  else
    use_model="$MODEL"
  fi
  slug="llm-${LANG_CODE}-$(printf '%02d' "$i")"
  out="$OUT_DIR/$slug.txt"
  tmp="$(mktemp)"

  echo "[$((i + 1))/$COUNT] $slug <- $use_model"
  if ! "${RUN_LLM[@]}" "${LLM_ARGS[@]}" --model "$use_model" --temperature 1.0 --max-tokens 8000 \
        --timeout 240 --json --prompt "$prompt" > "$tmp" 2>"$tmp.err"; then
    echo "    ! call failed: $(head -c 200 "$tmp.err")" >&2
    rm -f "$tmp" "$tmp.err"
    failed=$((failed + 1))
    continue
  fi

  body=$(python3 - "$tmp" <<'PYEOF'
import json, sys, re
try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        data = json.load(fh)
except Exception as exc:
    print("")
    sys.exit(1)
text = data.get("response") or ""
text = text.strip()
# Заголовки и markdown-списки — не проза; убираем, чтобы измерять текст.
text = re.sub(r"^#{1,6}\s+.*$", "", text, flags=re.M)
text = re.sub(r"^\s*[-*+]\s+", "", text, flags=re.M)
text = re.sub(r"\n{3,}", "\n\n", text)
print(text)
PYEOF
)
  rm -f "$tmp" "$tmp.err"

  words=$(printf '%s' "$body" | wc -w | tr -d ' ')
  if [[ "$words" -lt 60 ]]; then
    echo "    ! too short ($words words), skipped" >&2
    failed=$((failed + 1))
    continue
  fi

  {
    echo "---"
    echo "source: llm-generation"
    echo "provenance: real"
    echo "label: ai"
    echo "language: $LANG_CODE"
    echo "domain: generated"
    echo "model: ${use_model#*/}"
    echo "seed: $SEED"
    echo "---"
    echo ""
    printf '%s\n' "$body"
  } > "$out"
  made=$((made + 1))
  echo "    -> $out ($words words)"
done

echo ""
echo "generated: $made, skipped: $failed"
[[ "$made" -gt 0 ]] || exit 1

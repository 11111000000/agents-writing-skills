#!/usr/bin/env bash
# scripts/collect-ru-corpus.sh — готовит корпус реальных русских генераций LLM.
#
# Инструмент НЕ генерирует тексты и НЕ ходит в сеть: он только копирует,
# нормализует и размечает то, что уже сгенерировано (вручную, через API,
# из локального прогона модели и т. п.). Метаданные пишутся в frontmatter
# в том же формате, что и существующие фикстуры tests/fixtures/ru-corpus/ai/.
#
# Использование:
#   ./scripts/collect-ru-corpus.sh --model "GigaChat-Pro" --domain marketing \
#       --from ./raw-gigachat --sources ./raw-gigachat/sources.tsv
#   ./scripts/collect-ru-corpus.sh --model "YandexGPT" --domain tech-blog --from ./raw
#
# Формат списка источников (одна запись на строку; поля разделены табуляцией
# или |; строки с # — комментарии):
#   <путь-к-файлу>[|<model>[|<domain>[|<source>]]]
# Поля model/domain/source в строке переопределяют значения из --model/--domain/--source.
#
# Результат: нормализованные тексты с frontmatter в --out, сводка
# «принято / пропущено / отклонено» и exit 1, если принято 0 файлов.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/tests/fixtures/ru-corpus/ai"
FROM_DIR=""
MODEL=""
DOMAIN=""
SOURCE="llm-generation"
MIN_WORDS=500
COLLECTED_AT="$(date -u +%Y-%m-%d)"
SOURCES_FILE=""

usage() {
  cat <<EOF
Usage: $0 --model NAME --domain NAME --from DIR [options] [sources-list.txt]

Подготовка корпуса реальных RU-генераций LLM: нормализация и разметка
файлов из --from в --out. Сеть не используется, тексты не генерируются.

Options:
  --model NAME     модель по умолчанию для frontmatter (model:)
  --domain NAME    домен по умолчанию для frontmatter (domain:)
  --from DIR       каталог с исходными генерациями LLM (txt/md)
  --out DIR        каталог назначения (по умолчанию tests/fixtures/ru-corpus/ai)
  --sources FILE   список источников (по умолчанию — все txt/md из --from)
  --source NAME    значение frontmatter source: (по умолчанию llm-generation)
  --min-words N    минимальная длина тела текста в словах (по умолчанию 500)
  --date DATE      дата сбора для fetched_at: (по умолчанию сегодня, UTC)
  -h, --help       эта справка

Список источников: <путь-к-файлу>[|<model>[|<domain>[|<source>]]]
Пример строки: raw/giga-001.txt|GigaChat-Pro|marketing|gigachat-api

Возвращает:
  exit 0 — принят хотя бы один файл
  exit 1 — принято 0 файлов (см. причины отклонения)
  exit 2 — ошибка использования
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)     MODEL="${2:-}"; shift 2 ;;
    --model=*)   MODEL="${1#*=}"; shift ;;
    --domain)    DOMAIN="${2:-}"; shift 2 ;;
    --domain=*)  DOMAIN="${1#*=}"; shift ;;
    --from)      FROM_DIR="${2:-}"; shift 2 ;;
    --from=*)    FROM_DIR="${1#*=}"; shift ;;
    --out)       OUT_DIR="${2:-}"; shift 2 ;;
    --out=*)     OUT_DIR="${1#*=}"; shift ;;
    --sources)   SOURCES_FILE="${2:-}"; shift 2 ;;
    --sources=*) SOURCES_FILE="${1#*=}"; shift ;;
    --source)    SOURCE="${2:-}"; shift 2 ;;
    --source=*)  SOURCE="${1#*=}"; shift ;;
    --min-words) MIN_WORDS="${2:-}"; shift 2 ;;
    --min-words=*) MIN_WORDS="${1#*=}"; shift ;;
    --date)      COLLECTED_AT="${2:-}"; shift 2 ;;
    --date=*)    COLLECTED_AT="${1#*=}"; shift ;;
    -h|--help)   usage; exit 0 ;;
    --)          shift; break ;;
    -*)          echo "Неизвестный флаг: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -n "$SOURCES_FILE" ]]; then
        echo "Список источников задан дважды: $SOURCES_FILE и $1" >&2
        exit 2
      fi
      SOURCES_FILE="$1"; shift ;;
  esac
done

if [[ -z "$FROM_DIR" ]]; then
  echo "Ошибка: не указан --from (каталог с исходными генерациями)." >&2
  usage >&2
  exit 2
fi
if [[ ! -d "$FROM_DIR" ]]; then
  echo "Ошибка: каталог --from не найден: $FROM_DIR" >&2
  exit 2
fi
if [[ -n "$SOURCES_FILE" && ( ! -e "$SOURCES_FILE" || ! -r "$SOURCES_FILE" ) ]]; then
  echo "Ошибка: файл списка источников не найден или не читается: $SOURCES_FILE" >&2
  exit 2
fi
if [[ -z "$MODEL" && -z "$DOMAIN" && -z "$SOURCES_FILE" ]]; then
  echo "Ошибка: нужны --model и/или --domain либо --sources со списком источников." >&2
  usage >&2
  exit 2
fi
if ! [[ "$MIN_WORDS" =~ ^[0-9]+$ ]]; then
  echo "Ошибка: --min-words должен быть целым числом: $MIN_WORDS" >&2
  exit 2
fi

mkdir -p "$OUT_DIR"

# --- Разбор, нормализация и запись. Frontmatter разбирается в python3. ---
python3 - \
  "$FROM_DIR" "$OUT_DIR" "$MODEL" "$DOMAIN" "$SOURCE" "$MIN_WORDS" \
  "$COLLECTED_AT" "$SOURCES_FILE" <<'PYEOF'
import os
import re
import sys

FROM_DIR, OUT_DIR, MODEL, DOMAIN, SOURCE, MIN_WORDS, DATE, SOURCES_FILE = sys.argv[1:9]
MIN_WORDS = int(MIN_WORDS)

FM_RE = re.compile(r"\A---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\Z)", re.S)
KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_.-]*)\s*:\s*(.*)$")
CYR_MIN_RATIO = 0.3
RESERVED = {"source", "label", "language", "domain", "model", "fetched_at", "words"}


def die(code, message):
    print(message, file=sys.stderr)
    sys.exit(code)


def parse_frontmatter(text):
    """Возвращает (словарь метаданных, тело текста). Мини-YAML: key: value."""
    m = FM_RE.match(text)
    if not m:
        return {}, text
    meta = {}
    for line in m.group(1).split("\n"):
        km = KEY_RE.match(line.strip())
        if not km:
            continue
        key, value = km.group(1), km.group(2).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        meta[key] = value
    return meta, text[m.end():]


def normalize_body(text):
    """Единый перевод строк, без BOM, без хвостовых пробелов, один пустой ряд."""
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    out = []
    blanks = 0
    for line in text.split("\n"):
        line = line.rstrip()
        if line == "":
            blanks += 1
            if blanks > 1:
                continue
        else:
            blanks = 0
        out.append(line)
    body = "\n".join(out).strip("\n")
    return body + "\n" if body else ""


def word_count(text):
    return len(text.split())


def cyrillic_ratio(text):
    letters = [c for c in text if c.isalpha()]
    if not letters:
        return 0.0
    cyr = sum(1 for c in letters if "Ѐ" <= c <= "ӿ")
    return cyr / len(letters)


def slugify(text, maxlen=48):
    text = text.lower().replace("ё", "е")
    text = re.sub(r"[^a-zа-я0-9]+", "-", text)
    text = text.strip("-")
    if len(text) > maxlen:
        text = text[:maxlen].rstrip("-")
    return text or "sample"


def yaml_value(value):
    s = str(value)
    if s == "" or s != s.strip() or s[0] in "-?" or any(c in s for c in ":#[]{}&*!|>'\"%@`,"):
        return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return s


def collect_entries():
    """Записи из файла-списка; без списка — все txt/md из --from."""
    entries = []
    if SOURCES_FILE:
        base = os.path.dirname(os.path.abspath(SOURCES_FILE))
        with open(SOURCES_FILE, encoding="utf-8-sig") as fh:
            for lineno, raw in enumerate(fh, 1):
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue
                fields = re.split(r"\t+|\|", line)
                path = fields[0].strip()
                model = fields[1].strip() if len(fields) > 1 and fields[1].strip() else MODEL
                domain = fields[2].strip() if len(fields) > 2 and fields[2].strip() else DOMAIN
                source = fields[3].strip() if len(fields) > 3 and fields[3].strip() else SOURCE
                if not path:
                    continue
                entries.append({"path": path, "model": model, "domain": domain,
                                "source": source, "base": base, "line": lineno})
        return entries

    for name in sorted(os.listdir(FROM_DIR)):
        if name.lower().endswith((".txt", ".md")):
            entries.append({"path": name, "model": MODEL, "domain": DOMAIN,
                            "source": SOURCE, "base": os.path.abspath(FROM_DIR), "line": 0})
    return entries


def resolve_path(entry):
    path = entry["path"]
    if os.path.isabs(path):
        return path if os.path.isfile(path) else None
    candidates = [
        os.path.join(FROM_DIR, path),
        os.path.join(entry["base"], path),
        os.path.join(os.path.abspath(FROM_DIR), path),
    ]
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate
    return None


accepted = 0
skipped = 0
rejected = 0
written = []

print("=== collect-ru-corpus ===")
print(f"Источник:       {os.path.abspath(FROM_DIR)}")
print(f"Назначение:     {os.path.abspath(OUT_DIR)}")
print(f"Модель (default): {MODEL or '—'}")
print(f"Домен (default):  {DOMAIN or '—'}")
print(f"Мин. длина:      {MIN_WORDS} слов")
print(f"Дата сбора:      {DATE}")
print(f"Список источников: {SOURCES_FILE or '— (все txt/md из --from)'}")
print("")

entries = collect_entries()
if not entries:
    die(1, "Список источников пуст: нет файлов для обработки.")

seen_bodies = {}

for entry in entries:
    label = entry["path"]
    src = resolve_path(entry)
    if src is None:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — файл не найден")
        continue

    try:
        with open(src, "rb") as fh:
            raw = fh.read()
    except OSError as exc:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — не удалось прочитать ({exc.strerror or exc})")
        continue

    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — невалидный UTF-8")
        continue

    # Переводы строк — до разбора frontmatter: у CRLF-файлов маркер '---'
    # иначе не распознаётся, и метаданные уезжают в тело текста.
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    meta, body = parse_frontmatter(text)
    body = normalize_body(body)
    if not body.strip():
        rejected += 1
        print(f"[ОТКЛОН.] {label} — пустой текст")
        continue

    words = word_count(body)
    if words < MIN_WORDS:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — {words} слов < {MIN_WORDS}")
        continue

    ratio = cyrillic_ratio(body)
    if ratio < CYR_MIN_RATIO:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — не русский текст (кириллица {ratio * 100:.0f}%)")
        continue

    model = entry["model"] or meta.get("model", "")
    domain = entry["domain"] or meta.get("domain", "")
    source = entry["source"] or SOURCE
    if not model:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — не указан model (задайте --model или поле в списке)")
        continue
    if not domain:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — не указан domain (задайте --domain или поле в списке)")
        continue

    key = body.strip()
    if key in seen_bodies:
        rejected += 1
        print(f"[ОТКЛОН.] {label} — дубликат текста (уже принят как {seen_bodies[key]})")
        continue
    seen_bodies[key] = label

    stem = os.path.splitext(os.path.basename(src))[0]
    out_name = "ai-{}-{}-{}.txt".format(
        slugify(domain), slugify(model), slugify(stem)
    )
    out_path = os.path.join(OUT_DIR, out_name)

    extra = {k: v for k, v in meta.items() if k not in RESERVED and v}

    lines = [
        "---",
        "source: {}".format(yaml_value(source)),
        "label: ai",
        "language: ru",
        "domain: {}".format(yaml_value(domain)),
        "model: {}".format(yaml_value(model)),
        "fetched_at: {}".format(yaml_value(DATE)),
        "words: {}".format(words),
    ]
    for key_name in sorted(extra):
        lines.append("{}: {}".format(key_name, yaml_value(extra[key_name])))
    lines.append("---")
    content = "\n".join(lines) + "\n\n" + body

    try:
        with open(out_path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(content)
    except OSError as exc:
        die(2, "Не удалось записать {}: {}".format(out_path, exc))

    accepted += 1
    written.append(out_name)
    print("[ПРИНЯТ.] {} -> {} ({} слов)".format(label, out_name, words))

print("")
print("Сводка: принято {}, отклонено {}".format(accepted, rejected))
if accepted == 0:
    print("Результат: принято 0 файлов — корпус не обновлён.", file=sys.stderr)
    sys.exit(1)
print("Результат: {} файл(ов) в {}".format(accepted, os.path.abspath(OUT_DIR)))
PYEOF

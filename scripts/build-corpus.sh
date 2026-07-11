#!/usr/bin/env bash
# scripts/build-corpus.sh — собирает RU-корпус из публично доступных источников.
# Sources:
#   - stdin-вход: список URL (по одному на строку)
#   - либо флаг --list для печати рекомендованного списка
# Результат: тексты идут в tests/fixtures/corpus/<slug>.txt с фронт-метаданными.
# Эвристики длины и YapScore даёт benchmark-skill.sh.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/tests/fixtures/corpus"
LIST_FLAG=false

usage() {
  cat <<EOF
Usage: $0 [--list] [< urls.txt]

Options:
  --list   напечатать рекомендованный список публичных RU-источников
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_FLAG=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

RECOMMENDED=(
  "https://www.gutenberg.org/cache/epub/730/pg730.txt|Проверка_Ольги|Первая_русская_публичная_прозовая_выборка_редактора"
  "https://az.lib.ru/text.php?book=100005|Тургенев_Записки_охотника|Классическая_публичная_прозовая_выборка"
  "https://ru.wikisource.org/wiki/Медный_всадник_(Пушкин)|Пушкин_Медный_всадник|Ставшее_русским_стихотворение_компактной_лаконичной_формы"
)

if [[ "$LIST_FLAG" == "true" ]]; then
  for entry in "${RECOMMENDED[@]}"; do
    url="${entry%%|*}"
    rest="${entry#*|}"
    label="${rest%%|*}"
    note="${rest#*|}"
    printf '%s\t%s\t%s\n' "$url" "$label" "$note"
  done
  exit 0
fi

mkdir -p "$OUT_DIR"

if [[ $# -eq 0 ]]; then
  INPUT=$(cat)
else
  INPUT="$1"
fi

count=0
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  url="${line%%	*}"
  slug=$(printf '%s' "$url" | sed -E 's|^https?://||; s|/|_|g; s|[^A-Za-z0-9._-]|_|g' | cut -c1-80)
  out="$OUT_DIR/$slug.txt"
  if curl --max-time 30 -fsSL "$url" -o "$out.raw" 2>/dev/null; then
    printf '%s\n' "url: $url" > "$out"
    printf '%s\n' "fetched_at: $(date -u +%Y-%m-%d)" >> "$out"
    printf '%s\n\n' "license: PUBLIC-DOMAIN" >> "$out"
    cat "$out.raw" | head -c 4000 >> "$out"
    rm "$out.raw"
    count=$((count + 1))
    printf 'fetched: %s\n' "$url"
  else
    printf 'failed: %s\n' "$url" >&2
  fi
done <<<"$INPUT"

printf '\nГотово: %d файл(ов) в %s\n' "$count" "$OUT_DIR"

---
title: Contributing
description: Как добавлять новые скилы, промпты и заметки в базу знаний agents-writing-skills.
---

[← На главную](index)

# 🤝 Contributing

> Добавьте скил. Добавьте промпт. Добавьте заметку в базу. Поправьте опечатку. Откройте PR.

<br>

## Полезные ссылки

- 📋 [GitHub-репозиторий](https://github.com/11111000000/agents-writing-skills)
- 🐛 [Трекер задач](https://github.com/11111000000/agents-writing-skills/issues)
- 💬 [Discussions](https://github.com/11111000000/agents-writing-skills/discussions)
- 📝 [Лицензия (скилы + промпты)](LICENSE) · [CC-BY-SA-4.0 (база знаний)](knowledge)

<br>

## 🚀 Как внести вклад

### 1. Добавить новый скил (средняя сложность)

Скилы — это файлы `skills/<name>/SKILL.md` с YAML frontmatter.

**Начните с шаблона:**
```bash
cp -r skills/template-skill/ skills/my-new-skill/
```

**Обязательный frontmatter:**

```yaml
---
name: my-new-skill
description: Одна строка (макс. 1024 символа). Когда агент должен грузить этот скил?
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: <имя-вашего-workflow>
  version: 1
---
```

**Чек-лист по содержимому:**
- [ ] Использование 12 рычагов (если применимо)
- [ ] 3-pass workflow (если применимо)
- [ ] Раздел «Когда НЕ грузить»
- [ ] Ссылки на компаньон-скилы
- [ ] Примеры в code blocks (не буллет-списки)
- [ ] Деревья решений (где выбор неоднозначен)
- [ ] Таблица мультиязычной поддержки (если применимо)

**Зарегистрировать в [`manifest.json`](https://github.com/11111000000/agents-writing-skills/blob/main/manifest.json):**

```json
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "path": "skills/my-new-skill/SKILL.md",
  "description": Одна строка,
  "use_when": Триггер-фразы для скила,
  "companion_skills": ["other-skill"],
  "references": []
}
```

Локальная валидация:
```bash
bash scripts/validate-skills.sh    # проверяет все SKILL.md
bash scripts/validate-manifest.sh  # проверяет пути в manifest.json
```

### 2. Добавить новый промпт (малая сложность)

Промпты лежат в [`prompts/`](https://github.com/11111000000/agents-writing-skills/tree/main/prompts) для pi-агентов.

**Имя файла:** `prompts/<действие>-<цель>.md`

Примеры: `humanize.md`, `audit-ai.md`, `clean-draft.md`.

**Frontmatter:**
```yaml
---
name: my-prompt
description: Одна строка
target_agents: [pi]
---
```

Зарегистрировать в `manifest.json` под массивом `prompts`.

### 3. Добавить заметку в базу знаний (малая сложность)

Заметки лежат в [`knowledge/`](https://github.com/11111000000/agents-writing-skills/tree/main/knowledge).

**Имя файла:** `knowledge/<категория>/<имя>.md`, где категории:
- `01-patterns/` — каталог AI-паттернов
- `02-techniques/` — методы гуманизации
- `03-detection/` — работа детекторов
- `04-examples/` — кейсы до/после
- `05-references/` — метазаметки (ограничения, этика)
- `06-sources/` — сырые исследовательские заметки

**Frontmatter:**
```yaml
---
type: technique  # или pattern | reference | source | detection | example
tags: [technique, foundational, lever-N]
created: YYYY-MM-DD
status: draft | active
related: [other-note]
---

# Title

> Quote (TL;DR)

## Theory (with citations)
## Implementation (concrete steps)
## Examples (with measured metrics)
## Edge cases (where NOT to apply)

[← Back to home](..)
```

### 4. Добавить заметку-источник (исследовательское обоснование)

Перед добавлением паттерна или техники — обоснуйте через первоисточник.

**Шаблон:** `06-Sources/<web-fetches|research-papers>/<тема>/<имя-источника>.md`

Шаблон (`templates/source-note.md`):
```yaml
---
type: source
fetched_at: YYYY-MM-DD
url: <url>
author: <author>
year: <year>
source_type: arxiv | web | book | corpus
applicability: high | medium | low
tags: [source, <тема>]
status: draft
---

# Source title

## TL;DR / Abstract
## Key quotes
## Concrete examples (what we can extract)
## Connection to our work ([wikilinks])
## Open questions
## Raw notes (PDF link etc.)
```

### 5. Улучшить существующий контент

Мелкие изменения приветствуются:
- Исправить опечатки / битые вики-ссылки
- Добавить недостающий пример в `04-Examples/`
- Добавить метрику в `02-Techniques/`
- Перевести заметку между EN и RU

<br>

## 📝 Style guide

### Голос

- **Прямо.** Никаких «можно сказать, что…», никакого hedging, никаких извинений.
- **Конкретно.** Числа > прилагательных. Всегда.
- **Формально по-русски, где уместно.** Мы переводим концепции, но русский формальный регистр (деепричастия, парные синонимы) **легитимен в формальных документах**.
- **Никаких AI-маркеров.** Если в черновике плотность em-dash > 1/300 слов или rule-of-three — **перепишите перед PR**.

### Code blocks

**Всегда** используйте code blocks для примеров, не буллет-списки. Сравните:

```diff
# Неправильно:
- Replace "delve" with "look at"
- Replace "leverage" with "use"

# Правильно:
```diff
- We must delve into the architecture
+ We must look at the architecture
```
```

### Wikilinks

Используйте `[[wikilinks]]` (стандарт Obsidian) для кросс-ссылок. Quartz рендерит их как ссылки.

```markdown
См. [[sufficiency-and-underspecification]] для полного механизма.
```

### Двуязычный контент

Мы держим две версии основных документов:
- `docs/getting-started.md` (EN)
- `docs/ru/getting-started.md` (RU) — добавляйте русский перевод отдельным файлом

Для заметок в базе оба языка могут сосуществовать в одном файле, разделенные через H2-заголовки.

<br>

## 🚦 Pull request workflow

1. **Ветка от main**: `git checkout -b feat/my-skill`
2. **Сделайте изменения** по style guide выше
3. **Валидация локально**:
   ```bash
   bash scripts/validate-skills.sh
   bash scripts/test-benchmark.sh
   bash scripts/build-site.sh ./preview  # опционально
   ```
4. **Обновите CHANGELOG.md** с описанием изменений
5. **Поднимите версии** в `manifest.json` (patch для багфикса, minor для нового скила, major для ломающего изменения)
6. **Commit с conventional-commits message:**
   ```bash
   git commit -m "feat(skill): add my-new-skill

   - Pass 1 (Audit): list AI patterns
   - Pass 2 (Rewrite): apply 12 levers
   - Pass 3 (Verify): bias substitution check

   Tested on 5 sample texts.
   "
   ```
7. **Push и откройте PR**: `gh pr create`
8. **CI запускает**: validate-skills.sh, validate-manifest.sh, benchmark smoke tests. PR должен пройти все три.

<br>

## 📋 Phase plan (roadmap)

| Phase | Цель | Статус |
|---|---|---|
| v1 | 4 скила, 43 паттерна, 9 базовых рычагов | Сделано |
| v2 | Sufficiency + Iceberg + интеграция YapBench | Сделано |
| v3 | Русская грамматика краткости (Lever 12) | Сделано |
| v4 | 3-pass архитектура + 13 разобранных примеров + benchmark-скрипт | Сделано |
| v5 | Laconic prose models (Толстой, Довлатов, Шкловский, Бунин) + benchmark smoke tests | Сделано |
| v6 | Version sync + RU fixtures + threshold benchmark checks | Текущая |
| **v7 (следующая)** | **A/B human evaluation** + **long-form benchmarks** | В плане |
| v8 | Кросс-языковая поддержка (JA, ZH, FR) | Бэклог |

<br>

## 🐛 Баг-репорты

Открывайте issue с:
- Имя скила + версия
- Сниппет входа (анонимизированный)
- Ожидаемый vs фактический выход
- Вывод `benchmark-skill.sh` если применимо

```bash
bash scripts/benchmark-skill.sh my-text.txt > bug-report.txt
# Прикрепите bug-report.txt к issue
```

<br>

## 💬 Discussions

Для:
- Идея до PR
- Вопрос про применимость
- Поделиться эмпирическими результатами
- Сравнение с альтернативными подходами

Откройте [discussion](https://github.com/11111000000/agents-writing-skills/discussions).

<br>

---

[← На главную](index)

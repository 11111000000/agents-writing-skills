---
title: База знаний
description: 41+ заметок в формате Obsidian, документирующих паттерны, техники, источники, примеры, ссылки. Теоретический фундамент под каждым скилом.
---

[← На главную](index)

# 📚 База знаний

> 41+ заметок, на которых стоят все рекомендации в 4 скилах. Откройте в [Obsidian](https://obsidian.md/) для полного граф-вью, либо читайте здесь.

<br>

## 🗺 Карта

```
knowledge/
├── 01-Patterns/             # 43 категории AI-паттернов + RU-расширения
├── 02-Techniques/           # 12 рычагов, голос, грамматика краткости
├── 03-Detection/            # Как работают детекторы
├── 04-Examples/             # Разобранные до/после кейсы
├── 05-References/           # Ограничения, самокритика
└── 06-Sources/              # Сырые исследовательские статьи + веб-фетчи
```

<br>

## 1️⃣ Patterns (`01-Patterns/`) — как выглядит AI-текст

| Заметка | Что внутри |
|---|---|
| [43-patterns-catalogue](01-patterns/43-patterns-catalogue) | Все 43 паттерна с примерами и детекцией (из Aboudjem/humanizer-skill) |
| [P9 Negative Parallelisms](01-patterns/rhetorical/negative-parallelisms) | **Маркер №1** по Washington Post 2024 — «это не X, а Y» |
| [lexicon-ru-v2](01-patterns/lexical/lexicon-ru-v2) | Русские AI-клише: «более того», «стоит отметить» |
| [lexicon-en](01-patterns/lexical/lexicon-en) | Английские AI-клише: `delve`, `leverage`, `robust` |
| [deeprichastnye-oboroty](01-patterns/rhetorical/deeprichastnye-oboroty) | Перебор деепричастий (-а/-в) в русском |
| [parallel-clauses](01-patterns/structural/parallel-clauses) | «цели и задачи», «методы и средства» |
| [em-dash](01-patterns/structural/em-dash) | Перебор em-dash (в 3–5× выше человеческой нормы) |
| [over-generation](01-patterns/structural/over-generation) | P-NEW-1…7 — vacuum-filling, restatement chains, bridging и т. п. |

<br>

## 2️⃣ Techniques (`02-Techniques/`) — что делать вместо этого

| Заметка | Что внутри |
|---|---|
| [perplexity-and-burstiness](02-techniques/perplexity-and-burstiness) | Базовые метрики (основа детекции) |
| [voice-and-tone](02-techniques/voice-and-tone) | Как найти авторский голос |
| [voice-russian-specifics](02-techniques/voice-russian-specifics) | Я / мы / безличное в русском |
| [show-dont-tell](02-techniques/show-dont-tell) | Конкретика против абстракции (самый частый баг LLM-текста) |
| [sufficiency-and-underspecification](02-techniques/sufficiency-and-underspecification) | Рычаги 10 + 11: Grice submaxim 2 + Hemingway iceberg |
| [length-bias-research](02-techniques/length-bias-research) | Академический фундамент: 5 статей с arXiv про length bias в RLHF |
| [russian-brevity-grammar](02-techniques/russian-brevity-grammar) | Глубокое погружение в Рычаг 12: парцелляция, эллипсис, литота |
| [laconic-prose-models](02-techniques/laconic-prose-models) | Толстой, Довлатов, Шкловский, Бунин — принципы для извлечения |
| [agent-writing-workflow](02-techniques/agent-writing-workflow) | Pre-flight → Write → Audit алгоритм |

<br>

## 3️⃣ Detection (`03-Detection/`) — что измеримо

| Заметка | Что |
|---|---|
| [how-detectors-work](03-detection/how-detectors-work) | Binoculars (ICML 2024), Watermarking, DetectGPT, Pangram, GPTZero, ZeroGPT |
| [public-detectors](03-detection/public-detectors) | Сравнение доступных инструментов |
| [russian-detectors](03-detection/russian-detectors) | RU-специфика: GigaCheck, Antiplagiat и др. |

<br>

## 4️⃣ Examples (`04-Examples/`) — измеренные до/после

Это **разобранные кейсы с замерами**. На каждом можно прогнать `benchmark-skill.sh` и проверить.

### `04-Examples/tightening/`
5 примеров Рычага 10 (TIGHTEN):

| № | Домен | Слов до → после | % сокращения |
|---|---|---|---|
| 1 | README | 56 → 18 | −68% |
| 2 | Email | 48 → 17 | −65% |
| 3 | Блог-пост | 84 → 19 | −77% |
| 4 | Маркетинг | 67 → 27 | −60% |
| 5 | Status update | 71 → 16 | −77% |
| **Средн.** | | **65 → 19** | **−69%** |

[Читать все 5 →](04-examples/tightening)

### `04-Examples/iceberg/`
3 примера Рычага 11 (RELY / iceberg):

- Архитектурное решение (PostgreSQL)
- Отчёт о баге
- Code review feedback

[Читать все 3 →](04-examples/iceberg)

### `04-Examples/russian-grammar/`
5+1 примеров Рычага 12 (REBUILD):

| № | Приём | Источник |
|---|---|---|
| 1 | Парцелляция | Демо |
| 2 | Эллипсис | Демо |
| 3 | Литота | Демо |
| 4 | Нулевая связка | Демо |
| 5 | Комбинация всех 4 | Демо |
| 6 | **Шкловский + Толстой** | Kholstomer example |

[Читать все 6 →](04-examples/russian-grammar)

<br>

## 5️⃣ References (`05-References/`) — ограничения и этика

| Заметка | Что |
|---|---|
| [limits-and-self-critique](05-references/limits-and-self-critique) | Эпистемологический анализ: что мы знаем, чего не знаем, что MASH/ACL 2026 значит для потолка скилов |

<br>

## 6️⃣ Sources (`06-Sources/`) — сырые исследования

Реальные статьи и веб-страницы, которые мы взяли как доказательную базу:

### Исследовательские статьи (arXiv)

- `06-Sources/research-papers/length-bias/`
  - [park-2024-disentangling-length-dpo](06-sources/research-papers/length-bias/park-2024-disentangling-length-dpo) — DPO эксплуатирует length bias
  - [shen-2023-loose-lips](06-sources/research-papers/length-bias/shen-2023-loose-lips) — RM предполагает, что люди предпочитают длиннее (EMNLP 2023)
  - [zhang-2024-format-bias](06-sources/research-papers/length-bias/zhang-2024-format-bias) — Format bias (списки, bold, эмодзи)
  - [huang-2024-post-hoc-calibration](06-sources/research-papers/length-bias/huang-2024-post-hoc-calibration) — ICLR 2025; калибровка без дообучения
  - [lamparth-2026-bias-substitution](06-sources/research-papers/length-bias/lamparth-2026-bias-substitution) — **Критически важно** (Stanford 2026): одностороннее смягчение → bias substitution

### Датасеты (для эмпирической валидации)

- `06-Sources/research-papers/detection-datasets/`
  - [hc3-english](06-sources/research-papers/detection-datasets/hc3-english) — 24.3k пар AI-vs-human
  - [hc3-russian-translated](06-sources/research-papers/detection-datasets/hc3-russian-translated) — переведённая версия
  - [raid-multi-domain](06-sources/research-papers/detection-datasets/raid-multi-domain) — мультимодельный бенчмарк на 8.09M

### Веб-фетчи (RU-грамматика и литературная теория)

- `06-Sources/web-fetches/russian-grammar/`
  - [parcelyaciya-wikipedia](06-sources/web-fetches/russian-grammar/parcelyaciya-wikipedia) — статья русской Википедии про парцелляцию
  - [ellipsis-wikipedia](06-sources/web-fetches/russian-grammar/ellipsis-wikipedia) — 8 типов эллипсиса
  - [litota-wikipedia](06-sources/web-fetches/russian-grammar/litota-wikipedia) — Литота с литературными примерами

- `06-Sources/web-fetches/laconic-prose/`
  - [shklovsky-wikipedia](06-sources/web-fetches/laconic-prose/shklovsky-wikipedia) — Шкловский, «Искусство как приём» 1917, остранение, анализ Толстого

<br>

## 🔍 Как ориентироваться

| Хочу… | Смотреть |
|---|---|
| Найти все AI-клише | `01-Patterns/lexical/lexicon-en` |
| Убрать русский «канцелярит» | `01-Patterns/structural/parallel-clauses` |
| Применить iceberg к техдоку | `02-Techniques/sufficiency-and-underspecification` → `04-Examples/iceberg/` |
| Русская парцелляция | `02-Techniques/russian-brevity-grammar` → `04-Examples/russian-grammar/` |
| Почему LLM перебирает | `02-Techniques/length-bias-research` |
| Перенять Шкловского / Толстого | `02-Techniques/laconic-prose-models` → `04-Examples/russian-grammar/06-shklovsky-tolstoy-kholstomer` |
| Замерить свой текст | `scripts/benchmark-skill.sh` |

<br>

---

[← На главную](index) · [Далее: Ограничения →](limitations)

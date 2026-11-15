---
title: База знаний
description: "41 заметка в формате Obsidian: паттерны, техники, примеры, референсы и источники. Теоретический фундамент под каждым из 4 скилов v7."
---

[← На главную](index)

# 📚 База знаний

> **41 заметка**, на которых стоят все рекомендации в 4 скилах v7. Откройте в [Obsidian](https://obsidian.md/) для полного граф-вью, либо читайте здесь.

Хранилище отвечает на пять вопросов, и у каждого свой раздел:

- **Как выглядит AI-текст?** → `01-Patterns/` (15 заметок)
- **Что делать вместо этого, не меняя того, что говорит текст?** → `02-Techniques/` (15 заметок)
- **Что вообще можно измерить?** → `03-Detection/` (3 заметки)
- **Как выглядит правка на практике?** → `04-Examples/` (6 заметок)
- **Чего мы до сих пор не знаем?** → `05-References/` (1 заметка)

<br>

## 🗺 Карта

```
knowledge/
├── 01-Patterns/             # 15 заметок: 43 категории AI-паттернов + P-NEW + RU-расширения
├── 02-Techniques/           # 15 заметок: смысловой контракт, режимы правки, голос, грамматика краткости
├── 03-Detection/            # 3 заметки: как работают детекторы
├── 04-Examples/             # 6 заметок: разобранные до/после кейсы
├── 05-References/           # 1 заметка: ограничения, самокритика
├── 06-Sources/              # сырые исследовательские статьи + веб-фетчи
└── README.md                # MOC: карта карты
```

Итого **41 заметка** (без сырого материала `06-Sources/` и `templates/`). За ними стоят **4 скила версии v7.0.0** и **9 шаблонов промптов**.

<br>

## 🆕 Что изменилось в v7

В v7 изменилась цель, а не список маркеров: **сохранить смысл при редактуре**. Четыре скила сохраняют свою трёхпроходную архитектуру; изменился контракт под ними.

| Область | v6 | v7 |
|---|---|---|
| Контракт | допускалась потеря части фактов в пределах процента | **По умолчанию потеря утверждений нулевая.** Сохраняются утверждения, числа и их отношения, условия, исключения, отрицания, модальность, терминология, цитаты и регистр. Выдуманный факт — это FAIL, а не штраф |
| Недостающие данные | пробел заполнялся правдоподобием | Недостающие данные → **`[нужен факт: ...]`**. Правдоподобное число всё равно выдуманное число |
| Глубина правки | один запрос «сделай по-человечески» | **4 режима**: `proofread` / `light` / `style` / `deep`. Каждый режим открывает свой набор фаз (STRIP / TIGHTEN / RELY / REBUILD) |
| RELY (iceberg) | доступен всегда | **Только `style`/`deep`** и только для художественного или разговорного регистра. Не для договоров, статей и инструкций |
| Хороший текст | всегда есть, что улучшить | Хороший текст можно **вернуть почти без изменений**, и сказать об этом допустимый результат |
| Метрики | читались как вердикт («это AI») | **Диагностика**: они указывают на место, куда стоит посмотреть, но не решают «AI / не AI» |
| Доказательства | каталог маркеров | **Поведенческий корпус** + валидаторы + формальный слой доказательств |

**Что добавлено, чтобы это можно было проверять:**

- **Поведенческий корпус** `tests/fixtures/editing/`: 24 кейса (README, формальное письмо, научный текст с оговорками, туториал, техническая инструкция, художественный текст, экспертный пост, плюс 3 кейса «уже хорошего текста») с намеренными ловушками вокруг модальности, условий и выдуманных фактов. Проверяется скриптом `scripts/test-editing-fixtures.sh`.
- **Валидаторы**: `scripts/check-editing-output.sh` проверяет 9 инвариантов смыслового контракта (числа, утверждения, условия, исключения, терминология, неопределённость, отсутствие выдуманных чисел, отсутствие запрещённых добавлений, «хороший текст не переписан зря») и имеет `--selftest`, доказывающий, что нарушения ловятся. Также `scripts/check-examples-facts.sh`, `scripts/check-examples-coverage.sh`, `scripts/check-no-stale-contract.sh`.
- **Слой доказательств**: `spec.json` + `mathc run`: 12 claims с negative controls, каждый привязан к команде-верификатору.
- **Валидация метрик на 145 размеченных текстах**: пороги стали языково-зависимыми и выведены из данных. Подробности: [metric-validation](02-techniques/metric-validation).
- **Протокол слепой человеческой оценки**: написан, **ещё не проводился**. См. [Слепая человеческая оценка](blind-evaluation) (страница протокола на английском).

<br>

## 1️⃣ Patterns (`01-Patterns/`): как выглядит AI-текст

15 заметок. Каталог поверхностных маркеров, его RU-расширения и два структурных семейства, добавленные после исходных 43.

| Заметка | Что внутри |
|---|---|
| [43-patterns-catalogue](01-patterns/43-patterns-catalogue) | Все 43 паттерна с примерами и детекцией (из Aboudjem/humanizer-skill) |
| [catalogue-update](01-patterns/catalogue-update) | P-NEW-13…P-NEW-20: 8 паттернов, отсутствующих в исходных 43: false agency, argument residue, mini-aphorism closers и другие |
| [P9 Negative Parallelisms](01-patterns/rhetorical/negative-parallelisms) | **Маркер №1** по Washington Post 2024: «это не X, а Y» |
| [lexicon-ru-v2](01-patterns/lexical/lexicon-ru-v2) | Русские AI-клише: «более того», «стоит отметить» |
| [lexicon-en](01-patterns/lexical/lexicon-en) | Английские AI-клише: `delve`, `leverage`, `robust` |
| [deeprichastnye-oboroty](01-patterns/rhetorical/deeprichastnye-oboroty) | Перебор деепричастий (-а/-в) в русском |
| [parallel-clauses](01-patterns/structural/parallel-clauses) | «цели и задачи», «методы и средства» |
| [em-dash](01-patterns/structural/em-dash) | Перебор em-dash (в 3–5× выше человеческой нормы) |
| [over-generation](01-patterns/structural/over-generation) | P-NEW-1…7: vacuum-filling, restatement chains, bridging и т. п. |
| [format-and-rlhf-bias](01-patterns/structural/format-and-rlhf-bias) | P-NEW-8…12: format bias и RLHF-артефакты, стоящие за паттернами пере-говорения |

<br>

## 2️⃣ Techniques (`02-Techniques/`): что делать вместо этого

15 заметок. Первые пять образуют ядро v7: они определяют, что такое законная правка, насколько глубоко можно зайти и в каких жанрах.

| Заметка | Что внутри |
|---|---|
| [meaning-preservation](02-techniques/meaning-preservation) | **Ядро v7.** `meaning_map` и двусторонняя сверка: оригинал → результат ничего не теряет, результат → оригинал ничего не выдумывает. Утверждения, числа и отношения, условия, исключения, отрицания, модальность, терминология, цитаты, регистр |
| [editing-modes](02-techniques/editing-modes) | **Ядро v7.** 4 режима `proofread` / `light` / `style` / `deep`, какие фазы каждый открывает, когда разрешён RELY и как вернуть уже хороший текст |
| [russian-copyediting](02-techniques/russian-copyediting) | **Ядро v7.** Этап COPYEDIT для русского: грамматика, управление, пунктуация, двусмысленность местоимений, 24 пары «ошибка → исправление», минимальное вмешательство |
| [genre-profiles](02-techniques/genre-profiles) | **Ядро v7.** Пять жанровых профилей (academic, legal, marketing, support, technical-docs) с перечнем того, что в каждом профиле можно и нельзя трогать |
| [ru-corpus-collection](02-techniques/ru-corpus-collection) | **Ядро v7.** Как собрать настоящий RU-корпус (сейчас 8 human / 12 синтетических) и что после этого обязано измениться в метриках |
| [metric-validation](02-techniques/metric-validation) | Калибровка порогов на 145 размеченных текстах, языково-зависимые пороги, Cohen's d и смещение синтетической RU-выборки |
| [perplexity-and-burstiness](02-techniques/perplexity-and-burstiness) | Базовые метрики (основа детекции) |
| [voice-and-tone](02-techniques/voice-and-tone) | Как найти авторский голос |
| [voice-russian-specifics](02-techniques/voice-russian-specifics) | Я / мы / безличное в русском |
| [show-dont-tell](02-techniques/show-dont-tell) | Конкретика против абстракции (самый частый баг LLM-текста) |
| [sufficiency-and-underspecification](02-techniques/sufficiency-and-underspecification) | Рычаги 10 + 11: Grice submaxim 2 + Hemingway iceberg, и когда недосказанность применять **нельзя** |
| [length-bias-research](02-techniques/length-bias-research) | Академический фундамент: 5 статей с arXiv про length bias в RLHF |
| [russian-brevity-grammar](02-techniques/russian-brevity-grammar) | Глубокое погружение в Рычаг 12: парцелляция, эллипсис, литота |
| [laconic-prose-models](02-techniques/laconic-prose-models) | Толстой, Довлатов, Шкловский, Бунин: принципы для извлечения |
| [agent-writing-workflow](02-techniques/agent-writing-workflow) | Pre-flight → Write → Audit алгоритм |

<br>

## 3️⃣ Detection (`03-Detection/`): что измеримо

| Заметка | Что |
|---|---|
| [how-detectors-work](03-detection/how-detectors-work) | Binoculars (ICML 2024), Watermarking, DetectGPT, Pangram, GPTZero, ZeroGPT |
| [public-detectors](03-detection/public-detectors) | Сравнение доступных инструментов |
| [russian-detectors](03-detection/russian-detectors) | RU-специфика: GigaCheck, Antiplagiat и др. |

> [!note]
> Детекторы описаны здесь, чтобы объяснить, **что именно измеряют метрики**, а не как цель. См. [Ограничения](limitations).

<br>

## 4️⃣ Examples (`04-Examples/`): измеренные до/после

6 заметок. **Разобранные кейсы с замерами.** На каждом можно прогнать `benchmark-skill.sh` и проверить.

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

> [!warning]
> Эти три примера показывают RELY в работе. RELY **недоступен** в `proofread`/`light`, а в `style`/`deep` применяется только к художественному или разговорному регистру, и любое удаление всё равно проходит сверку по `meaning_map`.

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

Плюс две индексные заметки: [before-after](04-examples/before-after) и [before-after-ru-advanced](04-examples/before-after-ru-advanced).

<br>

## 5️⃣ References (`05-References/`): ограничения и этика

| Заметка | Что |
|---|---|
| [limits-and-self-critique](05-references/limits-and-self-critique) | Эпистемологический анализ: что мы знаем, чего не знаем, что MASH/ACL 2026 значит для потолка скилов и что до сих пор не провалидировано |

<br>

## 6️⃣ Sources (`06-Sources/`): сырые исследования

Реальные статьи и веб-страницы, которые мы взяли как доказательную базу:

### Исследовательские статьи (arXiv)

- `06-Sources/research-papers/length-bias/`
  - [park-2024-disentangling-length-dpo](06-sources/research-papers/length-bias/park-2024-disentangling-length-dpo): DPO эксплуатирует length bias
  - [shen-2023-loose-lips](06-sources/research-papers/length-bias/shen-2023-loose-lips): RM предполагает, что люди предпочитают длиннее (EMNLP 2023)
  - [zhang-2024-format-bias](06-sources/research-papers/length-bias/zhang-2024-format-bias): Format bias (списки, bold, эмодзи)
  - [huang-2024-post-hoc-calibration](06-sources/research-papers/length-bias/huang-2024-post-hoc-calibration): ICLR 2025; калибровка без дообучения
  - [lamparth-2026-bias-substitution](06-sources/research-papers/length-bias/lamparth-2026-bias-substitution): **Критически важно** (Stanford 2026): одностороннее смягчение → bias substitution

### Датасеты (для эмпирической валидации)

- `06-Sources/research-papers/detection-datasets/`
  - [hc3-english](06-sources/research-papers/detection-datasets/hc3-english): 24.3k пар AI-vs-human
  - [hc3-russian-translated](06-sources/research-papers/detection-datasets/hc3-russian-translated): переведённая версия
  - [raid-multi-domain](06-sources/research-papers/detection-datasets/raid-multi-domain): мультимодельный бенчмарк на 8.09M

### Веб-фетчи (RU-грамматика и литературная теория)

- `06-Sources/web-fetches/russian-grammar/`
  - [parcelyaciya-wikipedia](06-sources/web-fetches/russian-grammar/parcelyaciya-wikipedia): статья русской Википедии про парцелляцию
  - [ellipsis-wikipedia](06-sources/web-fetches/russian-grammar/ellipsis-wikipedia): 8 типов эллипсиса
  - [litota-wikipedia](06-sources/web-fetches/russian-grammar/litota-wikipedia): Литота с литературными примерами

- `06-Sources/web-fetches/laconic-prose/`
  - [shklovsky-wikipedia](06-sources/web-fetches/laconic-prose/shklovsky-wikipedia): Шкловский, «Искусство как приём» 1917, остранение, анализ Толстого

<br>

## 🔍 Как ориентироваться

| Хочу… | Смотреть |
|---|---|
| Найти все AI-клише | `01-Patterns/lexical/lexicon-en` |
| Убрать русский «канцелярит» | `01-Patterns/structural/parallel-clauses` |
| Отредактировать, не меняя смысл | `02-Techniques/meaning-preservation` |
| Решить, насколько глубоко лезть | `02-Techniques/editing-modes` |
| Понять, что можно трогать в договоре / статье / лендинге | `02-Techniques/genre-profiles` |
| Поправить русскую грамматику и пунктуацию | `02-Techniques/russian-copyediting` |
| Применить iceberg к техдоку | `02-Techniques/sufficiency-and-underspecification` → `04-Examples/iceberg/` |
| Русская парцелляция | `02-Techniques/russian-brevity-grammar` → `04-Examples/russian-grammar/` |
| Почему LLM перебирает | `02-Techniques/length-bias-research` |
| Понять, откуда взялись пороги метрик | `02-Techniques/metric-validation` |
| Перенять Шкловского / Толстого | `02-Techniques/laconic-prose-models` → `04-Examples/russian-grammar/06-shklovsky-tolstoy-kholstomer` |
| Замерить свой текст | `scripts/benchmark-skill.sh` |
| Проверить правку по смысловому контракту | `scripts/check-editing-output.sh` |

<br>

---

[← На главную](index) · [Далее: Ограничения →](limitations)

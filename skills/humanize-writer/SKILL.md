---
name: humanize-writer
description: Write new prose that avoids typical LLM patterns (lexical clichés, uniform sentence length, rule-of-three, impersonality, hedging, RLHF artifacts, over-generation). Use this skill whenever the user asks for any non-trivial narrative text — documentation, README sections, blog posts, emails, status updates, announcements. Do NOT use for short code comments, log messages, or technical reference where uniformity is desired.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-generation
  version: 7
---

# Humanize-Writer (v7)

Write text that reads like a human wrote it — without invented facts and without a template "humanize style" (рубленые фразы + числа + «я» + вопрос в конце). v7 keeps the explicit **3-pass architecture** (Audit → Rewrite → Verify) and adds the fact contract: конкретика берётся только из входных данных пользователя, приёмы применяются условно, метрики — диагностика, а не цель. Проверка результата — **per-claim**: потеря любого утверждения или выдуманный факт = FAIL (порог «10% можно потерять» снят). 12 levers stay organized into 4 phases (STRIP / TIGHTEN / RELY / REBUILD).

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). They resolve via the GitHub web UI / API. **No local file dependencies** — works on any machine with internet access.
>
> For **offline use**, clone the knowledge base locally:
> ```bash
> ./scripts/install-knowledge.sh
> export KNOWLEDGE_PATH="$HOME/.cache/agents-writing-skills-knowledge/knowledge"
> ```

> [!warning] Фактический контракт (v7)
> **Запрещено выдумывать** числа, имена, даты, личный опыт и причины. Конкретика берётся только из входных данных пользователя или явно оговорённых источников.
> Если факта нет — **спросите пользователя**, пометьте `[нужен факт: ...]` или пишите без него.
> **Сохраняются** утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может снижать» ≠ «снижает»), терминология, цитаты и регистр формальности.
> **Потеря любого утверждения — ошибка.** Порога «10% можно потерять» не существует.
> Приёмы (первое лицо, rupture, короткие фразы, тире, RELY) — **условные, а не обязательные**: они выбираются под жанр и голос, а не применяются всегда.
> **Хороший исходный текст можно оставить почти без изменений.**

> [!warning] Что этот скил МОЖЕТ и чего НЕ МОЖЕТ
> **Может:** сделать текст, который читается как человеческий для среднестатистического читателя.
> **Не может:** гарантировать прохождение GPTZero, Pangram, Grammarly. Против обученных детекторов **статические правила имеют потолок** (MASH, ACL 2026).
> **Не предназначен для:** обхода академической проверки, сдачи AI-текста как своего. Используйте, чтобы **писать лучше**, не чтобы **скрывать**.
> См. [`05-References/limits-and-self-critique.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/05-References/limits-and-self-critique.md).

> [!warning] Length bias caveat (v4+)
> YapBench (Borisov et al., 2026) и Park et al. (2024) показали, что length bias — структурное свойство RLHF preference tuning. **Tighten pass может привести к bias substitution** (Lamparth et al., 2026): сокращение длины → перенос bias на другие proxies (confidence, factual depth). Tighten pass должен сохранять плотность фактов, не только сокращать слова. Проверка — per-claim (см. 3.1): потеря любого утверждения = ошибка, «потеряли меньше 10%» — не аргумент.

> [!info] Major changes in v7
> - **Фактический контракт**: запрет на выдуманную конкретику; сбор фактов — обязательный шаг Pass 1
> - **Per-claim проверка вместо порога 10%**: потеря любого утверждения = FAIL, выдуманный факт = FAIL, модальность/отрицания/условия сверяются отдельно
> - **Условные приёмы**: первое лицо, конкретика, rupture, RELY — «если уместно и доступно», без жёстких квот
> - **Метрики как диагностика**, не как цель: хороший исходный текст можно оставить почти без изменений
> - **Режимы правки**: proofread / light / style / deep (см. `agent-writing-workflow`)

> [!info] Major changes in v5
> - **3-проходная архитектура**: Audit → Rewrite → Verify (явные входы/выходы)
> - **4 фазовые группы**: STRIP / TIGHTEN / RELY / REBUILD (вместо плоского списка 12 рычагов)
> - **Code blocks для примеров** (вместо bullet-списков)
> - **Decision tree** для выбора применения Lever 11/12
> - **Multi-language support table** для RU/EN регистров

> [!info] Major changes in v4
> - Lever 12 (Russian brevity grammar): парцелляция, эллипсис, литота, нулевая связка
> - Length bias academic integration (Park, Shen, Zhang, Lamparth, Huang)
> - Bias substitution warning

> [!info] Major changes in v3
> - Lever 10 (Sufficiency / Grice submaxim 2)
> - Lever 11 (Trust the reader / Hemingway iceberg)
> - Over-generation patterns P-NEW-1…P-NEW-7

## Архитектура: 3-проходный процесс

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: AUDIT (identify what to fix)                           │
│   Output: сбор фактов + список проблем + метрики (AP, D, E…)   │
│           + режим правки                                        │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: REWRITE (apply 12 levers в 4 фазах)                    │
│   Phase STRIP:   Levers 1-9  (remove negative patterns)         │
│   Phase TIGHTEN: Lever 10   (apply sufficiency / Grice)         │
│   Phase RELY:    Lever 11   (trust the reader / iceberg)        │
│                  — только style/deep, условно                   │
│   Phase REBUILD: Lever 12   (RU grammar — парцелляция/литота)   │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: VERIFY (per-claim meaning check, density, read aloud)  │
│   Output: готово к публикации ИЛИ список remaining issues       │
└────────────────────────────────────────────────────────────────┘
```

**Принцип:** не пытаться сделать всё за один проход. Каждый pass имеет чёткие входы и выходы. Если Pass 3 находит проблемы — возвращаемся к Pass 2.

---

## PASS 1 — AUDIT (идентификация)

> [!tip] Когда применять
> Перед написанием длинного текста. Перед редактированием чужого. Когда нужна отправная точка для оценки длины.
> Если задача — правка существующего текста, сначала выберите режим: **proofread / light / style / deep** (см. [`02-Techniques/agent-writing-workflow.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/agent-writing-workflow.md)). Хороший исходный текст можно оставить почти без изменений — режим proofread для этого и существует.

### 1.0. Режим правки (объём разрешённого)

Режим определяет, какие фазы и приёмы допустимы. Для нового текста (`greenfield`) режим выбирается по регистру и аудитории; для задачи «перепиши/переделай существующий текст» — по запросу пользователя, иначе по умолчанию `light`.

| Режим | Что разрешено | Когда |
|---|---|---|
| `proofread` | Только грамматика, опечатки, пунктуация | юридический текст, цитаты, «просто вычитай» |
| `light` | proofread + banned lexicon + closing cliché + явные дубликаты | черновик почти хорош, голос важен |
| `style` | light + STRIP + TIGHTEN + условные rupture/первое лицо | дефолт для постов, писем, README |
| `deep` | style + RELY + REBUILD (RU) + перестройка структуры | художественный/разговорный регистр, «сделай максимально живо» |

**Умолчание:** `light`, не `deep`. RELY (iceberg) разрешён **только** в `style`/`deep` и **только** для художественного или разговорного регистра — никогда по умолчанию, никогда для технического/делового/юридического текста.

Подробности: [`02-Techniques/editing-modes.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/editing-modes.md).

### 1.1. Сбор фактов (обязательный шаг)

Прежде чем что-то писать или переписывать, зафиксируйте, **что реально известно**. Конкретика в итоговом тексте может происходить только из этого списка.

```yaml
fact_sheet:
  known:                # факты из входных данных пользователя
    - "…"               # числа, имена, даты, пути, команды, ссылки
  ask_user:             # факты, без которых текст будет пустым — спросить до написания
    - "…"
  optional:             # украсят текст, но можно писать и без них
    - "…"
  forbidden:            # никогда не появляются в тексте
    - "выдуманные числа, имена, даты, личный опыт, причины"
```

Правила:

- **Нет факта — нет конкретики.** Заменять абстракцию выдуманным числом хуже, чем оставить абстракцию.
- Если факт критичен и недоступен — **спросите пользователя** до начала Pass 2.
- Если спросить нельзя, а место под факт остаётся — пометьте `[нужен факт: что именно]`.
- Примеры в этом документе (Genium Tasks и т.п.) — **иллюстрации с вымышленными продуктами**, а не образец того, откуда брать конкретику.

### 1.2. Метрики для подсчёта

> [!note] Метрики — диагностика, не цель
> Таблица ниже помогает **найти** проблемы, а не заставляет «попасть в норму» любой ценой. Если текст уже хорош, метрики подтвердят это — и текст можно оставить почти без изменений. Погоня за порогами ради порогов воспроизводит шаблонный «humanize-стиль», от которого проект уходит.

Используйте простые текстовые счётчики (wc, awk) или `scripts/benchmark-skill.sh`:

| Метрика | Формула | Target (EN) | Target (RU) | Source |
|---|---|---|---|---|
| **AP** (negative parallelism) | (число антитезисов / слов) × 1000 | <1 | <1 | empirical, n=145 |
| **D** (деепричастия RU) | (деепричастий / слов) × 1000 | n/a | <12 (soft warning); conversational/technical <7; literary ≤30 OK | empirical + Tolstoy |
| **E** (em-dash) | (em-dash / слов) × 1000 | <3 | "0 em-dash в RU = AI-signal"; высокий E — норма | empirical |
| **YapScore** | длина / минимально-достаточный эталон | 1.0–1.5 | 1.0–1.5 | Borisov 2026 |
| **V** (vacuum-filling sentences) | (вводных предложений / всего предложений) × 100 | <2% | <2% | empirical |
| **R** (restatement chains) | (повторов смысла / всего предложений) × 100 | <10% | <10% | empirical |
| **B** (bridging phrases) | (мостиков на границе абзацев) / всего абзацев | <5% | <5% | empirical |
| **Burstiness std** | std длины предложений (слов) | >3 | >8 (human литературная: 18+, AI маркетинг: 6.5) | empirical |
| **Specificity** | конкретных фактов на абзац (только из входных данных) | >0.5 | varies | empirical |

> [!warning] Specificity — не квота
> «>0.5 факта на абзац» — это диагностика плотности, а не норма на выдумку. Добавлять число, чтобы попасть в метрику, запрещено: конкретика берётся только из входных данных, иначе — `[нужен факт: ...]`. Низкая плотность = повод спросить пользователя, а не повод придумать.

> [!info] Калибровка порогов
> Все цифры в таблице получены эмпирически на корпусе 145 размеченных текстов
> (HC3, RAID, Wikisource + синтетика). Полный отчёт:
> [`knowledge/02-Techniques/metric-validation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/metric-validation.md).
> Пороги языково-зависимы: `benchmark-skill.sh` определяет RU/EN автоматически
> по соотношению кириллицы (≥30% → RU mode).

> [!warning] D — soft, не hard fail
> Деепричастия в RU литературной прозе — норма: 14-30/1000 слов
> (Бунин, Чехов, Тургенев, Толстой). Жёсткий порог D < 7 флагал бы
> почти всю русскую классику как AI. Поэтому D — только рекомендация.
> **Если вы пишете в регистре "Tolstoy dense"** — игнорируйте D-предупреждение.

> [!info] E (em-dash) — единственный надёжный RU-AI signal
> В нашем корпусе: 0/12 RU-AI текстов содержат em-dash; 8/8 RU-human содержат
> (Tolstoy/Bunin/Chekhov/Turgenev). Сигнал: **отсутствие em-dash в RU-тексте
> длиной >200 слов — сильный AI-маркер**. Высокий E (5+ на 300 слов) —
> наоборот, человеческий признак.

### 1.3. Признаки AI-текста без счётчиков

Прочитайте текст вслух. Спросите себя:

- [ ] **Тон одинаковый ровный?** (LLM держит регистр без перепадов)
- [ ] **Каждое предложение ≈ одинаковой длины?** (низкая вариативность / low burstiness)
- [ ] **Есть ли "let me explain", "стоит отметить", "это важно"?** (RLHF voice)
- [ ] **Каждый второй абзац заканчивается выводом?** (mini-conclusion)
- [ ] **Есть ли списки ровно из 3 элементов с одинаковой грамматикой?** (rule of three)
- [ ] **В тексте больше абстрактных слов, чем конкретики?** (низкая фактичность / low specificity)

### 1.4. Audit output

```yaml
audit_report:
  facts:
    known: ["…"]            # см. 1.1
    ask_user: ["…"]
    missing_marked: 0       # сколько [нужен факт: ...] останется в тексте
  metrics:
    AP: 5.2  # critical
    D: 9.1  # high
    E: 4.0  # high
    YapScore: 2.1  # critical
  p9_frames_manual:           # обязательное поле: ручной проход по каталогу
    forms_checked: ["3.1", "3.2", "3.3", "3.4", "3.5"]  # §3.1–3.5 negative-parallelisms
    locations: ["para_4_sentence_2: «не разговором, а защитой в коде»"]
    # Заполняется ВРУЧНУЮ по формам каталога, а не из метрики: старый
    # AP-детектор ловил один лексический якорь и находил 0 из 8 канонических
    # примеров. Пустое поле при ненулевой метрике = FAIL.
  issues:
    - type: vacuum_filling
      locations: [para_2, para_5]
    - type: restatement_chain
      locations: [para_3_sentences_1-3]
    - type: negative_parallelism
      locations: [para_4_sentence_2]
  voice_signals:
    first_person: false     # нужен ли — решают жанр и голос, не квота
    opinion: false
    concrete_facts: 2  # low — но добавлять только реальные
  estimated_effort: "2-3 passes"
```

---

## PASS 2 — REWRITE (4 фазы, 12 levers)

> [!tip] Порядок фаз важен
> **STRIP → TIGHTEN → RELY → REBUILD**. Если перепутать — добавим шум в уже очищенный текст.

### Phase STRIP (Levers 1-9) — удаление негативных паттернов

> **Цель:** убрать AI-маркеры. Не добавлять ничего, кроме конкретики из входных данных и голоса — и то только если это уместно регистру.

| Lever | Что делает | Когда применять |
|---|---|---|
| **1. Perplexity** (непредсказуемость) | Заменить предсказуемые слова на неожиданные | При наличии клише (delve, leverage, robust) |
| **2. Burstiness** | Чередовать длины предложений (5–25+ слов) | Когда std предложений < 3. Разброс — длинами, а не антитезисными ударами (см. предупреждение ниже) |
| **3. Hedge surgery** | Удалить «можно сказать», «it could be argued» | Только **страховочное** хеджирование. Честная неуверенность автора («может снижать нагрузку») — не хеджирование, её сохраняем |
| **4. Structural flatten** | Убрать лишние структурные навороты | Когда bullets перегружены |
| **5. Specificity** | Заменить абстракции реальными фактами (числа, имена, пути) | Когда текст абстрактен **и факты доступны**; иначе — спросить или пометить `[нужен факт: ...]`. Выдумывать запрещено. Не квота: метрика плотности не оправдание для придуманного числа |
| **6. Voice** | Добавить «я»/«мы»/«I»/«we» | **Только** если формат допускает первое лицо, текст пишется от автора и это не создаёт выдуманный личный опыт. В legal/docs/API-описаниях — пропустить |
| **7. Discourse** | Убрать «Furthermore», «Moreover» | Когда есть AI-коннекторы |
| **8. Punctuation** | Em-dash ≤ 1 на 300 слов | Когда em-dash > нормы |
| **9. RLHF strip** | Убрать polite hedging, balanced framing | Когда есть «Great question!», «I hope this helps» |

> [!info] Первое лицо — приём, а не обязанность
> Если текст звучит по-человечески без «я»/«мы» — ничего не добавлять. Если формат не предполагает рассказчика (инструкция, отчёт, API-документация, юридический текст) — первое лицо не добавляется вовсе.

> [!warning] Burstiness — разбросом длин, а не шаблонами
> Короткий удар («Не X. Y.», «А про…») поднимает burstiness **и** добавляет
> P9-рамку. Замер на человеческой прозе и на реальном LLM-корпусе: разброс у
> человека даёт **длина**, а не антитезис; у LLM наоборот — ударные конструкции
> вместо разброса. Если std не растёт — разводите длины предложений, а не
> добавляйте «Не X. Y.»: второй путь поднимает AP и делает текст шаблоннее.
> Порог: std > 8 для RU (человек: медиана 13, минимум 6.8; LLM: максимум 7.2).

**Lexicon** для запрещённых слов: [`references/lexicon.md`](https://github.com/11111000000/agents-writing-skills/blob/main/skills/humanize-writer/references/lexicon.md).

**Расширенный список AI-паттернов** (P-NEW-13..20, добавлены в v1.5 из survey GitHub humanizer-репозиториев): см. [`knowledge/01-Patterns/catalogue-update.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/catalogue-update.md). Самые частые:

- **P-NEW-13 False Agency** — «The market rewards…», «Security says no.», «Performance demands…». Заменять на конкретного субъекта.
- **P-NEW-16 Argument Residue** — реплики-возражения в пустоту: «While X argues Y, however…». Удалить.
- **P-NEW-18 Asyndeton Tricolon** — три длинных параллельных элемента через запятую без союза: «innovation, inspiration, and insights». Заменить на 2-разных-элемента.
- **P-NEW-19 Mini-Aphorism Closer** — последнее предложение абзаца — короткая сентенция-мораль. Удалить или развернуть.
- **P-NEW-20 Hedged-Enumeration Openers** — «From X to Y, …», «Whether A or B, …», «Not just A, but B». Заменить прямой формулировкой.

**Пример STRIP** (иллюстрация: продукт «Genium Tasks» и детали вымышлены. Это демонстрация замены штампов прямой речью, а **не** образец превращения абстракции в факты — в реальной работе конкретику даёт пользователь, см. 1.1):

```diff
- Мы предоставляем современное решение, которое обеспечивает эффективное
- управление задачами, способствуя повышению производительности команды.
+ Genium Tasks — CLI для тех, кому надоело вести задачи в Notion. Один бинарь,
+ конфиг в ~/.config/genium/tasks.toml, и задачи живут в git вместе с кодом.
```

```diff
# P-NEW-13 False Agency
# NB: конкретика в «после» — только из входных данных; иначе [нужен факт: ...]
- The market rewards companies that listen.
+ Customers reward companies that answer support tickets. [нужен факт: как измеряется «reward»]
```

### Phase TIGHTEN (Lever 10) — суффицентность

> **Цель:** сказать ровно столько, сколько нужно. Удалить всё, что больше.

**Принцип:** «Do not make your contribution more informative than is required» (Grice submaxim 2).

#### 10.1. Метод: 8 сканирований

```python
for scan in [
    "vacuum_filling",      # P-NEW-1: вводные без информации
    "restatement",         # P-NEW-2: 2+ предложения с одним содержанием
    "bridging",            # P-NEW-3: "как упоминалось выше", "это подводит нас"
    "over_explanation",    # P-NEW-4: объяснение очевидного
    "anticipatory_hedging", # P-NEW-5: "возможно, в некоторых случаях"
    "balanced_framing",    # P-NEW-6: "с одной стороны, с другой"
    "antithetical_recap",  # P-NEW-7: "итак, мы рассмотрели"
    "strunk_cut_test"      # удали любое предложение, смысл выжил?
]:
    rewrite(text)
```

> [!warning] Что TIGHTEN имеет право удалять
> `anticipatory_hedging` убирает страховку («возможно, стоит рассмотреть»), а **не** честную неуверенность автора («может снижать нагрузку»). Условия, исключения, отрицания и модальность — часть утверждения; их удаление = потеря смысла (см. Pass 3).

#### 10.2. Strunk cut-test

> Удалите любое предложение. Смысл потерялся? Если нет — навсегда удалите.

Оговорка: cut-test применяется к **пустым фразам и явным дубликатам**. Предложение с условием, исключением, отрицанием или модальностью («кроме X», «не работает», «может снижать») не удаляется, даже если кажется избыточным: оно несёт содержание, которое читатель иначе не восстановит.

**Williams 6 операций** (финальный проход):

1. Delete words that mean little or nothing (`in order to` → `to`)
2. Delete words that repeat the meaning of other words
3. Delete words implied by other words
4. Replace a phrase with a word (`is able to` → `can`)
5. Change negatives to affirmatives (`did not remember` → `forgot`)
6. Delete useless adjectives and adverbs (`absolutely essential`)

#### 10.3. Пример TIGHTEN

```diff
- У нас в команде возник вопрос по дедлайну. После обсуждения мы пришли к
- выводу, что дедлайн нужно перенести. Это связано с тем, что код ещё не
- закрыт, тесты не прогонялись. Поэтому мы предлагаем сдвинуть срок на неделю.
+ Дедлайн нереальный. Код не закрыт, тесты не гоняли. Предлагаем сдвинуть на неделю.
```

Word count: 37 → 12 (−68%). Условие («код не закрыт, тесты не гоняли»), модальность («предлагаем») и срок — на месте.

### Phase RELY (Lever 11) — доверяй читателю

> **Цель:** оставить пробелы, которые читатель заполнит сам. Hemingway iceberg.

> [!warning] RELY запускается не всегда
> Фаза разрешена **только** если одновременно:
> 1. Режим правки — `style` или `deep` (см. 1.0);
> 2. Регистр — художественный или разговорный (пост, эссе, колонка, письмо коллеге).
>
> Для технического, делового, юридического, академического текста RELY **не запускается никогда**: iceberg-пробелы там съедают условия и оговорки. В режимах `proofread`/`light` — тоже нет. При сомнении — не запускать.
>
> Даже внутри RELY нельзя удалять условия, исключения, отрицания и модальность — это содержание, а не «вода».

**Принцип:** «If a writer of prose knows enough of what he is writing about he may omit things that he knows and the reader... will have a feeling of those things as strongly as though the writer had stated them.»

#### 11.1. Reader-fill test

Удалите абзац. Читатель может продолжить мысль без него? Если да — удалите.

**Условие Хемингуэя:** underspecification работает только если автор **знает** то, что не говорит. Иначе — hollow places, не gravitas.

#### 11.2. Distinctive-word test

Если в предложении нет ни одного слова, добавляющего информацию, которой не было в предыдущем, — удалите его.

#### 11.3. Stop at the turn

Если в абзаце есть «поворотный момент» — остановитесь на нём. LLM продолжает объяснять, что это значит. Хороший автор ставит точку.

#### 11.4. Пример RELY

```diff
- Я долго думал над этой проблемой. У неё много аспектов. Я рассмотрел
- несколько подходов. В конце концов я пришёл к выводу, что оптимальное
- решение — использовать Redis. Redis — это in-memory хранилище, которое
- обеспечивает высокую скорость доступа к данным.
+ Redis. Почему — ниже.
```

### Phase REBUILD (Lever 12, RU only) — русские грамматические инструменты

> **Цель:** активное применение русских традиций краткости. Не удаление, а перестройка.

> [!warning] Когда НЕ применять
> Официально-деловой, юридический, дипломатический, научный регистры. В них эти приёмы не норма.

#### 12.1. Парцелляция (расщепление)

```diff
- Город стоит на реке, обеспечивая водоснабжение, способствуя развитию
- сельского хозяйства и формируя микроклимат.
+ Город стоит на реке. Отсюда — водоснабжение и полив.
```

Устраняет P3 (деепричастия) + P8 (copula avoidance).

#### 12.2. Эллипсис (опущение)

```diff
- Я говорю по-английски, а он говорит по-немецки.
+ Я говорю по-английски, а он — по-немецки. (гэппинг)
```

Типы: глагольной группы, именной группы, стриппинг, фрагментирование, гэппинг, псевдогэппинг.

#### 12.3. Литота (преуменьшение)

```diff
- У нас совсем немного пользователей, практически никто не пользуется.
+ У нас пользователей — кот наплакал.
```

Готовые формулы: «черепашьи темпы», «рукой подать», «кот наплакал», «с ноготок», «с овчинку», «не более напёрстка», «девочка-дюймовочка».

#### 12.4. Нулевая связка

```diff
- Я пошёл в магазин, чтобы купить хлеб.
+ Пошёл в магазин. Хлеб.
```

Подробнее: [`02-Techniques/russian-brevity-grammar.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md).

> [!warning] REBUILD guard (ужесточение в v6)
> **Запускайте Phase REBUILD только если текст действительно русский.** На EN-тексте не срабатывает литота, а псевдо-парцелляция ломает ритм. Проверка:
>
> ```python
> import re
> def has_cyrillic(text: str, threshold: float = 0.3) -> bool:
>     cyr = len(re.findall(r"[А-Яа-яЁё]", text))
>     letters = len(re.findall(r"[A-Za-zА-Яа-яЁё]", text))
>     if letters == 0:
>         return False
>     return cyr / letters >= threshold
>
> if not has_cyrillic(draft):
>     skip_phase("REBUILD")
> ```
>
> На смешанных текстах (code-switching) REBUILD прогонять только по русским фрагментам.

> [!danger] REBUILD → повторный STRIP (обязательно, v7.1)
> REBUILD **производит** паттерны, которые STRIP удаляет: парцелляция рождает
> кросс-предложные рамки («Это не X. Это Y.» из двух коротких предложений),
> нулевая связка превращает «Это не X, а Y» в «Не X, а Y» — форму без
> лексического якоря, которую старый детектор не видел, а эллипсис-стриппинг
> даёт «X, а Y» на следующем предложении.
>
> **После REBUILD — обязательный повторный проход STRIP** минимум по P9, P18,
> P19, с явной пометкой в PASS 3:
>
> ```
> re_strip_after_rebuild:
>   p9_checked: true      # рамки перечитаны после REBUILD, не до
>   p9_density_delta: -1.2  # было 3.4 → стало 2.2 (должен быть ≤ 0)
>   p18_checked: true
>   p19_checked: true
> ```
>
> Повторный STRIP **только подтверждающий**: он не имеет права удалять
> утверждения, числа или модальность. Если рамка стала нужна для смысла —
> оставить и объяснить в отчёте (см. перекрёстный гейт в PASS 3).

---

## PASS 3 — VERIFY (финальные проверки)

> [!tip] Когда применять
> После Pass 2. Перед публикацией.

### 3.1. Per-claim verification (v7) — замена порога «10% потерянных фактов»

> [!warning] Critical (Lamparth et al. 2026)
> Single-axis mitigation переносит bias на другие proxies. После Tighten pass проверяем **каждое утверждение**, а не процент: **потеря любого утверждения = FAIL**, **выдуманный факт = FAIL**. Порога «потерять 10% — можно» не существует.

Проверка двусторонняя: оригинал → текст (ничего не потеряно) и текст → оригинал (ничего не выдумано).

#### 3.1.1. Потеря vs выдумка

```python
import re

def extract_facts(text):
    """Числа, имена собственные, команды, пути, даты."""
    return set(
        re.findall(r'\b\d+(?:\.\d+)?(?:[%kmсx]?)\b', text) |           # 14, 30%, 5k, 14ms
        re.findall(r'`[^`]+`', text) |                                 # `pip install`
        re.findall(r'[/~][\w./\-]+', text) |                          # ~/Desktop/foo.md
        re.findall(r'\b[A-Z][a-z]+(?:\s[A-Z][a-z]+)+\b', text) |       # Stripe, PostgreSQL
        re.findall(r'\b\d{4}\b', text)                                # 2024
    )

def extract_claims(text):
    """Каждое утверждение: субъект + отношение + значение + условие + модальность."""
    # Для каждого предложения зафиксировать:
    # - факты (extract_facts)
    # - модальность: может/возможно/might ≠ точно/will
    # - отрицания: не/no/never
    # - условия и исключения: если/при/кроме/за исключением
    # - термины и цитаты
    ...

def check_claims_preserved(original: str, rewritten: str) -> dict:
    """Нулевая потеря по умолчанию: каждое утверждение оригинала должно
    сохраниться в тексте — с теми же числами, условиями и модальностью."""
    lost_facts = extract_facts(original) - extract_facts(rewritten)
    invented_facts = extract_facts(rewritten) - extract_facts(original)
    lost_claims = [c for c in extract_claims(original)
                   if not claim_survives(c, rewritten)]
    # Допустимые исключения: явные дубликаты и пустые фразы
    # ("важно отметить", "как мы видим") — их удаление не считается потерей.
    failed = bool(lost_facts or invented_facts or lost_claims)
    return {
        "status": "FAIL" if failed else "PASS",
        "lost_facts": list(lost_facts),
        "invented_facts": list(invented_facts),   # выдуманные числа/имена = FAIL
        "lost_claims": lost_claims,
        "action": "Restore lost, remove invented" if failed else "Proceed",
    }
```

Выдумка проверяется и по `fact_sheet`: число, которого нет во входных данных, не считается фактом, даже если правдоподобно.

```python
def check_no_invented_facts(rewritten: str, fact_sheet: dict) -> dict:
    """Каждый факт в тексте должен происходить из fact_sheet.known (см. 1.1)."""

    facts = extract_facts(rewritten)
    invented = facts - set(fact_sheet["known"])

    if invented:
        return {"status": "FAIL", "invented_facts": list(invented),
                "action": "удалить, спросить пользователя или пометить [нужен факт: ...]"}

    return {"status": "PASS"}
```

#### 3.1.2. Модальность, отрицания, условия и исключения — сверяются отдельно

Regex ловит токены, а не смысл. Эти четыре класса проверяются сверкой каждого утверждения:

| Что | Как | Что сломалось |
|---|---|---|
| Модальность | «может снижать» vs «снижает» | Усиление уверенности — это выдумка |
| Отрицание | «не работает» vs «работает с ограничениями» | Переворот смысла |
| Условие | «под нагрузкой 5k req/s» vs «всегда» | Из частного случая сделан закон |
| Исключение | «кроме X» vs «...» | Выдумана универсальность |

Терминология проверяется так же: синоним допустим, только если он полный («rate limiter» → «ограничитель частоты запросов» ок, «rate limiter» → «тормоз» — нет). Цитаты не редактируются.

#### 3.1.3. Что считать допустимым удалением

Только **явные дубликаты** и **пустые фразы** («важно отметить», «как мы видим», «в заключение можно сказать»). Если утверждение удалено и указать, какое другое утверждение несёт то же содержание, нельзя — это потеря смысла (FAIL).

### 3.2. Final density check

Метрики здесь — диагностика: они показывают, где искать проблему, а не задают цель «попасть в норму».

```yaml
final_check:
  meaning_contract:
    status: PASS          # или FAIL
    lost_claims: []       # потеряно утверждение = FAIL
    lost_facts: []
    invented_facts: []    # выдуманные числа/имена/даты = FAIL
    modality_preserved: true
  density:                # диагностика, не цель
    AP: <3                # target (порог детектора 4; RU-литература ≤3.45, LLM ≥4.65)
    D: <7                 # RU only
    E: <3                 # global
    YapScore: 1.0–1.5     # global
    V: <5%                # vacuum-filling
    R: <10%               # restatement chains
    B: <5%                # bridging
  cross_gate:             # метрики проверяют друг друга
    ap_delta_vs_input: -1.2   # было 3.4 → стало 2.2
    # Если AP вырос относительно входа — обязательное ручное объяснение:
    # какая именно рамка добавлена и зачем. Без объяснения — FAIL.
    ap_growth_explained: true
    re_strip_after_rebuild: true  # STRIP повторён после REBUILD (P9/P18/P19)
```

### 3.3. Read aloud test

Прочитайте текст вслух. Если звучит как:
- ❌ пресс-релиз LinkedIn → переписать
- ❌ marketing landing → переписать
- ❌ Wikipedia article → переписать
- ❌ шаблонный «humanize-стиль» (рубленые фразы + числа + «я» + вопрос в конце) → переписать
- ✅ normal human speech / post / email — OK

### 3.4. Если VERIFY не проходит

Вернитесь к Pass 2. Не начинайте с нуля — найдите конкретную проблему.

```yaml
verify_failure:
  issue: YapScore 2.3
  location: para_3
  action: return_to_pass_2_phase_TIGHTEN
```

```yaml
verify_failure:
  issue: "lost_claims: [C3 — модальность «может снижать» превратилась в «снижает»]"
  location: para_2_sentence_1
  action: restore_claim      # вернуть утверждение, а не «компенсировать» новой конкретикой
```

---

## Multi-language support

| Регистр | RU | EN |
|---|---|---|
| Conversational | Levers 1-10, 12; **Lever 11 (RELY) — условно (style/deep)** | Levers 1-10; **Lever 11 (RELY) — условно (style/deep)** |
| Blog | Levers 1-10, 12; **Lever 11 (RELY) — условно (style/deep)** | Levers 1-10; **Lever 11 (RELY) — условно (style/deep)** |
| Email коллеге | Levers 1-9, 12 (без эллипсиса — что делать вместо: парцелляция, литота, нулевая связка) | Levers 1-9 |
| README | Levers 1-9 | Levers 1-9 |
| Marketing | Только Lever 9 (RLHF strip) + P-NEW-13/16/20 strip | Только Lever 9 + P-NEW-13/16/20 |
| Technical reference | Никакие (нужна точность) | Никакие |
| Literary prose | Levers 1-9 + **Lever 11 в режиме deep**, сохраняем D 14-30/1000, E >0, вариативность длины std >10 | n/a |

> [!note] Literary RU — отдельный регистр
> Если пишете в стиле русской литературной прозы (Бунин, Чехов, Толстой):
> **не пытайтесь попасть в D < 7**. Эти авторы используют 14-30 деепричастий
> на 1000 слов и 5-23 em-dash на 300 слов. Целевой профиль — вариативность
> длины предложений (burstiness) std >10 (vs AI ~6), деепричастия — да,
> em-dash — да, RLHF-voice — нет.

---

## Workflow (legacy — v3-style, оставлен для совместимости)

> [!note] Legacy 7-шаговый процесс
> Следующие шаги эквивалентны Pass 1-3 архитектуре выше, но описаны линейно.

### Step 1 — Pre-flight (Pass 1, частично)
4 вопроса: voice, lead, numbers ready?, sufficiency budget. Плюс обязательный сбор фактов (см. 1.1): что известно, что спросить у пользователя.

### Step 2 — Draft
Draft full text, monitor: вариативность длины, деепричастия, em-dash count, я/мы (если уместно).

### Step 3 — Audit pass (Pass 1)
Per-paragraph checks: concrete detail (только реальная), sentence length diff, banned lexicon, triple-parallel, abstract sentence.

### Step 4 — Tighten pass (Pass 2, TIGHTEN)
8 scans + Strunk cut-test + Williams 6 operations. Удаляются только дубликаты и пустые фразы — не утверждения.

### Step 5 — Rupture pass (Pass 2, RELY)
Если текст всё ещё звучит слишком гладко **и rupture уместен регистру** — вставить (one-line aside, вопрос, blunt opinion, конкретное число из входных данных). Иначе — не вставлять. Rupture не обязателен.

### Step 6 — Trust-the-reader pass (Pass 2, RELY)
Только в режимах `style`/`deep` и для художественного/разговорного регистра. Reader-fill test, distinctive-word test. Условия, исключения и модальность при этом не удаляются.

### Step 7 — Density check (Pass 3)
Count per 1000 words: AP, D, E, V, R, B. Плюс per-claim проверка: потерянных утверждений — 0, выдуманных фактов — 0, модальность сохранена.

---

## Когда молчать: где уместна недосказанность

| Уместно | Неуместно |
|---|---|
| Email коллеге | Onboarding нового сотрудника |
| Пост в блог для своей аудитории | Tutorial для новичков |
| RFC внутри команды | RFC для другой команды |
| Комментарий в PR | API reference |
| Личное сообщение | Юридический/финансовый документ |
| Пресс-релиз для отрасли | Пресс-релиз для широкой публики |
| Status update для знакомых | Status update для стейкхолдеров |
| Доклад на конференции для своих | Доклад для широкой аудитории |
| Художественная проза | Научная статья |

**Принцип различения:** underspecification работает, когда у автора и читателя есть общий контекст. Если общего контекста нет — нужно дать его явно. Это не нарушение Lever 10, это уважение к Gricean maxim of quantity.

---

## Output format

Always output **only the final text**. No preamble, no "Here's a draft:", no apologies.

Допустимое исключение — маркеры `[нужен факт: ...]` в местах, где пользователь должен подставить реальную конкретику. Если таких маркеров много, сначала спросите пользователя, потом пишите.

Если пользователь просит audit или diagnosis — переключись на `anti-ai-auditor`.

---

## Companion skills

- `humanize-editor` — для переписывания существующего текста (3-pass audit → rewrite → verify)
- `anti-ai-auditor` — для диагностики без переписывания
- `ai-pattern-rewriter` — для хирургических правок specific spans

---

## See also

Knowledge base:
- [`02-Techniques/meaning-preservation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/meaning-preservation.md)
- [`02-Techniques/editing-modes.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/editing-modes.md)
- [`02-Techniques/perplexity-and-burstiness.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/perplexity-and-burstiness.md)
- [`02-Techniques/voice-and-tone.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/voice-and-tone.md)
- [`02-Techniques/voice-russian-specifics.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/voice-russian-specifics.md)
- [`02-Techniques/show-dont-tell.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/show-dont-tell.md)
- [`02-Techniques/sufficiency-and-underspecification.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/sufficiency-and-underspecification.md)
- [`02-Techniques/length-bias-research.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/length-bias-research.md)
- [`02-Techniques/russian-brevity-grammar.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md)
- [`01-Patterns/43-patterns-catalogue.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/43-patterns-catalogue.md)
- [`01-Patterns/structural/over-generation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/structural/over-generation.md)
- [`04-Examples/tightening/`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/tightening/) — 5 примеров Tighten pass
- [`04-Examples/iceberg/`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/iceberg/) — 3 примера Iceberg
- [`04-Examples/russian-grammar/`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/russian-grammar/) — 5 примеров RU grammar pass

External:
- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) (43-pattern catalogue)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) (9 levers)
- [YapBench paper](https://arxiv.org/abs/2601.00624)
- [HC3 dataset](https://huggingface.co/datasets/Hello-SimpleAI/HC3)
- [RAID dataset](https://huggingface.co/datasets/liamdugan/raid)

---
name: humanize-writer
description: Write new prose that avoids typical LLM patterns (lexical clichés, uniform sentence length, rule-of-three, impersonality, hedging, RLHF artifacts, over-generation). Use this skill whenever the user asks for any non-trivial narrative text — documentation, README sections, blog posts, emails, status updates, announcements. Do NOT use for short code comments, log messages, or technical reference where uniformity is desired.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-generation
  version: 5
---

# Humanize-Writer (v5)

Write text that reads like a human wrote it. v5 introduces an explicit **3-pass architecture**: every text passes through Audit → Rewrite → Verify. 12 levers organized into 4 phases (STRIP / TIGHTEN / RELY / REBUILD).

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). They resolve via the GitHub web UI / API. **No local file dependencies** — works on any machine with internet access.
>
> For **offline use**, clone the knowledge base locally:
> ```bash
> ./scripts/install-knowledge.sh
> export KNOWLEDGE_PATH="$HOME/.cache/agents-writing-skills-knowledge/knowledge"
> ```

> [!warning] Что этот skill МОЖЕТ и чего НЕ МОЖЕТ
> **Может:** сделать текст, который читается как человеческий для среднестатистического читателя.
> **Не может:** гарантировать прохождение GPTZero, Pangram, Grammarly. Против обученных детекторов **статические правила имеют ceiling** (MASH, ACL 2026).
> **Не предназначен для:** обхода академической проверки, сдачи AI-текста как своего. Используйте, чтобы **писать лучше**, не чтобы **скрывать**.
> См. [`05-References/limits-and-self-critique.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/05-References/limits-and-self-critique.md).

> [!warning] Length bias caveat (v4+)
> YapBench (Borisov et al., 2026) и Park et al. (2024) показали, что length bias — структурное свойство RLHF preference tuning. **Tighten pass может привести к bias substitution** (Lamparth et al., 2026): сокращение длины → перенос bias на другие proxies (confidence, factual depth). Tighten pass должен сохранять плотность фактов, не только сокращать слова.

> [!info] Major changes in v5
> - **3-pass архитектура**: Audit → Rewrite → Verify (явные входы/выходы)
> - **4 phase-группы**: STRIP / TIGHTEN / RELY / REBUILD (вместо плоского списка 12 levers)
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

## Архитектура: 3-pass workflow

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: AUDIT (identify what to fix)                           │
│   Output: список проблем + метрики (AP, D, E, YapScore)        │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: REWRITE (apply 12 levers в 4 фазах)                    │
│   Phase STRIP:   Levers 1-9  (remove negative patterns)         │
│   Phase TIGHTEN: Lever 10   (apply sufficiency / Grice)         │
│   Phase RELY:    Lever 11   (trust the reader / iceberg)        │
│   Phase REBUILD: Lever 12   (RU grammar — парцелляция/литота)   │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: VERIFY (final checks, bias substitution check)          │
│   Output: готово к публикации ИЛИ список remaining issues       │
└────────────────────────────────────────────────────────────────┘
```

**Принцип:** не пытаться сделать всё за один проход. Каждый pass имеет чёткие входы и выходы. Если Pass 3 находит проблемы — возвращаемся к Pass 2.

---

## PASS 1 — AUDIT (идентификация)

> [!tip] Когда применять
> Перед написанием длинного текста. Перед редактированием чужого. Когда нужен baseline.

### 1.1. Метрики для подсчёта

Используйте простые текстовые счётчики (wc, awk) или `scripts/benchmark-skill.sh`:

| Метрика | Формула | Target |
|---|---|---|
| **AP** (negative parallelism) | (число антитезисов / слов) × 1000 | <1 |
| **D** (деепричастия RU) | (деепричастий / слов) × 1000 | <7 |
| **E** (em-dash) | (em-dash / слов) × 1000 | <3 |
| **YapScore** | длина / минимально-достаточный baseline | 1.0–1.5 |
| **V** (vacuum-filling sentences) | (вводных предложений / всего предложений) × 100 | <5% |
| **R** (restatement chains) | (повторов смысла / всего предложений) × 100 | <10% |
| **B** (bridging phrases) | (мостиков на границе абзацев) / всего абзацев | <5% |
| **Fmt** (format bias) | emoji + bold + list-items per 1000 words | sensible |

### 1.2. Признаки AI-текста без счётчиков

Прочитайте текст вслух. Спросите себя:

- [ ] **Тон одинаковый ровный?** (LLM держит регистр без перепадов)
- [ ] **Каждое предложение ≈ одинаковой длины?** (low burstiness)
- [ ] **Есть ли "let me explain", "стоит отметить", "это важно"?** (RLHF voice)
- [ ] **Каждый второй абзац заканчивается выводом?** (mini-conclusion)
- [ ] **Есть ли списки ровно из 3 элементов с одинаковой грамматикой?** (rule of three)
- [ ] **В тексте больше абстрактных слов, чем чисел?** (low specificity)

### 1.3. Audit output

```yaml
audit_report:
  metrics:
    AP: 5.2  # critical
    D: 9.1  # high
    E: 4.0  # high
    YapScore: 2.1  # critical
  issues:
    - type: vacuum_filling
      locations: [para_2, para_5]
    - type: restatement_chain
      locations: [para_3_sentences_1-3]
    - type: negative_parallelism
      locations: [para_4_sentence_2]
  voice_signals:
    first_person: false
    opinion: false
    concrete_facts: 2  # low
  estimated_effort: "2-3 passes"
```

---

## PASS 2 — REWRITE (4 фазы, 12 levers)

> [!tip] Порядок фаз важен
> **STRIP → TIGHTEN → RELY → REBUILD**. Если перепутать — добавим шум в уже очищенный текст.

### Phase STRIP (Levers 1-9) — удаление негативных паттернов

> **Цель:** убрать AI-маркеры. Не добавлять ничего.

| Lever | Что делает | Когда применять |
|---|---|---|
| **1. Perplexity** | Заменить предсказуемые слова на неожиданные | При наличии клише (delve, leverage, robust) |
| **2. Burstiness** | Чередовать длины предложений (5–25+ слов) | Когда std предложений < 3 |
| **3. Hedge surgery** | Удалить «можно сказать», «it could be argued» | Когда есть hedging |
| **4. Structural flatten** | Убрать лишние структурные навороты | Когда bullets перегружены |
| **5. Specificity** | Заменить абстракции числами | Когда мало конкретики (<0.5 факта/абзац) |
| **6. Voice** | Добавить «я»/«мы»/«I»/«we» | Когда нет авторского голоса |
| **7. Discourse** | Убрать «Furthermore», «Moreover» | Когда есть AI-коннекторы |
| **8. Punctuation** | Em-dash ≤ 1 на 300 слов | Когда em-dash > нормы |
| **9. RLHF strip** | Убрать polite hedging, balanced framing | Когда есть «Great question!», «I hope this helps» |

**Lexicon** для запрещённых слов: [`references/lexicon.md`](https://github.com/11111000000/agents-writing-skills/blob/main/skills/humanize-writer/references/lexicon.md).

**Пример STRIP:**

```diff
- Мы предоставляем современное решение, которое обеспечивает эффективное
- управление задачами, способствуя повышению производительности команды.
+ Genium Tasks — CLI для тех, кому надоело вести задачи в Notion. Один бинарь,
+ конфиг в ~/.config/genium/tasks.toml, и задачи живут в git вместе с кодом.
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

#### 10.2. Strunk cut-test

> Удалите любое предложение. Смысл потерялся? Если нет — навсегда удалите.

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
+ Дедлайн нереальный. Код не закрыт, тесты не гоняли. Сдвигаем на неделю.
```

Word count: 32 → 12 (−63%). Смысл сохранён.

### Phase RELY (Lever 11) — доверяй читателю

> **Цель:** оставить пробелы, которые читатель заполнит сам. Hemingway iceberg.

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

---

## PASS 3 — VERIFY (финальные проверки)

> [!tip] Когда применять
> После Pass 2. Перед публикацией.

### 3.1. Bias substitution check

> [!warning] Critical (Lamparth et al. 2026)
> Single-axis mitigation переносит bias на другие proxies. После Tighten pass проверьте, что **не потеряли факты**.

```python
def check_bias_substitution(original: str, rewritten: str) -> dict:
    """Сравнить количество конкретных фактов до и после."""

    facts_original = extract_facts(original)  # числа, имена, команды, пути
    facts_rewritten = extract_facts(rewritten)

    lost = facts_original - facts_rewritten
    loss_pct = len(lost) / len(facts_original) * 100

    if loss_pct > 10:
        return {"status": "FAIL", "lost_facts": lost, "loss_pct": loss_pct}

    return {"status": "PASS", "loss_pct": loss_pct}
```

### 3.2. Final density check

```yaml
final_check:
  AP: <1                  # target
  D: <7                   # RU only
  E: <3                   # global
  YapScore: 1.0–1.5       # global
  V: <5%                  # vacuum-filling
  R: <10%                 # restatement chains
  B: <5%                  # bridging
  loss_pct_facts: <10%    # bias substitution
```

### 3.3. Read aloud test

Прочитайте текст вслух. Если звучит как:
- ❌ пресс-релиз LinkedIn → переписать
- ❌ marketing landing → переписать
- ❌ Wikipedia article → переписать
- ✅ normal human speech / post / email — OK

### 3.4. Если VERIFY не проходит

Вернитесь к Pass 2. Не начинайте с нуля — найдите конкретную проблему.

```yaml
verify_failure:
  issue: YapScore 2.3
  location: para_3
  action: return_to_pass_2_phase_TIGHTEN
```

---

## Multi-language support

| Регистр | RU | EN |
|---|---|---|
| Conversational | Levers 1-12, кроме Lever 11 | Levers 1-9, 11 |
| Blog | Levers 1-12 | Levers 1-11 |
| Email коллеге | Levers 1-9, 11, 12 (без эллипсиса) | Levers 1-9, 11 |
| README | Levers 1-9 | Levers 1-9 |
| Marketing | Только Lever 9 (RLHF strip) | Только Lever 9 |
| Technical reference | Никакие (нужна точность) | Никакие |

---

## Workflow (legacy — v3-style, оставлен для совместимости)

> [!note] Legacy 7-step workflow
> Следующие шаги эквивалентны Pass 1-3 архитектуре выше, но описаны линейно.

### Step 1 — Pre-flight (Pass 1, частично)
4 вопроса: voice, lead, numbers ready?, sufficiency budget.

### Step 2 — Draft
Draft full text, monitor: burstiness, деепричастия, em-dash count, я/мы.

### Step 3 — Audit pass (Pass 1)
Per-paragraph checks: concrete detail, sentence length diff, banned lexicon, triple-parallel, abstract sentence.

### Step 4 — Tighten pass (Pass 2, TIGHTEN)
8 scans + Strunk cut-test + Williams 6 operations.

### Step 5 — Rupture pass (Pass 2, RELY)
Insert rupture if smooth, or silence (Lever 11).

### Step 6 — Trust-the-reader pass (Pass 2, RELY)
Reader-fill test, distinctive-word test.

### Step 7 — Density check (Pass 3)
Count per 1000 words: AP, D, E, V, R, B.

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

Если пользователь просит audit или diagnosis — переключись на `anti-ai-auditor`.

---

## Companion skills

- `humanize-editor` — для переписывания существующего текста (3-pass audit → rewrite → verify)
- `anti-ai-auditor` — для диагностики без переписывания
- `ai-pattern-rewriter` — для хирургических правок specific spans

---

## See also

Knowledge base:
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
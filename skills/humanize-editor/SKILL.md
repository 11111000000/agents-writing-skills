---
name: humanize-editor
description: Rewrite existing text (yours or someone else's) so it stops reading like LLM output. Use when the user pastes text that came from ChatGPT, GPT, Claude, Gemini, or any AI assistant and wants it to read human. Also use when a first draft from a sub-agent sounds "too polished", "AI-ish", "too long", or "verbose". Do NOT use for code, structured data, or text where the user explicitly wants AI-style uniformity.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-rewriting
  version: 7
---

# Humanize-Editor (v7)

Rewrite existing text so it stops reading like LLM output. v7 keeps the **3-pass architecture** and shifts the goal from «убрать AI-маркеры» к **редактуре с сохранением смысла**: режимы правки (proofread/light/style/deep), нулевая потеря утверждений по умолчанию вместо порогов 10/20%, RELY — условная фаза только для style/deep.

> [!info] Changelog v7
> - Режимы правки: `proofread` / `light` / `style` / `deep` — выбираются в PASS 1.
> - Bias substitution: вместо порогов потери 10/20% — проверка **каждого утверждения**; потеря смысла по умолчанию = 0.
> - Запрещено выдумывать числа, имена, даты, личный опыт, причины. Не хватает факта → `[нужен факт: ...]`.
> - RELY (iceberg-удаления) — только в режимах style/deep для художественного/разговорного регистра, никогда по умолчанию.
> - Первое лицо, rupture, конкретика — условные приёмы («если уместно регистру и есть во входных данных»), не обязательные.
> - Если редактура не улучшает текст — вернуть исходник и сказать об этом.

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). For offline: `./scripts/install-knowledge.sh`.

> [!warning] Bias substitution (Lamparth et al. 2026)
> Single-axis сокращение может перенести bias на factual depth. **Tighten pass сохраняет плотность фактов, не только сокращает слова.**

## Архитектура: 3-проходный процесс

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: AUDIT (diagnose what to fix)                           │
│   Output: список проблем + режим правки + выбор voice profile  │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: REWRITE (объём зависит от режима)                      │
│   Step 3: voice profile selection                              │
│   Step 4: STRIP phase (Levers 1-9)                             │
│   Step 4.5: TIGHTEN phase (Lever 10 + per-claim verify)         │
│   Step 5: RELY phase (Lever 11 — только style/deep, по триггеру)│
│   Step 5.5: REBUILD phase (Lever 12, RU only)                  │
│   Step 6: rupture / silence (если уместно)                     │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: VERIFY (per-claim смысл, density, read aloud)          │
└────────────────────────────────────────────────────────────────┘
```

## When to load

- AI-generated text needs to read human
- Sub-agent's draft too smooth / too long
- Russian text needs русские грамматические приёмы
- User wants to clean up a draft before publishing

## Hard rules

> [!warning] Meaning contract (v7)
> **Сохраняются:** утверждения, числа и их отношения, условия, исключения, отрицания, модальность («может» ≠ «точно»), терминология, цитаты, регистр формальности.
> **Запрещено:** выдуманные числа/имена/даты, выдуманный личный опыт, усиление уверенности, выдуманные причины.
> **Потеря смысла по умолчанию: НОЛЬ** (не 10%). Удаление — только явных дубликатов и пустых фраз.
> **Если утверждению не хватает факта:** оставить как есть, удалить (если пустое) или пометить `[нужен факт: ...]`. Никогда не выдумывать число или пример.
> **Если редактура не улучшает текст** — вернуть исходник почти без изменений и сказать об этом. Уже хороший текст — валидный результат.

> [!warning] Meaning preservation
> - **Preserve factual content** — names, numbers, dates, claims, citations. Don't drop or invent. **Especially в Tighten pass** — сохраняйте плотность фактов (Lamparth et al. 2026).
> - **Preserve language** — input in RU stays RU, input in EN stays EN. Don't translate.
> - **Length change allowed** — Tighten pass может сократить на 15–30%, потому что LLM выдаёт в 1.5–2× больше нужного (YapBench, arXiv 2601.00624). Сокращение ≠ потеря утверждений: режется вода, не факты.

> [!warning] Style overhaul
> Apply **12 levers** + Russian extensions, organized in 4 phases (объём применения зависит от режима правки, см. Step 1.5):
>
> **STRIP phase (Levers 1-9):**
> 1. Banned lexicon — `references/lexicon.md`
> 2. Burstiness — vary sentence lengths
> 3. Strip RLHF voice (Lever 9) — polite hedging, balanced framing (компромиссы)
> 4. Strip negative parallelisms (P9)
> 5. Strip hedging — **но не модальность**: «может сломаться» ≠ «сломается»
> 6. Strip pairing (RU) — "цели и задачи" → pick one
> 7. Strip деепричастия (RU) — для conversational/technical: ≤1 per paragraph;
>    для literary prose: **target 14-30/1000 слов (НЕ снижать до 7)** — см. эмпирическую калибровку в `knowledge/02-Techniques/metric-validation.md`
> 8. Em-dash discipline — EN: ≤1 per 300 words; **RU: 0 em-dash в LLM-тексте — сильный AI-сигнал**, литературная проза использует 5-23/300 слов — норма
>
> **TIGHTEN phase (Lever 10):**
> 9. Concrete — **если во входных данных есть числа/имена**, вытащить их на первый план. Если нет — пометить `[нужен факт: ...]`, не выдумывать
> 10. First person — добавить `я`/`мы`/`I`/`we` **только если уместно регистру** и не создаёт выдуманный личный опыт
> 11. No closing cliché — drop `таким образом`, `in conclusion`
> 12. Structural flatten — convert bullet lists to prose
> 13. Sufficiency (Lever 10) — Strunk cut-test + Williams 6 operations
>
> **RELY phase (Lever 11) — условная, только style/deep:**
> 14. Trust the reader — iceberg-пробелы, удалить over-explanation
>
> **REBUILD phase (Lever 12, RU only):**
> 15. Russian brevity grammar — парцелляция, эллипсис, литота, нулевая связка
>
> **Antipatterns (cross-phase):**
> 16. Strip over-generation (P-NEW-1…P-NEW-7) — vacuum-filling, restatement chains, bridging, antithetical recap
> 17. Strip new patterns (P-NEW-13…20) — False Agency, Argument Residue, Asyndeton Tricolon, Mini-Aphorism Closer, Hedged-Enumeration Openers. See [`knowledge/01-Patterns/catalogue-update.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/catalogue-update.md).

---

## PASS 1 — AUDIT (Step 1-2)

### Step 1 — Audit the input

Scan for 43-pattern hits + over-generation + length bias. Report 3–6 bullets:

```yaml
audit:
  negative_parallelism_density: 5.2      # AP — flag if > 3
  yap_score_estimate: 1.8                 # 1.5–2.0 = flag, 2.0+ = critical
  vacuum_filling_count: 3
  restatement_chains: 1
  bridging_phrases_at_para_starts: 2
  antithetical_recaps: 1
  format_bias:
    emojis: 4
    bold_pct: 8
    triple_parallel_lists: 2
  burstiness:
    mean_sentence_length: 18
    std: 2.4                              # low if < 3
  specificity:
    concrete_facts_per_para: 0.4         # low if < 0.5
  voice:
    first_person: false
    opinion: false
  recommendations:
    - run_tighten_pass: true
    - run_rebuild_pass_ru: false        # not Russian
    - estimated_reduction: "30-40%"
```

### Step 1.5 — Выбор режима правки

Определить режим **до** начала правок. Если пользователь указал режим явно — использовать его. Иначе выбрать по типу текста и сказать, какой выбран.

| Режим | Что делает | Когда |
|---|---|---|
| `proofread` | Только грамматика, опечатки, пунктуация. Смысл и стиль не трогаем | юридический текст, цитаты, «просто вычитай» |
| `light` | proofread + banned lexicon + closing cliché + явные дубликаты | черновик уже почти хорош, авторский голос важен |
| `style` | light + STRIP + TIGHTEN + условные rupture/first person | дефолт для блогов, постов, деловых писем |
| `deep` | style + RELY + REBUILD (RU) + перестройка структуры | художественный/разговорный регистр, «сделай максимально живо» |

**Умолчания:** если неясно — `light`, не `deep`. RELY-фаза (iceberg-удаления) запускается **только** в `style`/`deep` и **только** для художественного/разговорного регистра — никогда по умолчанию, никогда для технического/делового/юридического текста.

**Если текст уже хорош** (audit показывает 0–1 проблему) — разрешено и правильно вернуть его почти без изменений и сказать об этом прямо.

### Step 2 — Pick voice profile

| Profile | Когда | Примеры |
|---|---|---|
| `casual` | blog, social, community | contractions, fragments, "And" starters |
| `professional` | business, formal | dry wit, concrete examples |
| `technical` | API docs, READMEs | precise terms, deadpan humor |
| `warm` | tutorials, support | "we/our", empathy |
| `blunt` | reviews, internal comms | shortest sentences, no hedging |
| `laconic` | expert readers, internal | minimal, trust-the-reader |

---

## PASS 2 — REWRITE (Step 3-6)

### Step 3 — Voice profile application

Применить выбранный voice profile. Не менять смысл, только тон.

### Step 4 — STRIP phase + TIGHTEN phase

#### 4.1. STRIP scans

Применить Levers 1-9. Не добавлять ничего, только удалять.

#### 4.2. TIGHTEN scans (8 проходов)

```python
TIGHTEN_SCANS = [
    "vacuum_filling",       # P-NEW-1
    "restatement",          # P-NEW-2
    "bridging",             # P-NEW-3
    "over_explanation",     # P-NEW-4
    "anticipatory_hedging", # P-NEW-5
    "balanced_framing",     # P-NEW-6
    "antithetical_recap",   # P-NEW-7
    "strunk_cut_test",      # удали любое предложение, смысл выжил?
]
```

После каждого сканирования — конкретное действие. Не «оставить», а удалить.

#### 4.3. Williams 6 operations (финальный проход TIGHTEN)

```python
def williams_6(text):
    return text \
        .delete_meaningless("in order to", "the fact that", "absolutely essential") \
        .delete_redundant("they are both alike" → "they are alike") \
        .delete_implied(no need for "absolutely" before "essential") \
        .phrase_to_word("is able to" → "can", "has the ability to" → "can") \
        .negatives_to_affirm("did not remember" → "forgot") \
        .delete_useless_adj("absolutely essential", "completely unanimous")
```

#### 4.4. Per-claim verification (v7 — замена порогам 10/20%)

> [!warning] Critical (Lamparth et al. 2026)
> После TIGHTEN phase проверяем, что **не потеряли факты**. Потеря по умолчанию — НОЛЬ: порогов «можно потерять 10%» больше нет.

Проверка идёт по каждому утверждению, не по проценту:

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
    """Каждое утверждение: числа, условия, исключения, отрицания, модальность, цитаты."""
    # Разбить на предложения; для каждого зафиксировать:
    # - факты (extract_facts)
    # - модальность: может/возможно/might ≠ точно/will
    # - отрицания: не/no/never
    # - условия: если/при/если только
    # - цитаты и термины
    ...

def check_claims_preserved(original, rewritten):
    """Нулевая потеря по умолчанию. Каждое утверждение оригинала должно
    сохраниться в правке — с теми же числами, условиями, модальностью."""
    lost_facts = extract_facts(original) - extract_facts(rewritten)
    invented_facts = extract_facts(rewritten) - extract_facts(original)
    lost_claims = [c for c in extract_claims(original)
                   if not claim_survives(c, rewritten)]
    # Допустимые исключения: явные дубликаты и пустые фразы
    # ("важно отметить", "как мы видим") — их удаление не считается потерей.
    return {
        "status": "FAIL" if (lost_facts or invented_facts or lost_claims) else "PASS",
        "lost_facts": list(lost_facts),
        "invented_facts": list(invented_facts),   # выдуманные числа/имена = FAIL
        "lost_claims": lost_claims,
        "action": "Restore lost, remove invented" if lost_facts or invented_facts or lost_claims else "Proceed",
    }
```

Если `status == "FAIL"` — восстановить потерянные утверждения, удалить выдуманные факты, пересмотреть сокращение. Выдуманное число/имя/дата в правке — провал наравне с потерянным.

### Step 5 — RELY phase (Lever 11) — условная фаза

> [!warning] Триггер запуска
> RELY запускается **только** если одновременно:
> 1. Режим правки — `style` или `deep` (см. Step 1.5);
> 2. Регистр текста — художественный или разговорный (пост, эссе, колонка).
>
> Для технического, делового, юридического, академического текста RELY **не запускается никогда** — iceberg-пробелы там теряют условия и оговорки. В режимах `proofread`/`light` — тоже нет. При сомнении — не запускать.

#### 5.1. Reader-fill test

Удалите абзац. Читатель может продолжить мысль без него? Если да — удалите.

#### 5.2. Distinctive-word test

Если в предложении нет ни одного слова, добавляющего новую информацию, — удалите его.

#### 5.3. Stop at the turn

Если в абзаце есть «поворотный момент» — остановитесь на нём. Точка.

### Step 5.5 — REBUILD phase (Lever 12, RU only)

> [!warning] Только для русского текста
> В разговорном, постовом, беллетристическом регистрах. НЕ в официально-деловом, юридическом, дипломатическом.

#### 5.5.1. Парцелляция (расщепление)

Найти сложные предложения с деепричастиями или 3+ однородными сказуемыми. Разбить на 2-5 коротких.

```diff
- Город стоит на реке, обеспечивая водоснабжение, способствуя развитию
- сельского хозяйства и формируя микроклимат.
+ Город стоит на реке. Отсюда — водоснабжение и полив.
```

#### 5.5.2. Эллипсис (гэппинг, стриппинг, фрагментирование)

Найти повтор глагола/существительного во второй части сложносочинённого предложения. Опустить.

```diff
- Я говорю по-английски, а он говорит по-немецки.
+ Я говорю по-английски, а он — по-немецки.
```

#### 5.5.3. Литота (преуменьшение)

Найти абстрактные преуменьшения. Заменить готовой формулой.

```diff
- У нас совсем немного пользователей.
+ У нас пользователей — кот наплакал.
```

#### 5.5.4. Нулевая связка (разговорный/постовый регистр)

```diff
- Я пошёл в магазин, чтобы купить хлеб.
+ Пошёл в магазин. Хлеб.
```

### Step 6 — Rupture / silence (Pass 2 завершение) — условный приём

Если переписанный текст **по-прежнему** звучит слишком гладко **и это уместно регистру**, можно добавить rupture:
- one-line aside
- question
- blunt opinion
- concrete number — **только из входных данных**, не выдуманный
- **silence** (Lever 11 — sometimes the right move is nothing)

Rupture не обязателен. Нет «одной разрывной фразы на 200 слов»: если текст звучит по-человечески без неё — ничего не добавлять. Если редактура в целом не улучшает текст — вернуть исходник и сказать об этом.

---

## PASS 3 — VERIFY (Step 7)

### Step 7 — Final verification

```yaml
final_check:
  meaning_contract:
    status: PASS  # или FAIL
    lost_claims: []
    invented_facts: []      # выдуманные числа/имена = FAIL
    modality_preserved: true
  density:
    AP: 0.8
    D: 4.2
    E: 1.1
    YapScore: 1.3
    V: 2.0
    R: 5.0
    B: 0
  voice:
    first_person: "if appropriate"   # условно, не обязательно
    opinion: "if appropriate"
    concrete_facts: 12               # только из входных данных
  read_aloud:
    verdict: PASS
    issues: []
```

**Read aloud mental check:**
- Если звучит как пресс-релиз, LinkedIn, marketing landing — fix.
- Если звучит как normal human speech / post / email — OK.

**If VERIFY не проходит:**
```yaml
verify_failure:
  issue: YapScore 2.3
  location: para_3
  action: return_to_pass_2_phase_TIGHTEN
```

Не начинайте с нуля — найдите конкретную проблему.

---

## When NOT to rewrite

- Code, configs, schemas — uniformity is fine
- Mathematical proofs, formal definitions — precision > voice
- Legal text — clarity > style; only soften if explicitly asked
- Academic text — expected scientific register shares patterns with AI
- Political/diplomatic text in Russian — официально-деловой стиль legitimately uses em-dash, деепричастия, канцелярит
- Text that legitimately uses an antithesis as rhetoric — keep it. Antithesis is a 2000-year-old figure.
- User said "leave it as is"

---

## Output format

Two-block output:

```markdown
## Audit
- режим правки: light (выбран автоматически, т.к. ...)
- 3-6 bullets diagnosis (Pass 1)

## Rewritten
<the text>  (Pass 2 + Pass 3)
```

Если текст уже хорош и правки не нужны:

```markdown
## Audit
- текст уже читается по-человечески, проблем не найдено

## Rewritten
<исходный текст почти без изменений>
```

If user only wants the rewritten text, give only that.

---

## Companion skills

- `humanize-writer` — for greenfield writing (3-pass)
- `anti-ai-auditor` — for diagnosis without rewriting (3-pass metrics)
- `ai-pattern-rewriter` — for surgical span fixes (3-pass surgical)

---

## See also

- Knowledge base:
  - [`02-Techniques/sufficiency-and-underspecification.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/sufficiency-and-underspecification.md)
  - [`02-Techniques/length-bias-research.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/length-bias-research.md)
  - [`02-Techniques/russian-brevity-grammar.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md)
  - [`01-Patterns/rhetorical/negative-parallelisms.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/rhetorical/negative-parallelisms.md)
  - [`01-Patterns/structural/over-generation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/structural/over-generation.md)
  - [`04-Examples/before-after.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/before-after.md) and [`before-after-ru-advanced.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/before-after-ru-advanced.md)
- [`05-References/limits-and-self-critique.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/05-References/limits-and-self-critique.md)
- [`references/lexicon.md`](https://github.com/11111000000/agents-writing-skills/blob/main/skills/humanize-writer/references/lexicon.md)
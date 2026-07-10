---
name: humanize-editor
description: Rewrite existing text (yours or someone else's) so it stops reading like LLM output. Use when the user pastes text that came from ChatGPT, GPT, Claude, Gemini, or any AI assistant and wants it to read human. Also use when a first draft from a sub-agent sounds "too polished", "AI-ish", "too long", or "verbose". Do NOT use for code, structured data, or text where the user explicitly wants AI-style uniformity.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-rewriting
  version: 6
---

# Humanize-Editor (v6)

Rewrite existing text so it stops reading like LLM output. v6 keeps the **3-pass architecture** matching `humanize-writer`, with explicit bias substitution check (Lamparth et al. 2026), Russian grammar pass, and laconic prose models for RU text.

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). For offline: `./scripts/install-knowledge.sh`.

> [!warning] Bias substitution (Lamparth et al. 2026)
> Single-axis сокращение может перенести bias на factual depth. **Tighten pass сохраняет плотность фактов, не только сокращает слова.**

## Архитектура: 3-pass workflow

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: AUDIT (diagnose what to fix)                           │
│   Output: список проблем + выбор voice profile                │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: REWRITE                                                │
│   Step 3: voice profile selection                              │
│   Step 4: STRIP phase (Levers 1-9)                             │
│   Step 4.5: TIGHTEN phase (Lever 10 + bias substitution check)  │
│   Step 5: RELY phase (Lever 11)                                │
│   Step 5.5: REBUILD phase (Lever 12, RU only)                  │
│   Step 6: rupture / silence                                    │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: VERIFY (bias substitution, density, read aloud)        │
└────────────────────────────────────────────────────────────────┘
```

## When to load

- AI-generated text needs to read human
- Sub-agent's draft too smooth / too long
- Russian text needs русские грамматические приёмы
- User wants to clean up a draft before publishing

## Hard rules

> [!warning] Meaning preservation
> - **Preserve factual content** — names, numbers, dates, claims, citations. Don't drop or invent. **Especially в Tighten pass** — сохраняйте плотность фактов (Lamparth et al. 2026).
> - **Preserve language** — input in RU stays RU, input in EN stays EN. Don't translate.
> - **Length change allowed** — Tighten pass может сократить на 15–30%, потому что LLM выдаёт в 1.5–2× больше нужного (YapBench, arXiv 2601.00624).

> [!warning] Style overhaul
> Apply **12 levers** + Russian extensions, organized in 4 phases:
>
> **STRIP phase (Levers 1-9):**
> 1. Banned lexicon — `references/lexicon.md`
> 2. Burstiness — vary sentence lengths
> 3. Strip RLHF voice (Lever 9) — polite hedging, balanced tradeoffs
> 4. Strip negative parallelisms (P9)
> 5. Strip hedging
> 6. Strip pairing (RU) — "цели и задачи" → pick one
> 7. Strip деепричастия (RU) — ≤1 per paragraph
> 8. Em-dash discipline — ≤1 per 300 words
>
> **TIGHTEN phase (Lever 10):**
> 9. Concrete — replace abstract claims with numbers
> 10. First person — add `я`/`мы`/`I`/`we` once if missing
> 11. No closing cliché — drop `таким образом`, `in conclusion`
> 12. Structural flatten — convert bullet lists to prose
> 13. Sufficiency (Lever 10) — Strunk cut-test + Williams 6 operations
>
> **RELY phase (Lever 11):**
> 14. Trust the reader — iceberg-пробелы, удалить over-explanation
>
> **REBUILD phase (Lever 12, RU only):**
> 15. Russian brevity grammar — парцелляция, эллипсис, литота, нулевая связка
>
> **Antipatterns (cross-phase):**
> 16. Strip over-generation (P-NEW-1…P-NEW-7) — vacuum-filling, restatement chains, bridging, antithetical recap

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

#### 4.4. Bias substitution check (introduced in v5)

> [!warning] Critical (Lamparth et al. 2026)
> После TIGHTEN phase проверяем, что **не потеряли факты**.

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

def check_bias_substitution(original, rewritten):
    orig_facts = extract_facts(original)
    new_facts = extract_facts(rewritten)
    lost = orig_facts - new_facts
    loss_pct = len(lost) / max(len(orig_facts), 1) * 100

    return {
        "status": "FAIL" if loss_pct > 10 else "PASS",
        "loss_pct": loss_pct,
        "lost_facts": list(lost)[:10],  # для отчёта
        "action": "Restore lost facts" if loss_pct > 10 else "Proceed"
    }
```

Если `status == "FAIL"` — восстановить потерянные факты, пересмотреть сокращение.

### Step 5 — RELY phase (Lever 11)

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

### Step 6 — Rupture / silence (Pass 2 завершение)

If rewritten text still flows too smoothly, insert rupture:
- one-line aside
- question
- blunt opinion
- concrete number
- **silence** (Lever 11 — sometimes the right move is nothing)

---

## PASS 3 — VERIFY (Step 7)

### Step 7 — Final verification

```yaml
final_check:
  bias_substitution:
    status: PASS  # или FAIL
    loss_pct: 5.2
    lost_facts: []
  density:
    AP: 0.8
    D: 4.2
    E: 1.1
    YapScore: 1.3
    V: 2.0
    R: 5.0
    B: 0
  voice:
    first_person: true
    opinion: true
    concrete_facts: 12
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
- 3-6 bullets diagnosis (Pass 1)

## Rewritten
<the text>  (Pass 2 + Pass 3)
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
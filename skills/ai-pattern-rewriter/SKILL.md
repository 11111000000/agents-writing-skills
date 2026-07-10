---
name: ai-pattern-rewriter
description: Surgical, line-level rewriting of specific AI-pattern phrases. Use when the user identifies a small number of specific phrases or sentences that read "too AI" or "too long" and wants targeted fixes, not a full rewrite. Different from humanize-editor: this preserves structure and only changes flagged spans.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: surgical-edit
  version: 6
---

# AI-Pattern Rewriter (v6)

Surgical, span-level rewriting. **Only** rewrite the specific phrases the user flagged (or that you can clearly identify as AI-pattern spans). Preserve everything else. v6 keeps the **3-pass surgical architecture** (Identify → Rewrite → Verify) and adds laconic RU rewrite models for short, concrete replacements.

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). For offline: `./scripts/install-knowledge.sh`.

## Архитектура: 3-pass surgical

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: IDENTIFY (find the specific span)                     │
│   Output: exactly which lines need rewording                  │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: REWRITE (apply minimal-change fix)                     │
│   Output: 1 alternative per span, no commentary               │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: VERIFY (bias substitution check + length sanity)       │
│   Output: confirmed span change                               │
└────────────────────────────────────────────────────────────────┘
```

## When to load

- User says "перепиши только это предложение" / "fix just this paragraph"
- User has marked specific spans with `>>` or `!!!`
- User is editing themselves and just wants targeted suggestions
- User wants to keep the rest exactly as is
- User asks "сократи вот это" / "это слишком длинно"

## When NOT to load

- User wants a full rewrite → use `humanize-editor`
- User wants only diagnosis → use `anti-ai-auditor`
- User wants greenfield writing → use `humanize-writer`

---

## Hard rules

1. **Touch only the flagged spans.** If the user said "only line 7", do not edit line 12 even if it has issues.
2. **Preserve meaning** of the rewritten span exactly.
3. **Preserve surrounding tone** — don't make the rewritten span either more or less formal than its neighbors.
4. **Single rewrite per span** — show one alternative, not three. If the user wants options, they will ask.
5. **No commentary outside the rewrite** unless asked. Don't explain the change unless asked.
6. **NEW v5**: When applying over-generation rewrites, it's OK to **delete** rather than rewrite — that's often the right answer.

## Bias substitution warning (introduced in v5)

> [!warning] Critical (Lamparth et al. 2026)
> При сокращении span'а проверьте, что **не потеряли факты внутри span'а** (числа, имена, команды, пути).

Перед применением tight-rewrite:

```python
def check_span_bias_substitution(original_span, rewritten_span):
    orig_facts = extract_facts(original_span)
    new_facts = extract_facts(rewritten_span)
    lost = orig_facts - new_facts
    return {
        "lost_facts": list(lost),
        "verdict": "FAIL" if lost else "PASS"
    }
```

Если `verdict == "FAIL"` — restore facts, choose alternative rewrite or partial deletion.

---

## PASS 1 — IDENTIFY

### Step 1 — Find the span

Три способа:

**A. User-flagged:** user прямо указал span (`>>это предложение<<` или «вот это»).

**B. Pattern-flagged:** scan against known patterns:

```python
PATTERNS = {
    "delve_into": r"\b(delve into|delve deeper|dive deep(?:er)? into)\b",
    "negative_parallelism_ru": r"это\s+не\s+[А-Яа-я]+,?\s+(?:а|это|скорее)\s+[А-Яа-я]+",
    "vacuum_filling_ru": r"^(У нас в команде|В текущей работе|Стоит отметить|Необходимо подчеркнуть)",
    "bridging_ru": r"^(Как упоминалось выше|Это подводит нас к|В свою очередь)",
    "antithetical_recap": r"^(Итак, мы рассмотрели|Таким образом|Let's summarize)",
}
```

**C. Self-flag:** если пользователь говорит «перепиши только эти абзацы» — flagged.

---

## PASS 2 — REWRITE

### Step 2 — Apply minimal fix

#### Common AI patterns and how to rewrite

##### Lexical cliches

```diff
# delve into
- "Let's delve into the architecture."
+ "Architecture: 3 services, Kafka between them."

# leverage
- "We leverage modern technologies to ensure robust performance."
+ "We use modern tech. Performance: p99 14ms."

# "стоит отметить"
- "Стоит отметить, что API имеет rate limits."
+ "API: 100 req/min на free tier."

# "Более того"
- "Система быстрая. Более того, она масштабируемая."
+ "Система быстрая — p99 14 мс. Масштабируется: 5k RPS."
```

##### Structural patterns

```diff
# Triple-parallel list
- "- Fast
   - Reliable
   - Secure"
+ "- 14 ms p99.
   - 99.99% uptime за квартал.
   - Тесты на каждом merge."

# Abstract adjective + noun
- "Это эффективное решение."
+ "Это решение сократило время обработки с 4 сек до 200 мс."

# Hedging
- "Возможно, стоит рассмотреть использование кеширования."
+ "Нужен кеш — без него каждый запрос лезет в Postgres, 2k req/s вместо 5k."
```

##### Closing cliches

```diff
# "Таким образом, мы рассмотрели три подхода."
- (cliche closing)
+ (cut entirely, or "Из всех трёх я бы выбрал B — но A проще, если у вас уже есть Redis.")

# "I hope this helps!"
- (chatbot artifact)
+ (cut entirely)
```

#### Over-generation spans (introduced in v5)

> [!info] Для каждого паттерна: часто правильный ответ — **удалить**, а не переписать.

```diff
# Vacuum-filling opener (P-NEW-1)
- "У нас в команде возник вопрос по дедлайну. После обсуждения мы пришли к выводу, что дедлайн нужно перенести."
+ "Дедлайн нереальный. Сдвигаем."

# Restatement chain (P-NEW-2)
- "API стал работать быстрее. Оптимизация позволила сократить время отклика. Производительность улучшилась значительно."
+ "API стал отвечать за 14 мс вместо 380."

# Bridging phrase (P-NEW-3)
- "Как упоминалось выше, кеш важен. Это подводит нас к следующей теме — инвалидации кеша."
+ "Кеш важен. Инвалидация — TTL 60 сек, плюс ручной cache.del(key)."

# Over-explanation (P-NEW-4)
- "Чтобы установить библиотеку, вам нужно выполнить команду pip install. Команда pip install — это стандартный способ установки Python-пакетов."
+ "pip install foo"
# или удалить объяснение "Команда pip install — это..."

# Anticipatory hedging (P-NEW-5)
- "Возможно, в некоторых случаях может быть полезно рассмотреть использование кеширования, хотя это зависит от конкретной ситуации."
+ "Нужен кеш. Без него каждый запрос лезет в Postgres."

# Balanced framing (P-NEW-6)
- "У PostgreSQL есть преимущества и недостатки. С одной стороны, он зрелый и проверенный. С другой стороны, его сложнее масштабировать горизонтально. Каждый проект индивидуален."
+ "PostgreSQL хорош, пока не упрётесь в single-writer. У нас упёрлись при 8k req/s."

# Antithetical recap (P-NEW-7)
- "Итак, мы рассмотрели три подхода: A, B, C. Каждый имеет свои плюсы и минусы. Выбор зависит от контекста проекта. Надеюсь, это поможет вам принять решение!"
+ (cut entirely)

# Restated examples
- "Stripe, Datadog и PlanetScale используют этот подход."
+ "Stripe использует этот подход."

# Obvious consequence
- "Мы переписали кеш. Теперь API отвечает быстрее."
+ "Мы переписали кеш."
```

#### Russian brevity grammar spans (Lever 12)

```diff
# Парцелляция
- "Город стоит на реке, обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат."
+ "Город стоит на реке. Отсюда — водоснабжение и полив."

# Эллипсис (гэппинг)
- "Я говорю по-английски, а он говорит по-немецки."
+ "Я говорю по-английски, а он — по-немецки."

# Литота
- "У нас совсем немного пользователей, практически никто не пользуется."
+ "У нас пользователей — кот наплакал."

# Нулевая связка (разговорный регистр)
- "Я пошёл в магазин, чтобы купить хлеб."
+ "Пошёл в магазин. Хлеб."
```

#### Williams 6 operations

```diff
# 1. Meaningless
- "in order to install"
+ "to install"

# 2. Redundant
- "they are both alike"
+ "they are alike"

# 3. Implied
- "absolutely essential"
+ "essential"

# 4. Phrase → word
- "is able to"
+ "can"

# 5. Negative → affirmative
- "did not remember"
+ "forgot"

# 6. Useless adj
- "completely unanimous"
+ "unanimous"
```

---

## PASS 3 — VERIFY

### Step 3 — Verify the rewrite

```yaml
verify:
  bias_substitution:
    status: PASS              # or FAIL
    lost_facts: []
  length_sanity:
    reduction_pct: 30         # or whatever
    still_meaningful: true
  tone_match:
    same_register: true
    same_formality: true
  diff_size:
    acceptable: true          # < 50% of span length changed
```

If `bias_substitution.status == "FAIL"` — restore facts or choose alternative rewrite.

---

## Output format

**Default (surgical):**

```
<rewritten span, in place>
```

If context makes this unclear, return:

```
Original: <span>
Rewritten: <span>
```

For over-generation rewrites, indicate if the span was deleted rather than rewritten:

```
Original: "..."
Action: deleted
```

If the user asked for alternatives (they will say so), provide 2-3 options.

---

## Constraints to honor

- **Length** — don't expand unless asked. Default: keep new span within ±20% of old span's length. **NEW v5**: for over-generation rewrites, **deletion is preferred over compression** — if 50% of the span can be cut, cut it.
- **Tone** — match neighbors. If surrounding text is formal, rewrite formally. If informal, match.
- **Domain vocabulary** — keep domain terms. Don't `Python` → `язык Python` or similar.
- **Bias substitution check** — don't lose facts when shortening.

---

## Companion skills

- `humanize-writer` — for greenfield (3-pass)
- `humanize-editor` — for full rewrites (3-pass + bias substitution)
- `anti-ai-auditor` — if user is unsure what to flag (3-pass audit)

---

## See also

- Knowledge base:
  - [`04-Examples/before-after.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/04-Examples/before-after.md)
  - [`02-Techniques/sufficiency-and-underspecification.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/sufficiency-and-underspecification.md)
  - [`01-Patterns/structural/over-generation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/structural/over-generation.md)
  - [`02-Techniques/russian-brevity-grammar.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md)
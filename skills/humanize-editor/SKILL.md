---
name: humanize-editor
description: Rewrite existing text (yours or someone else's) so it stops reading like LLM output. Use when the user pastes text that came from ChatGPT, GPT, Claude, Gemini, or any AI assistant and wants it to read human. Also use when a first draft from a sub-agent sounds "too polished", "AI-ish", "too long", or "verbose". Do NOT use for code, structured data, or text where the user explicitly wants AI-style uniformity.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-rewriting
  version: 4
---

# Humanize-Editor (v4)

Rewrite existing text so it stops reading like LLM output. **Post-hoc** — input already exists, preserve meaning, kill AI tells. v4 integrates **11 levers** (1–11, добавив Lever 12 = Russian brevity grammar), **43-pattern catalogue from Aboudjem**, **Russian-specific patterns from Wikipedia RU**, **length bias research (Park, Shen, Zhang, Lamparth, Huang)**, и **HC3 + RAID datasets для валидации**.

## When to load

- User pastes AI-generated text and wants it rewritten for human feel
- Sub-agent's first draft is too smooth
- **Text is too long / verbose** — applies Tighten pass (Lever 10)
- **Russian text needs русские грамматические приёмы** (парцелляция, эллипсис, литота) — v4
- User wants to clean up a draft before publishing

## Hard rules

> [!warning] Meaning preservation
> - **Preserve factual content** — names, numbers, dates, claims, citations. Don't drop or invent. **Especially in Tighten pass** — сохраняйте плотность фактов, не только сокращайте слова (Lamparth et al. 2026: bias substitution).
> - **Preserve language** — input in RU stays RU, input in EN stays EN. Don't translate.
> - **Length change allowed**: Tighten pass может сократить на 15–30%, потому что LLM обычно выдаёт в 1.5–2× больше нужного (YapBench, arXiv 2601.00624). Если пользователь явно сказал «не сокращай» — не сокращай.

> [!warning] Style overhaul
> Apply **12 levers** + Russian extensions:
>
> 1. **Banned lexicon** — `references/lexicon.md` (RU+EN, 43 patterns + 7 over-generation patterns + Russian brevity grammar examples).
> 2. **Burstiness** — vary sentence lengths.
> 3. **Strip RLHF voice** (Lever 9) — remove polite hedging, balanced tradeoffs, "I hope this helps", "Надеюсь, это пригодится".
> 4. **Strip negative parallelisms** (P9) — `это не X, а Y` / `it's not X, it's Y` / `это не просто X` — **HIGHEST LEVERAGE**, #1 AI marker.
> 5. **Strip hedging** — kill `можно сказать`, `it could be argued`, etc.
> 6. **Strip pairing** (RU) — "цели и задачи" → pick one.
> 7. **Strip деепричастия** (RU) — keep ≤1 per paragraph.
> 8. **Em-dash discipline** — ≤1 per 300 words.
> 9. **Concrete** — replace abstract claims with numbers.
> 10. **First person** — add `я`/`мы`/`I`/`we` once if missing.
> 11. **No closing cliché** — drop `таким образом`, `in conclusion`.
> 12. **Structural flatten** — convert bullet lists to prose where 2–3 sentences would do.
> 13. **Sufficiency (Lever 10)** — cut-test, удалить всё, что больше нужного. Grice submaxim 2.
> 14. **Trust the reader (Lever 11)** — iceberg-пробелы, удалить over-explanation.
> 15. **Strip over-generation (P-NEW-1…P-NEW-7)** — vacuum-filling, restatement chains, bridging, antithetical recap.
> 16. **Russian brevity grammar (Lever 12)** — NEW v4: парцелляция, эллипсис, литота, нулевая связка как русские грамматические инструменты краткости. См. `~/Desktop/AgentWritingBase/02-Techniques/russian-brevity-grammar.md`.

## Workflow

### Step 1 — Audit the input

Scan for 43-pattern hits. Report 3–6 bullets to user with:
- **Negative parallelism density** (P9) — count, replace if AP > 3
- **Over-generation density** (P-NEW-1…P-NEW-7) — count bridging, restatement chains, vacuum-filling, antithetical recaps. NEW in v3.
- **YapScore estimate** — длина / минимально достаточный baseline. Если >1.5× — флаг «слишком длинный». NEW in v3.
- Hits per category (lexical / structural / rhetorical / punctuation)
- Burstiness estimate (std-dev of sentence length, sample of 10)
- Specificity (concrete facts per paragraph)
- Voice signals (first person, opinion, context references)

### Step 2 — Pick voice profile (if not specified)

Choose from:
- **casual**: contractions, first person, fragments, "And" starters (blog, social, community)
- **professional**: selective contractions, dry wit, concrete examples (business, formal)
- **technical**: precise terms, code-like clarity, deadpan humor (API docs, READMEs)
- **warm**: "we/our", empathy, shorter paragraphs (tutorials, support)
- **blunt**: shortest sentences, no hedging, active voice only (reviews, internal comms)
- **laconic** (NEW in v3): minimal, trust-the-reader, iceberg. Hemingway / Чехов / Шкловский. Для опытных читателей.

### Step 3 — Rewrite paragraph by paragraph

For each paragraph:
1. Read once for meaning.
2. Write a replacement that preserves meaning but breaks the patterns.
3. Apply levers 1–11 above.
4. If paragraph is "clean" already, leave it (or lightly polish).

### Step 4 — Tighten pass (Lever 10 / Strunk)

> [!info] Это самая частая операция в v3
> LLM-текст в 1.5–2× длиннее нужного. Tighten pass сокращает на 15–30% без потери смысла.

Применяйте последовательно:

1. **Vacuum-filling scan (P-NEW-1):** найдите вводные предложения без информации. Удалите.
2. **Restatement scan (P-NEW-2):** найдите 2+ предложения с одинаковым содержанием. Оставьте одно самое конкретное.
3. **Bridging scan (P-NEW-3):** найдите «как упоминалось выше», «это подводит нас к». Удалите. Начните новый абзац с содержания.
4. **Over-explanation scan (P-NEW-4):** найдите объяснения очевидного. Удалите. Оставьте команду/факт.
5. **Anticipatory hedging scan (P-NEW-5):** найдите «возможно, в некоторых случаях». Замените на конкретное условие или удалите.
6. **Balanced framing scan (P-NEW-6):** найдите «с одной стороны, с другой». Замените на мнение.
7. **Antithetical recap scan (P-NEW-7):** найдите «итак, мы рассмотрели». Удалите целиком.
8. **Strunk cut-test:** пройдите по каждому предложению: «Если я это уберу, что исчезнет?» Если ничего нового — удалите.
9. **Williams 6 операций:** финальный проход. См. `references/lexicon.md` раздел «Strunk cut-test».

Цель: сокращение 15–30% без потери информации. Если сокращение >40% — возможно, вы удалили содержание. Проверьте смысл.

### Step 5 — Trust-the-reader pass (Lever 11)

Reader-fill test:
- Прочитайте текст. Для каждого абзаца спросите: «Если я уберу 1–2 предложения, читатель всё поймёт?»
- Если да — удалите. Это iceberg.
- Условие: вы **знаете** то, что не говорите. Если не знаете — оставьте.

Distinctive-word test:
- Если в предложении нет ни одного слова, добавляющего информацию, — удалите его.

Stop at the turn:
- Если в абзаце есть «поворотный момент» — остановитесь на нём. Не объясняйте, что это значит. Точка.

### Step 5.5 — Russian grammar pass (Lever 12, RU only)

**Только для русского текста.** Применяйте 4 русских грамматических инструмента краткости:

#### 12.1. Парцелляция

Найдите сложное предложение с деепричастиями или несколькими однородными сказуемыми. Разбейте на 2–5 коротких.

> ❌ «Город стоит на реке, обеспечивая водоснабжение, способствуя развитию сельского хозяйства и формируя микроклимат.»
> ✅ «Город стоит на реке. Отсюда — водоснабжение и полив.»

#### 12.2. Эллипсис

Найдите повтор глагола/существительного во второй части сложносочинённого предложения. Опустите.

> ❌ «Я говорю по-английски, а он говорит по-немецки.»
> ✅ «Я говорю по-английски, а он — по-немецки.»

#### 12.3. Литота

Найдите абстрактные преуменьшения («совсем немного», «практически нет», «очень маленький»). Замените готовой формулой литоты.

> ❌ «У нас совсем немного пользователей.»
> ✅ «У нас пользователей — кот наплакал.»

Готовые формулы: «черепашьи темпы», «рукой подать», «кот наплакал», «с ноготок», «с овчинку», «не более напёрстка», «девочка-дюймовочка».

#### 12.4. Нулевая связка

В разговорном/постовом регистре: опустите личное местоимение в начале предложения, если это не меняет смысл.

> ❌ «Я пошёл в магазин, чтобы купить хлеб.»
> ✅ «Пошёл в магазин. Хлеб.»

**Условие применения Lever 12:**
- Разговорный, постовый, беллетристический регистр — да.
- Официально-деловой, дипломатический, юридический — нет.

### Step 6 — Add rupture sentences

If rewritten text still flows too smoothly, insert rupture:
- a one-line aside
- a question
- a blunt opinion
- a concrete number not in original
- **silence** — иногда правильный rupture = ничего не писать (Lever 11)

### Step 7 — Final read

Read aloud mentally. If anything sounds like a press release, LinkedIn post, marketing landing page, or Wikipedia article, fix.

Specific checks:
- [ ] YapScore ≤1.5× от минимально достаточного
- [ ] 0 bridging phrases («как упоминалось», «это подводит нас»)
- [ ] 0 antithetical recaps («итак, мы рассмотрели»)
- [ ] No paragraph starts with «Стоит отметить», «It's worth noting»
- [ ] No «с одной стороны, с другой стороны»
- [ ] Each paragraph: удаление любого предложения не теряет смысл → удалить

## Output format

Two-block output:

```
## Audit
- 3–6 bullets diagnosis

## Rewritten
<the text>
```

If user only wants the rewritten text, give only that.

## When NOT to rewrite

- **Code, configs, schemas** — uniformity is fine.
- **Mathematical proofs, formal definitions** — precision > voice.
- **Legal text** — clarity > style; only soften if explicitly asked.
- **Academic text** — expected scientific register shares patterns with AI; forcing change makes it worse.
- **Political/diplomatic text in Russian** — официально-деловой стиль legitimately uses em-dash, деепричастия, канцелярит.
- **The user said "leave it as is"** — confirm before editing.
- **Text that legitimately uses an antithesis as rhetoric** — keep it. Antithesis is a 2000-year-old figure. Don't remove when it actually adds meaning.

### Ethical scope

This skill helps you **rewrite your own text** with voice. It is NOT:
- A tool for academic fraud (cheating on papers).
- A reliable bypass of modern AI detectors.
- A way to hide the AI origin of generated text.

Use it to **write better**, not to **deceive**.

For full discussion of limits, see `~/Desktop/AgentWritingBase/05-References/limits-and-self-critique.md`.

## Companion skills

- `anti-ai-auditor` — if user only wants the diagnosis, no rewrite.
- `ai-pattern-rewriter` — for surgical fixes.
- `humanize-writer` — for greenfield writing rules.

## See also

- Obsidian: `~/Desktop/AgentWritingBase/04-Examples/before-after.md` and `04-Examples/before-after-ru-advanced.md`.
- `humanize-writer/references/lexicon.md` — full banned lexicon (RU+EN).
- External: [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill), [harshaneel/humanize](https://github.com/harshaneel/humanize), [Wikipedia RU: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста).
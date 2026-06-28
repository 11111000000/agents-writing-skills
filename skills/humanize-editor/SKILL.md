---
name: humanize-editor
description: Rewrite existing text (yours or someone else's) so it stops reading like LLM output. Use when the user pastes text that came from ChatGPT, GPT, Claude, Gemini, or any AI assistant and wants it to read human. Also use when a first draft from a sub-agent sounds "too polished" or "AI-ish". Do NOT use for code, structured data, or text where the user explicitly wants AI-style uniformity.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-rewriting
  version: 2
---

# Humanize-Editor (v2)

Rewrite existing text so it stops reading like LLM output. **Post-hoc** — input already exists, preserve meaning, kill AI tells. v2 integrates the **9 humanization levers from harshaneel/humanize** and **43-pattern catalogue from Aboudjem**, plus **Russian-specific patterns from Wikipedia RU**.

## When to load

- User pastes AI-generated text and wants it rewritten for human feel
- Sub-agent's first draft is too smooth
- User wants to clean up a draft before publishing

## Hard rules

> [!warning] Meaning preservation
> - **Preserve factual content** — names, numbers, dates, claims, citations. Don't drop or invent.
> - **Preserve length** — don't shorten by more than 10% unless asked.
> - **Preserve language** — input in RU stays RU, input in EN stays EN. Don't translate.

> [!warning] Style overhaul
> Apply the **9 levers** + Russian extensions:
>
> 1. **Banned lexicon** — `references/lexicon.md` (RU+EN, 43 patterns).
> 2. **Burstiness** — vary sentence lengths.
> 3. **Strip RLHF voice** (Lever 9) — remove polite hedging, balanced tradeoffs, "I hope this helps", "Надеюсь, это пригодится".
> 4. **Strip negative parallelisms** (P9) — `это не X, а Y` / `it's not X, it's Y` / `это не просто X` — **HIGHEST LEVERAGE**, #1 AI marker. See `~/Desktop/AgentWritingBase/01-Patterns/rhetorical/negative-parallelisms.md`.
> 5. **Strip hedging** — kill `можно сказать`, `it could be argued`, etc.
> 6. **Strip pairing** (RU) — "цели и задачи" → pick one.
> 7. **Strip деепричастия** (RU) — keep ≤1 per paragraph.
> 8. **Em-dash discipline** — ≤1 per 300 words.
> 9. **Concrete** — replace abstract claims with numbers.
> 10. **First person** — add `я`/`мы`/`I`/`we` once if missing.
> 11. **No closing cliché** — drop `таким образом`, `in conclusion`.
> 12. **Structural flatten** — convert bullet lists to prose where 2–3 sentences would do.

## Workflow

### Step 1 — Audit the input

Scan for 43-pattern hits. Report 3–6 bullets to user with:
- **Negative parallelism density** (P9) — count, replace if AP > 3
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

### Step 3 — Rewrite paragraph by paragraph

For each paragraph:
1. Read once for meaning.
2. Write a replacement that preserves meaning but breaks the patterns.
3. Apply levers 1–11 above.
4. If paragraph is "clean" already, leave it (or lightly polish).

### Step 4 — Add rupture sentences

If rewritten text still flows too smoothly, insert rupture:
- a one-line aside
- a question
- a blunt opinion
- a concrete number not in original

### Step 5 — Final read

Read aloud mentally. If anything sounds like a press release or LinkedIn post, fix.

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
---
name: humanize-writer
description: Write new prose that avoids typical LLM patterns (lexical clichés, uniform sentence length, rule-of-three, impersonality, hedging, RLHF artifacts). Use this skill whenever the user asks for any non-trivial narrative text — documentation, README sections, blog posts, emails, status updates, announcements. Do NOT use for short code comments, log messages, or technical reference where uniformity is desired.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-generation
  version: 2
---

# Humanize-Writer (v2)

Write text that reads like a human wrote it. Bundles operating instructions from the knowledge base, expanded with research-grounded techniques. Apply by default for non-trivial prose.

> [!warning] What this skill CAN and CANNOT do
> **Can:** make text read as human to average readers.
> **Cannot:** guarantee passing GPTZero, Pangram, Grammarly. Static rules have a ceiling against trained detectors (MASH, ACL 2026).
> **Not designed for:** academic integrity check bypass, submitting AI text as own work. Use to **write better**, not to **hide origin**.
> See `knowledge/05-References/limits-and-self-critique.md`.

> [!info] Major changes in v2
> - 9 levers from harshaneel/humanize (RLHF voice strip, disfluency)
> - Full 43-pattern catalogue from Aboudjem/humanizer-skill
> - Russian-specific patterns from Wikipedia RU
> - Academic sources (Binoculars, MASH, watermarking)
> - Output quality audit checklist
> - Scope and ethics disclaimer

## When to load

Load automatically when the user asks for any of:
- README / docs sections (other than API reference tables)
- blog posts, articles, essays
- emails, announcements, status updates
- PR/issue descriptions longer than ~5 lines
- marketing copy, landing pages, social posts
- Wikipedia-style encyclopedic content

Do **not** load for:
- Code comments, log strings, JSON/YAML schemas
- Short error messages, machine-generated reference
- Academic papers, legal documents (different register)
- Translations (double set of patterns; different approach)

## Scope: where this skill works and where it doesn't

### Optimizes well for

- Technical documentation (README, API docs, how-tos)
- Blog posts for general/dev audience
- Email to colleagues
- Status updates, release notes
- Marketing copy for mainstream audiences

### Weak zone

- Academic text (scientific register shares many patterns with AI)
- Legal text (канцелярит IS the same patterns we flag)
- Highly formal official documents

### Don't use this skill when

- Writing in a register that legitimately uses em-dashes, деепричастия, канцелярит as standard style (Russian political texts, diplomatic notes)
- Trying to evade academic integrity check (won't work, unethical)
- Need to fool a trained commercial detector (won't work — see MASH)

## 9 Humanization Levers

### Lever 1: Perplexity injection (word-level)

Replace predictable vocabulary with surprising but accurate words. One or two per paragraph.

**Banned EN:** `delve`, `leverage (verb)`, `robust`, `streamline`, `comprehensive`, `notably`, `it is worth noting`, `significant (overused)`, `pivotal`, `foster`, `facilitate`, `myriad`, `realm`, `tapestry`, `navigate (abstract)`, `underscore`.

**Banned RU:** `более того`, `кроме того`, `стоит отметить`, `следует отметить`, `важно подчеркнуть`, `таким образом`, `в заключение`, `в современном мире`, `обеспечивает`, `представляет собой`, `способствует`, `впечатляющий`, `инновационный`, `уникальный`.

Full list: `references/lexicon.md`.

### Lever 2: Burstiness enforcement (sentence-level)

Heuristic, not absolute.

Rules:
- At least one sentence of ≤6 words per 150 words of output.
- Avoid three consecutive sentences within 5 words of each other in length.
- Allow long sentences when the compound thought genuinely can't be broken.

When NOT to apply: technical reference where uniform sentence length aids scannability.

### Lever 3: Hedge surgery

Audit every softening word. Delete unless factually required.

If uncertainty is real, express it human-style.

### Lever 4: Structural flattening

Convert AI prose patterns (bullet + numbered + "In conclusion") to human prose. Structure emerges from content.

When NOT to apply: reference docs, API tables, structured checklists where structure aids scanning.

### Lever 5: Specificity insertion

Every abstract claim needs a grounding anchor: number, named example, time reference, named person/tool.

### Lever 6: Voice and register

Add traceable perspective: first-person where natural, second-person direct address, rhetorical questions as transitions, contractions in conversational registers.

When NOT to apply: API reference where third-person passive is genre norm; academic writing; legal text.

### Lever 7: Discourse coherence (human transitions)

Remove AI transition words. Replace with concrete connections.

### Lever 8: Punctuation normalization

- Em dashes (—): replace most with period, comma, or cut. Hard limit: 1 per 300 words.
- Semicolons (;): replace with period.
- Mid-sentence colons (:): replace with full sentence construction.

Russian em-dash is even more diagnostic. When NOT to apply: Russian official-business style.

### Lever 9: Strip RLHF / instruction-tuning voice (HIGHEST LEVERAGE)

Detectors fire on RLHF artifacts, not "AI-ness". Strip:
- Polite hedging
- Balanced tradeoffs offered unprompted
- Structured enumeration when a single answer would do
- Perfect local coherence
- "Helpful assistant" register
- Acknowledgment-prefix openers
- Hedged closers

## Russian-specific extensions (R-0 through R-5)

### R-0: Strip negative parallelisms (P9). HIGHEST LEVERAGE FOR RU

The construction «Это не X. Это Y.» / «Это не X, а Y.» is the #1 AI marker in Russian. LLM uses it 5–15 times per 1000 words; humans use it 0–1.

Forms to ban:
- ❌ «Это не X, а Y.»
- ❌ «Это не просто X. Это Y.»
- ❌ «Это не столько X, сколько Y.»
- ❌ «Это больше, чем X. Это Y.»
- ❌ «Это не только X, но и Y.»

Replacement rules:
1. If X and Y are genuinely mutually exclusive (монорепо vs polyrepo), keep but add concrete details.
2. If X and Y are both abstract labels, replace with concrete facts.
3. If construction adds nothing, delete it entirely.

Density target: <1 per 1000 words.

Full methodology: `knowledge/01-Patterns/rhetorical/negative-parallelisms.md`.

### R-1: Strip deeprichastnye chains

Russian LLM overuses деепричастия (-а/-в/-вши/-я). Limit to 1 per paragraph, prefer глагол.

### R-2: Break paired synonyms through "и"

LLM loves "цели и задачи", "принципы и подходы", "методы и средства". Pick one.

### R-3: Em-dash discipline

≤1 per 300 words in Russian.

### R-4: Voice in Russian

Use «я» for personal content, «мы» (team) for collaborative, безличное for instructions. Don't switch between them.

### R-5: Concrete with Russian flavor

Numbers: «на 30%», not «существенно». Cities: «в Казани», not «в России». Years: «в 2024», not «недавно».

## Workflow

### Step 1 — Pre-flight

Ask (or default) 3 questions:
1. Voice — 2–3 adjectives. Default: *practical, concrete, direct, opinionated*.
2. Lead — most concrete / surprising fact you can open with.
3. Numbers ready? — collect ≥3 hard facts.

### Step 2 — Draft

Write full text. Monitor:
- Sentence length diversity (5–25+ words)
- No 3-parallel bullet lists without rupture
- One деепричастие per paragraph max (RU)
- Em-dash count: ≤1 per 300 words
- At least one «я»/«мы» per 200 words (where format allows)

### Step 3 — Audit pass

For each paragraph:
- [ ] Contains concrete detail (number/name/date/path/command)
- [ ] Sentence lengths visibly differ
- [ ] No banned lexicon item
- [ ] No triple-parallel without rupture
- [ ] No abstract sentence that could be cut without loss

### Step 4 — Rupture pass

If a paragraph looks "smooth", insert a rupture sentence: one-line aside, personal aside, blunt opinion, short question, tangent.

### Step 5 — Density check

Count per 1000 words:
- AI-clichés from lexicon: target <5
- Деепричастия (RU): target <7
- Em-dashes: target <3
- Парные синонимы (RU): target <2
- Канцеляризмы: target <3

If multiple metrics exceed targets → rewrite.

## Output format

Always output only the final text. No preamble, no apologies.

## Companion skills

- `humanize-editor` — for rewriting existing text.
- `anti-ai-auditor` — for diagnosis without rewriting.
- `ai-pattern-rewriter` — for surgical span fixes.

## See also

- Knowledge base: `knowledge/`
- External: [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill), [harshaneel/humanize](https://github.com/harshaneel/humanize).
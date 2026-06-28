---
description: Rewrite AI-sounding text to read human. Preserves meaning; kills AI tells. Optional voice prompt: "voice:<adjectives>".
argument-hint: "[voice:<adjectives>] <text or path>"
---

You are operating as the `humanize-editor` workflow.

Take the input text and rewrite it so it stops reading like LLM output. Apply ALL of:

1. **Banned lexicon** — replace hits from the humanize-writer references/lexicon.md.
2. **Burstiness** — vary sentence lengths (<5 to >25 words).
3. **Rupture** — insert at least one rupture sentence per 200 words.
4. **First person** — if format allows, add `я`/`мы`/`I`/`we` once.
5. **Concrete** — replace every abstract claim with a number/name/date.
6. **No hedging** — kill `можно сказать`, `it could be argued`, etc.
7. **No closing cliché** — drop `таким образом`, `in conclusion`, etc.

PRESERVE factual content (names, numbers, claims). PRESERVE language of input. Do not translate.

Output format:

## Audit
- 3–6 bullet diagnosis of what was wrong

## Rewritten
<the rewritten text>

If `$1` starts with `voice:`, use the comma-separated adjectives after `voice:` as the voice profile for the rewrite (e.g. `voice: краткий, конкретный, сухой`).

User input follows.

$@
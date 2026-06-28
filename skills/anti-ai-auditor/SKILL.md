---
name: anti-ai-auditor
description: Audit an existing text for AI-pattern probability without rewriting it. Returns a structured report: per-paragraph risk score, list of specific AI-tells (lexical, structural, rhetorical), perplexity/burstiness estimates, and concrete suggestions. Use when the user wants feedback only, or wants to compare two versions, or is unsure whether a text is "AI enough" to bother rewriting.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-audit
---

# Anti-AI Auditor

Audit an existing text for AI-pattern probability. **Do not rewrite** — only diagnose. The user will decide what to do with the report.

## When to load

- User pastes text and asks "is this too AI?"
- User wants a comparison of two drafts
- User wants a "score" or "verdict"
- User is editing themselves and wants feedback

## What to measure

### 1. Lexical hits

Scan against the banned lexicon in `humanize-writer/references/lexicon.md`. Count each category:
- EN sentence starters (`delve`, `leverage`, `It's important to note`, …)
- RU sentence starters (`более того`, `стоит отметить`, …)
- Hedging (`можно сказать`, `could be argued`, …)
- Marketing speak (`plays a crucial role`, `эффективный`, …)

### 2. Structural patterns

- Number of triple-parallel bullet items
- Number of em-dashes per paragraph (flag if >1.5/paragraph average)
- Sentence-length variance (rough estimate from sampling)
- Paragraph-length variance

### 3. Burstiness estimate

Sample 10 sentences. Compute approximate mean and std-dev of word count. AI-text typically has std < 3 words. Human text usually has std > 5.

### 4. Specificity

Count concrete facts per paragraph:
- Numbers, dates, versions
- File paths, commands, identifiers
- Names of people, products, libraries

If < 0.5 concrete facts per paragraph on average → flag.

### 5. Voice / authorship signals

- Does the text use `я`/`мы`/`I`/`we`? (flag absence if format allows)
- Does it have opinions / positions / value judgments?
- Does it reference specific context (people, events, internal jokes)?

### 6. Closing pattern

- Does it end with `таким образом` / `in conclusion` / `to summarize` / `подводя итог`?
- Does it have a "mini-conclusion" at the end of each paragraph?

## Output format

```
## AI-Audit Report

### Verdict: <Human-leaning | Mixed | AI-leaning | Strongly AI>

Risk score: <0-100>%
Detector expectation: <what ZeroGPT/GPTZero would likely say>

### Lexical (X hits)
- Line 3: "delve" — replace with "look at"
- Line 7: "moreover" — drop
- ...

### Structural (Y issues)
- Para 2: triple-parallel bullets, no rupture
- ...

### Burstiness
- Mean sentence length: ~X words
- Std: ~Y (low / medium / high)
- ...

### Specificity
- Concrete facts per paragraph: ~Z (low / medium / high)
- ...

### Voice
- First-person: yes/no
- Opinion: yes/no
- Context references: yes/no

### Recommendations (top 3)
1. ...
2. ...
3. ...
```

## Important caveats

- **This is a heuristic**, not a detector. A score of 30% here may score 60% on ZeroGPT, and vice versa.
- **Don't claim certainty.** Use "likely", "probably", "consistent with".
- **Format matters.** Technical docs naturally have less voice; legal text has more hedging. Adjust expectations.
- **Length matters.** Texts <100 words are unreliable. Note if input is short.

## Companion skills

- `humanize-editor` — for actually rewriting based on this audit.
- `ai-pattern-rewriter` — for surgical fixes.

## See also

- Obsidian: `~/Desktop/AgentWritingBase/03-Detection/how-detectors-work.md`
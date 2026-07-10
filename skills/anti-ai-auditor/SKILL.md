---
name: anti-ai-auditor
description: Audit an existing text for AI-pattern probability without rewriting it. Returns a structured report: per-paragraph risk score, list of specific AI-tells (lexical, structural, rhetorical, over-generation, length-bias-driven), perplexity/burstiness/YapScore estimates, format-bias density, and concrete suggestions. Use when the user wants feedback only, or wants to compare two drafts, or is unsure whether a text is "AI enough" to bother rewriting.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-audit
  version: 3
---

# Anti-AI Auditor (v3)

Audit an existing text for AI-pattern probability. **Do not rewrite** — only diagnose. v3 adds length bias academic grounding (Park 2024, Lamparth 2026, Zhang 2024), format bias detection (lists/bold/emojis), and bias substitution warnings.

## When to load

- User pastes text and asks "is this too AI?"
- User wants a comparison of two drafts
- User wants a "score" or "verdict"
- User is editing themselves and wants feedback
- **User asks "is this too long?" or "почему так много слов?"** (new in v2) — apply YapScore estimate

## What to measure

### 1. Lexical hits

Scan against the banned lexicon in `humanize-writer/references/lexicon.md`. Count each category:
- EN sentence starters (`delve`, `leverage`, `It's important to note`, …)
- RU sentence starters (`более того`, `стоит отметить`, …)
- Hedging (`можно сказать`, `could be argued`, …)
- Marketing speak (`plays a crucial role`, `эффективный`, …)
- **Over-generation patterns (NEW in v2)**: bridging phrases, antithetical recaps, vacuum-filling openers, over-explanation markers, balanced framing crutches, hedging + over-generation combos

### 2. Structural patterns

- Number of triple-parallel bullet items
- Number of em-dashes per paragraph (flag if >1.5/paragraph average)
- Sentence-length variance (rough estimate from sampling)
- Paragraph-length variance
- **Over-generation structural patterns (NEW in v2)**:
  - Restatement chains (2+ предложения с одинаковым содержанием)
  - Bridging phrases на границе абзацев
  - Vacuum-filling вводные

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

### 7. YapScore / Sufficiency estimate (NEW in v2)

Per YapBench (arXiv 2601.00624, январь 2026): LLMs systematically over-generate on brevity-ideal prompts. Estimate:

- **Step 1.** For each paragraph, imagine the minimal-sufficient version. Count words.
- **Step 2.** Compute YapScore = original_word_count / minimal_sufficient_word_count.
- **Step 3.** Categorize:
  - **1.0–1.2×** — оптимально, плотно
  - **1.2–1.5×** — допустимо для conversational
  - **1.5–2.0×** — флаг «можно сократить»
  - **2.0–3.0×** — флаг «over-generation»
  - **3.0×+** — флаг «вероятно AI, много мусора»

> [!warning] Эвристика
> YapScore — грубая оценка. Сравните с baseline: человек, решающий ту же задачу, написал бы столько же?

> [!info] Куда смотреть
> Часто 70% over-generation приходится на 20% текста. Найдите эти «горячие точки» — обычно вводные предложения и заключения.

### 8. Cut-test pass (Strunk / Lever 10)

Для каждого абзаца:
- Прочитайте каждое предложение. Спросите: «Если я это уберу, что исчезнет?»
- Если ничего нового — пометьте как кандидат на удаление.

Подсчитайте:
- **Cuttable sentences**: сколько предложений можно удалить без потери смысла.
- Если cuttable > 20% текста — это over-generation.

### 9. Reader-fill test (Lever 11)

- Есть ли абзацы, где 1–2 предложения можно удалить, и читатель всё поймёт?
- Если да — пометьте как iceberg opportunity.

### 10. Format bias density (NEW v3, Zhang et al. 2024)

Count format-level signals that LLMs exploit:
- **Lists**: трёхпараллельные bullet-списки без rupture
- **Bold**: чрезмерное `**жирное**` в markdown
- **Emojis**: 🤖📊💡 и т.п. (Zhang et al. подтверждают, что reward models предпочитают emoji)
- **Headings**: чрезмерное количество заголовков (Title Case в EN)

Mark **HIGH** if format bias density > baseline (e.g., >5 emoji per 1000 words, >10% words bolded).

### 11. Length bias structural check (NEW v3, Lamparth 2026)

> [!warning] Bias substitution
> Single-axis mitigation (только сокращение длины) может перенести bias на другие proxies (factual depth, confidence calibration). Audit должен проверять, что **факты не потеряны при сокращении**.

Compute:
- Number of concrete facts (numbers, names, dates, paths) before vs after Tighten pass.
- Если количество фактов уменьшилось более чем на 10% → флаг "potential bias substitution".

### 12. Russian brevity grammar opportunity (NEW v3, Lever 12, RU only)

If text is Russian, check if any of these can be applied:
- **Парцелляция**: есть ли длинные предложения с деепричастиями? (Candidate: P3 + структурная перестройка)
- **Эллипсис**: есть ли повтор глагола в сложносочинённых предложениях? (Candidate: гэппинг)
- **Литота**: есть ли абстрактные преуменьшения? (Candidate: «совсем немного» → «кот наплакал»)
- **Нулевая связка**: разговорный регистр с лишними местоимениями?

Mark as **opportunities**, not as violations. Lever 12 is positive technique, not removal.

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

### Over-generation (NEW)
- YapScore estimate: ~X (1.0–1.5 = optimal, 1.5–2.0 = flag, 2.0+ = critical)
- Vacuum-filling sentences: ~X per 1000 words
- Restatement chains: ~X
- Bridging phrases at paragraph starts: ~X
- Antithetical recaps: ~X
- Cuttable sentences (Strunk test): ~X (target <15%)
- Iceberg opportunities: ~X paragraphs
- **Format bias density (NEW v3):** emojis X, bold X%, triple-parallel lists X
- **Bias substitution warning (NEW v3):** факты до/после Tighten: X → Y (потеря Z%)
- **Russian grammar opportunities (NEW v3, RU only):** парцелляция X, эллипсис X, литота X

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

### Sufficiency verdict
- Is the text over-long? <yes / no / borderline>
- If yes: where would you cut? (1-3 specific spans)

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
- **YapScore is rough.** Comparison with an internal baseline («a smart colleague would write ~30 words») is more reliable than absolute number.

## Companion skills

- `humanize-editor` — for actually rewriting based on this audit.
- `ai-pattern-rewriter` — for surgical fixes.

## See also

- Obsidian: `~/Desktop/AgentWritingBase/03-Detection/how-detectors-work.md`
- Obsidian: `~/Desktop/AgentWritingBase/02-Techniques/sufficiency-and-underspecification.md` (NEW)
- Obsidian: `~/Desktop/AgentWritingBase/01-Patterns/structural/over-generation.md` (NEW)
- External: [YapBench paper](https://arxiv.org/abs/2601.00624)
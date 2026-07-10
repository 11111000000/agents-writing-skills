---
name: anti-ai-auditor
description: Audit an existing text for AI-pattern probability without rewriting it. Returns a structured report: per-paragraph risk score, list of specific AI-tells (lexical, structural, rhetorical, over-generation, length-bias-driven), perplexity/burstiness/YapScore estimates, format-bias density, and concrete suggestions. Use when the user wants feedback only, or wants to compare two drafts, or is unsure whether a text is "AI enough" to bother rewriting.
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: text-audit
  version: 5
---

# Anti-AI Auditor (v5)

Audit an existing text for AI-pattern probability. **Do not rewrite** — only diagnose. v5 introduces **3-pass audit architecture**: Surface Scan → Deep Analysis → Synthesis. Each pass has clear inputs/outputs and is independently auditable.

> [!info] Knowledge base access
> All references are GitHub URLs to [`11111000000/agents-writing-skills`](https://github.com/11111000000/agents-writing-skills). For offline: `./scripts/install-knowledge.sh`.

## Архитектура: 3-pass audit

```
┌────────────────────────────────────────────────────────────────┐
│ PASS 1: SURFACE SCAN (count patterns, flag locations)         │
│   Output: counts + locations + per-paragraph risk            │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 2: DEEP ANALYSIS (interpret metrics, compare to baselines)│
│   Output: 4-8 patterns identified with risk scores            │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│ PASS 3: SYNTHESIS (verdict, recommendations, NO rewrite)       │
│   Output: Human-leaning / Mixed / AI-leaning / Strongly AI    │
│           + 3-5 concrete actionable recommendations            │
└────────────────────────────────────────────────────────────────┘
```

## When to load

- User pastes text and asks "is this too AI?"
- User wants a comparison of two drafts
- User wants a "score" or "verdict"
- User is editing themselves and wants feedback
- User asks "is this too long?" (YapScore)
- User asks "is this human enough?"

---

## PASS 1 — SURFACE SCAN

### 1.1. Метрики (автоматический счёт)

```yaml
metrics:
  AP: <число>                        # negative parallelism density (per 1000 words)
  D: <число>                         # RU only: деепричастия per 1000 words
  E: <число>                         # em-dash per 300 words
  YapScore: <число>                  # длина / baseline
  V: <число>                         # vacuum-filling sentences (%)
  R: <число>                         # restatement chains (%)
  B: <число>                         # bridging phrases at para starts (%)
  burstiness:
    mean_sentence_length: <число>
    std: <число>
  specificity:
    concrete_facts_per_para: <число>
  format_bias:
    emojis_per_1000: <число>
    bold_pct: <число>
    triple_parallel_lists: <число>
  voice:
    first_person: true | false
    opinion: true | false
    opinion_count: <число>
```

### 1.2. Lexical hits

Scan against banned lexicon in [`references/lexicon.md`](https://github.com/11111000000/agents-writing-skills/blob/main/skills/humanize-writer/references/lexicon.md):

| Category | EN examples | RU examples |
|---|---|---|
| Sentence starters | `delve`, `leverage`, `It's important to note` | `более того`, `стоит отметить` |
| Hedging | `could be argued`, `it might be said` | `можно сказать`, `вероятно` |
| Marketing speak | `plays a crucial role`, `cutting-edge` | `играет важную роль`, `инновационный` |
| Over-generation (P-NEW) | `as mentioned above`, `it could be argued` | `как упоминалось выше` |
| Format bias (Zhang 2024) | emoji, bold, lists | emoji, bold, lists |

### 1.3. Structural patterns

- Triple-parallel bullet items
- Em-dashes per paragraph (flag if > 1.5/paragraph average)
- Sentence-length variance (std < 3 = low)
- Paragraph-length variance

---

## PASS 2 — DEEP ANALYSIS

### 2.1. Per-paragraph risk

```yaml
paragraphs:
  - id: 1
    risk_score: 30              # 0-100, weighted by patterns
    issues:
      - type: vacuum_filling
        severity: medium
      - type: negative_parallelism
        severity: high
      - type: hedging
        severity: low
  - id: 2
    risk_score: 80
    issues:
      - type: restatement_chain
        severity: critical
```

### 2.2. Burstiness estimate

Sample 10 sentences. Compute approximate mean and std-dev of word count.
- AI text typically: std < 3 words
- Human text usually: std > 5 words

```yaml
burstiness:
  mean: 16.2
  std: 2.4               # < 3 = suspicious
  verdict: low_burstiness
```

### 2.3. YapScore / Sufficiency estimate (Borisov 2026)

Per YapBench: LLMs systematically over-generate on brevity-ideal prompts.

```python
def estimate_yap_score(text):
    """Для каждого абзаца оценить minimal-sufficient version."""
    # Step 1. Imagine the minimal-sufficient version of each paragraph.
    # Step 2. Compute YapScore = original_word_count / minimal_sufficient_word_count.

    categories:
      - 1.0-1.2   # optimal, плотно
      - 1.2-1.5   # допустимо для conversational
      - 1.5-2.0   # flag "можно сократить"
      - 2.0-3.0   # flag "over-generation"
      - 3.0+      # critical "вероятно AI, много мусора"
```

> [!warning] Эвристика
> YapScore — грубая оценка. Сравните с baseline: человек, решающий ту же задачу, написал бы столько же?

### 2.4. Cut-test pass (Strunk / Lever 10)

Для каждого абзаца:
- Прочитайте каждое предложение. Спросите: «Если я это уберу, что исчезнет?»
- Если ничего нового — пометьте как кандидат на удаление.

```yaml
cuttable:
  total_sentences: 47
  cuttable: 9                # target < 15% = 7
  cuttable_pct: 19           # high
  locations: [para_2_sent_1, para_3_sent_2, ...]
```

### 2.5. Reader-fill test (Lever 11)

- Есть ли абзацы, где 1–2 предложения можно удалить, и читатель всё поймёт?
- Если да — пометьте как iceberg opportunity.

### 2.6. Format bias density (Zhang 2024)

Count format-level signals that LLMs exploit:
- **Lists**: трёхпараллельные bullet-списки без rupture
- **Bold**: чрезмерное `**жирное**` в markdown
- **Emojis**: 🤖📊💡 и т.п.

Mark **HIGH** if format bias density > baseline.

### 2.7. Length bias structural check (Lamparth 2026)

> [!warning] Bias substitution
> Single-axis mitigation (только сокращение длины) может перенести bias на другие proxies (factual depth, confidence calibration). Audit должен проверять, что **факты не потеряны при сокращении**.

Compute:
- Number of concrete facts (numbers, names, dates, paths) before vs after Tighten pass.
- Если количество фактов уменьшилось более чем на 10% → флаг "potential bias substitution".

### 2.8. Russian brevity grammar opportunity (Lever 12, RU only)

If text is Russian, check if any of these can be applied:
- **Парцелляция**: есть ли длинные предложения с деепричастиями?
- **Эллипсис**: есть ли повтор глагола в сложносочинённых предложениях?
- **Литота**: есть ли абстрактные преуменьшения?
- **Нулевая связка**: разговорный регистр с лишними местоимениями?

Mark as **opportunities**, not as violations.

---

## PASS 3 — SYNTHESIS

### 3.1. Verdict

```yaml
verdict:
  label: <Human-leaning | Mixed | AI-leaning | Strongly AI>
  risk_score: 0-100
  detector_expectation: <what ZeroGPT/GPTZero would likely say>
  confidence: low | medium | high
```

**Heuristic for verdict:**
- 0-25: Human-leaning
- 25-50: Mixed (likely AI, but not certain)
- 50-75: AI-leaning
- 75-100: Strongly AI

### 3.2. Recommendations

Top 3-5 concrete actionable items:

```yaml
recommendations:
  - priority: 1
    issue: "YapScore 2.3 — text is 2.3x longer than minimal sufficient"
    action: "Run humanize-editor with TIGHTEN phase. Expect 30-40% reduction."
  - priority: 2
    issue: "Vacuum-filling sentences in para 2, 5"
    action: "Delete first sentence of each affected paragraph"
  - priority: 3
    issue: "Triple-parallel bullets without rupture in section 3"
    action: "Apply rupture pattern or merge into prose"
```

### 3.3. Output format

```markdown
## AI-Audit Report

### Verdict: <Human-leaning | Mixed | AI-leaning | Strongly AI>

Risk score: <0-100>%
Detector expectation: <what ZeroGPT/GPTZero would likely say>

### Metrics
- AP: <число> (target <1)
- D: <число> (RU, target <7)
- E: <число> (target <3 per 300 words)
- YapScore: <число> (target 1.0-1.5)
- Burstiness std: <число> (target >5)
- Concrete facts per para: <число> (target >0.5)

### Lexical (X hits)
- Line 3: "delve" — replace with "look at"
- Line 7: "moreover" — drop
- ...

### Structural (Y issues)
- Para 2: triple-parallel bullets, no rupture
- ...

### Over-generation
- YapScore estimate: ~X (1.0-1.5 = optimal, 1.5-2.0 = flag, 2.0+ = critical)
- Vacuum-filling sentences: ~X per 1000 words
- Restatement chains: ~X
- Bridging phrases at paragraph starts: ~X
- Antithetical recaps: ~X
- Cuttable sentences (Strunk test): ~X (target <15%)
- Iceberg opportunities: ~X paragraphs
- Format bias density: emojis X, bold X%, triple-parallel lists X
- Bias substitution warning: facts before/after Tighten: X → Y (loss Z%)
- Russian grammar opportunities: парцелляция X, эллипсис X, литота X

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

---

## Important caveats

- **This is a heuristic**, not a detector. A score of 30% here may score 60% on ZeroGPT, and vice versa.
- **Don't claim certainty.** Use "likely", "probably", "consistent with".
- **Format matters.** Technical docs naturally have less voice; legal text has more hedging. Adjust expectations.
- **Length matters.** Texts <100 words are unreliable. Note if input is short.
- **YapScore is rough.** Comparison with an internal baseline is more reliable than absolute number.
- **Bias substitution is a real risk** (Lamparth 2026). Don't recommend Tighten pass without checking fact density.

---

## Companion skills

- `humanize-editor` — for actually rewriting based on this audit (3-pass)
- `ai-pattern-rewriter` — for surgical fixes (3-pass surgical)
- `humanize-writer` — for greenfield writing (3-pass)

---

## See also

- Knowledge base:
  - [`02-Techniques/sufficiency-and-underspecification.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/sufficiency-and-underspecification.md)
  - [`02-Techniques/length-bias-research.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/length-bias-research.md)
  - [`02-Techniques/russian-brevity-grammar.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/02-Techniques/russian-brevity-grammar.md)
  - [`03-Detection/how-detectors-work.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/03-Detection/how-detectors-work.md)
  - [`01-Patterns/structural/over-generation.md`](https://github.com/11111000000/agents-writing-skills/blob/main/knowledge/01-Patterns/structural/over-generation.md)
- External:
  - [YapBench paper](https://arxiv.org/abs/2601.00624) (Borisov 2026)
  - [Park et al. 2024](https://arxiv.org/abs/2403.19159) (DPO length bias)
  - [Lamparth et al. 2026](https://arxiv.org/abs/2605.27996) (bias substitution)
  - [Zhang et al. 2024](https://arxiv.org/abs/2409.11704) (format bias)
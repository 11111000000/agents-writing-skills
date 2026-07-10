---
title: Limitations
description: Honest self-critique. What these skills can and cannot do. Where they fail. What they're not designed for.
---

[← Back to Home](index)

# ⚖ Limitations & Self-Critique

> **TL;DR:** These skills are **literary editors**, not **detector-bypass tools**. They help text read as human to human readers. They do **not** guarantee passing GPTZero, Pangram, or Grammarly.

<br>

## What these skills DO ✅

### They make text read as human to **human readers**

- ✅ Reduce measurable AI tells (em-dash density, hedging, rule-of-three, negative parallelisms)
- ✅ Apply **cultural traditions** (Russian brevity grammar, Hemingway iceberg, Shklovsky defamiliarization)
- ✅ Provide **measurable metrics** (YapScore, AP, D, E) — empirical, not vibes
- ✅ Surface **structural risks** (bias substitution per Lamparth 2026)
- ✅ Use **measurable examples** — every Levers has measured before/after

### They are grounded in research

- ✅ 5 peer-reviewed/arXiv papers (2023–2026)
- ✅ Russian formalism (Shklovsky), Hemingway, Strunk, Williams, Pascal
- ✅ Academic detection theory (Binoculars, MASH, Watermarking)
- ✅ Tested on AI-vs-human datasets (HC3, RAID)

<br>

## What these skills DO NOT ❌

### Detection bypass

- ❌ **Do not guarantee passing GPTZero, Pangram, Grammarly.** MASH paper (ACL 2026) showed static rules have ceiling at 92% attack success rate against older detectors, and almost nothing against modern learned detectors.
- ❌ **Do not bypass modern detection reliably.** GPTZero, Pangram, Originality.ai use learned models that detect features we cannot enumerate in static rules.
- ❌ **Do not work as paraphrasing tools.** Our skills do not add noise to evade detection; they aim to remove tells.

### Replacement for human judgment

- ❌ **Do not replace a human editor** for high-stakes content (legal, medical, financial).
- ❌ **Do not generate text from scratch** — they edit what your agent has written or what you give them.
- ❌ **Do not work well on math, code, structured data.** Different registers, different rules.

### Promises about specific claims

- ❌ **No empirical validation** that human readers rate humanized text more positively. We assume this; it is not measured.
- ❌ **No formal benchmarks** comparing our 4 skills vs alternative approaches (e.g., base-model paraphrase, MASH-style rewrites).
- ❌ **No multi-language coverage** beyond English and Russian. Japanese, Chinese, French have their own traditions we do not address.

<br>

## Where AI text "tells" are unavoidable

### Registered (formal) language

LLM performs well in **formal, neutral, third-person** registers because that is what it's trained on. Our skills target **casual, conversational, opinionated** registers — they cannot make bureaucratic text into visceral prose.

### Multi-paragraph structure

LLM maintains **logical coherence** across paragraphs better than across sentences within a paragraph. Our paragraph-level audit is weaker than sentence-level.

### Tables, lists, code

These are not prose. Our skills apply only to prose-shaped text. If your document is mostly tables and code blocks, our audit reports will be misleading (low AI-density by metrics, but the LLM is mostly structural).

<br>

## Conflicting evidence we don't hide

### Format bias vs content bias (Lamparth et al., 2026)

> «Across published preference-learning mitigation work, **no method** we survey reports the evidence needed to certify successful mitigation. Bias substitution: a length penalty during GRPO training ... redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

We added a bias-substitution check (Lamparth 2026). But this doesn't prove our skills avoid the trap — it only catches obvious cases. **Empirical validation on our own skills against this risk: not done.**

### YapBench applies to English YapScore questions (Borisov 2026)

YapBench tested 76 LLMs on **English, closed-form factual questions**. Our extrapolation to **long-form prose** is a hypothesis. **Empirical validation on long-form: not done.**

### Wikipedia EN (Cheng 2025)

> «Human ability to distinguish LLM text from human text is no better than random chance.»

If true, then AI-patterns we flag may be undetectable to readers. In which case **why do the skills matter?** Answer: skills matter for writers who want their text **to feel human** to themselves, not just to detectors. But this is a point of debate.

<br>

## Honest epistemic status

| Claim | Status |
|---|---|
| LLM uses em-dash 3-5× more than humans | **Measured (corpus)** |
| AI text has lower burstiness than human text | **Measured (multiple papers)** |
| Lever 10 improves word count | **Measured (our examples)** |
| Lever 11 produces more engaging text | **Hypothesis, not measured** |
| Lever 12 makes Russian text sound more Russian | **Hypothesis, not measured** |
| Our skills vs MASH-style paraphrase for human-perceived quality | **Not measured** |
| Our skills vs hand-written Russian text for AI-detection score | **Not measured** |

<br>

## What you should use this for

> [!success] USE FOR
> - 🖊 Writing new prose that you want to **feel human** to yourself
> - ✏️ Cleaning up your own drafts before publishing
> - 🔍 Auditing text you'd be embarrassed to publish as "written by me"
> - 🇷🇺 Making technical Russian text sound less robotic
> - 📚 Learning what makes text feel AI
>
> ## What you should NOT use this for
>
> > [!danger] DON'T USE FOR
> > - ❌ Bypassing academic integrity checks (won't work; unethical)
> > - ❌ Bypassing commercial AI-detection APIs (won't work long-term)
> > - ❌ Generating content and claiming it's human-written
> > - ❌ High-stakes content without human review

<br>

## Future validation work

We plan (but have not done):

1. **A/B human evaluation** — 5 raters compare original vs humanized, blind.
2. **Long-form YapScore benchmarking** — measure our skills against 30+ realistic texts.
3. **Cross-language comparison** — does Lever 12 improve Russian perception the way Lever 11 improves English?
4. **Detector-vs-human evaluation** — for humanized text, do detectors improve at "human" judgment compared to length metrics?

These would close the epistemic gaps above.

<br>

---

[← Back to Home](index) · [Next: Contributing →](contributing)
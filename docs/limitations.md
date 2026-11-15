---
title: Limitations
description: Honest self-critique. What the v7 skills can and cannot do. Where they fail. What is still unvalidated. What they're not designed for.
---

[← Back to Home](index)

# ⚖ Limitations & Self-Critique

> **TL;DR:** These skills are **literary editors**, not **detector-bypass tools**. They help text read as human to human readers. They do **not** guarantee passing GPTZero, Pangram, or Grammarly.

<br>

## 🆕 What changed, and what it fixed

v6 left a lot of claims unsupported. v7 closed some of those gaps and made the remaining ones explicit.

| Gap in v6 | What v7 did |
|---|---|
| Metric thresholds were picked by intuition and applied to both languages | **Calibrated on 145 labeled texts** (HC3 / RAID / Wikisource RU + synthetic). `benchmark-skill.sh` now picks language-aware thresholds: RU uses E < 1, burstiness > 8, D as a soft warning at 18, V > 2%; EN uses E < 3, burstiness > 3, V > 2%. Regression tests lock the separation in `scripts/test-benchmark.sh`. Full derivation: [metric-validation](02-techniques/metric-validation) |
| "An edit keeps the facts" was a claim with nothing behind it | **Behavioral corpus** `tests/fixtures/editing/`: 24 cases with deliberate traps on modality, conditions and invented facts, checked by `scripts/test-editing-fixtures.sh` |
| Nothing checked whether an edit actually preserved the meaning | **Validators**: `scripts/check-editing-output.sh` checks 9 invariants of the meaning contract (numbers, claims, conditions, exceptions, terminology, uncertainty, no invented numbers, no forbidden additions, already-good-unchanged) and ships a `--selftest` proving it catches violations. Plus `scripts/check-examples-facts.sh`, `scripts/check-examples-coverage.sh`, `scripts/check-no-stale-contract.sh` |
| Claims lived only in prose | **Evidence layer**: `spec.json` + `mathc run`: 12 claims with negative controls, each bound to a verifier command |
| Tolerating a percentage of lost facts | **Zero loss of claims by default.** The 10%/20% thresholds are gone; the invariant is checked per claim |

What this buys: the *mechanical* part of "the edit did not change what the text says" is now verifiable. What it does not buy: proof that readers prefer the result.

<br>

## What these skills DO ✅

### They make text read as human to **human readers**

- ✅ Reduce measurable AI tells (em-dash density, hedging, rule-of-three, negative parallelisms)
- ✅ Apply **cultural traditions** (Russian brevity grammar, Hemingway iceberg, Shklovsky defamiliarization)
- ✅ Apply a **meaning contract**: claims, numbers and their relations, conditions, exceptions, negations, modality, terminology, quotes and register survive the edit; invented facts fail
- ✅ Provide **measurable metrics** (YapScore, AP, D, E), empirical, not vibes. **As diagnostics, not as a verdict**: a flagged number points at a place to look, it does not decide "AI / not AI"
- ✅ Surface **structural risks** (bias substitution per Lamparth 2026)
- ✅ Use **measurable examples**: every lever has a measured before/after

### They are grounded in research

- ✅ 5 peer-reviewed/arXiv papers (2023–2026)
- ✅ Russian formalism (Shklovsky), Hemingway, Strunk, Williams, Pascal
- ✅ Academic detection theory (Binoculars, MASH, Watermarking)
- ✅ Tested on AI-vs-human datasets (HC3, RAID): 145 labeled texts in total

<br>

## What these skills DO NOT ❌

### Detection bypass

- ❌ **Do not guarantee passing GPTZero, Pangram, Grammarly.** MASH paper (ACL 2026) showed static rules have ceiling at 92% attack success rate against older detectors, and almost nothing against modern learned detectors.
- ❌ **Do not bypass modern detection reliably.** GPTZero, Pangram, Originality.ai use learned models that detect features we cannot enumerate in static rules.
- ❌ **Do not work as paraphrasing tools.** Our skills do not add noise to evade detection; they aim to remove tells.
- ❌ **The project is not a detector-bypass project.** It is a literary editor. The point is a text that says the same thing and reads better; if it also passes a detector, that is a side effect that works inconsistently.

### Replacement for human judgment

- ❌ **Do not replace a human editor** for high-stakes content (legal, medical, financial).
- ❌ **Do not generate text from scratch**: they edit what your agent has written or what you give them.
- ❌ **Do not work well on math, code, structured data.** Different registers, different rules.

### Blind human evaluation has not happened

- ❌ **No blind human evaluation has been conducted.** The [protocol](blind-evaluation) is written: 2–3 independent readers, randomized column order, fixed criteria and a pass/fail rule — but **no raters have run it yet**. Every statement about "the edit reads better" is therefore still an expectation, not a measurement.
- ❌ **No formal benchmarks** comparing our 4 skills vs alternative approaches (e.g., base-model paraphrase, MASH-style rewrites).
- ❌ **No multi-language coverage** beyond English and Russian. Japanese, Chinese, French have their own traditions we do not address.

### The machine check has a blind spot

The validator is strong on what can be checked mechanically, and weak exactly where it matters most:

| Caught by machine | Not caught by machine |
|---|---|
| Lost numbers, changed numbers, invented numbers | **Meaning carried by no number at all**: a reversed conclusion, a changed actor, a flipped cause-and-effect, a softened conclusion |
| Lost conditions, exceptions, required claims | Claims that were never listed in `required_preservation`: the validator stays silent on what nobody wrote down |
| Dropped hedges, changed terminology | Clarity, grammaticality, naturalness, genre fit, overall impression |

> [!warning]
> The validator reads the `required_preservation` list of the fixture. **If that list is incomplete, the validator is silent**: it cannot notice a whole missing paragraph. That is exactly the gap the blind human protocol is meant to cover, and why the protocol is not optional for a claim of quality.

<br>

## The Russian corpus is still small

The RU arm of the validation rests on **8 human texts and 12 synthetic AI texts** (Wikisource classics vs. hand-made templates, ~138 words each). The EN arm has 60 human and 65 AI texts. Consequences:

- RU thresholds (E < 1, burstiness > 8, V > 2%, D soft at 18) are **a hypothesis on 20 files**, not a calibrated boundary.
- The synthetic RU AI set is biased: it is far shorter and smoother than real LLM output, and has almost no деепричастия. That makes the "AI uses fewer деепричастия" finding weaker than it should be.
- The human side is literary prose, so it says nothing about marketing, techblog or support copy.

So: **"AI text in Russian differs from human text by D, E and burstiness" is a hypothesis, not a result.** The plan to fix it (real generations, ≥ 30 per class, ≥ 3 domains, model and licence documented) is in [ru-corpus-collection](02-techniques/ru-corpus-collection).

<br>

## Where AI text "tells" are unavoidable

### Registered (formal) language

LLM performs well in **formal, neutral, third-person** registers because that is what it's trained on. Our skills target **casual, conversational, opinionated** registers: they cannot make bureaucratic text into visceral prose.

### Multi-paragraph structure

LLM maintains **logical coherence** across paragraphs better than across sentences within a paragraph. Our paragraph-level audit is weaker than sentence-level.

### Tables, lists, code

These are not prose. Our skills apply only to prose-shaped text. If your document is mostly tables and code blocks, our audit reports will be misleading (low AI-density by metrics, but the LLM is mostly structural).

<br>

## Conflicting evidence we don't hide

### Format bias vs content bias (Lamparth et al., 2026)

> «Across published preference-learning mitigation work, **no method** we survey reports the evidence needed to certify successful mitigation. Bias substitution: a length penalty during GRPO training ... redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

We added a bias-substitution check (Lamparth 2026). But this doesn't prove our skills avoid the trap; it only catches obvious cases. **Empirical validation on our own skills against this risk: not done.**

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
| Metric thresholds separate AI from human on this 145-text corpus | **Measured (EN solid, RU preliminary on 20 files)** |
| An edit preserves claims, numbers, conditions and modality | **Measured (24-case corpus + validators)** |
| Lever 11 produces more engaging text | **Hypothesis, not measured** |
| Lever 12 makes Russian text sound more Russian | **Hypothesis, not measured** |
| A human reader prefers the edited text to the original | **Not measured (blind evaluation not run)** |
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

## What you should NOT use this for

> [!danger] DON'T USE FOR
> - ❌ Bypassing academic integrity checks (won't work; unethical)
> - ❌ Bypassing commercial AI-detection APIs (won't work long-term)
> - ❌ Generating content and claiming it's human-written
> - ❌ High-stakes content without human review

<br>

## Future validation work

We plan (but have not done):

1. **Blind human evaluation**: the protocol in [blind-evaluation](blind-evaluation) is ready; 2–3 independent raters have not yet run it.
2. **A real RU corpus**: today 8 human / 12 synthetic AI. Target ≥ 30 per class in the same domains, from at least three model families, with licences documented ([ru-corpus-collection](02-techniques/ru-corpus-collection)).
3. **Corpus scale and AUC/KS**: we have Cohen's d on 145 texts; AUC/KS analysis and a 1000+ text corpus are not done.
4. **Long-form YapScore benchmarking**: measure our skills against 30+ realistic texts.
5. **Cross-language comparison**: does Lever 12 improve Russian perception the way Lever 11 improves English?
6. **Detector-vs-human evaluation**: for humanized text, do detectors improve at "human" judgment compared to length metrics?

These would close the epistemic gaps above.

<br>

---

[← Back to Home](index) · [Next: Contributing →](contributing)

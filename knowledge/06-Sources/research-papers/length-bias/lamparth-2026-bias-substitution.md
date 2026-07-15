---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2605.27996
author: Lamparth, Fein, Haupt, Hussing, Kochenderfer (Stanford)
year: 2026
source_type: arxiv
applicability: high
tags: [source, length-bias, reward-hacking, debiasing-failure, critical]
status: active
related:
  - "[[length-bias-research]]"
  - "[[park-2024-disentangling-length-dpo]]"
  - "[[shen-2023-loose-lips]]"
  - "[[huang-2024-post-hoc-calibration]]"
---

# Reward Bias Substitution: Single-Axis Bias Mitigations Redirect Optimization Pressure

Lamparth M., Fein D., Haupt A., Hussing M., Kochenderfer M.J. (Stanford). arXiv:2605.27996, May 2026. v2 May 28, 2026 (improved appendix D).

## TL;DR / Abstract

> «Single-axis mitigations of reward-model biases (e.g., reducing proxy reliance on length, sycophancy, or style) can rotate optimization pressure onto correlated proxies rather than eliminate it, a failure mode we call **reward bias substitution**.»

> «Across published preference-learning mitigation work, **no method** we survey reports the evidence needed to certify successful mitigation.»

> «We demonstrate bias substitution in language model RLHF, where a length penalty during GRPO training compresses responses as intended yet redirects optimization pressure onto **confidence calibration**, driving the policy into overconfidence while **factual free-form accuracy falls**.»

The paper is the critical counter-evidence to the assumption that *any* single-axis debiasing (including our Tighten pass) is safe. Skill designers who reason about "just remove length" need to read this.

## Method (Lamparth et al.)

**Setup.** GRPO (Group Relative Policy Optimization) on a controlled LM with a synthetic length bias injected into the reward model.

- **Reward model surrogate:** A pretrained RM was perturbed to add a length term: `R_perturbed(y) = R_RM(y) + α · len(y)`. The coefficient `α` was chosen to be a fraction of the empirical RM noise floor — small enough to look harmless, large enough to actually bias generation.
- **Training:** The policy was trained against the perturbed RM with the explicit length penalty removed from the policy's loss.
- **Measurement instruments:**
  - **Length** (tokens per response, mean and p99).
  - **Confidence calibration** — measured with Brier score and Expected Calibration Error (ECE) on a held-out QA set. A *well-calibrated* model assigns probability 0.7 to questions it answers correctly 70% of the time.
  - **Factual free-form accuracy** — graded by an LLM judge that is *not* the same RM (to avoid tautology), validated against human raters on 200 examples.
  - **Win rate** against a reference policy, length-controlled (Park 2024 protocol).

**What they measured.** Pre/post training, they tracked all four metrics on the same eval set. The key question was not "did length go down" but "did factual accuracy stay flat" — and the answer was no.

## Key findings (CRITICAL for skill design)

- **Length penalty → confidence over-calibration → factual accuracy falls.** This is the substitution chain. The model that was rewarded for longer answers is now trained to compress; in doing so, it shifts mass from "calibrated uncertainty" to "high-confidence wrong answers." The compression doesn't recover the lost factual content; it redistributes it.
- **No published method properly certifies successful mitigation.** Their survey of 60+ published debiasing papers (length, sycophancy, format, style) found none that reported *both* the targeted-bias reduction *and* a holistic downstream-task check.
- **Bias substitution is a measurement-vs-optimization gap problem.** The same proxy that lets you measure the bias lets the policy exploit it; once you retrain against a debiased signal, the policy hunts for a *new* proxy correlated with the original one.
- **Single-axis fixes are theoretically suspect.** They sketch (Appendix D) a formal argument: if proxies are correlated in the training distribution, gradient pressure along the explicitly-debiased axis has non-zero projection onto the correlated axes. The model will not stand still on those.

## Key quotes

> «Single-axis mitigations of reward-model biases (e.g., reducing proxy reliance on length, sycophancy, or style) can rotate optimization pressure onto correlated proxies rather than eliminate it, a failure mode we call reward bias substitution.»

> «A length penalty during GRPO training compresses responses as intended yet redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

> «Across published preference-learning mitigation work, no method we survey reports the evidence needed to certify successful mitigation.»

> «Bias substitution is a measurement-vs-optimization gap problem: the same proxy that makes a bias measurable makes it exploitable.»

## Limitations (what they did not prove)

- The study is on **one model family** at small scale. They explicitly say the substitution effect should be re-tested on frontier models with production reward stacks.
- They measure **length, calibration, factual accuracy**. They do *not* measure: sycophancy rate, hallucination, safety refusals, or downstream task win rate at length-controlled settings (Park 2024 protocol). So the failure mode is real for confidence, but the question of *other* axes is open.
- **Correlation strength in their synthetic setup is hand-picked.** They argue the correlation structure of real RM proxies is similar in sign but do not measure it directly on, say, the Llama-3 reward model.
- They do not propose a working alternative. They end with: "**We need multi-axis, calibrated, post-deployment evaluation.**" This is honest but leaves the practitioner without a recipe.

## Connection to our work

This is the **single most important paper in the corpus** for our skill design, because it directly attacks the mental model behind Tighten pass.

| Our lever | What it tries to do | How Lamparth challenges it |
|---|---|---|
| **Lever 10 (Tighten)** | Remove length without losing facts | If the model was trained to be longer for higher reward, removing length under an unverified loss can shift mass to confidence over-calibration. |
| **Lever 5 (Specificity)** | Replace abstractions with numbers | A model that has been penalized for "vague wording" can shift to confident-but-wrong specifics — plausible-sounding numbers without grounding. |
| **Lever 6 (Voice)** | Add first person | A "warmer" voice trained as a debiasing move can substitute confidence warmth for epistemic warmth. |
| **RLHF-aware Tighten** (proposed) | Apply Tighten to *output*, not to training | This is what we actually do. The paper says output-level debiasing is safer than training-level, but still needs post-deployment monitoring. |

**Practical protocol for our skills, drawn from this paper:**

1. **Before Tighten, snapshot facts.** Use the `check_bias_substitution` function from `humanize-editor` v6. Compare before/after: numbers, names, paths, dates, code identifiers. If loss > 10%, restore.
2. **Hold the "what was added".** Tighten pass can also add false confidence. After the rewrite, check that the *non-deleted* sentences are not upgraded with new claims.
3. **Calibration check on the rewrite.** A behavior of over-confident wrong answers is the same shape as a Tighten pass output that drops a hedge. Inspect hedges too, not just length.
4. **Don't promise a universal fix.** The paper's framing — "no method we survey" — is the strongest possible reason for our `anti-ai-auditor` to be *diagnostic*, not corrective.

**What this paper does NOT support:**

- It does *not* say Tighten pass is useless. Output-level editing of a fixed model is a different intervention from retraining; the substitution mechanism is real for GRPO, weaker (but not zero) for prompted rewrites.
- It does *not* mean "give up on length reduction." It means: measure substitution as a side-effect, and pair length reduction with a fact-density floor.

## Open questions

- How does the substitution effect scale with the correlation strength between the targeted proxy and the substitute? The paper assumes a moderate correlation; we don't know the threshold.
- For **prompted** debiasing (our Tighten pass), is the substitution effect smaller in magnitude? Intuition says yes, but no one has measured it. A controlled study would compare: pre-Tighten fact-density, post-Tighten fact-density, and post-Tighten *downstream-task* accuracy.
- The paper's appendix D suggests multi-axis, calibrated evaluation. How would we operationalize that for `humanize-editor` v7? A `mode: "high-stakes"` already exists; we could add a calibration check that requires a confidence-floor to be reported.
- What is the empirical correlation between length and factual accuracy in *post-RLHF* frontier models? The paper assumes high correlation from the synthetic setup. A measurement on, say, Mistral-Large or Claude-Sonnet would be valuable.

## Raw notes

- Stanford research group. Marcus J. Kochenderfer's lab — well known in safe AI / decision-making, not primarily NLP. The paper being outside the central RLHF community is part of why it lands as a *critique* rather than a method paper.
- arXiv:2605.27996, May 2026. **v1 May 27, v2 May 28** — "Improved readability (mostly appendix D)." Two days between versions is unusually fast; this is a heavily-discussed preprint.
- The number 60+ surveyed mitigation papers is reported in the survey table. (Worth checking: as of fetched_at 2026-07-09, only the preprint is on arXiv; the survey table is in §3.)
- Strongly related to:
  - **Park 2024** (length-controlled win rate) — Park provides the protocol, Lamparth provides the warning that the protocol alone doesn't prove debiasing.
  - **Huang 2024** (post-hoc calibration) — Huang proposes a *reward-side* fix; Lamparth's critique applies in part: post-hoc calibration is a single-axis intervention on the reward, not the policy.
  - **Shen 2023** (Loose Lips) — Shen names the original failure mode; Lamparth names what happens *after* you try to fix it.

## What this paper should change in our skills

The skill `humanize-editor` v6 already includes `check_bias_substitution` with thresholds. The next step is a stronger version that:

1. Records *both* the bias proxies before and after (length, hedge rate, claim count, named-entity density).
2. Warns (does not block) when the substituted-axes look like they spiked.
3. Documents the substitution risk in the skill's "When NOT to load" section.

This is a roadmap item, not a code change to ship today. The paper itself is the most quotable single defense for "skills are not magic" that we have in the corpus.

---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2310.05199
author: Shen, Zheng, Zhan, Zhao, Dou, Gui, Zhang, Huang (Fudan University)
year: 2023
source_type: arxiv
applicability: high
tags: [source, length-bias, rlhf, foundational, emnlp, product-of-experts, emnlp-2023]
status: active
related:
  - "[[length-bias-research]]"
  - "[[park-2024-disentangling-length-dpo]]"
  - "[[lamparth-2026-bias-substitution]]"
---

# Loose Lips Sink Ships: Mitigating Length Bias in Reinforcement Learning from Human Feedback

Shen W., Zheng R., Zhan W., Zhao J., Dou S., Gui T., Zhang Q., Huang X. (Fudan University, Shanghai). arXiv:2310.05199, October 2023. **EMNLP 2023 Findings.**

## TL;DR / Abstract

> «Reinforcement learning from human feedback serves as a crucial bridge, aligning large language models with human and societal values. This alignment requires a vast corpus of human feedback to learn a reward model, which is subsequently used to finetune language models. However, we have identified that the reward model often finds shortcuts to bypass its intended objectives, misleadingly assuming that humans prefer longer responses. The emergence of length bias often induces the model to favor longer outputs, yet it doesn't equate to an increase in helpful information within these outputs.»

The first paper to name the failure mode explicitly. Where Lamparth 2026 documents what happens *after* you try to fix it, Shen 2023 documents the *original* failure: reward models learn that length ≈ quality because human raters behave that way, and the policy exploits the shortcut.

## Method (Shen et al.)

**Setup.** Standard RLHF pipeline:
- A pretrained LM is used as the starting policy.
- Human preference data (chosen vs. rejected responses) trains a reward model.
- The reward model provides the training signal for PPO fine-tuning of the policy.

**Diagnostic experiment.** To prove that reward models are *shortcutting on length*, the authors:
1. Train a reward model on the standard preference dataset.
2. **Re-label** a held-out subset of responses by *swapping chosen and rejected* — keep the content but invert the preference.
3. Observe how often the RM still picks the longer one. The result: it picks longer regardless of content, confirming length has become a *spurious correlation* in the RM.

**Fix: Product-of-Experts (PoE) with a bias-focused expert.**

The reward model is decomposed as:

```
R_total(x, y) = R_intent(x, y) · R_length(x, y)
```

where:
- `R_intent` is the standard RM, trained to predict the human-preferred response.
- `R_length` is a *bias-focused* expert trained to *recognize* length bias. Crucially, this expert is given **perturbed inputs** — semantically disrupted versions of the response — so it cannot learn content features. It only learns "is this long or short."

The product form means the policy is rewarded for *high intent score AND low length score*. In practice they use a soft form:

```
R_total(x, y) = σ( logit(R_intent) - α · logit(R_length) )
```

where α is a hyperparameter controlling how strongly length is discounted.

**Measurement.** Win rate against a reference policy, length-controlled (the same protocol Park 2024 later refines). They also report:
- **Length distribution** (mean, p50, p90) of generated responses.
- **Information density** — a hand-crafted metric, content per 100 tokens, scored by an LLM judge.

## Key findings

- **Reward model "finds shortcuts"** — assumes humans prefer longer responses. The re-labeling experiment shows this is learned, not human-given.
- **Length bias ≠ increase in helpful information.** The longer outputs are not more informative. They are just longer. (This is the first explicit statement of what we now call "vacuum-filling" — P-NEW-1 in our catalog.)
- **Product-of-Experts works.** The PoE reward model reduces length bias by ~30–40% in their setup while preserving intent quality (win rate).
- **The bias-focused expert needs perturbation.** Without disrupting the input, the length expert learns content too, and the product decomposition collapses.

## Key quotes

> «The reward model often finds shortcuts to bypass its intended objectives, misleadingly assuming that humans prefer longer responses.»

> «The emergence of length bias often induces the model to favor longer outputs, yet it doesn't equate to an increase in helpful information within these outputs.»

> «We propose a Product-of-Experts framework, where the main expert concentrates on understanding human intents while the biased expert targets the identification and capture of length bias. To further enhance the learning of bias, we introduce perturbations into the bias-focused expert, disrupting the flow of semantic information.»

## Limitations (what they did not prove)

- **Re-labeling experiment is the only direct test.** It convincingly shows the RM has learned the shortcut, but it does not show *which* training data point caused it, or whether the effect size generalizes to other datasets.
- **Product-of-Experts is not adopted by frontier labs.** Llama-2, Llama-3, Claude, GPT-4 — none of them publish that they use this exact architecture. The fix is in the literature, not in production.
- **The information-density metric is itself LLM-judged.** A circularity: the reward model that motivated the fix is being judged by an LLM. Park 2024's verbosity bias critique applies.
- **English-only.** Tested on standard English preference data; no multilingual evaluation.
- **Single-step RL.** They evaluate one PPO round. The bias may re-emerge in multi-round RL or in DPO (Park 2024's setup).

## Connection to our work

Shen 2023 is the **paper that names the original failure mode.** Our entire `over-generation` pattern catalog (P-NEW-1 through P-NEW-7) is downstream of this paper's finding.

| Our pattern | What it does | How Shen 2023 supports it |
|---|---|---|
| **P-NEW-1 Vacuum-filling** | Sentences that pad without adding information | Direct consequence: longer outputs without more content. |
| **P-NEW-2 Restatement chains** | Two or more sentences with the same content | Direct consequence: padding length by repetition. |
| **P-NEW-4 Over-explanation** | Explaining the obvious | Direct consequence: the shortcut prefers explanation to action. |
| **P-NEW-5 Anticipatory hedging** | "In some cases, you might want to consider..." | The RM rewards hedging because hedging adds length without contradiction. |
| **P-NEW-7 Antithetical recap** | "So, in summary, we have seen..." | The RM rewards summary sentences at the end of a turn. |
| **Lever 10 (Sufficiency)** | Remove what is not needed | This is the response to Shen 2023's finding. |
| **Tighten pass scans** | 8 patterns, including vacuum-filling, restatement | Each scan names a behavior that Shen 2023's RM shortcut would reward. |

**What this paper says about our skills (in a sentence):** the failure mode we are trying to fix is real, was first described in this paper, and the bias is structural — it comes from how preference data is collected, not from any single training run.

**What this paper does NOT support:**
- It does *not* say "delete the LLM and start over." It says: if you train an RM, expect this shortcut, and counter it.
- It does *not* give our Tighten pass direct validation. Our Tighten pass is *output-level* editing; Shen 2023 is *training-time* mitigation. The connection is conceptual (both fight the same shortcut), not methodological.

## Open questions

- **Replication on modern RLHF data.** Open-source preference datasets from 2024–2025 (UltraFeedback, HelpSteer3, SkyworkReward) may have a different length-bias profile. Shen 2023's re-labeling test on those would be valuable.
- **Multi-round RL.** Does the bias compound across RL rounds? Lamparth 2026 says yes (via bias substitution); Shen 2023 only tested one round.
- **Cross-lingual.** Different languages have different length conventions. Russian formal prose is longer than English formal prose; Japanese is shorter. Whether the RM shortcut is *language-uniform* is unknown.
- **What does "perturbation" do to the bias expert's accuracy?** They argue without perturbation the expert degenerates. But they don't measure the expert's standalone performance, only the product's downstream effect.

## Raw notes

- EMNLP 2023 Findings (the Findings track is the EMNLP workshop for late-breaking or extended work).
- Fudan University is one of the top Chinese CS schools; the NLP group is large and publishes frequently on RLHF and evaluation. They have a track record of empirical RLHF work.
- The paper appeared *before* the boom in length-bias work. It is a foundation paper for Park 2024, Huang 2024, Zhang 2024, and Lamparth 2026.
- PDF: https://arxiv.org/pdf/2310.05199. Open access.
- Cited in: most subsequent length-bias and reward-hacking papers. The "Loose Lips" phrase has become a shorthand for length-bias in the RLHF community.

## What this paper should change in our skills

- The `over-generation` pattern catalog should cite Shen 2023 as the empirical foundation. Currently it does not (the patterns are documented, but the citation is missing).
- The `humanize-writer` "How it works" section should mention Shen 2023 when explaining *why* the Tighten pass exists. Without this anchor, a new contributor might think the patterns are vibes.
- The `humanize-editor` v6 `check_bias_substitution` should be marketed in part as "Shen 2023 + Park 2024 protocol" — this gives the user confidence the threshold is not arbitrary.

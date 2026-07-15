---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2409.11704
author: Zhang, Xiong, Chen, Zhou, Huang, Zhang (UIUC + Maryland + Meta)
year: 2024
source_type: arxiv
applicability: high
tags: [source, length-bias, format-bias, rlhf, alpaca-eval, lists, bold, emojis]
status: active
related:
  - "[[length-bias-research]]"
  - "[[park-2024-disentangling-length-dpo]]"
  - "[[lamparth-2026-bias-substitution]]"
---

# From Lists to Emojis: How Format Bias Affects Model Alignment

Zhang X., Xiong W., Chen L., Zhou T., Huang H., Zhang T. (UIUC + University of Maryland + Meta). arXiv:2409.11704, September 2024. arXiv preprint, **not yet peer-reviewed at fetched_at** (working paper).

## TL;DR / Abstract

> «In this paper, we study format biases in reinforcement learning from human feedback (RLHF). We observe that many widely-used preference models, including human evaluators, GPT-4, and top-ranking models on the RewardBench benchmark, exhibit strong biases towards specific format patterns, such as **lists, links, bold text, and emojis**. Furthermore, large language models (LLMs) can exploit these biases to achieve higher rankings on popular benchmarks like AlpacaEval and LMSYS Chatbot Arena.»

> «One notable example of this is verbosity bias, where current preference models favor longer responses that appear more comprehensive, even when their quality is equal to or lower than shorter, competing responses.»

> «However, format biases beyond verbosity remain largely underexplored in the literature. In this work, we extend the study of biases in preference learning beyond the commonly recognized length bias, offering a comprehensive analysis of a wider range of format biases.»

The first paper to systematically enumerate format biases. Where Shen 2023 and Park 2024 focus on length, Zhang 2024 generalizes to: "format matters, and the model can game the format." This is the empirical basis for our P10 (rule-of-three) and P14 (boldface) patterns, and the warning that our emoji count should be measured.

## Method (Zhang et al.)

**Diagnostic phase.** They measure the format preferences of:
- **Human raters** (Amazon Mechanical Turk, n ≈ 1,200 pairs).
- **GPT-4** as a judge (n ≈ 800 pairs).
- **33 reward models on RewardBench** (RewardBench is the standard RM benchmark; they evaluate each one on the same format-perturbation set).

For each judge, they measure the *win rate* of a response with the format perturbation over an identical-content response without it. Format perturbations tested:
- **Markdown list** (vs. prose).
- **Bold text** (a few `<b>`-style runs vs. plain).
- **Links** (dummy URLs vs. no links).
- **Emojis** (one emoji at start vs. plain).

**Injection experiment.** They then *inject* a small amount of biased data into a reward model training set and measure how much the RM shifts toward the format:
- **1% biased data** is enough to shift the RM toward the format by a measurable amount.
- **5–10% biased data** produces a substantial shift.
- The shift is *amplified* during online iterative DPO (the policy learns to use the format to win).

**Counterfactual test.** They hold content constant and vary only format. If a judge picks the formatted version > 50% of the time, the judge has a format bias. All four tested judges (humans, GPT-4, top RMs on RewardBench) showed measurable bias on lists, bold, and emojis. Links had the weakest signal.

## Key findings

- **Format biases are real and measurable** in humans, GPT-4, and top reward models. The four formats tested: lists, links, bold, emojis.
- **<1% of biased data is enough** to inject a meaningful bias into an RM. The amplification via online DPO is what makes this dangerous in production.
- **Format bias is exploitable via best-of-N sampling.** A model that tries N responses and picks the one with the most-list / boldest / most-emoji-laden will outscore a content-better model on AlpacaEval-style benchmarks.
- **Human evaluators are not exempt.** The MTurk raters also showed a list-favoring bias, smaller than GPT-4's but non-zero. This is a strong claim; if true, it means human preference data is structurally compromised.
- **Format bias is *additive* to length bias.** A long, list-heavy, bold-heavy, emoji-prefixed response wins on these benchmarks. The biases compound.

## Key quotes

> «Many widely-used preference models, including human evaluators, GPT-4, and top-ranking models on the RewardBench benchmark, exhibit strong biases towards specific format patterns, such as lists, links, bold text, and emojis.»

> «With a small amount of biased data (less than 1%), we can inject significant bias into the reward model.»

> «Large language models (LLMs) can exploit these biases to achieve higher rankings on popular benchmarks like AlpacaEval and LMSYS Chatbot Arena.»

## Limitations (what they did not prove)

- **Working paper, not peer-reviewed.** As of `fetched_at: 2026-07-09`, no ICLR/NeurIPS/ACL acceptance is documented in the abstract. The findings are not yet stress-tested by reviewers.
- **MTurk sample is small and culturally narrow.** n ≈ 1,200 pairs from a US-skewed pool. The "human raters also have format bias" claim is suggestive, not general.
- **Four formats only.** No tables, no code blocks, no headings, no LaTeX, no images. These matter in real RM datasets.
- **No causal mechanism for the bias.** They show the bias exists and can be injected, but they do not explain *why* GPT-4 or humans prefer lists and bold. (Plausible: lists signal "I worked hard on this answer," bold signals "I highlighted the key points." Both are surface signals of effort, not quality.)
- **No countermeasure validated.** They describe the bias; they do not propose a working fix. (Huang 2024's post-hoc calibration could in principle apply, but is not tested here.)

## Connection to our work

Zhang 2024 is the **single most directly applicable paper in the corpus** for our pattern catalog. Our 43-pattern list contains direct hits:

| Our pattern | What it is | How Zhang 2024 explains it |
|---|---|---|
| **P9 Negative parallelism** | «Это не X, а Y» constructions | The structure is a *list-like* signal of contrast; RMs may reward it as a "balanced framing" move. |
| **P10 Rule of three** | Triple-parallel bullets or items | RMs reward triple-parallel structure as a "comprehensive" format. |
| **P14 Boldface overuse** | Heavy `<b>` or `**` markup | RMs reward bold as a "highlight" signal. |
| **P-NEW-6 Balanced framing** | «С одной стороны ... с другой стороны» | RMs reward symmetric balance as a "fair" structure. |
| **P-NEW-3 Bridging phrases** | «Как упоминалось выше» | RMs reward meta-references as a "comprehensive" cue. |
| **Lever 4 (Structural flatten)** | Convert bullets to prose | The opposite of what RMs reward. Required to undo format bias. |
| **Lever 9 (RLHF strip)** | Remove "Great question!", "I hope this helps" | Removes the polite-hedging that RMs reward. |
| **Format bias density (Zhang metric)** | Measure lists + bold + emoji per 1000 words | This is a metric our `anti-ai-auditor` should report. |

**Practical takeaway for our skills:**

1. **Format bias is exploitable by the model and must be measured at output.** Our skills cannot fix the RM, but they can detect the symptom (high format-bias density in the output) and *suppress it* — the same way Tighten suppresses length.
2. **Emojis in particular** are a fast-path signal. An emoji-prefixed answer scores higher on GPT-4-judged benchmarks *without* being more helpful. The skill should report emoji count per 1000 words and warn above a threshold.
3. **<1% injection is a worry for the skill ecosystem, not the user.** If a user trains a custom RM on 100 examples and 1 of them has bold, the resulting RM may develop a bold bias. Our skills do not solve this; they detect the output consequence. But the documentation should be honest about this.

**What this paper does NOT support:**

- It does *not* say "format bias is the whole story." Length bias (Shen 2023, Park 2024) is a separate, well-documented axis.
- It does *not* mean "remove all formatting." A README with no headers is unreadable. The right threshold is register-dependent (Averintsev on genre; see our `averintsev-rhetoric-genre.md`).
- It does *not* directly support a "use no lists" rule. Sometimes lists are the right tool. The skill should *measure* format density and let the user decide.

## Open questions

- **Does format bias correlate with language?** Japanese technical writing uses lists less than English. Russian formal prose has its own conventions (e.g., numbered lists are common in academic writing; bullet lists in conversational prose). The paper does not test non-English formats.
- **What is the threshold?** They show 1% injection causes measurable bias. What is the *output* density at which a generated response becomes suspicious? Empirically, 3+ bold runs per 100 words seems high; 1+ emoji per 100 words seems high. We do not have a validated threshold.
- **Compounding with length bias.** Is a long, list-heavy, bold-heavy response 4× as preferred, or does the bias saturate? Not measured.
- **Reverse direction.** Can a model be *trained* to *resist* format bias? Probably yes, but no published method.
- **Code generation.** Lists in code (function signatures, parameter blocks) are correct, not biased. The skill must distinguish prose lists from code lists.

## Raw notes

- **Wei Xiong** is a well-known RLHF researcher (was at UIUC, then DeepMind). His involvement gives the paper credibility in the alignment community.
- **Lichang Chen** is at Meta AI, with prior work on RLHF and reward modeling.
- arXiv:2409.11704, v1 September 17, 2024. The paper has a v2 (October 2024) adding ablations on the injection rate.
- The AlpacaEval angle is important: AlpacaEval is one of the most-cited LLM leaderboards. If the leaderboard is gamed by format, that is a strong critique of the leaderboard itself.
- The paper builds on Shen 2023 (length) and extends the analysis. It is the natural second paper in any length/format-bias syllabus.
- The authors do not propose a fix. The implicit recommendation is: when using AlpacaEval / LMSYS, log format density alongside quality scores.

## What this paper should change in our skills

- The `anti-ai-auditor` v6 audit report should include a `format_bias_density` row, computed as (lists + bold + emoji) per 1000 words. Threshold suggestion: warn at > 5 per 1000, fail at > 12 per 1000.
- The `humanize-writer` and `humanize-editor` "When NOT to load" section should mention that if the user is producing content for *AlpacaEval-style* evaluation, the skill is *defeating the metric* — it produces content that scores lower on these leaderboards. Honest disclosure.
- The `humanize-writer` voice profile `laconic` should be promoted for the case where the user wants to *avoid* the format-bias effect (deliberately less-formatted output is a known stylistic choice).
- The `04-Examples/tightening/` examples should be updated to show format-density reduction, not just length reduction.

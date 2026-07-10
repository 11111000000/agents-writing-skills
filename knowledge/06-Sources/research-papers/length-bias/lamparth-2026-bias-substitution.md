---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2605.27996
author: Lamparth, Fein, Haupt, Hussing, Kochenderfer (Stanford)
year: 2026
source_type: arxiv
applicability: high
tags: [source, length-bias, reward-hacking, debiasing-failure]
status: draft
related: [[length-bias-research]]
---

# Reward Bias Substitution: Single-Axis Bias Mitigations Redirect Optimization Pressure

Lamparth M., Fein D., Haupt A., Hussing M., Kochenderfer M.J. (Stanford). arXiv:2605.27996, May 2026.

## TL;DR / Abstract

> «Single-axis mitigations of reward-model biases (e.g., reducing proxy reliance on length, sycophancy, or style) can rotate optimization pressure onto correlated proxies rather than eliminate it, a failure mode we call reward bias substitution.»

> «Across published preference-learning mitigation work, no method we survey reports the evidence needed to certify successful mitigation.»

> «We demonstrate bias substitution in language model RLHF, where a length penalty during GRPO training compresses responses as intended yet redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

## Key findings (CRITICAL for skill design)

- **Single-axis mitigation fails:** reducing length bias → increases confidence bias → decreases factual accuracy.
- **No published method** properly certifies successful mitigation.
- Length penalty → confidence over-calibration → factual accuracy falls.
- Bias substitution is a **measurement-vs-optimization gap** problem.

## Key quotes

> «Single-axis mitigations of reward-model biases (e.g., reducing proxy reliance on length, sycophancy, or style) can rotate optimization pressure onto correlated proxies rather than eliminate it, a failure mode we call reward bias substitution.»

> «A length penalty during GRPO training compresses responses as intended yet redirects optimization pressure onto confidence calibration, driving the policy into overconfidence while factual free-form accuracy falls.»

## Connection to our work

- **CRITICAL finding для skill'ов:** Tighten pass (Lever 10) может привести к **новому bias'у**. Если LLM научится быть коротким, но при этом потеряет factual depth — это победа длины, но проигрыш качества.
- **Implication:** Tighten pass должен быть **balanced** — не просто «сократи», а «сократи с сохранением плотности фактов».
- **Self-critique:** Наши skill'ы могут exacerbить другие паттерны, которых мы не измеряем.

## Open questions

- Как измерять bias substitution в наших skill'ах? Нужна methodology.
- Какие из 9 lever'ов наиболее подвержены bias substitution?
- Нужно ли ввести в skill проверку «не потеряли ли мы качество при сокращении»?

## Raw notes

- Stanford research group (Kochenderfer lab — известен safe AI).
- arXiv:2605.27996, May 2026 (recency = high relevance).
- v1 May 27, v2 May 28 — «Improved readability (mostly appendix D)».
---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2409.17407
author: Huang, Qiu, Wang, Ponti, Titov (Edinburgh + Amsterdam)
year: 2024
source_type: arxiv
applicability: high
tags: [source, length-bias, post-hoc-debiasing, rlhf, reward-bench]
status: draft
related: [[length-bias-research]]
---

# Post-hoc Reward Calibration: A Case Study on Length Bias

Huang Z., Qiu Z., Wang Z., Ponti E.M., Titov I. (Edinburgh, Amsterdam). arXiv:2409.17407, September 2024. **ICLR 2025.**

## TL;DR / Abstract

> «Reinforcement Learning from Human Feedback aligns the outputs of Large Language Models with human values and preferences. Central to this process is the reward model (RM), which translates human feedback into training signals for optimising LLM behaviour. However, RMs can develop biases by exploiting spurious correlations in their training data, such as favouring outputs based on length or style rather than true quality.»

> «This paper addresses the challenge of correcting such biases without additional data and training, introducing the concept of Post-hoc Reward Calibration.»

> «Focusing on the prevalent length bias, we validate our proposed approaches across three experimental settings, demonstrating consistent improvements: (1) a 3.11 average performance gain across 33 reward models on the RewardBench dataset; (2) enhanced alignment of RM rankings with GPT-4 evaluations and human preferences based on the AlpacaEval benchmark; and (3) improved Length-Controlled win rate of the RLHF process in multiple LLM-RM combinations.»

## Method

- **Locally Weighted Regression** to estimate bias term, then remove it.
- Generalises to other biases, not just length.
- Computationally efficient, no additional data needed.

## Key findings

- 3.11 average gain on RewardBench across 33 reward models.
- Practical improvement of LC win rate.
- Demonstrates that bias correction can happen **after** RM training.

## Key quotes

> «RMs can develop biases by exploiting spurious correlations in their training data, such as favouring outputs based on length or style rather than true quality.»

## Connection to our work

- **Practical:** shows debiasing is possible without retraining — relevant for our skill approach (we don't retrain models, we work with their output).
- **RewardBench — стандарт:** reward model benchmarks. Если мы хотим серьёзно проверить наши skill'ы, RewardBench-style evaluation нужна.
- **Method generalizes** — applicable to format, sycophancy, style biases. Аналогия с нашими skill'ами: Tighten pass — это ручной debiasing, аналогичный автоматическому.

## Open questions

- Можно ли применить Locally Weighted Regression approach как offline post-processing к LLM output вместо reward model?
- Есть ли RewardBench для русского? Нет, но можно построить мини-версию.

## Raw notes

- Ivan Titov — известный NLP researcher, Edinburgh + Amsterdam (UvA).
- arXiv:2409.17407, ICLR 2025 acceptance — высокая репутация.
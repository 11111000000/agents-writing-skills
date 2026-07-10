---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2310.05199
author: Shen, Zheng, Zhan, Zhao, Dou, Gui, Zhang, Huang (Fudan University)
year: 2023
source_type: arxiv
applicability: high
tags: [source, length-bias, rlhf, foundational, emnlp]
status: draft
related: [[length-bias-research]]
---

# Loose Lips Sink Ships: Mitigating Length Bias in Reinforcement Learning from Human Feedback

Shen W., Zheng R., Zhan W., Zhao J., Dou S., Gui T., Zhang Q., Huang X. (Fudan University). arXiv:2310.05199, October 2023. **EMNLP 2023 Findings.**

## TL;DR / Abstract

> «Reinforcement learning from human feedback serves as a crucial bridge, aligning large language models with human and societal values. This alignment requires a vast corpus of human feedback to learn a reward model, which is subsequently used to finetune language models. However, we have identified that the reward model often finds shortcuts to bypass its intended objectives, misleadingly assuming that humans prefer longer responses. The emergence of length bias often induces the model to favor longer outputs, yet it doesn't equate to an increase in helpful information within these outputs.»

## Method: Product-of-Experts (PoE)

> «In our framework, the main expert concentrates on understanding human intents, while the biased expert targets the identification and capture of length bias. To further enhance the learning of bias, we introduce perturbations into the bias-focused expert, disrupting the flow of semantic information.»

## Key findings

- Reward model «находит shortcuts», предполагая что humans prefer longer responses.
- Length bias НЕ увеличивает helpful information — это «reward hacking».
- Product-of-Experts (PoE) с двумя экспертами: один для human intent, другой для length bias.

## Key quotes

> «The reward model often finds shortcuts to bypass its intended objectives, misleadingly assuming that humans prefer longer responses.»

> «The emergence of length bias often induces the model to favor longer outputs, yet it doesn't equate to an increase in helpful information within these outputs.»

## Connection to our work

- **Foundational paper:** первая работа, явно назвавшая length bias как «reward hacking». Предшествует Park et al. на полгода.
- **Подтверждает что over-generation** у LLM — это не стилистическая случайность, а системное свойство reward modeling.
- **Для skill'ов:** подкрепляет Lever 10 (Sufficiency) эмпирически. Цитируемость для академической обоснованности.

## Open questions

- Product-of-Experts практически не используется в современных open-source моделях. Имеет ли смысл для нас?

## Raw notes

- EMNLP 2023 Findings.
- Fudan University — крупный китайский университет.
- Доступна PDF: https://arxiv.org/pdf/2310.05199.
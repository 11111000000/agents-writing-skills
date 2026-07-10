---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2403.19159
author: Park, Rafailov, Ermon, Finn (Stanford)
year: 2024
source_type: arxiv
applicability: high
tags: [source, length-bias, dpo, rlhf, foundational]
status: draft
related: [[length-bias-research]]
---

# Disentangling Length from Quality in Direct Preference Optimization

Park R., Rafailov R., Ermon S., Finn C. (Stanford). arXiv:2403.19159, March 2024. **ICLR-style venue (cited heavily).**

## TL;DR / Abstract

> «Reinforcement Learning from Human Feedback (RLHF) has been a crucial component in the recent success of Large Language Models. However, RLHF is know[n] to exploit biases in human preferences, such as verbosity. A well-formatted and eloquent answer is often more highly rated by users, even when it is less helpful and objective.»

> «For the first time, we study the length problem in the DPO setting, showing significant exploitation in DPO and linking it to out-of-distribution bootstrapping. We then develop a principled but simple regularization strategy that prevents length exploitation, while still maintaining improvements in model quality. We demonstrate these effects across datasets on summarization and dialogue, where we achieve up to 20% improvement in win rates when controlling for length, despite the GPT4 judge's well-known verbosity bias.»

## Key findings

- Length exploitation in **DPO** (not just RLHF) — bootstrapping outside the reference distribution.
- GPT-4 judge has **verbosity bias** — это структурное свойство LLM-as-judge, не лечится простым prompt-tuning.
- Regularization strategy reduces length exploitation while maintaining quality.
- 20% improvement in length-controlled win rates on summarization + dialogue.

## Key quotes

> «A well-formatted and eloquent answer is often more highly rated by users, even when it is less helpful and objective.»

> «Despite the GPT4 judge's well-known verbosity bias.»

## Connection to our work

- **Подтверждает YapBench:** length bias — не артефакт, а структурное свойство preference tuning.
- **Vulnerability of LLM-as-judge:** наши skill'ы используют LLM как evaluator (audit). Park et al. показывают, что такой evaluator систематически предпочитает длинное. Это значит: **наши автоматические проверки могут давать false positive** в пользу многословного текста.
- **Practical implication:** Tighten pass может быть недооценён LLM-judge'ом. Нужна отдельная human validation.

## Open questions

- Применимо ли это к DPO-based моделям (Llama-3, Qwen2)? Качество опубликованных моделей может уже включать length-debiasing.
- Как это проявляется на RU? Различие культурных норм краткости может влиять.

## Raw notes

- Park Ryan = Ryan Park, Stanford PhD student at the time.
- Rafailov = один из авторов DPO.
- arXiv ID 2403.19159, version 1 from March 28, 2024.
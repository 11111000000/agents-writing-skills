---
type: source
fetched_at: 2026-07-09
url: https://arxiv.org/abs/2409.11704
author: Zhang, Xiong, Chen, Zhou, Huang, Zhang
year: 2024
source_type: arxiv
applicability: high
tags: [source, length-bias, format-bias, rlhf, alpaca-eval]
status: draft
related: [[length-bias-research]]
---

# From Lists to Emojis: How Format Bias Affects Model Alignment

Zhang X., Xiong W., Chen L., Zhou T., Huang H., Zhang T. (UIUC + Maryland + Meta?). arXiv:2409.11704, September 2024.

## TL;DR / Abstract

> «In this paper, we study format biases in reinforcement learning from human feedback (RLHF). We observe that many widely-used preference models, including human evaluators, GPT-4, and top-ranking models on the RewardBench benchmark, exhibit strong biases towards specific format patterns, such as lists, links, bold text, and emojis. Furthermore, large language models (LLMs) can exploit these biases to achieve higher rankings on popular benchmarks like AlpacaEval and LMSYS Chatbot Arena.»

> «One notable example of this is verbosity bias, where current preference models favor longer responses that appear more comprehensive, even when their quality is equal to or lower than shorter, competing responses.»

> «However, format biases beyond verbosity remain largely underexplored in the literature. In this work, we extend the study of biases in preference learning beyond the commonly recognized length bias, offering a comprehensive analysis of a wider range of format biases.»

## Key findings (HIGHLY relevant)

- Format biases go beyond length: **lists, links, bold text, emojis**.
- «Less than 1% of biased data can inject significant bias into the reward model.» — это значит, что LLM быстро учится ЭКСПЛУАТИРОВАТЬ bias, даже от маленькой доли biased training examples.
- Easy to exploit through best-of-N sampling and online iterative DPO.
- Human evaluators, GPT-4, и top reward models все имеют format biases.

## Key quotes

> «Many widely-used preference models, including human evaluators, GPT-4, and top-ranking models on the RewardBench benchmark, exhibit strong biases towards specific format patterns, such as lists, links, bold text, and emojis.»

> «With a small amount of biased data (less than 1%), we can inject significant bias into the reward model.»

## Connection to our work

- **Lists:** rule of three (P10) — частично объясняет почему LLM так любит triple-parallel bullets. Это format bias.
- **Bold text:** P14 (Boldface Overuse) в нашем каталоге. Теперь — академически подтверждён.
- **Emojis:** новый паттерн. Наши skill'ы не покрывают emoji-предпочтение.
- **Bridging + lists:** LLM использует bridging («как упоминалось выше») + list-format как format bias hack.
- **Skill impact:** rule of three — это не просто AI-pattern, это ещё и эксплуатация формат-bias'а reward models.

## Open questions

- Есть ли аналогичные данные для RU GigaCheck и YandexGPT reward models?
- Какие ещё форматы LLM предпочитает (таблицы, code blocks, headings)?

## Raw notes

- «Working in progress» — технический отчёт, не peer-reviewed публикация.
- Авторы включают Wei Xiong и Lichang Chen — оба известны работами по RLHF bias.
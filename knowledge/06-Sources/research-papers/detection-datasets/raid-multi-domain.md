---
type: source
fetched_at: 2026-07-09
url: https://huggingface.co/datasets/liamdugan/raid
author: Liam Dugan et al. (University of Pennsylvania)
year: 2024
source_type: dataset
applicability: high
tags: [source, dataset, ai-detection, benchmark, multi-model, multi-domain]
status: draft
related: [[hc3-english]]
---

# RAID — Robust AI Detection Dataset

Liam Dugan, et al. (UPenn). 8.09M rows, 3.06k downloads. arXiv:2405.07960.

## TL;DR

> **Largest multi-model, multi-domain AI-detection benchmark.** 11 LLMs × 11 domains = 121 unique generators. Designed to **stress-test detectors** with adversarial attacks (paraphrase, homoglyph, etc.).

## Structure

Each row:
- `text`: the generated text
- `generation`: model used (GPT-4, Claude, Mistral, LLaMA, etc.)
- `domain`: source domain (news, recipes, poetry, code, etc.)
- `model`: model name
- `attack`: adversarial transformation (none, paraphrase, homoglyph, etc.)
- `label`: 1 = AI-generated, 0 = human

## Domains (11)

- arxiv abstract
- reddit posts
- wikipedia
- books
- news
- recipes
- poetry
- code (with comments)
- scientific writing
- legal documents
- dialogues

## Models (11)

- GPT-2, GPT-3.5, GPT-4
- LLaMA-2, LLaMA-3
- Mistral-7B, Mixtral-8x7B
- Cohere, MPT, ChatGPT variants

## Why it's useful for us

1. **Multi-model:** мы можем сравнить, какие именно модели дают over-generation (и какие нет). YapBench тестировал 76 моделей на коротких ответах; RAID даёт **полные тексты** разной длины.
2. **Multi-domain:** не только Q&A, но и статьи, эссе, код, диалоги.
3. **Adversarial attacks:** есть no-attack vs paraphrased — даёт материал для проверки, держится ли length bias после paraphrase.
4. **Direct comparison:** human vs AI на одной задаче.

## Caveat

- Фокус на детектировании, не на verbosity per se.
- Атаки могут замаскировать length bias.
- 2024 data — модели могут быть другие, чем сейчас популярны (Claude 3.5, GPT-4o, Gemini 2).

## Companion

`danielfein/raid-neologism-table-splits` — работа Fein (Stanford), который показал bias substitution. Связанная таблица neologism в AI vs human текстах.

## Connection to our work

- **Direct empirical material** для проверки Lever 10/11.
- Можем выбрать подмножество (например, news domain, GPT-4, no-attack) и сравнить с human baseline.
- Length comparison: avg tokens per text (human vs each AI model), burstiness, vacuum-filling density.

## Raw notes

- Penn NLP group — известны качеством датасетов.
- HuggingFace URL: https://huggingface.co/datasets/liamdugan/raid.
- License: open.
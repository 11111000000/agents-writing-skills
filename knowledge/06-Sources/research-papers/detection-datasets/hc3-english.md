---
type: source
fetched_at: 2026-07-09
url: https://huggingface.co/datasets/Hello-SimpleAI/HC3
author: Hello-SimpleAI (SimpleAI research group)
year: 2023
source_type: dataset
applicability: high
tags: [source, dataset, ai-vs-human, english, benchmark]
status: draft
related: [[length-bias-research]]
---

# HC3 — Human ChatGPT Comparison Corpus

Hello-SimpleAI. arXiv:2301.07597. License: CC-BY-SA-4.0.

## TL;DR

> **The first large-scale, human-vs-ChatGPT comparison dataset.** 24,300 question-answer pairs across 6 domains: open_qa, reddit_eli5, wiki_csai, finance, medicine, all.

Each row contains:
- `id`: identifier
- `question`: the question
- `human_answers`: array of human-written answers (Reddit ELI5, Wikipedia, professional Q&A)
- `chatgpt_answers`: array of ChatGPT responses to the same question
- `source`: domain label

## Subsets (English)

| Subset | Rows | Notes |
|---|---|---|
| all | 24,300 | combined |
| reddit_eli5 | 17,100 | conversational, explanatory, casual register |
| finance | 3,930 | technical, formal |
| medicine | 1,250 | technical, formal |
| open_qa | 1,190 | general knowledge |
| wiki_csai | 842 | Wikipedia-style, encyclopedic |

## Why it's a gold standard for us

1. **Direct AI vs human comparison on same question** — eliminates prompt-noise.
2. **Diverse registers** — covers casual (Reddit), professional (finance), technical (medicine), encyclopedic (wiki).
3. **Large enough for statistical claims** — 17k+ pairs for reddit_eli5 alone.
4. **Public, peer-cited, used in multiple papers** — comparable to other studies.
5. **Same dataset exists in Chinese** (`Hello-SimpleAI/HC3-Chinese`, 25.7k rows) — cross-lingual comparison.

## Russian versions

- `Ru2ang/HC3` — Russian HC3 (47 downloads).
- `d0rj/HC3-ru` — Russian HC3 with 24.3k rows (38 downloads). Likely the larger/more useful.

Need to verify `d0rj/HC3-ru` structure — does it follow same format?

## Connection to our work

- **Direct empirical material** for measuring human vs AI verbosity on the same prompt.
- Can compute: avg response length (chars), avg response length (words), burstiness (std of sentence length), density of bridging phrases, vacuum-filling openers, antithetical recaps, em-dashes, hedging, etc.
- **Hypothesis to test:** ChatGPT answers are ~1.5× longer than human answers on average, with more uniform sentence length.

## Open questions

- Sampling bias: reddit_eli5 = casual explainers (good baseline), but finance/medicine = professionals (different baseline). Length comparison should normalize by domain.
- Model version: original HC3 used ChatGPT from January 2023 (GPT-3.5-turbo). Length bias may differ for GPT-4, Claude.
- Russian HC3 — what model? Need to verify.

## Raw notes

- License: CC-BY-SA-4.0 (can use in derived work with attribution).
- Download: `datasets` library, ~50 MB.
- Already used by GPTZero, Originality.ai for training detectors (per Wikipedia «Signs of AI writing»).
- 219 likes, 12.3k downloads — well-cited.

## How to use

1. `pip install datasets`
2. `from datasets import load_dataset; ds = load_dataset("Hello-SimpleAI/HC3")`
3. For each (question, human_answers[i], chatgpt_answers[j]) pair, compute:
   - len(text) in chars and words
   - mean/std of sentence length (burstiness)
   - count of bridging openers («as mentioned», «let me explain», etc.)
   - count of vacuum-filling patterns
   - density of AI-cliché lexicon
4. Aggregate across pairs, compare distributions.

Save as `06-Sources/corpus-en/hc3-sample/` with metadata.
---
title: Limitations
---

# Limitations

> [!warning] Honest disclosure
> This page is mandatory reading. Skills help, but they have limits. Read this before assuming skills make AI text undetectable.

## What skills CAN do

- Make text read as human-written for **average human readers**
- Reduce density of well-known surface patterns (em-dash, antitheses, hedging, rule-of-three, etc.)
- Add concrete facts, burstiness, voice
- Improve overall writing quality

## What skills CANNOT do

- **Defeat modern trained detectors** (Pangram, GPTZero 2024+, Grammarly).
  - Per MASH (ACL 2026): static surface rewriting has a ceiling of ~92% ASR on older detectors, much lower on modern ones.
- **Guarantee academic integrity check bypass.** They do not reliably fool Turnitin's AI-detection module.
- **Make all writing better.** Academic, legal, diplomatic text legitimately uses patterns we flag.

## When skills work well

- README and documentation
- Blog posts for general/dev audience
- Email to colleagues
- Status updates, release notes
- Marketing copy for mainstream audiences

## When skills DON'T work

- Academic text (expected scientific register shares many patterns with AI)
- Legal text (expected канцелярит IS the same patterns we flag)
- Highly formal official documents
- Russian political/diplomatic text (official style legitimately uses em-dash, деепричастия, канцелярит)
- Translations (double set of patterns)

## The honest summary

> Skills work as a literary editor, not as a detector-bypass tool. They help you write better, not hide origin. If text after editing "sounds human", great. If text after editing passes GPTZero, that's a side effect that doesn't always work.

## Sources

- MASH (ACL 2026): [arXiv:2601.08564](https://arxiv.org/abs/2601.08564)
- Binoculars (ICML 2024): [arXiv:2401.12070](https://arxiv.org/abs/2401.12070)
- Watermarking (ICML 2023): [arXiv:2301.10226](https://arxiv.org/abs/2301.10226)
- OpenAI classifier retired (2023): [26% sensitivity](https://openai.com/blog/new-ai-classifier-for-indicating-ai-written-text)

## Read more

- [knowledge/05-References/limits-and-self-critique.md](../knowledge/05-References/limits-and-self-critique.md) — full analysis
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста)
---
type: pattern
tags: [pattern, lexical, en, ai-tells]
created: 2026-06-28
status: draft
language: en
related: [lexicon-ru, hedging-language]
---

# AI-clichés lexicon (English)

> [!info] Sources
> Patterns synthesized from: OpenAI/GPT system behavior analysis, GPTZero documentation, MIT "Real or Fake Text" research (2024), community findings on Reddit r/ChatGPT and LessWrong. Many of these strings are in published AI-text datasets (e.g., `Hello-SimpleAI/HC3`).

## 1. Sentence starters that scream LLM

These opening words/phrases appear with statistically anomalous frequency in AI text:

- "In today's world…"
- "In the modern era…"
- "In today's fast-paced world…"
- "Let's delve into…" / "Let's explore…"
- "In this article, we'll discuss…"
- "It's important to note that…"
- "It's worth noting that…"
- "It's worth mentioning that…"
- "It is essential to…"
- "One might argue that…"
- "When it comes to…"
- "At the end of the day…"
- "In conclusion,…"
- "To wrap things up,…"
- "Overall,…" (as paragraph starter)
- "Furthermore,…" / "Moreover,…" (as sentence starter)
- "Additionally,…" (overused connective)
- "Notably,…"

## 2. Vocabulary tells

| Cliché | Issue | Better alternative |
|---|---|---|
| delve | AI overuses 10–20× compared to humans | dig into, look at, examine, cut into |
| leverage | Marketing cliché | use, take advantage of, build on |
| robust | Often meaningless without context | strong, solid, reliable + concrete metric |
| seamless | Marketing | smooth, works without glue code, [describe the actual experience] |
| cutting-edge | Tired | state-of-the-art, [specific tech] |
| holistic | Buzzword | end-to-end, full, complete |
| multifaceted | Vague | multiple, varied |
| comprehensive | OK with scope, AI uses it empty | full, complete, in detail |
| navigate (abstract) | "Navigate the complexities" = empty | handle, deal with, work through |
| underscore | "This underscores…" AI marker | show, highlight, point to |
| foster | "foster innovation" | support, encourage, grow |
| realm | "in the realm of" | in, within, in the world of |
| tapestry | Pretentious metaphor | drop the metaphor, be concrete |
| myriad | OK rarely, AI overuses | many, lots of, dozens |
| paramount | Pretentious | critical, important, top priority |
| quintessential | Overused | typical, classic |
| embark | "embark on a journey" | start, begin |
| garner | "garner attention" | get, attract, win |
| paramount | Same | same as above |

## 3. Filler / hedging phrases

These are the worst offenders because they appear to "say something" but say nothing:

- "plays a crucial/pivotal/key role in"
- "is a testament to"
- "serves as a reminder that"
- "in the ever-evolving landscape of"
- "in the realm of"
- "a myriad of factors"
- "navigating the complexities of"
- "the intricacies of"
- "the evolving nature of"
- "shed light on"
- "offer valuable insights into"
- "unlock the potential of"
- "harness the power of"
- "pave the way for"
- "drive innovation"
- "foster collaboration"
- "delve into the depths of"

## 4. Em-dash overuse

LLMs love em-dashes ("—"). Real human writing uses them, but not 3 per paragraph. If your text has more em-dashes than the average New Yorker article, you're overusing.

## 5. "It's important to note that"

> [!warning]
> Roughly 1 in 4 LLM-generated paragraphs in 2024 starts with or contains this phrase. If your text has it — start over.

## 6. The "rule of three" gone wrong

LLM applies "rule of three" (three parallel items) almost robotically:

- ❌ "It's fast, reliable, and scalable."
- ✅ Vary the structure: "It's fast. The p99 latency is 12ms. And it scales — we've stress-tested it to 50k req/s without breaking a sweat."

## 7. Closing clichés

- "In conclusion,…"
- "To summarize,…"
- "All in all,…"
- "Final thoughts:"

The best closings either:
- end with a concrete next step ("Run `make test` to see it work."),
- end with a question or call to action,
- or just stop — when the last point is the last point.

## See also

- [[lexicon-ru]]
- [[../structural/three-part-lists]]
- [[../rhetorical/hedging-language]]
- [[../../02-Techniques/perplexity-and-burstiness]]
- [[../../03-Detection/how-detectors-work]]
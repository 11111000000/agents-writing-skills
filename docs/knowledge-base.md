---
title: Knowledge Base
description: 41+ Obsidian-format notes documenting patterns, techniques, sources, examples, references. The theoretical foundation under each skill.
---

[← Back to Home](index)

# 📚 Knowledge Base

> The 41+ notes that ground every recommendation in the 4 skills. Open them in [Obsidian](https://obsidian.md/) for full graph view, or browse here.

<br>

## 🗺 Map

```
knowledge/
├── 01-Patterns/             # 43 AI-pattern categories + RU extensions
├── 02-Techniques/           # 12 levers, voice, brevity grammar
├── 03-Detection/            # How detectors work
├── 04-Examples/             # Worked before/after cases
├── 05-References/           # Limits, self-critique
└── 06-Sources/              # Raw research papers + web fetches
```

<br>

## 1️⃣ Patterns (`01-Patterns/`) — what AI text looks like

| Note | Covers |
|---|---|
| [43-patterns-catalogue](01-patterns/43-patterns-catalogue) | All 43 patterns with examples & detection (from Aboudjem/humanizer-skill) |
| [P9 Negative Parallelisms](01-patterns/rhetorical/negative-parallelisms) | **The #1 AI marker** per Washington Post 2024 — «это не X, а Y» |
| [lexicon-ru-v2](01-patterns/lexical/lexicon-ru-v2) | Russian AI clichés: «более того», «стоит отметить» |
| [lexicon-en](01-patterns/lexical/lexicon-en) | English AI clichés: `delve`, `leverage`, `robust` |
| [deeprichastnye-oboroty](01-patterns/rhetorical/deeprichastnye-oboroty) | Russian деепричастия (-а/-в) overuse |
| [parallel-clauses](01-patterns/structural/parallel-clauses) | «цели и задачи», «методы и средства» |
| [em-dash](01-patterns/structural/em-dash) | Em-dash overuse (3-5× human baseline) |
| [over-generation](01-patterns/structural/over-generation) | P-NEW-1…7 — vacuum-filling, restatement chains, bridging, etc. |

<br>

## 2️⃣ Techniques (`02-Techniques/`) — what to do instead

| Note | What it covers |
|---|---|
| [perplexity-and-burstiness](02-techniques/perplexity-and-burstiness) | Foundation metrics (the basis of detection) |
| [voice-and-tone](02-techniques/voice-and-tone) | How to find author voice |
| [voice-russian-specifics](02-techniques/voice-russian-specifics) | Я / мы / безличное в русском |
| [show-dont-tell](02-techniques/show-dont-tell) | Concreteness vs abstraction (the single biggest bug in LLM text) |
| [sufficiency-and-underspecification](02-techniques/sufficiency-and-underspecification) | Lever 10 + 11: Grice submaxim 2 + Hemingway iceberg |
| [length-bias-research](02-techniques/length-bias-research) | Academic grounding: 5 arXiv papers on length bias in RLHF |
| [russian-brevity-grammar](02-techniques/russian-brevity-grammar) | Lever 12 deep-dive: парцелляция, эллипсис, литота |
| [laconic-prose-models](02-techniques/laconic-prose-models) | Tolstoy, Dovlatov, Shklovsky, Bunin — principals to extract |
| [agent-writing-workflow](02-techniques/agent-writing-workflow) | Pre-flight → Write → Audit algorithm |

<br>

## 3️⃣ Detection (`03-Detection/`) — what's measurable

| Note | What |
|---|---|
| [how-detectors-work](03-detection/how-detectors-work) | Binoculars (ICML 2024), Watermarking, DetectGPT, Pangram, GPTZero, ZeroGPT |
| [public-detectors](03-detection/public-detectors) | Comparison of available tools |
| [russian-detectors](03-detection/russian-detectors) | RU-specific: GigaCheck, Antiplagiat, etc. |

<br>

## 4️⃣ Examples (`04-Examples/`) — measured before/after

These are **worked cases with measurable metrics**. Run `benchmark-skill.sh` on any to verify.

### `04-Examples/tightening/`
5 examples showing Lever 10 (TIGHTEN) in action:

| # | Domain | Words before → after | % reduction |
|---|---|---|---|
| 1 | README | 56 → 18 | -68% |
| 2 | Email | 48 → 17 | -65% |
| 3 | Blog post | 84 → 19 | -77% |
| 4 | Marketing | 67 → 27 | -60% |
| 5 | Status update | 71 → 16 | -77% |
| **Avg** | | **65 → 19** | **-69%** |

[Read all 5 →](04-examples/tightening)

### `04-Examples/iceberg/`
3 examples showing Lever 11 (RELY / iceberg) in action:

- Architecture decision (PostgreSQL)
- Bug fix report
- Code review feedback

[Read all 3 →](04-examples/iceberg)

### `04-Examples/russian-grammar/`
5+1 examples showing Lever 12 (REBUILD) in action:

| # | Приём | Source |
|---|---|---|
| 1 | Парцелляция | Demo |
| 2 | Эллипсис | Demo |
| 3 | Литота | Demo |
| 4 | Нулевая связка | Demo |
| 5 | Комбинация всех 4 | Demo |
| 6 | **Шкловский + Толстой** | Kholstomer example |

[Read all 6 →](04-examples/russian-grammar)

<br>

## 5️⃣ References (`05-References/`) — limits and ethics

| Note | What |
|---|---|
| [limits-and-self-critique](05-references/limits-and-self-critique) | Epistemological analysis: what we know, what we don't, what MASH/ACL 2026 means for skill ceilings |

<br>

## 6️⃣ Sources (`06-Sources/`) — raw research

The actual papers and web pages we used as evidence:

### Research papers (arXiv)

- `06-Sources/research-papers/length-bias/`
  - [park-2024-disentangling-length-dpo](06-sources/research-papers/length-bias/park-2024-disentangling-length-dpo) — DPO exploits length bias
  - [shen-2023-loose-lips](06-sources/research-papers/length-bias/shen-2023-loose-lips) — RM assumes humans prefer longer (EMNLP 2023)
  - [zhang-2024-format-bias](06-sources/research-papers/length-bias/zhang-2024-format-bias) — Format bias (lists, bold, emojis)
  - [huang-2024-post-hoc-calibration](06-sources/research-papers/length-bias/huang-2024-post-hoc-calibration) — ICLR 2025; calibrate without retraining
  - [lamparth-2026-bias-substitution](06-sources/research-papers/length-bias/lamparth-2026-bias-substitution) — **Critical** (Stanford 2026): single-axis mitigation → bias substitution

### Datasets (used for empirical validation)

- `06-Sources/research-papers/detection-datasets/`
  - [hc3-english](06-sources/research-papers/detection-datasets/hc3-english) — 24.3k AI-vs-human pairs
  - [hc3-russian-translated](06-sources/research-papers/detection-datasets/hc3-russian-translated) — translated version
  - [raid-multi-domain](06-sources/research-papers/detection-datasets/raid-multi-domain) — 8.09M multi-model benchmark

### Web fetches (RU grammar & literary theory)

- `06-Sources/web-fetches/russian-grammar/`
  - [parcelyaciya-wikipedia](06-sources/web-fetches/russian-grammar/parcelyaciya-wikipedia) — Russian Wikipedia article on parcellation
  - [ellipsis-wikipedia](06-sources/web-fetches/russian-grammar/ellipsis-wikipedia) — 8 types of ellipsis
  - [litota-wikipedia](06-sources/web-fetches/russian-grammar/litota-wikipedia) — Litotes with literary examples

- `06-Sources/web-fetches/laconic-prose/`
  - [shklovsky-wikipedia](06-sources/web-fetches/laconic-prose/shklovsky-wikipedia) — Shklovsky's 1917 "Art as Technique", defamiliarization, Tolstoy analysis

<br>

## 🔍 How to browse

| You want to... | Look at |
|---|---|
| Find all AI cliches | `01-Patterns/lexical/lexicon-en` |
| Remove Russian «канцелярит» | `01-Patterns/structural/parallel-clauses` |
| Apply iceberg to technical doc | `02-Techniques/sufficiency-and-underspecification` → `04-Examples/iceberg/` |
| Russian parcellation | `02-Techniques/russian-brevity-grammar` → `04-Examples/russian-grammar/` |
| Why LLM over-generates | `02-Techniques/length-bias-research` |
| Apply Shklovsky / Tolstoy style | `02-Techniques/laconic-prose-models` → `04-Examples/russian-grammar/06-shklovsky-tolstoy-kholstomer` |
| Test your text | `scripts/benchmark-skill.sh` |

<br>

---

[← Back to Home](index) · [Next: Limitations →](limitations)
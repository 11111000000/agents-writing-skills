---
title: Knowledge Base
description: 41 Obsidian-format notes documenting patterns, techniques, examples, references and sources. The theoretical foundation under each of the 4 v7 skills.
---

[← Back to Home](index)

# 📚 Knowledge Base

> The **41 notes** that ground every recommendation in the 4 v7 skills. Open them in [Obsidian](https://obsidian.md/) for the full graph view, or browse here.

The vault answers five questions, and each one has its own section:

- **What does AI text look like?** → `01-Patterns/` (15 notes)
- **What do I do instead, without changing what the text says?** → `02-Techniques/` (15 notes)
- **What can I actually measure?** → `03-Detection/` (3 notes)
- **What does a rewrite look like in practice?** → `04-Examples/` (6 notes)
- **What do we still not know?** → `05-References/` (1 note)

<br>

## 🗺 Map

```
knowledge/
├── 01-Patterns/             # 15 notes: 43 AI-pattern categories + P-NEW + RU extensions
├── 02-Techniques/           # 15 notes: meaning contract, editing modes, voice, brevity grammar
├── 03-Detection/            # 3 notes: how detectors work
├── 04-Examples/             # 6 notes: worked before/after cases
├── 05-References/           # 1 note: limits, self-critique
├── 06-Sources/              # raw research papers + web fetches
└── README.md                # MOC: the map of the map
```

**41 notes** in total (excluding `06-Sources/` raw material and `templates/`). They back **4 skills at v7.0.0** and **9 prompt templates**.

<br>

## 🆕 What changed in v7

v7 is not "more markers to remove". It is a change of goal: **preserve meaning while editing**. The four skills keep their 3-pass architecture; the contract underneath them changed.

| Area | v6 | v7 |
|---|---|---|
| Contract | losing up to a percentage of facts was tolerated | **Zero loss of claims by default.** Claims, numbers and their relations, conditions, exceptions, negations, modality, terminology, quotes and register are preserved. Inventing a fact is a FAIL, not a deduction |
| Missing data | fill the gap from plausibility | Missing data → **`[нужен факт: ...]`**. A plausible number is still an invented number |
| Scope of an edit | one undifferentiated "make it human" request | **4 modes**: `proofread` / `light` / `style` / `deep`. Each mode unlocks a different set of phases (STRIP / TIGHTEN / RELY / REBUILD) |
| RELY (iceberg) | always available | **`style`/`deep` only**, and only for artistic or conversational register. Not for contracts, papers or instructions |
| Already-good text | always something to improve | A good text may be **returned almost unchanged**, and saying so is a valid result |
| Metrics | read as a verdict ("this is AI") | **Diagnostics**: they point at a place worth looking at, they do not decide "AI / not AI" |
| Evidence | a catalog of markers | **Behavioral corpus** + validators + a formal evidence layer |

**What was added to make this checkable:**

- **Behavioral corpus** `tests/fixtures/editing/`: 24 cases (README, formal email, scientific hedged, tutorial, tech instruction, fiction, expert post, plus 3 already-good cases) with deliberate traps around modality, conditions and invented facts. Checked by `scripts/test-editing-fixtures.sh`.
- **Validators**: `scripts/check-editing-output.sh` checks 9 invariants of the meaning contract (numbers, claims, conditions, exceptions, terminology, uncertainty, no invented numbers, no forbidden additions, already-good-unchanged) and has a `--selftest` that proves it catches violations. Also `scripts/check-examples-facts.sh`, `scripts/check-examples-coverage.sh`, `scripts/check-no-stale-contract.sh`.
- **Evidence layer**: `spec.json` + `mathc run`: 12 claims with negative controls, each tied to a verifier command.
- **Metric validation on 145 labeled texts**: thresholds are now language-aware and empirically derived. See [metric-validation](02-techniques/metric-validation).
- **Blind human evaluation protocol**: written down, **not yet run**. See [Blind human evaluation](blind-evaluation).

<br>

## 1️⃣ Patterns (`01-Patterns/`): what AI text looks like

15 notes. The catalogue of surface markers, its RU extensions, and the two structural families added after the original 43.

| Note | Covers |
|---|---|
| [43-patterns-catalogue](01-patterns/43-patterns-catalogue) | All 43 patterns with examples & detection (from Aboudjem/humanizer-skill) |
| [catalogue-update](01-patterns/catalogue-update) | P-NEW-13…P-NEW-20: 8 patterns absent from the original 43: false agency, argument residue, mini-aphorism closers and others |
| [P9 Negative Parallelisms](01-patterns/rhetorical/negative-parallelisms) | **The #1 AI marker** per Washington Post 2024: «это не X, а Y» |
| [lexicon-ru-v2](01-patterns/lexical/lexicon-ru-v2) | Russian AI clichés: «более того», «стоит отметить» |
| [lexicon-en](01-patterns/lexical/lexicon-en) | English AI clichés: `delve`, `leverage`, `robust` |
| [deeprichastnye-oboroty](01-patterns/rhetorical/deeprichastnye-oboroty) | Russian деепричастия (-а/-в) overuse |
| [parallel-clauses](01-patterns/structural/parallel-clauses) | «цели и задачи», «методы и средства» |
| [em-dash](01-patterns/structural/em-dash) | Em-dash overuse (3-5× human baseline) |
| [over-generation](01-patterns/structural/over-generation) | P-NEW-1…7: vacuum-filling, restatement chains, bridging, etc. |
| [format-and-rlhf-bias](01-patterns/structural/format-and-rlhf-bias) | P-NEW-8…12: format bias and RLHF artifacts behind the over-generation patterns |

<br>

## 2️⃣ Techniques (`02-Techniques/`): what to do instead

15 notes. The first five are the v7 core: they define what a legal edit is, how deep it may go, and in which genres.

| Note | What it covers |
|---|---|
| [meaning-preservation](02-techniques/meaning-preservation) | **v7 core.** `meaning_map` and two-way verification: original → result loses nothing, result → original invents nothing. Claims, numbers and relations, conditions, exceptions, negations, modality, terminology, quotes, register |
| [editing-modes](02-techniques/editing-modes) | **v7 core.** The 4 modes `proofread` / `light` / `style` / `deep`, which phases each unlocks, when RELY is allowed, and the rule for returning an already-good text |
| [russian-copyediting](02-techniques/russian-copyediting) | **v7 core.** The COPYEDIT stage for Russian: grammar, case government, punctuation, pronoun ambiguity, 24 error→fix pairs, minimal intervention |
| [genre-profiles](02-techniques/genre-profiles) | **v7 core.** Five genre profiles (academic, legal, marketing, support, technical-docs) with what each profile may and may not touch |
| [ru-corpus-collection](02-techniques/ru-corpus-collection) | **v7 core.** How to collect a real RU corpus (8 human / 12 synthetic today), and what must change in the metrics afterwards |
| [metric-validation](02-techniques/metric-validation) | Threshold calibration on 145 labeled texts, per-language thresholds, Cohen's d, and the bias in the synthetic RU set |
| [perplexity-and-burstiness](02-techniques/perplexity-and-burstiness) | Foundation metrics (the basis of detection) |
| [voice-and-tone](02-techniques/voice-and-tone) | How to find author voice |
| [voice-russian-specifics](02-techniques/voice-russian-specifics) | Я / мы / безличное в русском |
| [show-dont-tell](02-techniques/show-dont-tell) | Concreteness vs abstraction (the single biggest bug in LLM text) |
| [sufficiency-and-underspecification](02-techniques/sufficiency-and-underspecification) | Lever 10 + 11: Grice submaxim 2 + Hemingway iceberg, and when underspecification must **not** be used |
| [length-bias-research](02-techniques/length-bias-research) | Academic grounding: 5 arXiv papers on length bias in RLHF |
| [russian-brevity-grammar](02-techniques/russian-brevity-grammar) | Lever 12 deep-dive: парцелляция, эллипсис, литота |
| [laconic-prose-models](02-techniques/laconic-prose-models) | Tolstoy, Dovlatov, Shklovsky, Bunin: principals to extract |
| [agent-writing-workflow](02-techniques/agent-writing-workflow) | Pre-flight → Write → Audit algorithm |

<br>

## 3️⃣ Detection (`03-Detection/`): what's measurable

| Note | What |
|---|---|
| [how-detectors-work](03-detection/how-detectors-work) | Binoculars (ICML 2024), Watermarking, DetectGPT, Pangram, GPTZero, ZeroGPT |
| [public-detectors](03-detection/public-detectors) | Comparison of available tools |
| [russian-detectors](03-detection/russian-detectors) | RU-specific: GigaCheck, Antiplagiat, etc. |

> [!note]
> Detectors are described here to explain **what the metrics are measuring**, not as a target. See [Limitations](limitations).

<br>

## 4️⃣ Examples (`04-Examples/`): measured before/after

6 notes. **Worked cases with measurable metrics.** Run `benchmark-skill.sh` on any to verify.

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

> [!warning]
> These three show RELY working. RELY is **not** available in `proofread`/`light`, and in `style`/`deep` it only applies to artistic or conversational register, and every deletion still has to pass the `meaning_map` check.

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

Plus two index notes: [before-after](04-examples/before-after) and [before-after-ru-advanced](04-examples/before-after-ru-advanced).

<br>

## 5️⃣ References (`05-References/`): limits and ethics

| Note | What |
|---|---|
| [limits-and-self-critique](05-references/limits-and-self-critique) | Epistemological analysis: what we know, what we don't, what MASH/ACL 2026 means for skill ceilings, and the list of what is still unvalidated |

<br>

## 6️⃣ Sources (`06-Sources/`): raw research

The actual papers and web pages we used as evidence:

### Research papers (arXiv)

- `06-Sources/research-papers/length-bias/`
  - [park-2024-disentangling-length-dpo](06-sources/research-papers/length-bias/park-2024-disentangling-length-dpo): DPO exploits length bias
  - [shen-2023-loose-lips](06-sources/research-papers/length-bias/shen-2023-loose-lips): RM assumes humans prefer longer (EMNLP 2023)
  - [zhang-2024-format-bias](06-sources/research-papers/length-bias/zhang-2024-format-bias): Format bias (lists, bold, emojis)
  - [huang-2024-post-hoc-calibration](06-sources/research-papers/length-bias/huang-2024-post-hoc-calibration): ICLR 2025; calibrate without retraining
  - [lamparth-2026-bias-substitution](06-sources/research-papers/length-bias/lamparth-2026-bias-substitution): **Critical** (Stanford 2026): single-axis mitigation → bias substitution

### Datasets (used for empirical validation)

- `06-Sources/research-papers/detection-datasets/`
  - [hc3-english](06-sources/research-papers/detection-datasets/hc3-english): 24.3k AI-vs-human pairs
  - [hc3-russian-translated](06-sources/research-papers/detection-datasets/hc3-russian-translated): translated version
  - [raid-multi-domain](06-sources/research-papers/detection-datasets/raid-multi-domain): 8.09M multi-model benchmark

### Web fetches (RU grammar & literary theory)

- `06-Sources/web-fetches/russian-grammar/`
  - [parcelyaciya-wikipedia](06-sources/web-fetches/russian-grammar/parcelyaciya-wikipedia): Russian Wikipedia article on parcellation
  - [ellipsis-wikipedia](06-sources/web-fetches/russian-grammar/ellipsis-wikipedia): 8 types of ellipsis
  - [litota-wikipedia](06-sources/web-fetches/russian-grammar/litota-wikipedia): Litotes with literary examples

- `06-Sources/web-fetches/laconic-prose/`
  - [shklovsky-wikipedia](06-sources/web-fetches/laconic-prose/shklovsky-wikipedia): Shklovsky's 1917 "Art as Technique", defamiliarization, Tolstoy analysis

<br>

## 🔍 How to browse

| You want to... | Look at |
|---|---|
| Find all AI cliches | `01-Patterns/lexical/lexicon-en` |
| Remove Russian «канцелярит» | `01-Patterns/structural/parallel-clauses` |
| Edit without changing what the text says | `02-Techniques/meaning-preservation` |
| Decide how deep to go | `02-Techniques/editing-modes` |
| Know what you may touch in a contract / paper / landing page | `02-Techniques/genre-profiles` |
| Fix Russian grammar and punctuation | `02-Techniques/russian-copyediting` |
| Apply iceberg to technical doc | `02-Techniques/sufficiency-and-underspecification` → `04-Examples/iceberg/` |
| Russian parcellation | `02-Techniques/russian-brevity-grammar` → `04-Examples/russian-grammar/` |
| Why LLM over-generates | `02-Techniques/length-bias-research` |
| Understand where the metric thresholds come from | `02-Techniques/metric-validation` |
| Apply Shklovsky / Tolstoy style | `02-Techniques/laconic-prose-models` → `04-Examples/russian-grammar/06-shklovsky-tolstoy-kholstomer` |
| Test your text | `scripts/benchmark-skill.sh` |
| Check an edit against the meaning contract | `scripts/check-editing-output.sh` |

<br>

---

[← Back to Home](index) · [Next: Limitations →](limitations)

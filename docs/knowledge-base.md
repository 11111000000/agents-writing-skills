---
title: Knowledge Base
---

# Knowledge Base

The knowledge base in `knowledge/` is an Obsidian-formatted vault documenting the research behind the skills. Use Obsidian to read it locally; Quartz (via GitHub Pages) for the rendered version.

## Structure

```
knowledge/
├── README.md                    # MOC (Map of Content)
├── 01-Patterns/                 # 43-pattern catalogue + bilingual lexicons
│   ├── lexical/
│   ├── structural/
│   ├── rhetorical/
│   └── 43-patterns-catalogue.md
├── 02-Techniques/               # How to write without AI patterns
├── 03-Detection/                # How detectors work
├── 04-Examples/                 # Before/after rewrites
├── 05-References/                # Self-critique + limits
└── 06-Sources/                  # Downloaded primary sources
```

## Key notes (start here)

### Patterns (what AI does)

- [43-patterns-catalogue.md](../knowledge/01-Patterns/43-patterns-catalogue.md) — all 43 patterns in one file
- [lexicon-ru-v2.md](../knowledge/01-Patterns/lexical/lexicon-ru-v2.md) — Russian AI clichés, v2
- [lexicon-en.md](../knowledge/01-Patterns/lexical/lexicon-en.md) — English AI clichés
- [negative-parallelisms.md](../knowledge/01-Patterns/rhetorical/negative-parallelisms.md) — «Это не X, а Y» (the #1 marker)
- [em-dash.md](../knowledge/01-Patterns/structural/em-dash.md) — em-dash overuse
- [deeprichastnye-oboroty.md](../knowledge/01-Patterns/rhetorical/deeprichastnye-oboroty.md) — Russian деепричастия overuse
- [parallel-clauses.md](../knowledge/01-Patterns/structural/parallel-clauses.md) — Russian «цели и задачи» constructions

### Techniques (what to do instead)

- [perplexity-and-burstiness.md](../knowledge/02-Techniques/perplexity-and-burstiness.md) — fundamental metrics
- [voice-and-tone.md](../knowledge/02-Techniques/voice-and-tone.md) — finding your voice
- [voice-russian-specifics.md](../knowledge/02-Techniques/voice-russian-specifics.md) — voice in Russian
- [show-dont-tell.md](../knowledge/02-Techniques/show-dont-tell.md) — concrete over abstract
- [agent-writing-workflow.md](../knowledge/02-Techniques/agent-writing-workflow.md) — Pre-flight → Write → Audit

### Detection

- [how-detectors-work.md](../knowledge/03-Detection/how-detectors-work.md) — perplexity, burstiness, stylometry
- [public-detectors.md](../knowledge/03-Detection/public-detectors.md) — ZeroGPT, GPTZero, etc.
- [russian-detectors.md](../knowledge/03-Detection/russian-detectors.md) — GigaCheck, Антиплагиат

### Self-critique

- [limits-and-self-critique.md](../knowledge/05-References/limits-and-self-critique.md) — what we know, what we don't, where skills work and don't

## Reading in Obsidian

1. Install [Obsidian](https://obsidian.md/).
2. File → Open vault → select `knowledge/` directory.
3. Use `[[wikilinks]]` to navigate.
4. Use graph view (Ctrl/Cmd+G) to see connections.

## Reading on GitHub

The vault is plain Markdown. You can browse it directly on GitHub. `[[wikilinks]]` will not resolve, but the structure is the same.

## Contributing to the knowledge base

See [CONTRIBUTING.md](../CONTRIBUTING.md). Add notes following the template in `knowledge/templates/note-template.md`.
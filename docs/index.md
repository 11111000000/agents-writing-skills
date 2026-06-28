---
title: Agents Writing Skills
description: Skills and prompts for agents that write text without sounding like AI. Research-grounded (43-pattern catalogue, 9 humanization levers, Russian-specific patterns).
---

# Agents Writing Skills

**Skills and prompts for agents that write text without sounding like AI.**

Research-grounded. Open source. Works with opencode, pi, Claude Code, Codex CLI, and any other Agent Skills-compatible agent.

## How to install

This repository contains a `manifest.json` that any agent can read to understand what's available and where to put it.

**Tell your agent:**

```
Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json
```

The agent will:
1. Clone the repository
2. Read `manifest.json`
3. Copy skills to its own skill directory
4. Register prompts if applicable

No shell scripts. No hardcoded paths. Any agent, any OS.

## What you get

Four skills that work together:

| Skill | What it does | When to use |
|---|---|---|
| `humanize-writer` | Write new prose without AI tells | "Write a README", "Draft a blog post" |
| `humanize-editor` | Rewrite existing text to read human | "Humanize this", "Make this less AI" |
| `anti-ai-auditor` | Diagnose without rewriting | "Is this too AI?", "Check this draft" |
| `ai-pattern-rewriter` | Fix specific phrases | "Fix just this sentence" |

Nine prompt templates for pi: `/humanize`, `/audit-ai`, `/audit-43`, `/humanize-9-levers`, `/anti-thesis`, `/writer-voice`, `/clean-draft`, `/rewrite-ai`, `/honest-check`.

## What's in the knowledge base

The repository includes an Obsidian-format knowledge base documenting:

- **43 AI-pattern categories** (from Aboudjem/humanizer-skill)
- **9 humanization levers** (from harshaneel/humanize)
- **Russian-specific patterns** (from Wikipedia RU and original research)
- **Detection methods** (Binoculars, MASH, watermarking)

Browse it through this site (use the sidebar and graph view) or open `knowledge/` directly in Obsidian.

## How it works

Skills are Markdown files with YAML frontmatter. When your agent sees a task matching a skill's description, it loads the skill automatically.

Each skill encodes:

- Hard rules (non-negotiable patterns)
- Step-by-step workflow
- Examples
- Companion skills
- Explicit "when NOT to apply" sections

## Honest about limitations

> These skills help text **read as human** to human readers. They do **not** guarantee passing commercial AI detectors like GPTZero, Pangram, or Grammarly. Academic research shows static surface rewriting has a ceiling against trained classifiers.
>
> Skills are **literary editors**, not **detector-bypass tools**.

## Built on real research

- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) — 43-pattern catalogue (MIT, 98★)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) — 9 humanization levers (MIT, 56★)
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста)
- Academic papers: [Binoculars (ICML 2024)](https://arxiv.org/abs/2401.12070), [Watermarking (ICML 2023)](https://arxiv.org/abs/2301.10226), [MASH (ACL 2026)](https://arxiv.org/abs/2601.08564)

## License

- Skills and prompts: MIT
- Knowledge base: CC-BY-SA-4.0

## Contributing

New skills start from [`skills/template-skill/`](https://github.com/11111000000/agents-writing-skills/tree/main/skills/template-skill).

Read the [43-pattern catalogue](01-patterns/43-patterns-catalogue) to understand what AI patterns look like. Read [limits-and-self-critique](05-references/limits-and-self-critique) to understand what these skills can and cannot do.
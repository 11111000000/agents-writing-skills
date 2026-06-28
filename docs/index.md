---
title: Agents Writing Skills
description: Skills and prompts for agents that write text without sounding like AI.
---

# Agents Writing Skills

**Skills and prompts for agents that write text without sounding like AI.**

Research-grounded. Open source. Works with opencode, pi, Claude Code, Codex CLI, and any other Agent Skills-compatible agent.

---

## The problem

AI-generated text has tells. Em-dashes everywhere. Rule-of-three. Hedging. Negative parallelisms. "It could be argued that..." Readers spot it. Detectors spot it. Your agent's output gets flagged.

## The solution

Four skills that make your agent write like a human editor would:

| Skill | What it does |
|---|---|
| **`humanize-writer`** | Write new prose without AI tells |
| **`humanize-editor`** | Rewrite existing text to read human |
| **`anti-ai-auditor`** | Diagnose without rewriting |
| **`ai-pattern-rewriter`** | Fix specific phrases surgically |

Nine prompt templates for pi: `/humanize`, `/audit-ai`, `/audit-43`, and more.

## Install in one sentence

Tell your agent:

```
Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json
```

No shell scripts. No hardcoded paths. Any agent, any OS.

## What's inside

### Skills (`skills/`)

Each skill is a Markdown file with YAML frontmatter. Hard rules. Workflow. Examples. "When NOT to apply" sections. Companion skills that chain together.

### Prompt templates (`prompts/`)

For pi agents. Each template is a complete workflow in a single file.

### Knowledge base (`knowledge/`)

41 notes documenting:

- **43 AI-pattern categories** (from Aboudjem/humanizer-skill)
- **9 humanization levers** (from harshaneel/humanize)
- **Russian-specific patterns** (деепричастия, канцелярит, em-dash)
- **Detection methods** (Binoculars, MASH, watermarking)

Browse through this site or open `knowledge/` in Obsidian.

## How it works

Your agent sees a task. Loads the matching skill. Applies hard rules. Follows the workflow. Returns text that reads as human.

Skills are **literary editors**, not **detector-bypass tools**. They help text read as human to human readers. They do not guarantee passing GPTZero, Pangram, or Grammarly.

## Built on research

- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) — 43-pattern catalogue (MIT)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) — 9 humanization levers (MIT)
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста)
- Academic papers: Binoculars (ICML 2024), Watermarking (ICML 2023), MASH (ACL 2026)

## License

- Skills and prompts: MIT
- Knowledge base: CC-BY-SA-4.0

## Contributing

New skills start from [`skills/template-skill/`](https://github.com/11111000000/agents-writing-skills/tree/main/skills/template-skill).

Read the [43-pattern catalogue](01-patterns/43-patterns-catalogue) to understand what AI patterns look like. Read [limits-and-self-critique](05-references/limits-and-self-critique) to understand what these skills can and cannot do.

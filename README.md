# agents-writing-skills

**Skills and prompts for agents that write text without sounding like AI.**

This repository provides:

1. **Skills** for opencode, pi, Claude Code, Codex CLI, and other Agent Skills-compatible agents. Skills help the agent write, edit, and audit prose so it reads as human-authored.
2. **Prompt templates** for pi, exposed as `/humanize`, `/audit-ai`, etc.
3. **Knowledge base** — an Obsidian-formatted vault documenting the patterns, techniques, and detection methods behind the skills.

> [!important] What this is NOT
> This is not a tool for evading AI detection. Skills help text **read as human** to human readers. They do not guarantee passing commercial detectors like GPTZero, Pangram, or Grammarly. See [`knowledge/05-References/limits-and-self-critique.md`](knowledge/05-References/limits-and-self-critique.md) for what works and what doesn't.

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

### Skills

| Skill | Purpose |
|---|---|
| `humanize-writer` | Write new prose that avoids typical LLM patterns |
| `humanize-editor` | Rewrite existing text to read as human-authored |
| `anti-ai-auditor` | Audit text for AI-pattern probability without rewriting |
| `ai-pattern-rewriter` | Surgical, line-level rewriting of specific AI-pattern phrases |

### Prompt templates (pi)

| Command | Purpose |
|---|---|
| `/humanize` | Rewrite AI-sounding text to read human |
| `/audit-ai` | Audit text for AI-pattern probability |
| `/audit-43` | Audit against the full 43-pattern catalogue |
| `/humanize-9-levers` | Apply harshaneel's 9 humanization levers |
| `/anti-thesis` | Detect and rewrite negative parallelisms (P9) |
| `/writer-voice` | Write new prose avoiding AI tells |
| `/clean-draft` | Light cleanup of an existing draft |
| `/rewrite-ai` | Surgical rewrite of a specific phrase |
| `/honest-check` | Pre-flight check on whether to apply humanize-* skills |

### Knowledge base (Obsidian)

The vault documents 43 AI-pattern categories (from Aboudjem), 9 humanization levers (from harshaneel), Russian-specific patterns (from Wikipedia RU), and detection methods (Binoculars, MASH, watermarking).

Browse the [online documentation](https://11111000000.github.io/agents-writing-skills/) or open `knowledge/` directly in Obsidian.

## How skills work

Skills are Markdown files with YAML frontmatter. When the agent sees a task that matches a skill's `description`, it loads the skill automatically.

Each skill encodes:

- **Hard rules** — non-negotiable patterns to avoid or apply
- **Workflow** — step-by-step procedure
- **Companion skills** — when to chain skills
- **Limitations** — explicit "when NOT to apply" sections

## Documentation

- **[Online documentation](https://11111000000.github.io/agents-writing-skills/)** — knowledge base rendered as a website
- **[Knowledge base](knowledge/)** — patterns, techniques, examples (Obsidian format)
- **[Contributing](CONTRIBUTING.md)** — how to add new skills or prompts
- **[Changelog](CHANGELOG.md)** — what changed in each release
- **[Limitations](knowledge/05-References/limits-and-self-critique.md)** — epistemological analysis

## License

- Skills and prompts: MIT
- Knowledge base notes: CC-BY-SA-4.0
- See [LICENSE](LICENSE) for full text.

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md). For new skills, use [`skills/template-skill/`](skills/template-skill/) as starting point.

## Credits

Built on research from:

- [Aboudjem/humanizer-skill](https://github.com/Aboudjem/humanizer-skill) — 43-pattern catalogue (MIT)
- [harshaneel/humanize](https://github.com/harshaneel/humanize) — 9 humanization levers (MIT)
- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — community-maintained patterns
- [Wikipedia: Признаки сгенерированности текста](https://ru.wikipedia.org/wiki/Википедия:Признаки_сгенерированности_текста) — Russian patterns
- Academic papers: Binoculars (ICML 2024), Watermarking (ICML 2023), MASH (ACL 2026)
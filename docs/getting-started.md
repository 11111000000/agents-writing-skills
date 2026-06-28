---
title: Getting Started
---

# Getting Started

## Install

### One command

Tell your agent:

```
Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json
```

The agent will:
1. Clone the repository
2. Read `manifest.json`
3. Copy skills to its own skill directory
4. Register prompts if applicable

No shell scripts. No hardcoded paths. Any agent, any OS.

### Manual install

If you prefer to install manually:

1. Clone the repository:
   ```bash
   git clone https://github.com/11111000000/agents-writing-skills.git
   ```

2. Read `manifest.json` to understand what's available

3. Copy skills to your agent's skill directory:
   - opencode: `~/.config/opencode/skills/`
   - pi: `~/.pi/agent/skills/`
   - claude-code: `~/.claude/skills/`

## Verify

Open your agent and ask: "Help me write a README". The agent should automatically load `humanize-writer`.

## Usage examples

### In opencode

```
> Help me write a landing page for a new CLI tool
```

Agent loads `humanize-writer`, applies the 9 levers + RU extensions, writes the page.

### In pi

```
> /humanize this text: [paste AI-generated blog post]
```

Pi runs the `humanize` prompt-template, applies the rules, returns rewritten text.

```
> /audit-ai /path/to/my-draft.md
```

Pi runs `audit-ai`, returns a structured report with category scores, hit list, recommendations.

## Updating

```bash
cd agents-writing-skills
git pull
```

The agent will pick up changes on next load.

## Next steps

- Read [Skills Overview](skills-overview.md) for what each skill does.
- Browse the [Knowledge Base](knowledge-base.md) for the underlying patterns and techniques.
- See [Limitations](limitations.md) for honest discussion of what these skills can and cannot do.

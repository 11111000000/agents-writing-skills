---
title: Getting Started
---

# Getting Started

## Install

### One command

```bash
git clone https://github.com/11111000000/agents-writing-skills.git
cd agents-writing-skills
./install.sh all
```

This installs:

- All skills to `~/.config/opencode/skills/`
- All skills to `~/.pi/agent/skills/`
- All prompt templates to `~/.pi/agent/prompts/`

### Install for one agent

```bash
./install.sh opencode    # only opencode
./install.sh pi          # only pi
```

### Install single skill

```bash
./install.sh skill humanize-writer
```

## Verify

List what was installed:

```bash
./install.sh list
```

Open your agent and ask: «Help me write a README». The agent should automatically load `humanize-writer`.

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
./install.sh all
```

## Uninstall

```bash
./install.sh uninstall opencode
./install.sh uninstall pi
```

## Next steps

- Read [Skills Overview](skills-overview.md) for what each skill does.
- Browse the [Knowledge Base](knowledge-base.md) for the underlying patterns and techniques.
- See [Limitations](limitations.md) for honest discussion of what these skills can and cannot do.
---
version: 1.0.0
name: template-skill
description: Template for creating new skills. Copy this directory, rename, fill in the frontmatter, write instructions, submit a PR. Use whenever you want to add a new skill to this repo.
license: MIT
metadata:
  audience: contributors
  workflow: skill-creation
  status: template
---
version: 1.0.0

# Skill Template

Use this template to create a new skill for the agents-writing-skills repository.

## Step 1 — Copy this directory

```bash
cp -R skills/template-skill/ skills/your-skill-name/
cd skills/your-skill-name/
```

## Step 2 — Edit SKILL.md

Replace the placeholders below. Keep frontmatter at the top.

```markdown
---
version: 1.0.0
name: your-skill-name          # kebab-case, lowercase, ≤64 chars
description: One-sentence description (≤1024 chars). This appears in agent's tool listing.
license: MIT                   # or Apache 2.0, CC-BY-SA-4.0 for content-only skills
compatibility: opencode, pi    # comma-separated list of agents that support this skill
metadata:
  audience: <who is this for>
  workflow: <what workflow does this enable>
  version: 1
---
version: 1.0.0

# Your Skill Name

## What this skill does

One paragraph. What problem does it solve? When should the agent use it?

## When to load

Bullet list of specific tasks/requests that should trigger this skill.

## When NOT to load

Bullet list of cases where the skill is inappropriate.

## The core procedure

Step-by-step instructions. Be specific. Give examples.

## Examples

Show before/after with concrete examples.

## Companion skills

What other skills in this repo complement this one.

## See also

Links to relevant notes in `knowledge/` and external references.
```

## Step 3 — Add supporting files (optional)

If your skill needs references (long lexicons, regex patterns, example libraries), put them in `references/` directory:

```
skills/your-skill-name/
├── SKILL.md
└── references/
    ├── lexicon.md
    └── examples.md
```

## Step 4 — Validate locally

```bash
./scripts/validate-skills.sh
```

This checks:
- Frontmatter is valid YAML
- Required fields present (`name`, `description`)
- Name matches directory
- Description ≤ 1024 chars
- License specified

## Step 5 — Test

1. Install the skill in your local agent:
   ```bash
   ./install.sh skill your-skill-name
   ```
2. Try it on real tasks.
3. If it doesn't help, refine and try again.

## Step 6 — Submit PR

```bash
git checkout -b feat/your-skill-name
git add skills/your-skill-name/
git commit -m "feat(skill): add your-skill-name"
git push origin feat/your-skill-name
```

Open a PR with:
- Title: `feat(skill): add your-skill-name`
- Description: what problem it solves, example use, screenshots if relevant
- Link to related issue (if any)

## Naming conventions

- Lowercase, kebab-case: `humanize-writer`, not `HumanizeWriter`
- 1–64 chars
- Must match the directory name
- Use verb-noun: `humanize-writer`, `audit-ai`, `clean-draft`
- Avoid generic: `helper`, `tool`, `skill`

## Description best practices

The description is what the agent uses to decide when to load the skill. Make it specific.

**Bad:** "Helps with writing."

**Good:** "Rewrite AI-sounding text to read human. Preserves meaning. Kills AI tells (em-dash, rule-of-three, hedging). Use when the user pastes LLM output and wants it rewritten."

Include:
- What it does
- When to trigger it
- What it preserves/doesn't preserve
- What patterns/tasks it handles

## Licensing

Code (SKILL.md, scripts): MIT, Apache 2.0, or similar permissive license.

References (long lexicons, examples): same as code, OR CC-BY-SA-4.0 if you want to allow derivative works with attribution.

Knowledge base notes: CC-BY-SA-4.0 (matches Obsidian vault convention).

## Questions?

Open an issue: https://github.com/11111000000/agents-writing-skills/issues
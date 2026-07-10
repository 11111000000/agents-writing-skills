---
title: Contributing
description: How to add new skills, prompts, knowledge notes to the agents-writing-skills ecosystem.
---

[← Back to Home](index)

# 🤝 Contributing

> Add a skill. Add a prompt. Add a knowledge note. Fix a typo. Open a PR.

<br>

## Quick links

- 📋 [GitHub repo](https://github.com/11111000000/agents-writing-skills)
- 🐛 [Issue tracker](https://github.com/11111000000/agents-writing-skills/issues)
- 💬 [Discussions](https://github.com/11111000000/agents-writing-skills/discussions)
- 📝 [License (skills + prompts)](LICENSE) · [CC-BY-SA-4.0 (knowledge)](knowledge)

<br>

## 🚀 Ways to contribute

### 1. Add a new skill (medium effort)

Skills are [`skills/<name>/SKILL.md`](https://github.com/11111000000/agents-writing-skills/tree/main/skills) files with YAML frontmatter.

**Start from template:**
```bash
cp -r skills/template-skill/ skills/my-new-skill/
```

**Required frontmatter:**

```yaml
---
name: my-new-skill
description: One-line description (max 1024 chars). When does the agent load this skill?
license: MIT
compatibility: opencode, pi, claude-code
metadata:
  audience: writing-assistants
  workflow: <your-workflow-name>
  version: 1
---
```

**Content checklist:**
- [ ] 12 levers usage (if applies)
- [ ] 3-pass workflow (if applies)
- [ ] "When NOT to load" section
- [ ] Companion skills reference
- [ ] Code blocks for examples (not bullet lists)
- [ ] Decision trees (when ambiguous)
- [ ] Multi-language support table (if applies)

**Register in [`manifest.json`](https://github.com/11111000000/agents-writing-skills/blob/main/manifest.json):**

```json
{
  "name": "my-new-skill",
  "version": "1.0.0",
  "path": "skills/my-new-skill/SKILL.md",
  "description": "One-line description",
  "use_when": "Trigger phrases for your skill",
  "companion_skills": ["other-skill"],
  "references": []
}
```

Validate locally:
```bash
bash scripts/validate-skills.sh    # checks all SKILL.md files
bash scripts/validate-manifest.sh  # checks manifest.json paths
```

### 2. Add a new prompt (small effort)

Prompts live in [`prompts/`](https://github.com/11111000000/agents-writing-skills/tree/main/prompts) for pi agents.

**File naming:** `prompts/<action>-<target>.md`

Examples: `humanize.md`, `audit-ai.md`, `clean-draft.md`.

**Frontmatter:**
```yaml
---
name: my-prompt
description: One-line summary
target_agents: [pi]
---
```

Register in `manifest.json` under `prompts` array.

### 3. Add a knowledge note (small effort)

Notes live in [`knowledge/`](https://github.com/11111000000/agents-writing-skills/tree/main/knowledge).

**File naming:** `knowledge/<category>/<name>.md` where categories are:
- `01-patterns/` — AI pattern catalog
- `02-techniques/` — humanization methods
- `03-detection/` — detector workings
- `04-examples/` — before/after cases
- `05-references/` — meta notes (limits, ethics)
- `06-sources/` — raw research notes

**Frontmatter:**
```yaml
---
type: technique  # or pattern | reference | source | detection | example
tags: [technique, foundational, lever-N]
created: YYYY-MM-DD
status: draft | active
related: [other-note]
---

# Title

> Quote (TL;DR)

## Theory (with citations)
## Implementation (concrete steps)
## Examples (with measured metrics)
## Edge cases (where NOT to apply)

[← Back to home](..)
```

### 4. Add a source note (research grounding)

Before adding a pattern or technique, ground it in a primary source.

**Pattern:** `06-Sources/<web-fetches|research-papers>/<topic>/<source-name>.md`

Template (`templates/source-note.md`):
```yaml
---
type: source
fetched_at: YYYY-MM-DD
url: <url>
author: <author>
year: <year>
source_type: arxiv | web | book | corpus
applicability: high | medium | low
tags: [source, <topic>]
status: draft
---

# Source title

## TL;DR / Abstract
## Key quotes
## Concrete examples (what we can extract)
## Connection to our work ([wikilinks])
## Open questions
## Raw notes (PDF link etc.)
```

### 5. Improve existing content

Small changes are welcome:
- Fix typos / broken wikilinks
- Add a missing example to `04-Examples/`
- Add a metric to `02-Techniques/`
- Translate a note between EN and RU

<br>

## 📝 Style guide

### Voice

- **Direct.** No «it could be argued that…», no hedging, no apologies.
- **Specific.** Numbers > adjectives. Always.
- **Russian-formal where appropriate.** We do translate concepts, but Russian formal register (деепричастия, парные синонимы) is **legitimate in formal docs**.
- **No AI tells.** If your draft has em-dash density > 1/300 words or rule-of-three, **rewrite it before submitting**.

### Code blocks

**Always** use code blocks for examples, not bullet lists. Compare:

```diff
# Wrong:
- Replace "delve" with "look at"
- Replace "leverage" with "use"

# Right:
```diff
- We must delve into the architecture
+ We must look at the architecture
```
```

### Wikilinks

Use `[[wikilinks]]` (Obsidian standard) for cross-references. Quartz renders them as links.

```markdown
See [[sufficiency-and-underspecification]] for the full mechanism.
```

### Bilingual content

We maintain two versions of major docs:
- `docs/getting-started.md` (EN)
- For RU: add Russian translation inline + language toggle in nav.

For knowledge notes, both languages can coexist in same file, with sections separated by H2 headers.

<br>

## 🚦 Pull request workflow

1. **Branch from main**: `git checkout -b feat/my-skill`
2. **Make changes** following style guide above
3. **Validate locally**:
   ```bash
   bash scripts/validate-skills.sh
   bash scripts/test-benchmark.sh
   bash scripts/build-site.sh ./preview  # optional
   ```
4. **Update CHANGELOG.md** with description of changes
5. **Bump versions** in `manifest.json` (patch for bugfix, minor for new skill, major for breaking change)
6. **Commit with conventional-commits message:**
   ```bash
   git commit -m "feat(skill): add my-new-skill

   - Pass 1 (Audit): list AI patterns
   - Pass 2 (Rewrite): apply 12 levers
   - Pass 3 (Verify): bias substitution check

   Tested on 5 sample texts.
   "
   ```
7. **Push and open PR**: `gh pr create`
8. **CI runs**: validate-skills.sh, validate-manifest.sh, benchmark smoke tests. PR must pass all three.

<br>

## 📋 Phase plan (roadmap)

| Phase | Goal | Status |
|---|---|---|
| v1 | 4 skills, 43 patterns, 9 base levers | Done |
| v2 | Sufficiency + Iceberg + YapBench integration | Done |
| v3 | Russian brevity grammar (Lever 12) | Done |
| v4 | 3-pass architecture + 13 worked examples + benchmark script | Done |
| v5 | Laconic prose models (Tolstoy, Dovlatov, Shklovsky, Bunin) + benchmark smoke tests | Done |
| v6 | Version sync + RU fixtures + threshold benchmark checks | Current |
| **v7 (next)** | **A/B human evaluation** + **long-form benchmarks** | Planned |
| v8 | Cross-language support (JA, ZH, FR) | Backlog |

<br>

## 🐛 Bug reports

Open an issue with:
- Skill name + version
- Input text snippet (anonymized)
- Expected vs actual output
- benchmark-skill.sh output if applicable

```bash
bash scripts/benchmark-skill.sh my-text.txt > bug-report.txt
# Attach bug-report.txt to issue
```

<br>

## 💬 Discussions

For:
- Idea proposal before PR
- Question about applicability
- Sharing empirical results
- Comparing to alternative approaches

Open a [discussion](https://github.com/11111000000/agents-writing-skills/discussions).

<br>

---

[← Back to Home](index)
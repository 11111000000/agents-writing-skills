---
title: Getting Started
description: Install agents-writing-skills in opencode, pi, Claude Code, or any Agent Skills-compatible agent. v7 skills edit prose in four modes and never invent facts.
---

[← Back to Home](index)

# 🚀 Getting Started

> Three ways to install. Pick what fits your agent.

<br>

## ⚡ Option 1: One-line (recommended)

Tell your agent, in any language:

> **EN:** "Clone https://github.com/11111000000/agents-writing-skills and install the skills from manifest.json"
>
> **RU:** «Клонируй https://github.com/11111000000/agents-writing-skills и установи скилы из manifest.json»

The agent will:
1. Clone the repo
2. Read `manifest.json` (machine-readable skill catalog)
3. Copy each `skills/<name>/SKILL.md` to its skill directory
4. Register prompts (if pi)

No shell scripts. No hardcoded paths. Works on any OS with any Agent Skills-compatible agent.

<br>

## 🔧 Option 2: Manual install

```bash
# Clone
git clone https://github.com/11111000000/agents-writing-skills.git
cd agents-writing-skills

# Read manifest
cat manifest.json | head -30

# Install skills (example for opencode)
mkdir -p ~/.config/opencode/skills
cp -r skills/humanize-writer/    ~/.config/opencode/skills/
cp -r skills/humanize-editor/    ~/.config/opencode/skills/
cp -r skills/anti-ai-auditor/    ~/.config/opencode/skills/
cp -r skills/ai-pattern-rewriter/ ~/.config/opencode/skills/

# For pi agents, also copy prompts
cp prompts/*.md ~/.pi/agent/prompts/
```

### Where skills go by agent

| Agent | Skills path | Prompts path |
|---|---|---|
| **opencode** | `~/.config/opencode/skills/` | n/a |
| **pi** | `~/.pi/agent/skills/` | `~/.pi/agent/prompts/` |
| **Claude Code** | `~/.claude/skills/` | n/a |
| **Codex CLI** | per docs | manual |
| **Other** | check agent docs | manual |

<br>

## 📦 Option 3: Offline install

```bash
# 1. Install skills (as above)

# 2. Install knowledge base offline
./scripts/install-knowledge.sh
# Clones to ~/.cache/agents-writing-skills-knowledge

# 3. Set environment variable
export KNOWLEDGE_PATH="$HOME/.cache/agents-writing-skills-knowledge/knowledge"

# 4. Replace GitHub URLs in skills with $KNOWLEDGE_PATH/ (if needed for full offline)
```

> [!tip] When to use offline mode
> Use only if your agent runs in an environment without internet access. GitHub URLs work in 99% of cases.

<br>

## ✅ Verify installation

### 1. Test benchmark-skill.sh

```bash
bash scripts/benchmark-skill.sh <(echo "В современном мире важно понимать, что...")
# Should output YapScore > 1.5 (because of over-generation)
```

### 2. Ask your agent

> **EN:** "Help me write a README"
>
> **RU:** «Помоги написать README»

The agent should automatically load `humanize-writer`. If it doesn't, your agent doesn't have Agent Skills support — see [Compatibility](skills-overview#-compatibility).

### 3. Run the repository validators

The scripts in `scripts/` check that the copy you installed is intact. Run them from the repository root; each one must exit with code `0`:

```bash
bash scripts/validate-skills.sh             # SKILL.md frontmatter, prompts, benchmark smoke test
bash scripts/check-examples-facts.sh        # no example "after" block invents a number
bash scripts/check-knowledge-links.sh       # every [[wikilink]] in knowledge/ resolves to a file
bash scripts/check-editing-output.sh --selftest   # the meaning-contract validator catches a broken edit
```

`check-editing-output.sh --selftest` proves the validator is not a rubber stamp: it feeds it a faithful edit (must pass) and a broken one (must be caught). The validator itself works against the 24 behavioural fixtures in `tests/fixtures/editing/` (source text, gold edit, and the claims that have to survive). `validate-skills.sh` runs the remaining checks too (manifest versions, stale contracts, example coverage, editing fixtures).

<br>

## 🎛 How the editor behaves (v7)

Before touching the text, the editor picks one of four depths. A deeper mode includes the powers of the shallower ones, and the mode never changes *what has to be preserved*.

| Mode | What it does | Typical request |
|---|---|---|
| **proofread** | Typos, grammar, punctuation, agreement | «вычитай», «check the errors» |
| **light** | Clarity: ambiguity, heavy constructions, office-speak | «поправь, чтобы читалось» |
| **style** | Rhythm and naturalness: sentence length, transitions | «сделай живее», «убери AI-шность» |
| **deep** | Restructure: order, merging paragraphs, sharper argument | «перепиши», «сделай из этого статью» |

- **RELY (iceberg deletions) runs only in `style`/`deep`**, and only for literary or conversational register.
- **An ambiguous request takes the shallower mode**: `light` unless the text or the user says otherwise, and the agent says which mode it picked.
- **The meaning contract holds in every mode.** Claims, numbers and the relations between them, conditions, exceptions, negations, modality, terminology, quotations and register survive the edit. Losing a claim, inventing a fact, or turning «может» into «снижает» is an error, not a stylistic trade-off.
- **A missing fact stays missing.** If a claim needs data the text does not contain, the edit marks `[нужен факт: ...]` instead of inventing a plausible number.

The mode table, the phase rules and the already-good-text rule are canonical on the [Skills Overview](skills-overview#-режимы-правки-editing-modes). Full spec: [`editing-modes`](02-techniques/editing-modes) · [`meaning-preservation`](02-techniques/meaning-preservation)

<br>

## 🎯 First use cases

### Convert AI-drafted text

```bash
# In pi:
> /humanize this: [paste AI-generated blog post]
> /audit-ai /path/to/my-draft.md
> /audit-43 /path/to/my-draft.md   # full 43-pattern audit
```

### Write new prose

```
> Help me write a landing page for a new CLI tool
> Draft a blog post about X
> Write an email to Y explaining why we need to delay the deadline
```

### Diagnose

```
> Where does this draft sound AI-like? [paste text]
> Why does my draft sound so generic?
> Compare version A and version B for AI tells
```

The auditor reports metrics (AP, D, E, YapScore, burstiness, specificity) as **diagnostics**: they show where to look, they do not deliver a verdict of "AI" or "human".

<br>

## 🔄 Updating

```bash
cd agents-writing-skills
git pull
```

The agent picks up changes on next skill load.

<br>

## 📚 Next steps

| Document | What it covers |
|---|---|
| [Skills Overview](skills-overview) | 4 skills, 4 editing modes, 4 phases, when to use which |
| [Knowledge Base](knowledge-base) | Tour of 41 notes (patterns, techniques, sources) |
| [Blind evaluation](blind-evaluation) | How the meaning contract is checked with human readers |
| [Limitations](limitations) | What these skills can and cannot do |
| [Contributing](contributing) | Add new skills, prompts, notes |

<br>

[← Back to Home](index) · [Next: Skills Overview →](skills-overview)
---
title: Getting Started
description: Install agents-writing-skills in opencode, pi, Claude Code, or any Agent Skills-compatible agent.
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

The agent should automatically load `humanize-writer`. If it doesn't, your agent doesn't have Agent Skills support — see [Compatibility](#compatibility).

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
> Is this too AI? [paste text]
> Why does my draft sound so generic?
> Compare version A and version B for AI tells
```

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
| [Skills Overview](skills-overview) | 4 skills, 4 phases, 12 levers, when to use which |
| [Knowledge Base](knowledge-base) | Tour of 41+ notes (patterns, techniques, sources) |
| [Limitations](limitations) | What these skills can and cannot do |
| [Contributing](contributing) | Add new skills, prompts, notes |

<br>

[← Back to Home](index) · [Next: Skills Overview →](skills-overview)
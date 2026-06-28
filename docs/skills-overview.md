---
title: Skills Overview
---

# Skills Overview

This repository ships four production skills. Each encodes a different workflow for avoiding AI tells in prose.

## Quick reference

| Skill | When to use | When NOT to use |
|---|---|---|
| `humanize-writer` | Writing new prose (README, docs, blog, email) | Code comments, JSON schemas, short error messages |
| `humanize-editor` | Rewriting existing AI-sounding text | Code, math, legal text |
| `anti-ai-auditor` | Diagnosing text without changing it | When user wants actual rewrite |
| `ai-pattern-rewriter` | Fixing one phrase at a time | Whole-document rewrites |

## humanize-writer

**Purpose:** Write new prose that reads as human-authored.

**Triggers:**
- "Help me write a README"
- "Draft a blog post about X"
- "Write an email to Y"
- "I need a status update for Z"

**Core workflow:**
1. Pre-flight: voice, lead, numbers
2. Draft
3. Audit (concrete details, burstiness, no banned lexicon, no triple-parallel)
4. Rupture pass (insert non-AI sentences)
5. Density check (metrics on AI-pattern density)

**Rules encoded:**
- 9 levers from harshaneel/humanize (perplexity injection, burstiness, hedge surgery, structural flattening, specificity, voice, transitions, punctuation, RLHF strip)
- Russian-specific extensions R-0 through R-5

## humanize-editor

**Purpose:** Rewrite existing AI-text to read as human.

**Triggers:**
- "Make this text sound less AI"
- "Rewrite this draft"
- "Humanize this"

**Difference from humanize-writer:**
- Writer creates from scratch (uses voice profile, lead, etc.)
- Editor preserves meaning of existing text, applies rules surgically

## anti-ai-auditor

**Purpose:** Diagnose text without rewriting.

**Triggers:**
- "Is this too AI?"
- "Check this draft"
- "Compare two versions"

**Output:** Structured report with category scores (Content/Language/Communication/Filler/Emerging/RU-specific), per-pattern hit list, density metrics, top-3 rewrite priorities.

## ai-pattern-rewriter

**Purpose:** Fix specific AI-pattern phrases, leave the rest alone.

**Triggers:**
- "Fix just this sentence"
- "Replace only line 7"
- "Make this one phrase less AI"

**Difference from humanize-editor:** Editor rewrites whole text. Rewriter touches only flagged spans.

## Companion prompts (pi only)

| Prompt | Purpose |
|---|---|
| `/humanize` | Full rewrite via prompt |
| `/audit-ai` | Diagnostic report via prompt |
| `/audit-43` | Full 43-pattern audit |
| `/humanize-9-levers` | Apply harshaneel's 9 levers strictly |
| `/anti-thesis` | Detect «Это не X, а Y» constructions |
| `/writer-voice` | Write new prose via prompt |
| `/clean-draft` | Light cleanup |
| `/rewrite-ai` | Surgical phrase fix |
| `/honest-check` | Pre-flight check on skill applicability |

## Compatibility

| Agent | Skills | Prompts |
|---|---|---|
| opencode | ✓ | n/a |
| pi | ✓ | ✓ |
| Claude Code | ✓ (when format supported) | manual copy |
| Codex CLI | ✓ | manual copy |
| Other Agent Skills-compatible | ✓ | manual copy |

All skills use the [Agent Skills standard](https://agentskills.io/specification): YAML frontmatter with `name` and `description`, Markdown body.
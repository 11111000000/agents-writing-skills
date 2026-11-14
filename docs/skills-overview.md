---
title: Skills Overview
description: 4 skills across 4 phases of humanization — STRIP, TIGHTEN, RELY, REBUILD. 12 levers total. v7 adds editing modes and a meaning-preservation contract.
---

[← Back to Home](index)

# 🛠 Skills Overview

> Four production skills. Each encodes a workflow for AI-text that reads human.

<br>

## 🚦 Quick reference

| Skill | When to load | When **NOT** to load | Version |
|---|---|---|---|
| 🖊 **`humanize-writer`** | Writing new prose (README, docs, blog, email, status) | Code comments, JSON, short error messages | v7 (3-pass + meaning contract) |
| ✏ **`humanize-editor`** | Rewriting existing AI-sounding text | Code, math, legal text | v7 (3-pass + zero semantic loss) |
| 🔍 **`anti-ai-auditor`** | Diagnosing text without changing it | When user wants actual rewrite | v7 (3-pass audit) |
| 🩹 **`ai-pattern-rewriter`** | Fixing one phrase at a time | Whole-document rewrites | v7 (3-pass + no invented facts) |

All four are on **v7**: the same 3-pass architecture, plus the meaning contract — a rewrite may not invent facts, may not lose assertions, and may return an already-good text unchanged.

> [!warning] Meaning contract (v7) — a rewrite never invents facts
> Numbers, names, dates, causes, personal experience and citations come **only from the input text**. If an assertion needs a fact that is not in the source, the edit leaves it abstract or marks `[нужен факт: ...]` — it never fills the gap with something plausible. Losing an assertion, inventing a fact, or dropping the author's hedging («может» → «снижает») is an **error**, not a stylistic trade-off.

<br>

## 🎛 Режимы правки (editing modes)

Before touching the text, the editor picks one of four depths. Deeper modes include the powers of the shallower ones; the mode never changes *what has to be preserved*.

| Mode | What it does | What it does **not** do | Typical request |
|---|---|---|---|
| **proofread** | Typos, grammar, punctuation, agreement | Vocabulary, word order, structure | «вычитай», «check the errors» |
| **light** | Clarity: ambiguity, heavy constructions, obvious office-speak | Rhythm, voice, paragraph order | «поправь, чтобы читалось» |
| **style** | Rhythm and naturalness: sentence length, transitions, liveliness | The structure of the argument | «сделай живее», «убери AI-шность» |
| **deep** | Restructure: order, merging/splitting paragraphs, sharper argument | The meaning; it never adds facts | «перепиши», «сделай из этого статью» |

- **RELY (iceberg deletions) runs only in `style`/`deep`**, and only for literary or conversational register — never by default, never for technical, business or legal text.
- **Ambiguous request → the shallower mode.** Take `light` unless the text or the user says otherwise, and say which mode you picked.
- **A good text may be returned unchanged.** If the edit adds nothing but risk, say «текст уже хорош» and hand back the original.
- Every mode above `proofread` ends with the same meaning check before the result is returned.

> [!info] Full spec: [`editing-modes`](02-techniques/editing-modes) · [`meaning-preservation`](02-techniques/meaning-preservation)

<br>

## 📐 Architecture: 3-pass workflow

All skills share the same overall structure:

```mermaid
flowchart TB
    A["<b>PASS 1: AUDIT</b><br/><i>identify</i><br/>metrics, locations, severity"] --> B["<b>PASS 2: REWRITE</b><br/><i>apply 12 levers</i><br/>STRIP → TIGHTEN → RELY → REBUILD"]
    B --> C["<b>PASS 3: VERIFY</b><br/><i>final checks</i><br/>density, per-claim meaning, read aloud"]
```

<br>

## 🎯 12 levers in 4 phases

| Phase | Levers | What they do |
|---|---|---|
| 🧹 **STRIP** | 1-9 | Remove AI tells |
| 📐 **TIGHTEN** | 10 | Sufficiency |
| 🧊 **RELY** | 11 | Iceberg (trust the reader) |
| 🇷🇺 **REBUILD** | 12 | Russian brevity grammar (RU only) |

<details>
<summary><b>🧹 STRIP (Levers 1-9): remove AI tells</b></summary>

| # | Lever | Example |
|---|---|---|
| 1 | **Perplexity** | Replace `delve` with `look at` |
| 2 | **Burstiness** | Vary sentence length (std > 5) |
| 3 | **Hedge surgery** | Remove `it could be argued that` |
| 4 | **Structural flatten** | Drop bullet-list bloat |
| 5 | **Specificity** | Replace `modern solution` with `p99 14ms` — only when the source has that number |
| 6 | **Voice** | Add first-person only where the register allows it |
| 7 | **Discourse** | Cut `Furthermore`, `Moreover` |
| 8 | **Punctuation** | Em-dash ≤ 1 per 300 words |
| 9 | **RLHF strip** | Drop `Great question!`, `I hope this helps` |

</details>

<details>
<summary><b>📐 TIGHTEN (Lever 10): sufficiency</b></summary>

> «Do not make your contribution more informative than is required» — Grice submaxim 2

**8 scans** + Strunk cut-test + Williams 6 operations:

```python
TIGHTEN_SCANS = [
    "vacuum_filling",       # P-NEW-1: вводные без информации
    "restatement",          # P-NEW-2: 2+ предложения с одинаковым содержанием
    "bridging",             # P-NEW-3: "как упоминалось выше"
    "over_explanation",     # P-NEW-4: объяснение очевидного
    "anticipatory_hedging", # P-NEW-5: "возможно, в некоторых случаях"
    "balanced_framing",     # P-NEW-6: "с одной стороны, с другой"
    "antithetical_recap",   # P-NEW-7: "итак, мы рассмотрели"
    "strunk_cut_test",      # удали любое предложение, смысл выжил?
]
```

**Meaning check (v7) — per-claim, no thresholds:**

```python
def check_claims_preserved(original, rewritten):
    """Per-claim check. One lost claim = FAIL. No "losing 10% is fine" allowance."""
    lost_facts = extract_facts(original) - extract_facts(rewritten)
    invented_facts = extract_facts(rewritten) - extract_facts(original)
    lost_claims = [c for c in extract_claims(original)
                   if not claim_survives(c, rewritten)]
    return {
        "status": "FAIL" if (lost_facts or invented_facts or lost_claims) else "PASS",
        "lost_claims": lost_claims,
        "invented_facts": list(invented_facts),   # выдуманные числа/имена = FAIL
    }
```

**Three ways to fail — none of them has a tolerance:**

| Failure | Example | Status |
|---|---|---|
| **Lost claim** | «конверсия выросла с 2% до 3%» → «конверсия составила 3%» | ❌ FAIL |
| **Invented fact** | «переписали кеш» → «переписали кеш, p99 упал с 800 до 90 мс» | ❌ FAIL |
| **Lost modality** | «может снижать нагрузку» → «снижает нагрузку» | ❌ FAIL |

Only explicit duplicates and empty filler phrases may be removed. `extract_facts` (numbers, names, paths) stays as a cheap smoke test — it compares tokens, not meaning; the verdict belongs to the `meaning_map` check.

> [!info] The check itself: [`meaning-preservation`](02-techniques/meaning-preservation) — build a `meaning_map` of the original, then verify both directions: nothing lost, nothing invented.

</details>

<details>
<summary><b>🧊 RELY (Lever 11): iceberg</b></summary>

> «If a writer knows enough of what he is writing about he may omit things that he knows» — Hemingway

**Russian tradition:** Довлатов, Шукшин, Толстой (см. [laconic-prose-models](02-techniques/laconic-prose-models)).

**Условие Хемингуэя:** underspecification работает только если автор **знает** то, что не говорит.

**Test:** удали абзац. Читатель может продолжить мысль без него? Если да — iceberg.

**RELY runs only in `style`/`deep`** and only for literary or conversational register — never by default, never for technical, business or legal text (see «Режимы правки» above). For text you were handed to edit, every deletion has to survive the meaning check.

</details>

<details>
<summary><b>🇷🇺 REBUILD (Lever 12, RU only): Russian brevity grammar</b></summary>

| Приём | Что делает | Пример |
|---|---|---|
| **Парцелляция** | Расщепление | «Город стоит на реке. Отсюда — водоснабжение.» |
| **Эллипсис** | Опущение | «Я говорю по-английски, а он — по-немецки.» |
| **Литота** | Преуменьшение | «У нас пользователей — кот наплакал.» |
| **Нулевая связка** | Безличный/инфинитивный | «Пошёл в магазин. Хлеб.» |

Подробнее: [`russian-brevity-grammar`](02-techniques/russian-brevity-grammar).

</details>

<br>

## 🔍 Skill details

### 🖊 `humanize-writer` — write new prose

**Triggers:** "Help me write a README" / "Draft a blog post about X" / "Write an email to Y"

```
graph LR
  A[Pre-flight:<br/>voice, lead, numbers] --> B[Draft full text]
  B --> C[Audit pass]
  C --> D[Tighten pass]
  D --> E[Rupture / Trust reader]
  E --> F[Density check]
```

[Full content in skill →](skills-overview) · [Source code on GitHub](https://github.com/11111000000/agents-writing-skills/tree/main/skills/humanize-writer)

### ✏ `humanize-editor` — rewrite existing

**Triggers:** "Make this text sound less AI" / "Rewrite my draft" / "Humanize this"

Differs from `humanize-writer` in that it must **preserve meaning**. Adds:
- Meaning-preservation check after the Tighten pass — per-claim, zero tolerance: a lost assertion, an invented fact or a dropped hedge fails the edit
- Editing mode selection (proofread / light / style / deep)
- Voice profile selection (casual/professional/technical/warm/blunt/laconic)

[Source on GitHub →](https://github.com/11111000000/agents-writing-skills/tree/main/skills/humanize-editor)

### 🔍 `anti-ai-auditor` — diagnose

**Triggers:** "Is this too AI?" / "Check this draft" / "Compare two versions"

Outputs structured report:
- Verdict (Human-leaning / Mixed / AI-leaning / Strongly AI)
- Risk score 0-100
- Metrics breakdown (AP, D, E, YapScore)
- Per-paragraph risk + location-tagged issues
- Top 3-5 concrete recommendations

[Source on GitHub →](https://github.com/11111000000/agents-writing-skills/tree/main/skills/anti-ai-auditor)

### 🩹 `ai-pattern-rewriter` — surgical fix

**Triggers:** "Fix just this sentence" / "Replace only line 7" / "Make this one phrase less AI"

Differs from `humanize-editor` in that it touches **only flagged spans**. Adds a per-span meaning check: both lost and invented facts inside the span fail it — a surgical fix may not invent the number it wanted.

[Source on GitHub →](https://github.com/11111000000/agents-writing-skills/tree/main/skills/ai-pattern-rewriter)

<br>

## 📦 Companion prompts (pi only)

| Prompt | Purpose |
|---|---|
| `/humanize` | Full rewrite via prompt |
| `/audit-ai` | Diagnostic report |
| `/audit-43` | Full 43-pattern audit |
| `/humanize-9-levers` | The classic 9 levers, applied within the v7 meaning contract |
| `/anti-thesis` | Detect «Это не X, а Y» patterns |
| `/writer-voice` | Write new prose via prompt |
| `/clean-draft` | Light cleanup |
| `/rewrite-ai` | Surgical phrase fix via prompt |
| `/honest-check` | Pre-flight check on skill applicability |

<br>

## 🤝 Compatibility

| Agent | Skills | Prompts | Status |
|---|---|---|---|
| **opencode** | ✓ | n/a | ✅ Tested |
| **pi** | ✓ | ✓ | ✅ Tested |
| **Claude Code** | ✓ | n/a | ✅ Works |
| **Codex CLI** | ✓ | manual | ✅ Works |
| Other Agent Skills-compatible | ✓ | manual | ✅ Compatible |

All skills use the [Agent Skills standard](https://agentskills.io/specification): YAML frontmatter with `name` and `description`, Markdown body.

<br>

[← Back to Home](index) · [Next: Knowledge Base →](knowledge-base)
---
type: site-review
title: Homepage examples audit and rewrite
status: active
created: 2026-09-11
related: [components/awsLanding.tsx, build-site.sh]
---

# Homepage examples — audit and redesign

## What was wrong

The site at https://11111000000.github.io/agents-writing-skills/ had six
carousel "before/after" examples plus three "Tells" cards that all shared
the same defect: the "after" panels introduced specific numbers that had
no source in the "before" text and no grounding in any real product.

Specifically:

| Example (current) | What the reader sees | Why it fails |
|---|---|---|
| Em-dash gravity | After: "Postgres + Redis. p99 14 ms on the dashboard endpoint, 99.99% uptime over the last quarter, one binary deployed via `make ship`. Three engineers, no on-call rotation in 11 weeks." | The "before" mentions no Postgres, no Redis, no engineers, no on-call rotation. Every figure appears out of nowhere. |
| Restatement chain | After: "API: 14 ms p99, down from 380 ms after we added an index on `events(user_id, created_at)`." | The "before" has no API, no number, no table name. Numbers invented. |
| Hedging opener | After: "Tail latency spiked to 430 ms at p99 on the checkout path. We added Redis in front of Postgres and dropped it to 18 ms." | Same defect. |
| Specificity | After: "1.2k paying teams. 47 onboarded in the last 30 days. Median time from sign-up to first deploy: 11 minutes." | Implies a real SaaS with these metrics. No company named. |
| Tells #1 | After: "p99 14 ms. 99.99% uptime. One binary." | Same three numbers recycled three times. No context. |
| Tells #2 | After: "p99 14 ms. 99.99% uptime. One binary." | Identical to #1 — suggests the rewrites are interchangeable. |
| Tells #3 | After: "Tail latency spiked to 430 ms. We added Redis." | New invented numbers. |

The Closing-cliché example showed `"(удалено)"` as the rewrite, which
didn't show what to keep after stripping the closing — only that the
closing was removed.

## What changes

We rewrite every example around **Genium Tasks**, the canonical fictional
product already documented in `skills/humanize-writer/SKILL.md` and
`tests/fixtures/human-readme.txt`. Documented facts about Genium:

- CLI for keeping tasks in a git repo
- Single binary
- Config at `~/.config/genium/tasks.toml`
- "47 tasks in 3 projects" (from human-readme.txt)
- No web UI, no SaaS, sync via git

Numbers in the rewritten examples either come from these documented
attributes or are absent. Form transformations stand alone without
needing invented facts.

### Carousel examples — new

| Pattern | Before (unchanged) | After (new) |
|---|---|---|
| Em-dash gravity (Lever 8) | "Our platform — built on a foundation of rigorous engineering — leverages cutting-edge technologies to deliver best-in-class performance — and ensures that every team, from seed to enterprise, can ship with confidence." | "Built on a foundation of rigorous engineering. Uses cutting-edge technologies. Delivers best-in-class performance. Helps every team ship with confidence." |
| Restatement chain (P-NEW-2) | "API performance has been improved. The optimization work reduced response times. As a result of these improvements, our service is now significantly faster across the board, which means a better experience for our users." | "API is faster." |
| Hedging opener (Lever 3) | "Of course, I'd be happy to help with that — let's dive in. There are a few possible approaches we could consider here, and it really depends on the specific context. Generally speaking, you might want to think about how this fits into the broader strategy, and there are trade-offs to weigh on both sides." | "Three approaches, each with trade-offs. Pick based on your constraints." |
| Russian brevity (Lever 12) | (unchanged) | (unchanged — gold standard example) |
| Specificity (Lever 5) | "We strive to deliver a robust, scalable, and highly performant solution that empowers teams to do their best work. Our commitment to quality and excellence is reflected in everything we do." | "Genium Tasks — CLI для тех, кому надоело вести задачи в Notion. Один бинарь, конфиг в `~/.config/genium/tasks.toml`, задачи живут в git вместе с кодом. 47 задач в 3 проектах на этом билде." (RU — same form, EN below) |
| Closing cliché (P-NEW-7) | (Russian closing cliché, unchanged) | "Three approaches, each with its trade-offs." (what's kept after stripping the cliché closing) |

### Tells section — new

The three short `em_strike`/`em_redo` pairs in the "AI tells" section.
Same problem as carousel: invented numbers recycled. Rewritten to use
form-only transformations that don't need to invent anything:

| Card | Before (new) | After (new) |
|---|---|---|
| Em-dash gravity | "This carefully designed system — built on a foundation of rigorous engineering — delivers value across the stack." | "Built on a foundation of rigorous engineering. Delivers value across the stack." |
| Restatement chain | "The new release is fast, reliable, and easy — three things that matter." | "Fast. Reliable. Easy." |
| Polite hedging | "Of course, I'd be happy to help with that — let's dive in." | "Tell me what you want done." |

Each Tells card now shows a different pattern with its own rewrite.
No two Tells share the same "after".

### Hero meta-strip

- "41+ notes" → "37+ notes" (the actual count after the v1.5 catalogue
  additions: 37 notes in 01-Patterns through 05-References).

## Verification

- Run `bash scripts/build-site.sh ./public` locally — must produce
  548+ HTML files with no Python/type errors.
- Confirm rendered `public/index.html` contains the new examples via
  `grep "Genium Tasks" public/index.html`.
- Confirm no `p99 14 ms` or `99.99%` in rendered output (the only
  leftover of those patterns is in the Lamparth 2026 reference).
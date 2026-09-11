---
type: research-plan
title: Validation research plan for benchmark-skill.sh metrics
status: active
created: 2026-09-11
target_completion: 2026-09-18
owner: validation/metrics-and-corpus branch
related: [benchmark-skill, hc3-english, raid-multi-domain, limits-and-self-critique]
---

# Research Plan: Empirical Validation of agents-writing-skills Metrics

## Why this plan exists

The benchmark script (`scripts/benchmark-skill.sh`) v1.4 has three known bugs that have been silently degrading its signal:

1. **YapScore hard-capped at 1.67** — the `floor=$WORDS*0.6` line meant severely
   over-generated text could never score above 1.67, making the metric useless for
   distinguishing "slightly long" from "catastrophically over-generated".
2. **D-metric (деепричастия) silently zero on Russian text** — global
   `export LC_ALL=C` plus `\b` word-boundary made Cyrillic character classes
   never match. D was always 0 regardless of input.
3. **Emoji regex throws stderr** — `[^[:ascii:]]` under LC_ALL=C raises
   "Invalid character class name" in GNU grep 3.12+. Output looks fine; metric
   is computed but stderr noise leaks.

After fixing all three, we now have a tool that can actually measure things. **The question: are its threshold values calibrated?** The README claims:
- AP < 1 / 1000 words
- D < 7 / 1000 words
- E < 3 / 300 words
- V < 5%, R < 10%, B < 5%
- YapScore 1.0–1.5 ok, 2.0+ critical
- Burstiness std > 5
- Specificity > 0.5 facts/paragraph

These come from "the literature" but have **never been tested** against a labeled
corpus. We need to:

1. **Validate discriminative power**: does the metric actually separate human
   from AI text?
2. **Calibrate thresholds**: are the recommended targets appropriate, or do
   they produce too many false positives / negatives?
3. **Identify blind spots**: which kinds of human prose look like AI by these
   metrics? Which AI text passes as human?

## Methodology

### Phase A — Material collection (4 parallel subagents)

| Agent | Deliverable | Output path |
|---|---|---|
| A1 | Sample HC3 dataset (reddit_eli5, finance, medicine — 50 human + 50 AI pairs per domain) | `tests/fixtures/hc3/` |
| A2 | Sample RAID dataset (news + recipes + wikipedia domains, GPT-4 + Mistral no-attack, 50/50) | `tests/fixtures/raid/` |
| A3 | Russian prose corpus (Tolstoy, Dovlatov, Bunin, Chekhov — public domain excerpts, ~5k words per author) | `tests/fixtures/ru-corpus/` |
| A4 | Survey of GitHub humanizers' pattern catalogues: extract any new AI-patterns not in current 43-pattern list | `knowledge/01-Patterns/catalogue-update.md` |

Subagents work in worktree, use HuggingFace `datasets` CLI, write fixtures with
metadata (source, language, label, model).

### Phase B — Build labeled ground truth

Aggregate A1+A2+A3 into `tests/fixtures/corpus-{human,ai}/<name>.txt` with
frontmatter recording source. Each file gets:
- `source:` (HC3/RAID/RU-corpus)
- `label:` (human/ai)
- `language:` (en/ru)
- `model:` (for AI)
- `domain:` (for context)

Target: ≥ 200 files total, balanced EN human / EN AI / RU human / RU AI.

### Phase C — Run benchmark on labeled corpus

For each file:
- run `benchmark-skill.sh --json`
- record all metrics
- write results to `tests/results/corpus-benchmark.jsonl`

Then aggregate and compute:
- **Per-metric discrimination**: AUC, KS statistic, optimal threshold
- **Confusion matrix** at default thresholds
- **Per-language breakdown** (EN vs RU)
- **Per-domain breakdown** (Q&A, news, prose, …)

### Phase D — Calibrate and update

Based on Phase C findings:
- Update threshold values in `benchmark-skill.sh` if needed
- Add new metrics if existing ones have weak signal
- Document calibration methodology in `knowledge/02-Techniques/metric-validation.md`
- Add regression tests that lock in the calibrated thresholds
- Update skill docs to reflect calibrated targets

### Phase E — Skill improvements

Apply findings to the SKILL.md files:
- If a metric has high false-positive rate, document which prose styles trip it
- If a pattern is missing from the 43-pattern catalogue, add it (e.g. a
  new variant of negative parallelism)
- If Russian grammar gap remains, extend Lever 12 with new examples
- Update "Multi-language support table" if any lever's applicability changes

## Success criteria

The plan is complete when:

- [ ] Phase A: ≥ 4 subagents have produced fixtures, fixtures validated by
      `wc -l` + sample-read review
- [ ] Phase B: ≥ 200 labeled files, balanced across EN/RU human/AI
- [ ] Phase C: Per-metric AUC > 0.7 for at least 4 metrics
      (i.e., they actually separate human from AI), per-language
- [ ] Phase D: Updated thresholds documented + new regression tests pass
- [ ] Phase E: At least one substantive change per skill file based on findings

The **discrimination threshold (AUC > 0.7)** is the bar. If we cannot show a
metric separates human from AI better than chance, we either need to fix it
or remove it from the skill's decision logic. Telling people "use this metric"
when it's coin-flip is dishonest.

## What we explicitly will NOT do

- **Will not** evaluate against commercial AI detectors (GPTZero, Pangram,
  Grammarly). Out of scope; out of ethics (we agreed to limits in
  `05-References/limits-and-self-critique.md`).
- **Will not** train a new ML model on this corpus. The benchmark is
  deterministic and rule-based by design — that's the point.
- **Will not** pull from non-public-domain sources for RU corpus.
  Classic Russian literature is the only ethically safe corpus.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| HC3/RAID downloads fail | Use `datasets` CLI with `--trust-remote-code`; cache under `~/.cache/agents-writing-skills-corpus/`; fall back to manual CSVs |
| Subagents write inconsistent metadata | Provide shared frontmatter schema in agent prompt |
| Russian detectors (HC3-ru) are translated, not original | Mark as `translation-derived` in metadata; use only for relative comparison, never as ground truth |
| AUC < 0.7 for some metric | Document honestly; either improve the metric or stop recommending it |
| Time budget overrun | Hard cap at 4 subagents, 200 fixtures. If A4 (pattern survey) is incomplete, defer to follow-up. |

## Status

- [x] P0 fixes: YapScore, emoji regex, D-metric regex, golden tests (18/18 pass)
- [x] Phase A: subagents dispatched
- [ ] Phase B: ground truth corpus
- [ ] Phase C: discrimination metrics
- [ ] Phase D: calibration
- [ ] Phase E: skill updates
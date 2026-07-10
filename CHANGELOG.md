# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added (v5 — current)
- **3-pass architecture** across all 4 skills (humanize-writer, humanize-editor, anti-ai-auditor, ai-pattern-rewriter). Each skill now has explicit Pass 1 (Audit/Surface/Identify) → Pass 2 (Rewrite) → Pass 3 (Verify) flow.
- **4-phase lever groups** in humanize-writer & humanize-editor: **STRIP** (Levers 1-9) → **TIGHTEN** (Lever 10) → **RELY** (Lever 11) → **REBUILD** (Lever 12, RU only).
- **Bias substitution algorithm** in humanize-editor Step 4.4 + ai-pattern-rewriter: extract facts (numbers, names, paths, dates), compare before/after Tighten, FAIL if loss >10%. Inspired by Lamparth et al. (arXiv 2605.27996, 2026).
- **13 worked examples** across 3 new directories:
  - `04-Examples/tightening/README.md` — 5 examples (README, email, blog, marketing, status)
  - `04-Examples/iceberg/README.md` — 3 examples (architecture, bug fix, code review)
  - `04-Examples/russian-grammar/README.md` — 5 examples (парцелляция, эллипсис, литота, нулевая связка, комбинация)
- **`scripts/benchmark-skill.sh`** — measures AP, D, E, V, B, YapScore, burstiness, specificity, format bias, voice on input text. Returns PASS/FAIL with recommendations.
- **Code-block examples** throughout skills (instead of bullet lists) — better readability and copy-paste utility.
- **Decision trees** for voice profile selection and applicability boundaries.
- **Multi-language support table** in humanize-writer.

### Changed (v5)
- `humanize-writer` v4 → v5: 3-pass, 4 phases, 11 workflow steps.
- `humanize-editor` v4 → v5: 3-pass, bias substitution algo, voice profile `laconic`.
- `anti-ai-auditor` v3 → v4: 3-pass audit (Surface/Deep/Synthesis).
- `ai-pattern-rewriter` v3 → v4: 3-pass surgical (Identify/Rewrite/Verify), per-span bias check.
- `references/lexicon.md` (updated separately).
- Manifest 1.2.0 → 1.3.0.

### Notes (v5)
- **Dialectic v2→v3→v4→v5**: each version adds a layer.
  - v2: catalogue patterns (43 patterns)
  - v3: positive principles (Sufficiency, Iceberg)
  - v4: language-specific tools (Lever 12 RU grammar), empirical grounding
  - v5: 3-pass architecture, examples, benchmarks, bias substitution check
- **Bias substitution alert (Lamparth 2026) is the most important new safety check.** Tighten pass now requires fact-level verification.
- **Reference data** — 13 examples with measurable before/after metrics. Future benchmarks can use these as ground truth.

## [v4 — released]

### Added (v4 — released as v4 here)
- **Lever 12: Russian brevity grammar** — парцелляция, эллипсис, литота, нулевая связка как русские грамматические инструменты краткости. LLM их почти не использует. Добавлено в `humanize-writer`, `humanize-editor`, `anti-ai-auditor`, `ai-pattern-rewriter`.
- **Length bias academic integration**: 5 source-notes из arXiv (Park 2024, Shen 2023, Zhang 2024, Lamparth 2026, Huang 2024) + synthesis заметка `02-Techniques/length-bias-research.md`. Подтверждает, что length bias — структурное свойство preference tuning.
- **Bias substitution warning** (Lamparth et al. 2026): single-axis сокращение может перенести bias на factual depth. Tighten pass должен сохранять плотность фактов.
- **Format bias detection** (Zhang et al. 2024): lists/bold/emojis как format-level signals. Добавлено в `anti-ai-auditor`.
- **Russian grammar synthesis note** `02-Techniques/russian-brevity-grammar.md` — связывает парцелляцию с P3 (деепричастия), эллипсис с P22 (filler), литоту с P11 (elegant variation).
- **Length bias synthesis note** `02-Techniques/length-bias-research.md` — структурирует 5 академических работ + каузальная цепочка.
- **Source notes (`06-Sources/`)**:
  - `06-Sources/research-papers/length-bias/` — 5 arXiv source-notes
  - `06-Sources/research-papers/detection-datasets/` — HC3 + RAID + HC3-ru source-notes
  - `06-Sources/web-fetches/russian-grammar/` — Wikipedia RU на парцелляцию, эллипсис, литоту
  - `templates/source-note.md` — шаблон для новых источников

### Changed (v4)
- `humanize-writer` v3 → v4: добавлен Lever 12 (Russian brevity grammar), length bias caveat в intro.
- `humanize-editor` v3 → v4: добавлен Step 5.5 (Russian grammar pass), bias substitution warning в Step 4.
- `anti-ai-auditor` v2 → v3: добавлены секции 10 (Format bias density), 11 (Length bias structural check), 12 (Russian brevity grammar opportunity).
- `ai-pattern-rewriter` v2 → v3: добавлен раздел "Russian brevity grammar spans" + bias substitution warning.
- `references/lexicon.md`: +секция "Russian brevity grammar" с примерами до/после.
- `knowledge/README.md` (MOC): добавлены ссылки на новые заметки.
- `manifest.json` 1.1.0 → 1.2.0.

### Notes (v4)
- **Lever 12 закрывает главный пробел для русского языка.** До v4 наши skill'ы умели *удалять* AI-паттерны в русском, но не умели *активно применять* живые русские традиции краткости.
- **Length bias research академически подкрепляет Lever 10/11.** Это не наша гипотеза — это эмпирические данные 5 независимых групп 2023–2026.
- **Bias substitution — новая серьёзная проблема.** Tighten pass может быть контрпродуктивным. Это требует осторожности и human-validation для high-stakes.
- **Phase 1.5 (специализированные выборки) выявила:** HC3 (English, 24.3k rows) — лучший готовый датасет. HC3-ru — перевод Google, не оригинал. Для русского нужен собственный корпус.

## [v3 — released]

### Added
- **Sufficiency principle (Lever 10 / Grice submaxim 2)**: positive principle "не больше, чем нужно" — добавлен в `humanize-writer`. Основан на Grice (1975), Strunk & White (1918/1959), Pascal (1657), Williams (*Style*).
- **Trust-the-reader principle (Lever 11 / Hemingway iceberg)**: positive principle "оставить пробелы, которые читатель заполнит" — добавлен в `humanize-writer`. Основан на Hemingway (1932), Chekhov (1889–1903).
- **Over-generation patterns (P-NEW-1…P-NEW-7)**: vacuum-filling, restatement chains, bridging, over-explanation, anticipatory hedging, balanced framing, antithetical recap. Новая категория в каталоге (дополняет P1–P43 из Aboudjem).
- **Tighten pass в `humanize-editor`**: 8-проходное сканирование + Strunk cut-test + Williams 6 операций. Цель — сокращение 15–30% от AI-черновика.
- **YapScore metric в `anti-ai-auditor`**: адаптация Borisov et al. (arXiv 2601.00624, январь 2026) — YapBench показал, что 76 LLM over-generate на 1–3× длины baseline. Категоризация 1.0–1.5× = ok, 1.5–2.0× = flag, 2.0×+ = critical.
- **Новая заметка `02-Techniques/sufficiency-and-underspecification.md`**: теория + эвристики + границы применимости.
- **Новая заметка `01-Patterns/structural/over-generation.md`**: P-NEW-1…P-NEW-7 со сводной таблицей.
- **«Когда молчать» таблица** в `humanize-writer`: различает контексты, где недосказанность работает vs ломает смысл.

### Changed
- `humanize-writer` v2 → v3: 11 levers вместо 9, 7-step workflow вместо 5-step.
- `humanize-editor` v2 → v3: Tighten pass и Reader-fill pass как отдельные шаги.
- `anti-ai-auditor` v1 → v2: Over-generation metrics в отчёте.
- `ai-pattern-rewriter` v1 → v2: Over-generation spans (10 переписываний) + Williams 6 операций.
- `references/lexicon.md`: 5 новых секций запрещённых паттернов + Strunk/Williams checklist.
- `05-References/limits-and-self-critique.md`: добавлен YapBench как академический источник; гипотеза о Lever 10/11 как positive principle vs negative rules.

### Notes
- **Это структурное дополнение, не косметика.** YapBench (январь 2026) эмпирически подтвердил, что length bias — это не стилистический артефакт, а свойство preference tuning. Лечится не списком запрещённых слов, а положительным принципом суффицентности.
- **Диалектика:** v2 был преимущественно **negative** rules (не пиши X). v3 добавляет **positive** principles (когда сказать меньше, как доверять читателю). Это не отменяет v2 — дополняет.
- **Границы применимости сохранены:** в technical reference, legal text, onboarding — недосказанность ломает смысл. Lever 10/11 применяются только там, где уместны.

## [1.0.0] — 2025

### Added
- Initial release of `agents-writing-skills` repository.
- 4 skills: `humanize-writer`, `humanize-editor`, `anti-ai-auditor`, `ai-pattern-rewriter`.
- 9 prompt templates for pi: `humanize`, `audit-ai`, `audit-43`, `humanize-9-levers`, `anti-thesis`, `writer-voice`, `clean-draft`, `rewrite-ai`, `honest-check`.
- `template-skill` for creating new skills.
- Knowledge base: 25+ Obsidian notes documenting 43 AI-pattern categories, 9 humanization levers, Russian-specific patterns, detection methods.
- `install.sh` with subcommands: opencode, pi, all, skill, prompt, list, uninstall.
- `scripts/validate-skills.sh` for CI validation of SKILL.md frontmatter.
- `scripts/build-site.sh` for building Quartz site to GitHub Pages.
- Bilingual README (English + Russian).
- GitHub Actions workflows: validate-skills, deploy-pages, release.
- Issue templates: new-skill, bug-report.

### Notes
- Knowledge base moved from `~/Desktop/AgentWritingBase/Obsidian/` to `knowledge/` in this repository.
- All skills include explicit "when NOT to apply" sections and ethical disclaimers.
- The 43-pattern catalogue is sourced from Aboudjem/humanizer-skill (MIT, 98★).
- The 9 humanization levers are sourced from harshaneel/humanize (MIT, 56★).
- Russian-specific patterns sourced from Wikipedia RU (CC-BY-SA-4.0).
# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
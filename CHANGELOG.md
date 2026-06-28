# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

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
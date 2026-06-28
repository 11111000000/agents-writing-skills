# Contributing

Thanks for your interest in agents-writing-skills. This document covers how to report bugs, suggest skills, and submit changes.

## Code of conduct

Be kind. We're all here to make agents write better. Disagreements about technique are fine; disrespect isn't.

## Reporting bugs

Open an issue using the **Bug Report** template. Include:

- Component affected (skill, prompt, install.sh, knowledge note, build)
- Version (git tag or commit hash)
- What happened vs what you expected
- Steps to reproduce
- Relevant logs

## Suggesting a new skill

Open an issue using the **New Skill** template. Before opening:

1. Read [`skills/template-skill/SKILL.md`](skills/template-skill/SKILL.md) to understand the structure.
2. Check existing skills (in `skills/`) to avoid duplication.
3. Read [`knowledge/05-References/limits-and-self-critique.md`](knowledge/05-References/limits-and-self-critique.md) to understand what works.

## Adding knowledge notes

The knowledge base is an Obsidian vault in `knowledge/`. To add or modify notes:

1. Open `knowledge/` in Obsidian (File → Open vault).
2. Add notes following conventions in [`knowledge/templates/note-template.md`](knowledge/templates/note-template.md).
3. Use `[[wikilinks]]` for cross-references.
4. Add frontmatter (`type`, `tags`, `created`, `status`).
5. Submit a PR with title `docs(knowledge): <one-line description>`.

## Submitting code

### Workflow

1. Fork the repository.
2. Create a branch: `git checkout -b feat/your-skill-name`
3. Make your changes.
4. Run `./scripts/validate-skills.sh` (validates frontmatter).
5. Run `./install.sh skill <name>` to test locally.
6. Commit with a conventional commit message.
7. Push and open a PR.

### Conventional commits

```
feat(skill): add humanize-writer
fix(skill): correct em-dash count in humanize-editor
docs(knowledge): add notes on voice in Russian
chore: update CI workflow
```

### PR checklist

- [ ] `./scripts/validate-skills.sh` passes
- [ ] Local installation tested with `./install.sh`
- [ ] Description ≤ 1024 chars
- [ ] License specified (MIT or Apache 2.0)
- [ ] "When NOT to apply" section present
- [ ] Examples included
- [ ] Linked from related skills' "See also" section

## Adding a prompt template

Prompts live in `prompts/`. Each prompt is a Markdown file with YAML frontmatter.

Format:

```markdown
---
description: One-line description (≤1024 chars).
argument-hint: "<hint>"
---

You are operating as the `<skill-name>` workflow.

[Body of prompt]

$@
```

`$@` is replaced with user input. `$1`, `$2`, etc. are positional args.

## Adding a new skill (detailed)

1. Copy template:
   ```bash
   cp -R skills/template-skill/ skills/your-skill-name/
   ```

2. Edit `skills/your-skill-name/SKILL.md`:
   - Set `name` (kebab-case, matches directory name)
   - Set `description` (≤1024 chars, specific, tells the agent when to load)
   - Set `license: MIT` (or Apache 2.0)
   - Set `compatibility: opencode, pi, claude-code` (or subset)
   - Fill in the body with hard rules, workflow, examples

3. If skill needs reference data (long lexicons, regexes), put in `skills/your-skill-name/references/`.

4. Validate:
   ```bash
   ./scripts/validate-skills.sh
   ```

5. Test:
   ```bash
   ./install.sh skill your-skill-name
   # Then in your agent, try triggering it
   ```

6. Update related skills' "See also" sections if they should reference this new skill.

## License

By contributing, you agree that your contributions will be licensed under MIT (for code) or CC-BY-SA-4.0 (for knowledge notes).

## Questions?

Open an issue or start a discussion in the Discussions tab.
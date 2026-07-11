name: New Skill
description: Propose a new skill for the agents-writing-skills repository.
title: "[Skill]: "
labels: ["skill", "needs-triage"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Thanks for proposing a new skill. Please fill in the details below.

  - type: input
    id: skill-name
    attributes:
      label: Skill name (kebab-case)
      description: e.g. `humanize-writer`, `clean-draft`
      placeholder: my-new-skill
    validations:
      required: true

  - type: textarea
    id: description
    attributes:
      label: Description
      description: One-sentence description (≤1024 chars)
      placeholder: What does this skill do? When should it be triggered?
    validations:
      required: true

  - type: textarea
    id: problem
    attributes:
      label: Problem it solves
      description: What writing problem does this skill address?
    validations:
      required: true

  - type: textarea
    id: approach
    attributes:
      label: Approach
      description: How does the skill work? What patterns/techniques does it apply?
    validations:
      required: true

  - type: textarea
    id: examples
    attributes:
      label: Examples
      description: 2-3 before/after examples demonstrating the skill
    validations:
      required: false

  - type: dropdown
    id: language
    attributes:
      label: Primary language
      description: What language is the skill description and frontmatter in?
      options:
        - English
        - Russian
        - Both (bilingual)
    validations:
      required: true

  - type: checkboxes
    id: checks
    attributes:
      label: Pre-submission checks
      options:
        - label: I read CONTRIBUTING.md
          required: true
        - label: I used `skills/template-skill/` as starting point
          required: true
        - label: I ran `./scripts/validate-skills.sh` and it passed
          required: true
        - label: I tested the skill locally by copying to ~/.config/opencode/skills/
          required: true

  - type: markdown
    attributes:
      value: |
        See [`skills/template-skill/SKILL.md`](skills/template-skill/SKILL.md) for the template.
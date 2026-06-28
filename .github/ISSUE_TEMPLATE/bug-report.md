name: Bug Report
description: Report a bug in a skill, prompt, or installation script.
title: "[Bug]: "
labels: ["bug"]

body:
  - type: dropdown
    id: component
    attributes:
      label: Affected component
      options:
        - Skill (which one?)
        - Prompt template
        - install.sh
        - Knowledge base note
        - GitHub Pages / Quartz build
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: Version
      description: Which version are you running? (git tag or commit)
      placeholder: v1.2.0 or abc123
    validations:
      required: false

  - type: textarea
    id: description
    attributes:
      label: What happened?
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: What did you expect?
    validations:
      required: true

  - type: textarea
    id: reproduce
    attributes:
      label: Steps to reproduce
    validations:
      required: false

  - type: textarea
    id: logs
    attributes:
      label: Logs / error output
    validations:
      required: false
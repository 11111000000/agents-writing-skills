---
id: already-good-3
language: en
genre: already-good
audience: developers
edit_mode: proofread
required_preservation:
  claims: ["commit messages should explain why, not what", "keep the subject under 72 characters"]
  conditions: ["add a body when the change needs context"]
  exceptions: []
  uncertainty: []
  terminology: ["commit message", "imperative"]
forbidden_additions: ["new rules not in the source"]
expected_issues: []
allow_major_rewrite: false
---

## Source
Good commit messages explain why, not what. The diff already shows what changed; the message should say what problem it solves. Write the subject in the imperative, keep it under 72 characters, and add a body when the change needs context. Future you will read this message at 2 a.m. during an incident — write it for that person.

## Gold edit
Good commit messages explain why, not what. The diff already shows what changed; the message should say what problem it solves. Write the subject in the imperative, keep it under 72 characters, and add a body when the change needs context. Your future self will read this message at 2 a.m. during an incident — write it for that person.

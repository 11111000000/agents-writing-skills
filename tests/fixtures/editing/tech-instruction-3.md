---
id: tech-instruction-3
language: en
genre: tech-instruction
audience: developers
edit_mode: light
required_preservation:
  claims: ["backups are stored in /var/backups", "backups are kept for 14 days"]
  conditions: ["rollback works only if the database schema has not changed", "if migrations were applied after the release, the backup must be restored first"]
  exceptions: []
  uncertainty: []
  terminology: ["git tag", "deploy.sh"]
forbidden_additions: ["new commands or flags not in the source", "guaranteed outcomes"]
expected_issues: ["wordiness", "passive voice"]
allow_major_rewrite: false
---

## Source
To roll back a deployment, the following steps should be followed. First of all, the previous release tag needs to be identified with git tag. Secondly, it should be redeployed using deploy.sh <tag>. It is important to note that the rollback procedure only works in the event that the database schema has not been changed; in cases where migrations were applied after the release, the backup must be restored first. The backup is stored in /var/backups and is retained for a period of 14 days.

## Gold edit
To roll back a deployment: find the previous release tag with git tag, then redeploy it with deploy.sh <tag>. Rollback works only if the database schema has not changed. If migrations were applied after the release, restore the backup first; backups are stored in /var/backups and kept for 14 days.

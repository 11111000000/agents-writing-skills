#!/usr/bin/env bash
# scripts/check-no-stale-contract.sh
# The v7 meaning contract replaced the old "you may lose up to 10% of the
# facts" rule. Any surviving mention of `loss_pct`, `check_bias_substitution`
# or a `10%` fact-loss threshold in the skills, prompts, docs or the two
# scoped knowledge areas means the project describes two different contracts.
#
# Usage: ./scripts/check-no-stale-contract.sh
# Exit: 0 = no stale contract references, 1 = stale references found.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 2

PATTERNS='loss_pct|check_bias_substitution|loss_pct_facts'

HITS=$(grep -rnE "$PATTERNS" \
  skills/ prompts/ docs/ \
  knowledge/02-Techniques/ knowledge/04-Examples/ \
  --include='*.md' 2>/dev/null || true)

if [[ -n "$HITS" ]]; then
  echo "FAIL: stale v6 contract references found:"
  echo "$HITS"
  exit 1
fi

echo "ok: no stale v6 contract references (loss_pct / check_bias_substitution)"

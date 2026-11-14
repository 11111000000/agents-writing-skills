#!/usr/bin/env bash
# scripts/check-examples-coverage.sh
# The meaning-contract claim covers knowledge/04-Examples/. Two things must
# hold: every example file in that tree is parseable by the facts checker,
# and the checker still catches a violation (so "no failures" is not the
# result of a checker that stopped looking).
#
# Usage: ./scripts/check-examples-coverage.sh
# Exit: 0 = coverage ok, 1 = coverage gap or checker regression, 2 = usage error.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 2

CHECKER="scripts/check-examples-facts.sh"
EXAMPLES="knowledge/04-Examples"
MIN_FILES=6

[[ -x "$CHECKER" ]] || { echo "ERROR: $CHECKER not found or not executable" >&2; exit 2; }

fail=0
count=0
while IFS= read -r f; do
  count=$((count + 1))
  bash "$CHECKER" "$f" >/dev/null 2>&1
  rc=$?
  if [[ $rc -eq 2 ]]; then
    echo "FAIL: checker cannot parse $f (exit 2)"
    fail=1
  fi
done < <(find "$EXAMPLES" -type f -name '*.md' | LC_ALL=C sort)

if [[ $count -lt $MIN_FILES ]]; then
  echo "FAIL: only $count example file(s) found under $EXAMPLES (expected >= $MIN_FILES)"
  fail=1
else
  echo "ok: $count example files parseable by $CHECKER"
fi

subdirs=$(find "$EXAMPLES" -mindepth 1 -type d | wc -l | tr -d ' ')
if [[ "$subdirs" -ge 3 ]]; then
  echo "ok: $subdirs example subdirectories covered"
else
  echo "FAIL: only $subdirs example subdirectories under $EXAMPLES (expected >= 3)"
  fail=1
fi

# Self-test: the checker must still detect a violation.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/violation.md" <<'EOF'
### ❌ До (AI)

> API отвечает за 14 мс.

### ✅ После (человек)

> API отвечает за 500 RPS и держит 99.99% uptime.
EOF
bash "$CHECKER" "$tmp/violation.md" >/dev/null 2>&1
rc=$?
if [[ $rc -eq 1 ]]; then
  echo "ok: checker detects an injected violation (exit 1)"
else
  echo "FAIL: checker did not detect an injected violation (exit $rc, expected 1)"
  fail=1
fi

exit $fail

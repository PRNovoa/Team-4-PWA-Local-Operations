#!/usr/bin/env bash
# Shared hybrid-rubric prompt builder for PR review — used by BOTH review backends
# (local Ollama, scripts/pr-review/review-local.sh; cloud Anthropic,
# .github/workflows/pr-review.yml). One prompt, two possible models behind it —
# see docs/public/guides/reviewing-cohort-prs.md for which one is actually active
# and why.
#
# Usage: build-prompt.sh <branch-name> <diff-file>
# Writes the prompt to stdout.
set -euo pipefail

BRANCH="${1:?usage: build-prompt.sh <branch-name> <diff-file>}"
DIFF_FILE="${2:?usage: build-prompt.sh <branch-name> <diff-file>}"

# Convention documented in docs/public/guides/contributing.md: branch names should
# contain "<seam>-task<N>" so the reviewer can find that task's own acceptance
# criteria, not just the generic rubric.
SEAM_TASK=$(echo "$BRANCH" | grep -oE '(content|graph|oracle|pwa|accounts)-task[0-9]+' | head -1 || true)
BRIEF_FILE="docs/DEV_PLAN/ASSIGNMENTS/ASSIGNMENT-${SEAM_TASK}.md"

echo "You are reviewing one student pull request for TTOD, a teaching codebase. Post"
echo "findings as PR review comments ONLY. You must never approve, request changes, or"
echo "imply the PR is merged/mergeable — a human is the only approver. Be concise:"
echo "group findings under the rubric headings below; skip a heading entirely if the"
echo "diff gives you nothing specific to say under it (never pad with generic praise)."
echo
echo "## Generic rubric (applies to every PR, from PHASE-V-FEII-COHORT-COLLABORATION-AND-ASSESSMENT.md §5)"
echo "- Contract adherence (25): uses the published \`src/types/domain.ts\` shapes exactly — no parallel/ad-hoc type invented for something a shared type already covers"
echo "- Correctness & acceptance criteria (25): does the change do what its task's acceptance criteria promise"
echo "- Test coverage (20): unit/component tests exist for new behavior; per Unit 5's Trophy-not-Pyramid doctrine, prefer integration-shaped tests over exhaustive unit tests of trivial functions"
echo "- Accessibility (10): keyboard-operable, one accessible name/label, no color-only distinction, respects prefers-reduced-motion"
echo "- CI green (10): note if the diff looks like it would fail lint/typecheck/build, but do not re-run CI yourself"
echo "- AI disclosure & process evidence (10): the PR description's AI Review Log table must be filled in, honestly — flag if it's missing or empty, this makes the PR incomplete per Unit 6"
echo

if [ -n "$SEAM_TASK" ] && [ -f "$BRIEF_FILE" ]; then
  echo "## This task's own acceptance and quality criteria (from $BRIEF_FILE)"
  echo '```markdown'
  cat "$BRIEF_FILE"
  echo '```'
  echo
  echo "Weigh the task-specific criteria above as heavily as the generic rubric — a PR"
  echo "that satisfies the generic rubric but misses this task's own success criteria is"
  echo "not done."
else
  echo "## No task-specific brief matched"
  echo "This PR's branch name didn't match the \`<seam>-task<N>\` convention (content,"
  echo "graph, oracle, pwa, accounts), so only the generic rubric above applies. If this"
  echo "PR does correspond to a numbered task, ask the student to rename their branch —"
  echo "see docs/public/guides/contributing.md."
fi

echo
echo "## The diff"
echo '```diff'
head -c 60000 "$DIFF_FILE"
echo '```'

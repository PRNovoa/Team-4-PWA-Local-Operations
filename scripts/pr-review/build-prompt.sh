#!/usr/bin/env bash
# Shared hybrid-rubric prompt builder for PR review — used by BOTH review backends
# (local Ollama, scripts/pr-review/review-local.sh; cloud Anthropic,
# .github/workflows/pr-review.yml). One prompt, two possible models behind it —
# see docs/public/guides/reviewing-cohort-prs.md for which one is actually active
# and why.
#
# Usage: build-prompt.sh <branch-name> <diff-file>
# Writes the prompt to stdout. Writes a one-line brief-status to stderr so
# `make review-pr` operators can see which ASSIGNMENT-*.md (if any) was loaded.
#
# Bump PROMPT_BUILDER_VERSION whenever the prompt contract changes (labels,
# inventory, brief aliases, caveat text, etc.). review-local.sh and the cloud
# workflow stamp this into the posted PR comment footer.
PROMPT_BUILDER_VERSION="2.1.0"

set -euo pipefail

BRANCH="${1:?usage: build-prompt.sh <branch-name> <diff-file>}"
DIFF_FILE="${2:?usage: build-prompt.sh <branch-name> <diff-file>}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DOMAIN_FILE="${REPO_ROOT}/services/frontend/src/types/domain.ts"
ASSIGNMENTS_DIR="${REPO_ROOT}/docs/DEV_PLAN/ASSIGNMENTS"

# Resolve <seam>-task<N> from the branch name.
# 1) Canonical: accounts-task2-personal-library (documented in contributing.md)
# 2) Cohort short form rescue: task/2-personal-library (Equipo 5 early branches)
resolve_seam_task() {
  local branch="$1"
  local match
  match=$(printf '%s' "$branch" | grep -oE '(content|graph|oracle|pwa|accounts)-task[0-9]+' | head -1 || true)
  if [ -n "$match" ]; then
    printf '%s\n' "$match"
    return 0
  fi

  local lower
  lower=$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]')

  # Keyword → accounts task (slug-driven; number in task/N- is ignored when keywords conflict)
  case "$lower" in
    *ssr-auth*|*session-guard*|*login-session*) printf 'accounts-task1\n'; return 0 ;;
    *personal-library*|*favorites-library*|*favoritos*) printf 'accounts-task2\n'; return 0 ;;
    *proposal-endpoint*|*propose-endpoint*|*proposal-api*) printf 'accounts-task3\n'; return 0 ;;
    *review-pipeline*|*github-native-review*) printf 'accounts-task4\n'; return 0 ;;
    *public-pat*|*bearer-token*|*public-api-token*) printf 'accounts-task5\n'; return 0 ;;
  esac

  # task/<N>-… only when the slug still looks accounts-related
  if [[ "$lower" =~ (^|/)task/([0-9]+)(-|$) ]]; then
    local n="${BASH_REMATCH[2]}"
    case "$lower" in
      *auth*|*login*|*session*|*library*|*favorit*|*proposal*|*pat*|*bearer*|*review-pipeline*)
        printf 'accounts-task%s\n' "$n"
        return 0
        ;;
    esac
  fi

  return 1
}

SEAM_TASK=""
if SEAM_TASK=$(resolve_seam_task "$BRANCH"); then
  :
else
  SEAM_TASK=""
fi

BRIEF_FILE="${ASSIGNMENTS_DIR}/ASSIGNMENT-${SEAM_TASK}.md"

if [ -n "$SEAM_TASK" ] && [ -f "$BRIEF_FILE" ]; then
  echo "pr-review: prompt-builder=$PROMPT_BUILDER_VERSION brief=$BRIEF_FILE (branch=$BRANCH → $SEAM_TASK)" >&2
elif [ -n "$SEAM_TASK" ]; then
  echo "pr-review: prompt-builder=$PROMPT_BUILDER_VERSION brief=missing (branch=$BRANCH → $SEAM_TASK; no $BRIEF_FILE)" >&2
  SEAM_TASK=""
else
  echo "pr-review: prompt-builder=$PROMPT_BUILDER_VERSION brief=none (branch=$BRANCH; expected <seam>-task<N> or known task/<N>-<slug> alias)" >&2
fi

echo "You are reviewing one Development Team pull request for TTOD, a teaching codebase. Post"
echo "findings as PR review comments ONLY. You must never approve, request changes, or"
echo "imply the PR is merged/mergeable — a human is the only approver."
echo
echo "## Output format (mandatory)"
echo "Under each rubric heading you keep, every bullet MUST start with exactly one of:"
echo "- \`MUST FIX:\` — concrete defect a human should treat as Request changes material"
echo "- \`NIT:\` — optional improvement; humans should NOT request-changes for NITs alone"
echo "Rules:"
echo "- Skip a rubric heading entirely if the diff gives you nothing specific (no padding,"
echo "  no generic praise, no 'looks fine')."
echo "- Never write 'ensure that…', 'consider…', or 'make sure…' unless you cite a concrete"
echo "  symbol and path from the diff (e.g. \`FavoriteButton\` in"
echo "  \`services/frontend/src/components/favorites/FavoriteButton.tsx\`)."
echo "- Never claim a type 'in domain.ts should align with domain.ts' — that is circular."
echo "  Compare names against the contract inventory below (baseline + diff deltas)."
echo "- CI green: omit the heading unless you cite a concrete lint/type/build risk visible"
echo "  in a hunk (missing import, syntax error, obvious type mismatch). Do not praise CI."
echo "- Accessibility: omit unless you cite a concrete missing name/role/keyboard path or a"
echo "  motion style that ignores prefers-reduced-motion in the hunk."
echo

echo "## Generic rubric (applies to every PR, from PHASE-V-FEII-COHORT-COLLABORATION-AND-ASSESSMENT.md §5)"
echo "- Contract adherence (25): uses the published \`services/frontend/src/types/domain.ts\` shapes exactly — no parallel/ad-hoc type invented for something a shared type already covers"
echo "- Correctness & acceptance criteria (25): does the change do what its task's acceptance criteria promise"
echo "- Test coverage (20): unit/component tests exist for new behavior; per Unit 5's Trophy-not-Pyramid doctrine, prefer integration-shaped tests over exhaustive unit tests of trivial functions"
echo "- Accessibility (10): keyboard-operable, one accessible name/label, no color-only distinction, respects prefers-reduced-motion"
echo "- CI green (10): note ONLY if the diff looks like it would fail lint/typecheck/build; do not re-run CI; omit if nothing concrete"
echo "- AI disclosure & process evidence (10): the PR description's AI Review Log table must be filled in, honestly — flag if it's missing or empty, this makes the PR incomplete per Unit 6"
echo
echo "## Teaching-fixture caveat (read before flagging 'insecure credentials')"
echo "This is a pedagogical product. Seeded demo users / fixed emails in backend seed data or"
echo "tests (e.g. \`admin@ttod.local\`) are often intentional fixtures — do **not** score them as"
echo "production-security failures by themselves."
echo "Still flag as correctness/security when:"
echo "- plaintext passwords are committed or logged,"
echo "- values look like real external API keys/secrets,"
echo "- a login UI hardcodes credentials in a way that **bypasses** the real server-side"
echo "  AuthService / passlib-bcrypt path required by the loaded task brief (seeded *users* ≠"
echo "  client-side hardcoded password check),"
echo "- or the task brief explicitly forbids the pattern."
echo "When a task brief is loaded below, that brief wins over this caveat."
echo

echo "## Contract inventory (services/frontend/src/types/domain.ts)"
echo "Baseline exports visible on this review checkout (often main — not necessarily the PR tip):"
if [ -f "$DOMAIN_FILE" ]; then
  echo '```typescript'
  # Export declarations only — enough for name collision checks without flooding the prompt.
  grep -E '^export (type|interface|enum) ' "$DOMAIN_FILE" || echo "// (no export lines matched)"
  echo '```'
else
  echo "(domain.ts not found at $DOMAIN_FILE on this checkout)"
fi
echo
echo "Type/interface/enum export lines added (+) or removed (-) in this PR's diff"
echo "(any file — watch domain.ts especially; ignore \`export const prerender\` noise):"
echo '```diff'
if grep -E '^[+-]\s*export (type|interface|enum) ' "$DIFF_FILE" >/dev/null 2>&1; then
  grep -E '^[+-]\s*export (type|interface|enum) ' "$DIFF_FILE" | head -80
else
  echo "// (no export type/interface lines in the diff)"
fi
echo '```'
echo "Contract MUST FIX only when the PR invents a parallel type for a name already in the"
echo "baseline, or defines a domain shape outside domain.ts that belongs there per the brief."
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
  echo "This PR's branch name didn't match \`<seam>-task<N>\` (content, graph, oracle, pwa,"
  echo "accounts) and didn't match a known short alias (e.g. \`task/2-personal-library\` →"
  echo "accounts-task2). Only the generic rubric above applies. Prefer asking the author to"
  echo "rename to the contributing convention (e.g. \`accounts-task2-personal-library\`)."
fi

echo
echo "## The diff"
echo '```diff'
head -c 60000 "$DIFF_FILE"
echo '```'

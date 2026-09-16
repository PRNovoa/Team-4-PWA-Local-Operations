---
title: Reviewing the cohort's PRs
eyebrow: For the instructor, running review and your own work at once
description: A git/gh workflow for triaging student pull requests in parallel with your own backend work, without stashing, blocking, or losing state.
permalink: /guides/reviewing-cohort-prs/
---

# Review ten PRs without stopping your own work

**Who this is for:** the instructor/maintainer running review across the cohort — not students.
[Contributing]({{ '/guides/contributing/' | relative_url }}) covers what a student does to open a
PR and what the automated bot checks; this page covers what *you* do with the PRs that result,
while your own backend debugging keeps running in parallel.

**The actual problem this solves.** With five teams each landing PRs, checking one out the naive
way (`git checkout <branch>` in your own working copy) forces a choice every time: stash your own
in-progress backend changes, or don't review yet. Neither is acceptable at cohort scale. The fix is
one extra worktree, set up once.

## Set up once, before the first PR lands

Two one-time steps. Do both before you need either.

1. **The API key the automated review bot needs.** `.github/workflows/pr-review.yml` calls the
   Anthropic API to post its comment; without a key it fails safe (no comment, no error, no
   block), but that means no automated first pass either. Set it once:
   ```bash
   gh secret set ANTHROPIC_API_KEY
   ```
   You'll be prompted to paste the key value — it's stored as an encrypted repo secret, never
   printed back, never visible in workflow logs.
2. **The review worktree**, covered next.

## One worktree, not a habit of switching branches

From your existing clone's root:

```bash
git worktree add ../ttod-review main
```

Your original clone stays your own workspace — your backend debugging branch, your half-finished
changes, untouched. The new `../ttod-review` directory (a sibling of your clone, not inside it) is
a second, independent checkout of the same repository you use *only* for checking out and running
student PRs. Checking out a PR there never touches your own uncommitted work, because they're
different directories with different working trees over the same `.git`. Tear it down when the
cohort's PR wave is over: `git worktree remove ../ttod-review`.

## The core loop

Run every command below from the `ttod-review` worktree, not your main checkout.

1. **See what's waiting.** `make review-queue` (already in the Makefile) lists open PRs, read-only
   — it never approves or merges on your behalf. Or `gh pr list` for the raw list.
2. **Read the automated comment first.** Every PR already has one bot comment scored against the
   hybrid rubric (generic §5 dimensions + that task's own acceptance criteria, matched from the
   branch name — see [Contributing → Automated review]({{ '/guides/contributing/#automated-review' | relative_url }})).
   `gh pr view <N> --comments` shows it without opening a browser. Treat it as a first pass: it
   tells you where to look, not what to conclude.
3. **Check it out to actually run it.**
   ```bash
   gh pr checkout <N>
   npm --prefix services/frontend run check && npm --prefix services/frontend run build
   ```
   The bot reads a diff; it does not run the app. If a task's acceptance criterion is behavioral
   ("clicking a node updates the aside"), you still need to see it happen once.
4. **Decide, then say so on GitHub, not just in your head.**
   - Looks right, bot flagged nothing you disagree with → `gh pr review <N> --approve`
   - Small, nameable issue → `gh pr review <N> --comment --body "..."` and let the student push a
     fix, rather than fixing it yourself
   - Wrong direction or missing the task's own acceptance criteria → `gh pr review <N> --request-changes --body "..."`
5. **Merge only what's actually ready.** `gh pr merge <N> --squash` — branch protection already
   requires the `typecheck-and-build` check and one approval, so a merge attempt fails loudly if
   either is missing; you're not relying on memory to enforce that.

## When the bot isn't enough

The automated comment is one pass at PR-open time and on each push — it doesn't re-read context
you have and it didn't. Two situations call for you to run a review yourself, deliberately:

- **A PR the bot under-covered** — its branch name didn't match the `<seam>-task<N>` convention,
  so it only got the generic rubric, not the task-specific one. Run `/code-review <N> --comment` in
  your own Claude Code session for a fresh pass with real task context attached, rather than
  reading the bot's generic-only comment as if it were the full picture.
- **A PR you're about to request changes on** — post your own comment referencing the specific
  acceptance line from that task's own [detail sheet]({{ '/teaching/tasks/' | relative_url }})
  (there is no in-app `ASSIGNMENT.md` — the detail sheet on this site is the canonical source, and
  links to its own GitHub brief at the bottom), not a restatement of the bot's.

## Running this alongside your own backend work

This is the actual point of the separate worktree: your backend debugging session in your main
clone never needs to know review is happening. Concretely:

- Keep your main clone on your own working branch, mid-debug, dirty working tree and all.
- Do all of the loop above from the `ttod-review` worktree, on a clean `main`-tracking checkout
  that only ever holds one student's branch at a time (`gh pr checkout` replaces it each time,
  cleanly).
- If a student's PR changes `services/frontend/src/types/domain.ts` (the shared contract) and your
  own backend work depends on that file, that's the one case worth a manual look before merging —
  a contract change ripples into every module, including whatever you're mid-debugging. Everything
  else is safely isolated by the worktree split.

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| No bot comment appears on a new PR | `ANTHROPIC_API_KEY` repo secret not set — see Set up once, above | `gh secret set ANTHROPIC_API_KEY` |
| Bot comment only shows the generic rubric | Branch name didn't match `<seam>-task<N>` | Ask the student to rename the branch, or just run `/code-review <N> --comment` yourself for that one |
| `gh pr checkout <N>` fails or leaves stray files | You ran it from your main clone instead of the review worktree | `cd` into the `ttod-review` worktree first — this is the one command in this whole guide that must run from the right directory |
| Merge blocked despite an approval | `typecheck-and-build` hasn't reported yet, or reports failing | `gh pr checks <N>` to see which; don't override with an admin merge unless you know exactly why it's failing |

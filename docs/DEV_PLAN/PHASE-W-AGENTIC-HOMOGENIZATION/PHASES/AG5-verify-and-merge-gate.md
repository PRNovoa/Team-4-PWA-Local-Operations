# AG5 — Verify, pedagogical merge note, and human merge gate

**Status:** BLOCKED on AG4 DONE  
**Depends on:** AG0–AG4 complete on `agentic/homogenize-landings` (or AG1’s name)

## Goal

Prove the homogenized tree works; file the pedagogical “doorway / room / merge”
note; open (or prepare) the PR; **stop before merge**. Merge is a named human act —
the classroom analogue of the second approval that lands a quote-accept diff.

## Deliverables

1. Verification transcript: `make check` (or validate + stats --check + full
   unittest), privacy watcher on `docs/public` if touched, import smoke for any
   Python under `agentic/report-steward/scripts/`.
2. Short pedagogical paragraph landed in `AGENTS.md` or
   `docs/public/teaching/…` per AG0 (orchestrator §6 classroom phrasing).
3. PR body checklist linking Phase W INDEX + cold-review docs.
4. Product-owner merge decision line in `PHASE-AG5-REPORT.md` (`MERGE_APPROVED` /
   `MERGE_DEFERRED` / `MERGE_REJECTED`) — agent never sets `MERGED` itself.
5. Optional `AG6_DEFERRED` or `AG6_FOLLOW_ON` flag if student IDE harness ships in a
   second PR after layout merge.

## Scope

| In | Out |
| --- | --- |
| Verify + docs note + PR preparation | `git merge` / `gh pr merge` by the agent |
| Recording the pedagogical isomorphism | Running `cli.py proposal accept` |

## Prompt (paste when executing)

```text
Execute AG5 only. Run full verification. Add the pedagogical merge note.
Prepare PR description from the orchestrator §5–§6. Do not merge. Do not
force-push. Stop at VERIFYING with MERGE_* decision left for the human.
Do not mark DONE; hand off for cold review. After cold review, only a named
human may record MERGE_APPROVED and perform the merge.
```

## Acceptance

- [ ] Full suite + strict validate + stats --check exit 0 on the branch.
- [ ] Privacy watcher exit 0 on the paths AG4 touched (if any public docs).
- [ ] Pedagogical note present and does **not** claim layout PRs call
      `proposal accept`.
- [ ] PR checklist includes: landings thin, bodies under `agentic/`, CI path
      preserved, no `ttod.yml` diff.
- [ ] `git diff main...HEAD -- ttod.yml` is empty.
- [ ] Cold-review doc filed; blocking findings closed.
- [ ] Report status is DONE only when human recorded merge decision; if merge
      deferred, status may be DONE for the *verification* work with
      `MERGE_DEFERRED` explicit.

## Pedagogical merge checklist (for the human)

Use this when teaching or when merging:

1. Open the PR — treat it like a proposal under review.
2. Read cold review — another agent/mind already audited Acceptance.
3. Confirm `ttod.yml` unchanged — this PR is layout governance, not corpus accept.
4. Merge only if landings are doorways and `agentic/` is the room.
5. Tell students: *same discipline as quote accept; different write surface.*

## Risks

- Merging with a non-empty `ttod.yml` diff smuggles corpus changes into a layout PR.
- Self-merging by an agent collapses the two-touchpoint lesson Phase V already paid for.

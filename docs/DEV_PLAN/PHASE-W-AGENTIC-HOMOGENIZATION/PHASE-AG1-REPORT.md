# PHASE-AG1-REPORT.md

**Status:** PARTIAL — target tree and branch name frozen; branch creation deferred to the human
**Runbook:** [`PHASES/AG1-branch-and-target-layout.md`](PHASES/AG1-branch-and-target-layout.md)
**Depends on:** AG0 DONE ([`PHASE-AG0-REPORT.md`](PHASE-AG0-REPORT.md)) — satisfied
**Cold review:** [`PHASE-AG1-COLD-REVIEW.md`](PHASE-AG1-COLD-REVIEW.md) — clean, honest PARTIAL confirmed, no amendment required

## Why deferred, not created

The instruction that opened this phase ("Go AG1") did not contain the runbook's own explicit
trigger phrase — "create the branch now" — so per AG1's prompt ("If — and only if — the human's
paste explicitly says…") this report freezes the plan and leaves creation as a deferred,
copy-pasteable command block rather than running `git switch -c`. This is the conservative
reading the runbook itself asks for, not a capability gap.

## 1. Base commit

```
git rev-parse HEAD
950dc03290432d1a411f344398b9017bb8309b3
```

Recorded on branch `main`, 2026-09-18, immediately before any branch would be cut.

## 2. Frozen branch name

`agentic/homogenize-landings` — confirmed distinct from `origin/agentic/gh-pack` (the only
other `agentic/*` ref in `git branch -a`), so no shared-history collision.

## 3. Frozen target tree (orchestrator §7, amended by W0)

```
ttod/
  AGENTS.md                          # unchanged — root contract; AG4 adds the discovery map
  CLAUDE.md                          # unchanged — thin redirect → AGENTS.md
  agentic/
    README.md                        # NEW (AG2) — map of packs + landings + IDE harness pointer
    report-steward/                  # UNCHANGED — CI depends on this exact path (F4)
    rules/
      ttod-editing.md                # NEW (AG2) — body moved from .cursor/rules/ttod-editing.mdc
    skills/
      public-docs-i18n/
        SKILL.md                     # NEW (AG2) — body moved from .cursor/skills/public-docs-i18n/
    agents/                          # RESERVED, NOT POPULATED — W0 §2: cascade-phase-executor and
                                      #   cascade-cold-reviewer stay studio-canonical at
                                      #   ~/src/.agents/agents/; nothing TTOD-scoped exists yet to
                                      #   put here. Directory may stay absent until a genuinely
                                      #   TTOD-only agent is authorized in a later cascade.
    ide-mcp/                         # AG6 only — MCP templates, llms/, verify script
  .cursor/
    rules/ttod-editing.mdc           # AG3: becomes a landing (frontmatter + redirect)
    skills/public-docs-i18n/SKILL.md # AG3: becomes a landing (frontmatter + redirect)
    mcp.json                         # AG6: project IDE MCP (Astro + Svelte)
  .claude/
    agents/cascade-phase-executor.md # UNCHANGED — already a correct landing per W0 §2
    agents/cascade-cold-reviewer.md  # UNCHANGED — already a correct landing per W0 §2
  services/mcp/                      # UNCHANGED, out of scope — application FastMCP, never nested
                                      #   under agentic/ (W0 discovery-map non-goal)
```

This satisfies AG1's Acceptance bullet on target-tree contents via the "AG0-approved
equivalent" clause: `agentic/agents/` is listed as reserved-but-empty rather than populated,
because W0 froze that neither cascade subagent is TTOD-scoped content to move there.

## 4. Deferred branch-creation commands (for the human to run)

```bash
git status                       # confirm clean before branching (see note below)
git rev-parse HEAD               # expect 950dc03290432d1a411f344398b9017bb8309b3, or the current tip
git switch -c agentic/homogenize-landings
```

Not run in this phase. No push, no file moves — those remain AG2 (bodies) and AG1-authorized
creation (branch itself), each gated on separate explicit authorization.

## Acceptance

- [x] Branch name recorded and ≠ `agentic/gh-pack`.
- [x] Base commit SHA recorded (`950dc03…`).
- [x] Target tree lists `agentic/rules`, `agentic/skills`, `agentic/agents` (recorded as
      reserved-empty, an AG0-approved equivalent) plus preserved `agentic/report-steward/`.
- [x] Branch does not exist locally; report status is PARTIAL with deferred creation and no
      accidental branch (`git branch -a` shows no new `agentic/homogenize-*` ref).
- [ ] `git status` clean aside from AG1 doc edits — **not fully clean**: the working tree still
      carries the Phase W planning-pack edits from AG0 and earlier this session (new DECISIONS
      file, AG0/AG0-COLD-REVIEW/AG0-REPORT, and prior link/command fixes to the cascade and AG5
      files), none of which are committed yet. This is pre-existing session state, not something
      AG1 introduced, and none of it is a code or `ttod.yml` change — flagged here rather than
      silently checked off, per this cascade's own honesty rule.

## Next step

AG2 remains BLOCKED until a human runs the branch-creation commands above (or explicitly defers
further). This report itself authorizes nothing beyond the freeze.

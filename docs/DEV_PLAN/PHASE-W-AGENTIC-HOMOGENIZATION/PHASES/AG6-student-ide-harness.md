# AG6 — Student IDE harness (MCP configs, llms index, existence probes)

**Status:** BLOCKED on AG4 DONE (may draft docs in parallel after AG0 freeze; no
commit of `.cursor/mcp.json` until AG3 landings policy is clear)  
**Depends on:** AG0 discovery-map freeze; AG5 may merge without AG6 only if product
owner explicitly defers AG6 (record `AG6_DEFERRED` in AG5 report)

## Goal

Give co-developer students a **project-level** IDE agent harness: committed MCP
client config (Astro docs + Svelte official), an indexed `llms.txt` tree agents can
read, a short “role of each piece” section (from
[`AGENTIC-HARNESS.md`](../AGENTIC-HARNESS.md)), and a **verification** script that
proves the config exists and (when network is allowed) that servers respond.
Keep **Docker / `services/mcp`** strictly application-level and out of this file set
except as a named sibling in the discovery map.

## Deliverables

1. `agentic/ide-mcp/README.md` — student setup; HTTP vs stdio; single-folder Cursor warning.
2. `agentic/ide-mcp/mcp.cursor.json` + committed landing `.cursor/mcp.json` (same content
   or generated copy — AG6 picks one mechanism and documents it).
3. Optional `agentic/ide-mcp/mcp.claude-code.json` / `examples/*.json` for Desktop etc.
4. `agentic/ide-mcp/llms/` — vendored Svelte prompts `llms.txt` (+ README); optional Astro
   index if a stable URL is frozen in AG0.
5. `agentic/ide-mcp/scripts/verify-ide-mcp.sh` (or Python) + a unittest or Makefile target
   that runs the **offline** subset in CI.
6. Decision row on **React MCP**: portable install accepted **or** deferred with reason
   (Smithery OneDrive sample is not acceptable as default).
7. Explicit non-install: no `@modelcontextprotocol/server|client` in frontend
   `package.json` unless a separate optional lab is authorized.

## Scope

| In | Out |
| --- | --- |
| Project-level IDE MCP for Astro + Svelte | Moving `services/mcp` into `agentic/` |
| llms.txt vendor + offline verify | Requiring cloud frontier API keys in git |
| Existence probes (config + optional live) | Replacing product Ollama with cloud LLM |
| Harness role section linked from `AGENTS.md` | Mandating Claude Desktop for all students |

## Prompt (paste when executing)

```text
Execute AG6 only per
docs/DEV_PLAN/PHASE-W-AGENTIC-HOMOGENIZATION/PHASES/AG6-student-ide-harness.md.
Read ../AGENTIC-HARNESS.md first. Commit project-level Astro+Svelte MCP config,
vendor svelte llms.txt, add verify script (offline CI + optional live).
Do not add @modelcontextprotocol/* to services/frontend unless a separate lab
is explicitly authorized. Do not treat Docker MCP as IDE MCP. React MCP: portable
npx or defer — never ship OneDrive absolute paths. Full suite + offline verify
green. Stop at VERIFYING. Do not mark DONE; hand off for cold review.
```

## Acceptance

- [ ] `.cursor/mcp.json` exists in git and lists `astro-docs` (or AG0 name) and `svelte`.
- [ ] Astro entry uses HTTP URL **or** documented `mcp-remote` stdio fallback — both
      documented; one marked default.
- [ ] Svelte entry is `npx -y @sveltejs/mcp` (or AG0-pinned version).
- [ ] `agentic/ide-mcp/llms/` contains Svelte prompts index; README tells agents when to
      use file vs MCP `get-documentation`.
- [ ] `verify-ide-mcp` offline mode exits 0 in CI; live mode documented for students.
- [ ] `AGENTS.md` discovery map links this harness and states Docker MCP ≠ IDE MCP.
- [ ] React MCP either verified portable or `DEFERRED` with decision id in report.
- [ ] `git grep -n '@modelcontextprotocol/server' services/frontend/package.json`
      returns 0 (unless lab authorized).
- [ ] Full existing suite still green.
- [ ] Negative: removing `.cursor/mcp.json` makes offline verify fail (proves the check
      is load-bearing).

## Risks

- npx-on-first-agent-call surprises air-gapped students — document Node/npm prerequisite.
- HTTP Astro MCP blocked on campus networks — document stdio fallback.
- Treating IDE MCP outages as product bugs — keep checklists separate.
- Promoting untrusted React MCP into the default cohort attack surface.

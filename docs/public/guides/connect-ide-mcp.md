---
title: Connect your IDE to MCP
eyebrow: Official servers only, zero-install, one click to trust
description: How to wire Cursor or Claude Code to this project's committed MCP servers, and how to prove — not assume — that it actually worked.
permalink: /guides/connect-ide-mcp/
lang: en
alt_lang_missing: true
---

# Config that parses is not a server that answers

Cloning this repo gets you a working `.cursor/mcp.json`. It does not get you a connected MCP
server — those are two different claims, and this project treats the gap between them as
something to prove, not assume. This page covers what's committed, why only certain servers
ever qualify, and three separate ways to confirm it's actually wired: an offline config check,
a live protocol handshake, and a walkthrough you run yourself from a throwaway checkout.

## What's committed, and why

| Server | Type | Command | Why it's here |
| --- | --- | --- | --- |
| `astro-docs` | HTTP | `https://mcp.docs.astro.build/mcp` | Astro's own official docs MCP |
| `svelte` | stdio | `npx -y @sveltejs/mcp` | Svelte's own official MCP (docs, autofixer) |
| `playwright` | stdio | `npx @playwright/mcp@latest` | Microsoft's own official browser-automation MCP |
| `filesystem` | stdio | `npx -y @modelcontextprotocol/server-filesystem .` | Official reference server, sandboxed to the repo root — never your home directory |

**Official-only, as a hard rule, not a preference.** A server ships in the committed default
only if it's published and maintained by the framework vendor itself, or by the official
reference-server project. Third-party or marketplace listings are never cohort-default, no
matter how convenient the install looks — that's an unaudited attack surface running on every
collaborator's machine, not a taste call. An automated check enforces this on every change: an
unlisted server key in the committed config fails outright, not just a code-review nitpick.

**React has no entry — settled, not deferred.** No framework vendor publishes an official React
MCP server. That's not a gap waiting to be filled with a third-party substitute; it's a
standing decision, revisited only if that changes. React context stays file/docs-based for now.

**GitHub's MCP is opt-in only, never the committed default.** Not only because it needs a
personal credential, but because a `github` entry in everyone's config would show
disconnected/red for every collaborator who hasn't set one up — failing the one bar this
project actually holds itself to: a fresh clone should show nothing red by default. The server
itself runs via its own official Docker image — this project already requires Docker for
`make up`, so opting in adds no new tooling. To opt in: copy the repo root's `.env.example` to
`.env`, set your own `GITHUB_PERSONAL_ACCESS_TOKEN` there, and merge the `github` block from
[`examples/github.json`](https://github.com/ruvebal/ttod/blob/main/agentic/ide-mcp/examples/github.json)
into your own `.cursor/mcp.json`. The config references `${env:GITHUB_PERSONAL_ACCESS_TOKEN}` —
never paste a token into a file this repo tracks.

## IDE MCP is not the product's MCP

Two unrelated things share the initials. `.cursor/mcp.json` configures **development-time**
tools your coding agent calls from inside the editor — the servers in the table above. The
running application has its **own**, separate MCP server for read-only corpus retrieval,
consumed by the product itself at runtime, not by your IDE. An outage in one says nothing about
the other; don't debug your editor because the app misbehaved, or the other way around.

## First time in the IDE: servers start disabled — that's expected

Opening this folder loads the config; it does not connect anything. Cursor treats
project-committed MCP config as untrusted by default — every server here shows **disabled**,
not connected, until you flip it on once in the IDE's own MCP settings panel. That's a one-time,
per-server trust step, the same category as a "do you trust this workspace" prompt, not a sign
that setup failed. Zero-install is still true — nothing to run beforehand — zero-click is not:
budget one click per server the first time you open this folder.

## Two ways to verify it's wired, before you trust your eyes

Two scripts, two different questions, both live under `agentic/ide-mcp/scripts/`:

1. **`verify-ide-mcp.py`** — does the config exist, parse, list the right servers, and stay on
   the official allowlist? Offline, fast, no network needed:
   ```bash
   python3 agentic/ide-mcp/scripts/verify-ide-mcp.py
   ```
2. **`simulate-student-check.py`** — does each server actually *speak MCP*? Sends a real
   protocol handshake to every committed server — network and a first-time package fetch
   required, a slow first run is normal, not a failure:
   ```bash
   python3 agentic/ide-mcp/scripts/simulate-student-check.py
   ```
   A passing run prints each server's real identity response — not a guess, an actual
   round-trip, the same distinction this project draws everywhere else between declaring
   something works and proving it.

Neither script can see inside your editor's own UI. For that, do the walkthrough below.

## Confirm it like a new collaborator would

Don't trust "it works on my machine" — your own editor may carry global MCP config, a warm
package cache, or an already-authenticated tool that a genuinely fresh clone would not have.
Run this from a throwaway checkout, not your regular one:

1. `git worktree add --detach /tmp/mcp-sim <branch-you're-testing>` — detached, not a second
   checkout by branch name, since your primary clone may already have that branch checked out.
2. Open that folder as a single-root editor window (a multi-root workspace can silently fail to
   load project MCP config — this is the one setup detail that breaks everything else here if
   skipped).
3. Enable each server in the MCP panel (the one-time trust step above), then confirm each shows
   connected.
4. Ask the agent one real, checkable question per server — something only a working tool call,
   not model memory, could answer correctly: fetch a specific, current documentation section
   and quote one exact sentence; take a live accessibility snapshot of a running page; read a
   file back from the sandboxed root. A fluent-sounding but unverifiable answer is a **fail**,
   not a pass — memory can fake a docs summary, only a real round-trip returns something you
   can check against the live source.
5. `git worktree remove /tmp/mcp-sim` when done — a one-off simulation, not a standing worktree
   to maintain.

## When the MCP connection itself is unreachable

`agentic/ide-mcp/llms/` carries a vendored, offline documentation index for moments the live
MCP server isn't reachable — a network policy, a blocked package registry, a first-run fetch
that failed. Prefer the live MCP call whenever it's available; it returns current,
vendor-served content, not a point-in-time snapshot. Fall back to the vendored file only when
the server genuinely can't be reached, and treat it as an index of what to ask for, not a
replacement for asking.

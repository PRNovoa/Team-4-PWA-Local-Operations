# Technical proposal — TTOD `tags[]` → `semantic_tags` · Tao of Creativity pedagogical axes

**Status:** PROPOSED (planning only — **does not** mutate `ttod.yml`, schemas, CLI, bridge, or CT `quotes.json`)  
**Date:** 2026-09-15  
**Author:** studio planning (crea-comm.net)  
**Decider required:** Rubén Vega Balbás (TTOD rights holder + CT course owner)  
**Does not authorize:** bulk migration, `proposal accept` of CT invents, schema bump on live corpus, or Pages publish  

**Cross-repo counterparts (read-only pointers):**

| Surface | Path |
| --- | --- |
| CT Tao monograph data | `~/projects/ruvebal/scholar/universidadeuropea/creativity-techniques-uem/docs/tao/data/quotes.json` |
| CT slideshow forge (semantic_tags law) | `…/creativity-techniques-pedagogy/forge/STUDENT-SLIDESHOW-FORGE.mdc` § golden rule 3 |
| CT Tao forge | `…/forge/TAO-OF-CREATIVITY-FORGE.mdc` + `TAO-OF-CREATIVITY/` |
| TTOD quote contract | [`../../AGENTS.md`](../../AGENTS.md) § Quote record · [`../../schema/quote.schema.json`](../../schema/quote.schema.json) |
| TTOD taxonomy | `ttod.yml` → `tag_taxonomy` |
| Bridge | `~/src/.cursor/skills/ttod-bridge/` |

---

## 1. Problem

Two studio quote surfaces already talk past each other:

| Axis | TTOD (`ttod.yml` v3.1) | Tao of Creativity (`quotes.json` v0.1) |
| --- | --- | --- |
| Controlled labels | flat `tags[]` ∈ `tag_taxonomy` | `semantic_tags` (themes · cidoc · getty_aat · dcterms · skos→`ct:…`) + `lexicum` |
| Pedagogy | `section` · `subsection` · `level` · `teaches` · `show_when` | thin `ttod.{section,level,tags}` stub only |
| Provenance | `origin` · `rights` · `related` / `relation_edges` · digests | invent lineage implied; no item-level rights/relations |

CT invents proposed into TTOD therefore **drop** the DH envelope on accept, and Tao records **cannot** round-trip TTOD’s teaching/provenance axes without inventing a parallel schema.

This proposal closes that gap in both directions under one studio convention.

---

## 2. Goals

1. **TTOD:** evolve quote records so the primary semantic surface is studio `semantic_tags`, with `tags[]` either derived or deprecated on a versioned schedule.  
2. **Tao of Creativity:** promote each invent to carry the same pedagogical + provenance axes TTOD already requires for canonical quotes.  
3. **Bridge:** one proposal payload shape that preserves both layers through `proposal create` → human review → `proposal accept`.  
4. **Firewall:** student decks / `/tao/` HTML still default to aphorism text + Chicago / Tao label — DH and vault IDs stay machine metadata (or switch-gated), never Ahmes product names in public HTML.

Non-goals for this document: implementing the cascade, accepting the staged CT invents, inventing a new TTOD `section` named `creativity` without a separate decision, or claiming Ahmes node identity for invents.

---

## 3. Target shared shape

### 3.1 `semantic_tags` (studio convention — canonical DH block)

Align with slideshow forge + Tao `quotes.json`:

```yaml
semantic_tags:
  themes: []          # short controlled phrases (snake or camel; see §4)
  cidoc: []           # e.g. crm:E33_Linguistic_Object, crm:E73_Information_Object
  getty_aat: []       # e.g. aphorisms, creativity
  dcterms: []         # e.g. dcterms:type=Text, dcterms:subject=…
  skos:               # optional but preferred when a fieldlex exists
    inScheme: ""      # URI of the scheme (TTOD or CT)
    exactMatch: []    # local URIs: ttod:… and/or ct:…
```

**Default CIDOC for every aphorism record** (TTOD and Tao), unless a later decision narrows it:

- `crm:E33_Linguistic_Object`
- `crm:E73_Information_Object`

**Default AAT-style labels** when form is known: `aphorisms`; add form facets (`haiku`, `koan`, …) as themes or AAT only after taxonomy decision (§4).

### 3.2 Pedagogical axes (already first-class on TTOD — add to Tao)

| Field | TTOD today | Tao target |
| --- | --- | --- |
| `section` | required | required (propose `wisdom` until a creativity section is decided) |
| `subsection` | optional | optional (map to chapter id or unit seam, e.g. `open-close`, `U1`) |
| `level` | required enum | required (`beginner` \| `intermediate` \| `advanced` \| `master`) |
| `teaches` | optional string | required for slide-eligible invents |
| `show_when` | optional string | optional; recommend for deck-linked invents |

On Tao JSON, nest under a first-class block (rename today’s thin stub):

```json
"pedagogy": {
  "section": "wisdom",
  "subsection": "open-close",
  "level": "beginner",
  "teaches": "Judgement under a brief is not a brick-test score.",
  "show_when": "After talent-myth discussion; before domain-knowledge beat."
}
```

Deprecate the current `ttod: { section, level, tags }` stub once `pedagogy` + `semantic_tags` + `provenance` land (one minor version bump of `quotes.json`).

### 3.3 Provenance axes (already first-class on TTOD — add to Tao)

```json
"provenance": {
  "origin": "studio",
  "rights": {
    "access": "public",
    "license": "CC-BY-NC-SA-4.0",
    "holder": "ruvebal@crea-comm.net",
    "permission_basis": "rights-holder-relicense-2026-08-18"
  },
  "related": [],
  "relation_edges": []
}
```

**Origin mapping for Tao invents**

| Invent source | `origin` |
| --- | --- |
| Human-authored / heavily rewritten | `human` or `studio` |
| Thessia / Ollama draft accepted after human edit | `blackbox` (+ validation block on TTOD accept) |
| Mixed human+model | `mixed` (TTOD enum already allows) |

**Relations:** Tao chapter co-quotes use `related: [<tao-id>]` locally; once accepted into TTOD, add `relation_edges` with typed links (`inspired_by`, `same_as_tao`, `translation_of`, … — exact relation vocabulary is a schema decision in the cascade, not free text).

Tao-local IDs (`C-U1-open-01`) stay course-stable. On TTOD accept, the **canonical** ID is the next free `{prefix}-{n}`; store a relation `same_as_tao` / `derived_from` pointing at the Tao id in proposal metadata so the bridge can round-trip.

---

## 4. Transforming TTOD `tags[]` → `semantic_tags`

### 4.1 Mapping rule (deterministic seed)

`tag_taxonomy` today is grouped (`technical` · `conceptual` · `pedagogical` · `source` · …). Propose:

| Source | Target |
| --- | --- |
| every `tags[]` string | `semantic_tags.themes[]` (1:1, preserve string) |
| taxonomy group name | optional `dcterms:subject=<group>` **or** theme prefix — pick one in freeze decision; prefer **not** dual-encoding |
| known form tags (`haiku`, `koan`, `poetry`, …) | themes **and** `getty_aat` when AAT-plausible (`aphorisms`) |
| source-group tags (`wisdom-chapter`, …) | do **not** put in themes long-term — migrate to `source_refs` / lesson fields (already v3) |
| pedagogical flags (`featured`, `beginner-friendly`) | keep as themes **or** move to `show_when` / collections — freeze in decision |

### 4.2 SKOS scheme for TTOD

Introduce a TTOD-local scheme URI (illustrative):

`https://crea-comm.net/lexfield/ttod#`

with `skos.exactMatch: ["ttod:<tag>"]` for each taxonomy member that survives as a concept.

**Creativity invents** additionally carry `ct:…` exactMatch from CT Lexicum (`lexfield-public/v1`). A quote may list both:

```yaml
skos:
  inScheme: "https://crea-comm.net/lexfield/ttod#"
  exactMatch: ["ttod:teaching", "ct:talentMyth"]
```

(`inScheme` may become an array in a later schema revision if dual-scheme proves awkward; v1 of this proposal keeps one primary scheme + multi-scheme URIs in `exactMatch`.)

### 4.3 Compatibility window

Recommend **schema_version `3.2.0`** (illustrative — exact bump frozen in cascade):

| Phase | Rule |
| --- | --- |
| Dual-write | Writers must set `semantic_tags`; validators require `tags[]` ⊆ themes projection |
| Derived `tags[]` | `tags = semantic_tags.themes ∩ tag_taxonomy.flat` (unknown themes → error or proposal to extend taxonomy) |
| Deprecation | After one release + consumer update (Web Atelier, DevIAC ingest, bridge), `tags[]` becomes optional derived export only |

**Hard rule:** never invent taxonomy members by silent accept. Extend `tag_taxonomy` first (same as today’s AGENTS.md rule), then themes.

### 4.4 What stays out of `semantic_tags`

- Ahmes coat / node / page — lesson switch-gated comments only (publication firewall).  
- `content_digest`, WPL ids, evidence snapshot digests — remain TTOD v3 axes, not themes.  
- Student-facing slide render — still does not print CIDOC/AAT chips unless a teaching UI opts in (Tao `/tao/` may show chips; TTOD Oracle can later).

---

## 5. Tao of Creativity — concrete field upgrade

### 5.1 Per-quote target (after upgrade)

```json
{
  "id": "C-U1-open-01",
  "form": "Yoda",
  "text": "…",
  "slide_eligible": true,
  "pedagogy": {
    "section": "wisdom",
    "subsection": "open-close",
    "level": "beginner",
    "teaches": "…",
    "show_when": "…"
  },
  "provenance": {
    "origin": "studio",
    "rights": {
      "access": "public",
      "license": "CC-BY-NC-SA-4.0",
      "holder": "ruvebal@crea-comm.net",
      "permission_basis": "course-monograph-cc-by-nc-sa-4.0"
    },
    "related": ["C-U1-open-02"],
    "relation_edges": []
  },
  "lexicum": { "concepts": [], "primary": "ct:…" },
  "field_discussions": [],
  "creativity_areas": [],
  "semantic_tags": {
    "themes": [],
    "cidoc": ["crm:E33_Linguistic_Object", "crm:E73_Information_Object"],
    "getty_aat": ["aphorisms"],
    "dcterms": ["dcterms:type=Text"],
    "skos": {
      "inScheme": "https://crea-comm.net/lexfield/creativity_techniques#",
      "exactMatch": ["ct:talentMyth"]
    }
  }
}
```

### 5.2 Migration of current stub

| Current | Action |
| --- | --- |
| `ttod.section` / `ttod.level` | → `pedagogy.section` / `pedagogy.level` |
| `ttod.tags` | → seed `semantic_tags.themes` **and** candidate TTOD `tags[]` on proposal |
| missing `teaches` / `show_when` | backfill in a human pass before TTOD accept |
| missing `provenance` | default `origin: studio`, rights CC BY-NC-SA 4.0 (match course LICENSE), empty relations |

### 5.3 CT forge / bridge consequences

- `TAO-OF-CREATIVITY-FORGE.mdc` checklist: require `pedagogy` + `provenance` on accept into `quotes.json`.  
- `ttod-bridge` / `cli.py proposal create`: accept optional `semantic_tags` + map `pedagogy.*` into candidate content; refuse accept if `blackbox` without validation path.  
- Slideshow invents: keep slide-level `semantic_tags`; href stays `/tao/#…`; do not embed TTOD canonical ids on slides until accept is real.

---

## 6. Proposed work packages (future cascade — not opened here)

Suggested letter **W** (Semantic / Wisdom alignment) only if product-owner freezes this proposal. Until then these are **planning packages**, not runbooks.

| Package | Owner surface | Deliverable | Gate |
| --- | --- | --- | --- |
| **W0** | TTOD | Freeze decision doc in `DECISIONS/` (dual-write vs replace; scheme URI; relation types; creativity section yes/no) | Human sign-off |
| **W1** | TTOD | `quote.schema.json` + root schema: add `semantic_tags`; fixtures; validator projection `tags ↔ themes` | `make check` green on disposable corpus |
| **W2** | TTOD | Migrate live `ttod.yml`: every quote gets `semantic_tags` seeded from `tags[]` + default CIDOC/AAT | digest policy + strict validate |
| **W3** | TTOD | Bridge + proposal schema: carry `semantic_tags`; export JSON includes block | bridge round-trip test |
| **W4** | CT | Bump `quotes.json`: `pedagogy` + `provenance`; migrate stubs; UI chips unchanged | `verify:publication` |
| **W5** | CT + TTOD | Re-stage CT invent proposals with full payload; human accept into wisdom (or new section) | proposals only until accept |
| **W6** | Docs | Update `AGENTS.md`, ttod-bridge skill, slideshow/Tao forges | no canonical mutation |

**Cold-review rule:** no package marked DONE without an independent VERIFYING report (same discipline as Phase Q/R).

---

## 7. Risks

| Risk | Mitigation |
| --- | --- |
| Taxonomy explosion via free themes | Themes that are not in `tag_taxonomy` (or an explicit `theme_allowlist`) fail validate |
| Dual-scheme SKOS confusion (`ttod:` vs `ct:`) | Document precedence: TTOD canonical tags for TTOD search; `ct:` for course Lexicum / decks |
| Digest churn on mass annotate | W2 must recompute C14N digests in one atomic migrate (Q2E/Q6 pattern) |
| Invents mistaken for Ahmes cites | Keep `quote_origin: tao_invented` on decks; never set evaluator_safe / vault ids on invents |
| Premature creativity `section` | Default proposals to `wisdom` until W0 decides a section + id prefix |
| Consumer breakage (Jekyll `site.data.ttod`) | Dual-write window; announce derived `tags[]` |

---

## 8. Decision checklist (W0)

Product owner should answer before any schema PR:

1. Dual-write `tags[]` + `semantic_tags`, or replace `tags[]` immediately?  
2. Canonical theme spelling: keep existing taxonomy strings as-is?  
3. New TTOD section `creativity` (new id prefix) vs keep invents under `wisdom`?  
4. Relation type for Tao↔TTOD link (`same_as_tao` vs `derived_from` vs `related` only)?  
5. May `/tao/` publish rights holder + license chips, or provenance stays JSON-only?  
6. Is SKOS `inScheme` single URI or array in v1?

---

## 9. Explicit non-authorization

Existence of this file:

- does **not** reopen Phase Q, S, R, T, U, or V;  
- does **not** authorize edits to live `ttod.yml` or acceptance of CT invent proposals;  
- does **not** claim Tao invents are Ahmes-compatible vault records — only that they share the **studio `semantic_tags` envelope**;  
- does **not** alter NC content license defaults ([`DECISIONS/Q0-2026-08-18-RIGHTS-LICENSE-NC.md`](DECISIONS/Q0-2026-08-18-RIGHTS-LICENSE-NC.md)).

---

## 10. Resume

Safe next action: **W0 freeze** (answers in §8) → open a numbered cascade under `docs/DEV_PLAN/` only after that decision file exists. Until then, CT may continue enriching `quotes.json` `semantic_tags` / Lexicum locally; TTOD proposals for invents should keep flat `tags[]` that already exist in `tag_taxonomy`, and treat full `semantic_tags` as advisory metadata attached outside the accept path.

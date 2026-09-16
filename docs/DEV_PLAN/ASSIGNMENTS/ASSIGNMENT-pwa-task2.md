# Assignment — Team 4, Task 2: One observable offline boundary — content that keeps working without a connection

**Seam:** pwa · **Team:** 4 · **Task:** 2 of ~10
**Area(s):** PWA/Offline · **Verb served:** keep

## 1. Curriculum map

This task continues [Unit 4 — Progressive Web Apps & Offline Capabilities](https://ruvebal.github.io/web-atelier-udit/lessons/en/feii/unit-4-pwa-offline/) directly — the same unit Task 1 draws on — and the caching mechanics are the browser's own [Cache API](https://developer.mozilla.org/en-US/docs/Web/API/Cache) (MDN). Verifying the behavior under constrained network conditions reuses [Unit 5 — Testing strategy](https://ruvebal.github.io/web-atelier-udit/lessons/en/feii/unit-5-testing-strategy/).

## 2. Worked example, from the real TTOD app

**This task depends on Task 1.** It assumes `services/frontend/public/sw.js` and its registration in the app shell already exist — built by Task 1, not present in the repo before it. Do not start this task until Task 1's stub is merged.

Once Task 1 lands, the service worker defines a versioned `CACHE_NAME` (e.g. `'ttod-pwa-stub-v1'`) and caches one proof asset (e.g. `/visual-system/tokens.css`) Cache-First. That means: load the page, disconnect from the network, reload — the proof asset still serves from Cache Storage. That proves the *worker* is offline-capable, but only for that one static asset.

Task 1 also wires a `#ttod-network-boundary` banner (via `window` `online`/`offline` events) that reflects browser-level connectivity in a `data-state` attribute. That proves the *browser* knows it's offline — it does not yet prove *content* is being served offline. Your job here is to extend that proof to a piece of actual user-facing content.

## 3. What "done" looks like

`docs/public/teaching/tasks.md` does not currently contain specific prose for this exact board item. Therefore, the following definition of done is grounded directly in the module's `ASSIGNMENT.md` and the starter inventory.

**Visible result:**
When the browser is in an offline state (verified by the `#ttod-network-boundary` banner showing `data-state='offline'`), a specific piece of user-facing content (e.g., a text block, a component, or a specific route's HTML) remains fully readable and functional. It is not a blank screen, and it is not a network error message.

**What it includes:**
1.  **Selection of a Content Target:** You must identify one specific piece of content (e.g., the "Wisdom" text in `src/content/wisdom.ts` if rendered, or a static HTML section) that is critical to the user experience.
2.  **Cache Extension:** You must modify `services/frontend/public/sw.js` to include this content's required assets (HTML, CSS, JS, or data) in the `PROOF_ASSET` list or a new cache array. You must ensure the `install` event pre-caches these assets.
3.  **Fetch Strategy:** You must ensure the `fetch` event handler serves these assets from the cache when the network is unavailable.
4.  **Verification:** You must demonstrate that this content loads successfully while the browser is offline.

**What has to be done:**
1.  Read `services/frontend/public/sw.js` to understand the current `install` and `fetch` logic.
2.  Identify the specific assets required for your chosen content target.
3.  Update the `install` event in `sw.js` to add these assets to the cache.
4.  Update the `fetch` event in `sw.js` to serve these assets from the cache (Cache-First or Network-First, as appropriate for static content).
5.  Test the offline behavior using browser DevTools (Network tab -> Offline) and verify the content is visible.
6.  Document your choice of content and why it is a good "observable boundary" in your commit message or a brief note in the PR.

## 4. Success criteria (functional)

This task closes the following Acceptance Criteria from the parent module `ASSIGNMENT.md`:

1.  **Cache-First static / Network-First API.** The service worker applies Cache-First to the static asset set the app needs to render offline. A repeat load of a static asset is served from Cache Storage.
    *   *Note: This task focuses on the "static asset set" part. The "Network-First API" part is covered in other tasks.*

## 5. Quality criteria (the part that's new)

*   **Code Organization:** The changes to `sw.js` must be clean and maintainable. Avoid hardcoding asset paths in a way that makes future updates difficult. Consider using a constant array for the cache list.
*   **AI-use/process documentation discipline:** If you use AI to help generate the service worker code, you must document the specific prompts used and the reasoning behind the final code structure in your PR description. You must be able to explain every line of the `sw.js` changes in your own words during the oral defense.
*   **Test shape per [Unit 5 — Testing strategy](https://ruvebal.github.io/web-atelier-udit/lessons/en/feii/unit-5-testing-strategy/)'s own Trophy-not-Pyramid doctrine:** You must write a test that verifies the offline behavior. This could be a manual test script or an automated test using a tool like Playwright or Cypress that simulates an offline state and checks for the presence of the content. The test must be specific to the content you chose, not a generic "page loads" test.
*   **Accessibility:** The content you choose must be accessible. It must be keyboard-operable, have one accessible name or label, not carry meaning by color alone, and respect reduced-motion preferences. This is part of the global Definition of Done for all tasks.
*   **Defensible oral-defense answer:** You must be able to answer the following questions:
    *   Why did you choose this specific piece of content as the "observable boundary"?
    *   How does the service worker know which assets to cache?
    *   What happens if the cache is corrupted or outdated?
    *   How does this task relate to the broader PWA strategy of the app?

## Closing

> "First make it work. The path begins when the code runs, not when it is admired."
> — TTOD `wis-007`, *wisdom*

This task is deliberately narrow: one content target, genuinely proven offline, is worth more than a claimed general capability. The systematic extension of caching to the whole asset set is Task 3's job — this task's only job is making the first stone cross the river.
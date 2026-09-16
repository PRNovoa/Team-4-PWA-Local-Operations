# Assignment — Team 4, Task 1: Service worker registration and an installable manifest

**Seam:** pwa · **Team:** 4 · **Task:** 1 of ~10
**Area(s):** PWA/Offline · **Verb served:** keep

## 1. Curriculum map

This task exercises [Unit 4 — Progressive Web Apps & Offline Capabilities](https://ruvebal.github.io/web-atelier-udit/lessons/en/feii/unit-4-pwa-offline/) directly — service-worker lifecycle, caching strategy, and install quality are that unit's own subject, not an inference from an adjacent one. Read it before starting this task. Cache-storage mechanics specifically are the browser's own [Cache API](https://developer.mozilla.org/en-US/docs/Web/API/Cache) (MDN) — the `install`/`activate`/`fetch` lifecycle below is built on it. Lifecycle testing later reuses [Unit 5 — Testing strategy](https://ruvebal.github.io/web-atelier-udit/lessons/en/feii/unit-5-testing-strategy/).

## 2. Worked example, from the real TTOD app

**There is no service worker in the repo yet.** `services/frontend/public/sw.js` does not exist, and nothing in `services/frontend/src` calls `navigator.serviceWorker.register(...)`. This task is where that baseline gets created — do not go looking for an existing stub to "verify."

Build, from scratch:

1.  `services/frontend/public/sw.js` — a minimal service worker with `install`, `activate`, and `fetch` handlers. Use a versioned `CACHE_NAME` (e.g. `'ttod-pwa-stub-v1'`) and cache at least one real static asset (e.g. `/visual-system/tokens.css`) as the proof target. Cache-First for that asset in `fetch`; clean up any cache key that doesn't match the current `CACHE_NAME` during `activate` (see the Cache API link above for `caches.open`, `caches.keys`, `caches.delete`).
2.  A registration call — `navigator.serviceWorker.register('/sw.js')` — added to `services/frontend/src/layouts/Page.astro` (or wherever the app shell renders), plus a small `#ttod-network-boundary` banner driven by `window` `online`/`offline` events so the online/offline state is visible, not just present in devtools.
3.  A minimal installable manifest (`site.webmanifest` or `manifest.json`) linked from the page `<head>`. Icon-size completeness and the Lighthouse installability check are **Task 5's** deliverable ("Install-quality checks") — this task only needs a manifest that satisfies the browser's install-eligibility minimum, not full icon coverage.

*Out of scope for this task: manifest icon completeness and the Lighthouse audit (Task 5). This task's scope is standing up the worker and manifest for the first time and getting the lifecycle right — install/activate/fetch, client claiming, cache-name versioning.*

## 3. What "done" looks like

**Visible result:** A service worker registers on page load, caches the proof asset, and the app still serves that asset from cache when offline. You can demonstrate the lifecycle by changing `CACHE_NAME`, reloading, and showing the old cache gone from `caches.keys()`.

**What it includes:** Building the lifecycle is itself a learning outcome. The defense will ask you to walk through what happens when the cache version changes. You must be able to articulate why the cache name is versioned and how old caches get cleaned up.

**What has to be done:**
1.  **Create the service worker:** write `services/frontend/public/sw.js` with `install` (pre-cache the proof asset), `activate` (delete any cache key not equal to the current `CACHE_NAME`), and `fetch` (serve the proof asset Cache-First).
2.  **Register it:** wire `navigator.serviceWorker.register('/sw.js')` into the app shell and add the `#ttod-network-boundary` banner reflecting `window` online/offline events.
3.  **Prove versioning works:** bump `CACHE_NAME` (e.g. to `'ttod-pwa-stub-v2'`), reload, and confirm the old cache key is deleted during `activate`, not silently accumulated.

## 4. Success criteria (functional)

1.  **Service-worker lifecycle:** You can explain `install`, `activate`, and `fetch`, and show where your worker claims clients and updates its cache name.
2.  **Cache cleanup:** After a `CACHE_NAME` change and reload, the previous cache no longer appears in `caches.keys()` — old caches are deleted during `activate`, not silently accumulated.

## 5. Quality criteria (the part that's new)

*   **Code Organization:** The service worker logic in `services/frontend/public/sw.js` must remain modular. The cache cleanup logic in the `activate` event handler should be explicit and commented to show the intent of removing old caches.
*   **AI-use/process documentation:** Document any changes made to the manifest or service worker in your commit messages or a brief note in your PR description, explaining *why* the cache name was changed and *how* you verified the cleanup.
*   **Test shape:** Per R7's Trophy-not-Pyramid doctrine, focus on an integration test that registers the worker, forces a `CACHE_NAME` change, and asserts the old cache key is gone from `caches.keys()` after `activate`. Unit tests for the individual event handlers are less valuable than verifying this end-to-end lifecycle behavior.
*   **Accessibility:** The app must remain keyboard-operable, have one accessible name or label, no meaning carried by color alone, and respect reduced-motion preferences. This is inherited from the global Definition of Done and is not unique to this task.
*   **Oral defense:** Be prepared to explain the difference between `install`, `activate`, and `fetch` events. Explain why the cache name is changed and how the `activate` event ensures old caches are removed.

## Closing

> "The river updates the stones; it does not shatter them."
> — TTOD `wis-009`, *wisdom*

This quote connects to the task's requirement to update the cache name and clean up old caches without breaking the existing functionality. The service worker's lifecycle should update the cache (the river) without destroying the app's ability to function (the stones).

## Finding: Real, uncounted module scope

The module's own `ASSIGNMENT.md` includes a full, numbered, assessed Acceptance criterion for **CI/CD design** (Acceptance criterion 4): "A GitHub Actions workflow on the student branch gates lint, typecheck, unit, component, and E2E tests with a wall-clock budget under five minutes (Unit 5's own budget, reused verbatim). The workflow has **no deploy job** and references **no secret**." This is a separate learning outcome and is not covered by any board row or tasks.md prose for Team 4. It should be addressed in a separate task or as part of the broader CI/CD setup, not absorbed into this task.
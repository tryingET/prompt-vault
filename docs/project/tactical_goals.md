---
summary: "Tactical goals for the active strategic goal: keep Prompt Vault the canonical governed prompt-authoring substrate."
read_when:
  - "When turning the active strategic goal into medium-sized repo-local waves"
  - "When deciding which repo-local direction slice should be active now"
---

# Tactical Goals

Active strategic goal: **SG1 — Keep Prompt Vault the canonical governed prompt-authoring substrate**

## Recently completed tactical goal

### TG1 — Converge repo direction + handoff surfaces on current schema-v9 truth
- **Why it mattered:** direction docs were still carrying pre-convergence assumptions and the removed `docs/dev/status.md` mirror path had to stop acting like a live authority surface.
- **Outcome reached:** vision/strategy/handoff docs now point to `README.md`, deterministic validation, and current owner-boundary notes rather than stale mirrors.
- **Completion signal:** a cold-start operator can read the main direction docs without being told to rely on a removed status mirror.

## Active tactical goal

### TG4 — Improve aggregate-first evidence surfaces for governed router semantics
- **Why this is active now:** it is the clearest bounded repo-local follow-through still named by the handoff after the direction refresh, especially for multi-valued router semantics such as `selection_principles`.
- **Outcome:** analytics/quality surfaces better explain coverage and quality for governed router semantics without leaking private outputs.
- **Current status:** materially complete for the current wave; `pv quality rollup selection_principles`, focused privacy tests, and the docs/handoff refresh are now in place.
- **Done when:** operators can inspect those semantics through aggregate-only reporting, docs explain the surface clearly, and the validation suite protects the privacy boundary.

## Next tactical goals

### TG2 — Keep ontology/contracts clean and prompt bodies out of the wrong layers
- **Outcome:** ontology files stay contract-only, seeded prompt bodies stay canonical DB content, and verification keeps that split explicit.
- **Done when:** docs/tests/handoffs consistently reinforce the DB-vs-ontology boundary and no stale guidance suggests otherwise.

### TG3 — Expand the reusable procedure layer for recurring governance-shaped work
- **Outcome:** Prompt Vault contains reusable procedures for repeatable cross-repo review/fan-out and adjacent authoring/governance workflows.
- **Done when:** high-value recurring operator patterns exist as tested, discoverable templates instead of only living in session memory.

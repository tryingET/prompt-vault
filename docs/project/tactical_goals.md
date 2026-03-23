---
summary: "Tactical goals for the active strategic goal: keep Prompt Vault the canonical governed prompt-authoring substrate."
read_when:
  - "When turning the active strategic goal into medium-sized repo-local waves"
  - "When deciding which repo-local direction slice should be active now"
---

# Tactical Goals

Active strategic goal: **SG1 — Keep Prompt Vault the canonical governed prompt-authoring substrate**

## Recently completed tactical goals

### TG1 — Converge repo direction + handoff surfaces on current schema-v9 truth
- **Why it mattered:** direction docs were still carrying pre-convergence assumptions and the removed `docs/dev/status.md` mirror path had to stop acting like a live authority surface.
- **Outcome reached:** vision/strategy/handoff docs now point to `README.md`, deterministic validation, and current owner-boundary notes rather than stale mirrors.
- **Completion signal:** a cold-start operator can read the main direction docs without being told to rely on a removed status mirror.

### TG4 — Improve aggregate-first evidence surfaces for governed router semantics
- **Why it mattered:** operators needed aggregate-only reporting for multi-valued governed router semantics such as `selection_principles` without widening private-output exposure.
- **Outcome reached:** `pv quality rollup selection_principles`, focused privacy tests, and the docs/handoff refresh are now in place.
- **Completion signal:** operators can inspect governed router semantics through aggregate-only reporting and the validation suite protects the privacy boundary.

### TG2 — Keep ontology/contracts clean and prompt bodies out of the wrong layers
- **Why it mattered:** with the router-semantic reporting wave complete, the clearest repo-local follow-through was preventing drift back into ontology-carried prompt bodies or fuzzy boundary docs.
- **Outcome reached:** ontology verification now rejects prompt-body fields in seed metadata, fails if `ontology/index.md` stops stating the DB-only authoring boundary explicitly, and the docs/handoff/validation story reinforces that split.
- **Completion signal:** deterministic checks fail closed on DB-vs-ontology boundary regressions and operators are not sent back toward ontology-carried prompt content.

## Active tactical goal

### TG3 — Expand the reusable procedure layer for recurring governance-shaped work
- **Why this is active now:** recent Prompt Vault work repeatedly needed concern-first review/fan-out plus repo-native owner-boundary-note authoring patterns, and those workflows should live as tested templates instead of only in session memory.
- **Outcome:** Prompt Vault contains reusable procedures for repeatable cross-repo review/fan-out and adjacent authoring/governance workflows.
- **Current status:** the first TG3 slice is now complete; the vault now contains `concern-first-review-fanout` and `owner-repo-boundary-note` as tested workflow templates for adjacent governance-shaped work.
- **Done when:** high-value recurring operator patterns exist as tested, discoverable templates instead of only living in session memory.

## Next tactical decision

Use AK + current docs to decide whether TG3 needs another bounded procedure-layer follow-through or whether SG1 is materially complete and SG2 should be promoted next.
Do not infer the answer from stale handoff text alone.

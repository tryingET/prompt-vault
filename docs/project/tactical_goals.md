---
summary: "Tactical goals for the active SG2 wave after the first company-visibility evidence slice: keep completed evidence work closed and define bounded downstream handoff contracts for workstation posture machine snapshots."
read_when:
  - "When turning the active strategic goal into medium-sized repo-local waves"
  - "When deciding which repo-local direction slice should be active now"
---

# Tactical Goals

Active strategic goal: **SG2 — Deepen privacy-safe evidence and downstream usability without collapsing boundaries**

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

### TG3 — Expand the reusable procedure layer for recurring governance-shaped work
- **Why it mattered:** recent Prompt Vault work repeatedly needed concern-first review/fan-out plus repo-native owner-boundary-note authoring patterns, and those workflows should live as tested templates instead of only in session memory.
- **Outcome reached:** Prompt Vault now contains `concern-first-review-fanout` and `owner-repo-boundary-note` as tested workflow templates for adjacent governance-shaped work.
- **Completion signal:** high-value recurring operator patterns exist as tested, discoverable templates instead of only living in session memory.

### TG5 — Expand aggregate-first evidence surfaces across governed company visibility
- **Why it mattered:** downstream operators needed a privacy-safe view of how quality/evidence distribute across the governed multi-company visibility boundary that determines who can consume a prompt safely.
- **Outcome reached:** `pv quality rollup visibility_companies` is live with focused regression coverage and aligned docs/handoff updates.
- **Completion signal:** operators can inspect aggregate quality/evidence by `visibility_companies` without exposing private output text or inventing ad-hoc company buckets.

## Active tactical goal

### TG6 — Define bounded downstream handoff contracts for workstation posture machine snapshots
- **Why this is active now:** downstream runtime-aware consumers now have an infra-owned workstation posture machine snapshot to consume, but Prompt Vault still needs one repo-native statement describing what prompt/provenance facts may travel with that machine packet without turning it into prompt canon or private observability.
- **Outcome:** cold-start operators can combine workstation machine-state gating with Prompt Vault prompt provenance truthfully: machine snapshots remain infra-owned runtime facts, Prompt Vault remains prompt/execution authority, and downstream repos carry only the minimum bounded handoff packet they actually need.
- **Current status:** the first TG6 slice is now complete; the repo-native handoff note `docs/dev/workstation-posture-machine-snapshot-handoff.md` plus focused validation define the Prompt Vault side of this boundary.
- **Done when:** downstream runtime-aware consumers can carry bounded Prompt Vault provenance alongside workstation posture snapshots without copying prompt bodies, governance canon, or private outputs into machine-facing packets.

## Next tactical decision

Use AK + current docs to decide whether another bounded downstream-usability/contract slice is ready or whether no new repo-local task is currently ready.
Do **not** reopen task `#1717` unless the workstation posture snapshot contract or the bounded Prompt Vault handoff actually changes.

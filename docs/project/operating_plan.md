---
summary: "Operating plan and completion record for the first TG3 procedure-layer wave after ontology-boundary hardening completed."
read_when:
  - "When reviewing the active repo-local wave after TG2 completed"
  - "When checking which AK task covered the owner-repo boundary-note procedure slice"
---

# Operating Plan

Active strategic goal: **SG1 — Keep Prompt Vault the canonical governed prompt-authoring substrate**

Active tactical goal: **TG3 — Expand the reusable procedure layer for recurring governance-shaped work**

## Status

This operating wave is now materially complete:
- Prompt Vault now contains the active workflow template `owner-repo-boundary-note`
- focused bats coverage protects the template metadata and key anti-drift contract phrases
- README + tactical-goals + handoff docs now describe the promoted TG3 procedure-layer reality truthfully

## Scope of this operating wave

This wave stays bounded:
- promote TG3 after the completed ontology-boundary hardening wave
- capture repo-native owner-boundary-note authoring as a reusable Prompt Vault procedure
- add focused validation so the procedure remains discoverable and authority-preserving
- refresh repo direction/handoff surfaces so operators start from the new TG3 reality instead of the completed TG2 wave
- avoid reopening settled ontology/company-visibility/runtime-boundary decisions or widening private-output exposure

## Completed operating slice in this wave

### OP1 — Add an owner-repo boundary-note procedure template for authority-preserving follow-through
- **AK task:** `#265`
- **Why now:** recent Prompt Vault work repeatedly needed repo-native boundary notes that distinguish canonical ownership, bounded reads, projection-only surfaces, and warning posture; leaving that structure in session memory would slow future boundary work and invite drift.
- **Deliverable:** add the active template `owner-repo-boundary-note`, add focused bats coverage for its metadata and anti-cutover phrases, and refresh repo docs/handoff to show TG3 as the current tactical reality.
- **Completion evidence:** `./scripts/pv show template owner-repo-boundary-note`, `tests/pv-owner-repo-boundary-note-template.bats`, and the updated README/tactical/operating/handoff docs all point to the same procedure-layer truth.

## Previously completed operating waves

### Ontology-boundary hardening
- **AK task:** `#264`
- **Status:** complete
- **Completion evidence:** `pv-verify-ontology-contract` now rejects prompt-body leakage in ontology-shaped surfaces, focused tests cover the regressions, and repo docs/handoff keep prompt bodies DB-only.

### Router-semantic aggregate reporting + privacy hardening
- **AK tasks:** `#247`, `#248`, `#246`
- **Status:** complete
- **Completion evidence:** `pv quality rollup selection_principles` is live, router-only multi-valued bucketing is enforced, focused privacy tests are in place, and repo docs/handoff were refreshed.

### Shared runtime registry / execution-observability boundary clarification
- **AK task:** `#245`
- **Status:** complete
- **Completion evidence:** Prompt Vault now has a repo-native boundary note clarifying that shared runtime registry discovery remains process-local, `pi-vault-client` owns local receipt/telemetry bridges, and Prompt Vault exports only schema-governed execution/feedback facts plus privacy-safe aggregate observability.

## Next decision after this wave

Use AK + current docs to decide whether TG3 needs another bounded procedure-layer follow-through or whether SG1 is materially complete and SG2 should be promoted next.
Do not infer a synthetic next task from this file alone if AK does not currently show one.

## Validation expectation for this wave

At minimum, re-run:
```bash
./scripts/db-change-preflight.sh --stage db-dev
./scripts/pv show template owner-repo-boundary-note
./scripts/pv-bats tests/pv-owner-repo-boundary-note-template.bats
./scripts/pv-verify-ontology-contract
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future procedure-layer drift in the same slice.

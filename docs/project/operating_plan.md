---
summary: "Operating plan and completion record for the ontology-boundary hardening wave after the router-semantic reporting slice."
read_when:
  - "When reviewing the active repo-local wave after TG4 completed"
  - "When checking which AK task covered the ontology-boundary hardening slice"
---

# Operating Plan

Active strategic goal: **SG1 — Keep Prompt Vault the canonical governed prompt-authoring substrate**

Active tactical goal: **TG2 — Keep ontology/contracts clean and prompt bodies out of the wrong layers**

## Status

This operating wave is now materially complete:
- `pv-verify-ontology-contract` now rejects prompt-body keys in seed-contract metadata
- the verifier now fails if `ontology/index.md` stops stating that prompt bodies are not part of ontology
- focused contract tests now cover both failure modes
- README + handoff docs now describe the active boundary-hardening reality truthfully

## Scope of this operating wave

This wave stays bounded:
- harden deterministic verification around the DB-vs-ontology authoring boundary
- keep ontology files contract-only and prompt bodies canonical in the DB
- refresh direction/handoff docs so operators do not resume from the completed TG4 wave
- avoid reopening schema-v9 ontology/company-visibility decisions or widening private-output exposure

## Completed operating slice in this wave

### OP1 — Harden ontology verification so prompt bodies stay DB-only
- **AK task:** `#264`
- **Why now:** TG4 is materially complete, and the next local risk is drift back into ontology-carried prompt content or softened boundary docs.
- **Deliverable:** deterministic verification now rejects prompt-body leakage in contract fixtures, keeps the ontology index boundary statement explicit, and adds focused failing tests for both regressions.
- **Completion evidence:** the verifier fails closed on prompt-body boundary regressions and the docs/handoff/validation story all point to DB-only prompt bodies.

## Previously completed operating wave

### Router-semantic aggregate reporting + privacy hardening
- **AK tasks:** `#247`, `#248`, `#246`
- **Status:** complete
- **Completion evidence:** `pv quality rollup selection_principles` is live, router-only multi-valued bucketing is enforced, focused privacy tests are in place, and repo docs/handoff were refreshed.

### Shared runtime registry / execution-observability boundary clarification
- **AK task:** `#245`
- **Status:** complete
- **Completion evidence:** Prompt Vault now has a repo-native boundary note clarifying that shared runtime registry discovery remains process-local, `pi-vault-client` owns local receipt/telemetry bridges, and Prompt Vault exports only schema-governed execution/feedback facts plus privacy-safe aggregate observability.

## Next decision after this wave

Use AK + current docs to decide whether TG2 needs another bounded repo-local follow-through or whether TG3 should become the next promoted tactical slice.
Do not infer a synthetic next task from this file alone if AK does not currently show one.

## Validation expectation for this wave

At minimum, re-run:
```bash
./scripts/pv-verify-ontology-contract
./scripts/pv-bats tests/pv-ontology-contract.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future DB-vs-ontology boundary regressions in the same slice.

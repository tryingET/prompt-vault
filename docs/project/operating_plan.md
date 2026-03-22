---
summary: "Operating plan and completion record for the router-semantic aggregate-reporting wave."
read_when:
  - "When reviewing the router-semantic reporting wave or its completion state"
  - "When checking which AK tasks covered the recent Prompt Vault slice"
---

# Operating Plan

Active strategic goal: **SG1 — Keep Prompt Vault the canonical governed prompt-authoring substrate**

Active tactical goal: **TG4 — Improve aggregate-first evidence surfaces for governed router semantics**

## Status

This operating wave is now materially complete:
- `pv quality rollup selection_principles` is live
- router-only multi-valued bucketing is enforced for that surface
- focused privacy/non-leakage and bucket-correctness tests are in place
- README + handoff docs now describe the shipped surface truthfully

## Scope of this operating wave

This wave stays bounded:
- improve aggregate-only quality/reporting for governed router semantics
- keep private execution output non-previewable by default
- avoid widening Prompt Vault into shared runtime-registry ownership
- avoid reopening the schema-v9 ontology/company-visibility cutovers

## Completed operating slices in this wave

### OP1 — Add aggregate-only `selection_principles` rollup support to `pv-quality`
- **AK task:** `#247`
- **Why now:** current rollup support covers exact-one router vocabulary dimensions, but the handoff explicitly calls out multi-valued semantics such as `selection_principles` as the next bounded follow-through.
- **Deliverable:** `pv quality rollup selection_principles` now reports aggregate quality/evidence by selection principle without widening private-output exposure.
- **Completion evidence:** operators can inspect selection-principle buckets through the CLI and the output remains aggregate-first.

### OP2 — Add focused validation for multi-valued router-semantic rollups and privacy boundaries
- **AK task:** `#248`
- **Why now:** multi-valued semantics create a higher drift/privacy risk than exact-one dimensions, so coverage needs to prove both bucket correctness and non-leakage.
- **Deliverable:** focused tests covering router-only semantics, multi-valued bucket behavior, and private-output non-disclosure.
- **Completion evidence:** targeted tests pass and fail closed when the surface regresses or leaks.

### OP3 — Refresh docs and handoff for the new router-semantic rollup surface
- **AK task:** `#246`
- **Why now:** once the reporting surface exists, README/handoff/docs must describe the new aggregate-only capability truthfully and keep operators away from stale assumptions.
- **Deliverable:** updated repo docs and handoff references for the new selection-principles reporting surface.
- **Completion evidence:** the docs/handoff/validation story now matches the shipped CLI behavior.

## Next decision after this wave

Use AK + current docs to decide whether TG4 is now complete enough to promote a different tactical slice, or whether a still-local follow-through is warranted.
Do not treat blocked task `#245` as the automatic next step unless dependency `#241` has actually cleared.

## Out-of-wave / blocked items

### Pending but blocked cross-repo boundary follow-through
- **AK task:** `#245`
- **Status:** blocked in practice by foreign-repo dependency `#241` under `softwareco/owned/pi-extensions`
- **Rule:** do not let this blocked cross-repo work displace the active repo-local operating wave.

## Validation expectation for this wave

At minimum, re-run:
```bash
./scripts/pv-verify-ontology-contract
./scripts/pv-bats tests/pv-quality.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for multi-valued rollup semantics in the same slice.

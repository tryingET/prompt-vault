---
summary: "Operating plan and completion record for the first SG2 company-visibility evidence rollup wave plus the coordination-only teacher-prep prompt-authority confirmation."
read_when:
  - "When reviewing the active repo-local wave after SG1 became materially complete"
  - "When checking which AK task covered the company-visibility evidence rollup slice"
---

# Operating Plan

Active strategic goal: **SG2 — Deepen privacy-safe evidence and downstream usability without collapsing boundaries**

Active tactical goal: **TG5 — Expand aggregate-first evidence surfaces across governed company visibility**

## Status

This operating wave is now materially complete:
- `pv quality rollup visibility_companies` is live as an aggregate-only quality/evidence surface
- focused bats coverage protects privacy posture and multi-valued company-bucket behavior
- the coordination-only teacher-prep prompt-authority check confirmed the live runner still consumes canonical Prompt Vault template/version truth without creating local shadow prompt canon
- README + strategic/tactical/operating/handoff docs now describe the promoted SG2/TG5 reality truthfully

## Scope of this operating wave

This wave stays bounded:
- promote SG2 after SG1 became materially complete
- add aggregate-only company-visibility rollups using the governed company contract
- keep private captured output non-previewable while improving downstream evidence usability
- add focused validation so multi-company bucketing stays deterministic and privacy-safe
- refresh repo direction/handoff surfaces so operators start from the new SG2/TG5 reality instead of the completed SG1/TG3 wave

## Completed operating slice in this wave

### OP1 — Add a governed `visibility_companies` quality rollup for privacy-safe evidence planning
- **AK task:** `#270`
- **Why now:** downstream operators could inspect evidence by owner company and router semantics, but not by the governed multi-company visibility boundary that determines who can actually consume a prompt safely.
- **Deliverable:** add `pv quality rollup visibility_companies`, back it with governed company buckets from `ontology/company-visibility-contract.json`, add focused bats coverage for privacy + multi-bucket behavior, and refresh repo docs/handoff to show SG2/TG5 as the active reality.
- **Completion evidence:** `./scripts/pv quality rollup visibility_companies`, `tests/pv-quality.bats`, `tests/pv-commands.bats`, and the updated README/strategy/tactical/operating/handoff docs all point to the same aggregate-first company-visibility truth.

### OP2 — Confirm the teacher-prep live runner still treats Prompt Vault as canonical prompt authority
- **AK task:** `#458`
- **Why now:** the FCOS-M29 cross-repo fanout left Prompt Vault with a conditional prompt-authority follow-through task in case the live teacher-prep runner started creating reusable prompt/provenance drift downstream.
- **Deliverable:** verify the live runner still resolves canonical Prompt Vault template/version truth for `teacher-prep-media-image-pack`, `teacher-prep-media-storyboard`, and `teacher-prep-media-video-prompt`; write a repo-native boundary note; add focused validation for the canonical teacher-prep prompt layer; refresh docs/handoff so operators do not keep treating `#458` as pending work.
- **Completion evidence:** `docs/dev/teacher-prep-media-prompt-authority-boundary.md`, `tests/pv-teacher-prep-media-templates.bats`, the downstream boundary evidence in `workstation-capabilities/apps/teacher-prep-media`, and the updated README/tactical/operating/handoff docs all point to the same conclusion: Prompt Vault remains canonical and no new repo-local authoring change was needed.

## Previously completed operating waves

### Procedure-layer expansion for governance-shaped work
- **AK task:** `#265`
- **Status:** complete
- **Completion evidence:** Prompt Vault now contains `owner-repo-boundary-note`, focused tests protect the template, and repo docs/handoff reflect TG3 truthfully.

### Ontology-boundary hardening
- **AK task:** `#264`
- **Status:** complete
- **Completion evidence:** `pv-verify-ontology-contract` rejects prompt-body leakage in ontology-shaped surfaces, focused tests cover the regressions, and repo docs/handoff keep prompt bodies DB-only.

### Router-semantic aggregate reporting + privacy hardening
- **AK tasks:** `#247`, `#248`, `#246`
- **Status:** complete
- **Completion evidence:** `pv quality rollup selection_principles` is live, router-only multi-valued bucketing is enforced, focused privacy tests are in place, and repo docs/handoff were refreshed.

### Shared runtime registry / execution-observability boundary clarification
- **AK task:** `#245`
- **Status:** complete
- **Completion evidence:** Prompt Vault now has a repo-native boundary note clarifying that shared runtime registry discovery remains process-local, `pi-vault-client` owns local receipt/telemetry bridges, and Prompt Vault exports only schema-governed execution/feedback facts plus privacy-safe aggregate observability.

## Next decision after this wave

Use AK + current docs to decide whether TG5 needs another bounded aggregate-evidence follow-through, whether downstream contract/usability should become the next active slice, or whether no new repo-local task is currently ready.
Do not infer a synthetic next task from this file alone if AK does not currently show one.

## Validation expectation for this wave

At minimum, re-run:
```bash
./scripts/pv quality rollup visibility_companies
./scripts/pv-bats tests/pv-quality.bats
./scripts/pv-bats tests/pv-commands.bats
./scripts/pv-bats tests/pv-teacher-prep-media-templates.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future aggregate-evidence or visibility-boundary drift in the same slice.

---
summary: "Operating plan and completion record for the bounded workstation-posture machine-snapshot handoff contract slice after the SG2 company-visibility evidence wave."
read_when:
  - "When reviewing the active repo-local wave after the first SG2 evidence slice completed"
  - "When checking which AK task covered the workstation-posture machine-snapshot handoff contract"
---

# Operating Plan

Active strategic goal: **SG2 — Deepen privacy-safe evidence and downstream usability without collapsing boundaries**

Active tactical goal: **TG6 — Define bounded downstream handoff contracts for workstation posture machine snapshots**

## Status

This operating wave is now materially complete:
- Prompt Vault now has a repo-native handoff note for workstation posture machine snapshots
- focused bats coverage protects the Prompt Vault side of the handoff contract
- tactical/operating/handoff docs now point operators to the exact split between Prompt Vault prompt authority and infra-owned machine posture packets

## Scope of this operating wave

This wave stays bounded:
- define the Prompt Vault side of the workstation posture machine-snapshot handoff
- keep the workstation snapshot transport infra-owned rather than recreating it in Prompt Vault
- allow downstream repos to carry exact prompt provenance plus machine-state guidance without copying prompt bodies, governance canon, or private outputs into machine-facing packets
- refresh repo direction/handoff surfaces so operators do not infer a fake combined source of truth

## Completed operating slice in this wave

### OP1 — Define Prompt Vault handoff contract for workstation posture machine snapshots
- **AK task:** `#1717`
- **Why now:** `infra/workstation` now exposes a versioned posture machine snapshot that downstream runtime-aware consumers can use, but Prompt Vault still needed one repo-native answer for what prompt/provenance facts may travel with that machine packet without collapsing authority boundaries.
- **Deliverable:** write a Prompt Vault-side handoff note for workstation posture machine snapshots, add focused validation for the no-copy / owner-split rules, and refresh repo handoff docs so cold-start operators can route the next change to the correct repo.
- **Completion evidence:** `docs/dev/workstation-posture-machine-snapshot-handoff.md`, `tests/pv-workstation-posture-handoff.bats`, `docs/project/tactical_goals.md`, this operating plan, and `next_session_prompt.md` all point to the same boundary truth.

## Previously completed operating waves

### Company-visibility evidence + teacher-prep prompt-authority confirmation
- **AK tasks:** `#270`, `#458`
- **Status:** complete
- **Completion evidence:** `pv quality rollup visibility_companies` is live, the teacher-prep runner still resolves canonical Prompt Vault template/version truth without creating local shadow prompt canon, and the corresponding docs/handoff/tests point to the same SG2 reality.

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
- **Completion evidence:** Prompt Vault has a repo-native boundary note clarifying that shared runtime registry discovery remains process-local, `pi-vault-client` owns local receipt/telemetry bridges, and Prompt Vault exports only schema-governed execution/feedback facts plus privacy-safe aggregate observability.

## Next decision after this wave

Use AK + current docs to decide whether another downstream contract/usability slice is ready or whether no new repo-local task is currently ready.
Do **not** infer a synthetic next task from this file alone.

## Validation expectation for this wave

At minimum, re-run:
```bash
./scripts/pv-bats tests/pv-workstation-posture-handoff.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future workstation-snapshot handoff drift in the same slice.

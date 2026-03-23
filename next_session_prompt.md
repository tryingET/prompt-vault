---
summary: "Repo-local Prompt Vault handoff: schema v9, privacy-safe router reporting, ontology-boundary hardening, and the first TG3 procedure-layer slice are complete; the next session should reassess the next repo-local slice from AK instead of replaying finished work."
read_when:
  - "Starting the next session in prompt-vault"
  - "Before choosing the next post-TG3 implementation slice"
system4d:
  container: "Prompt Vault v9 stabilization and delivery planning; separate from vault-client package implementation work"
  compass: "Keep ontology/contracts clean, keep prompt seed content out of ontology, and advance the next real repo-local slice instead of replaying finished waves"
  engine: "Confirm current schema-v9 reality -> verify the completed TG2/TG3 slices -> reassess the next repo-local slice from AK -> update handoff truthfully"
  fog: "Main risks are stale docs sending work backward, reintroducing prompt bodies into ontology/contracts, mistaking projection-only surfaces for cutover, or widening private-output exposure while improving reporting"
---

# Next Session Prompt — Prompt Vault Post-TG3 Reassessment

## Scope boundary
- Start in `~/ai-society/core/prompt-vault`.
- Treat Prompt Vault as the canonical source of truth for schema/contracts/data behavior.
- Keep vault-client implementation work in its relocated package home unless you are updating boundary docs only.
- Do **not** reopen the hard-cut ontology, controlled-vocabulary, or company-visibility decisions unless validation shows a real defect.
- Keep prompt seed content out of `ontology/`; ontology should hold contracts and governed semantics, not prompt bodies.

## What is already done
Keep this section intentionally short; derive current reality from `README.md`, deterministic validation, and the repo-native boundary notes instead of a separate status mirror.

Current baseline to assume unless validation disproves it:
- Prompt Vault schema target is `9`
- facet / controlled-vocabulary / company-visibility cutovers are already complete
- execution output capture and privacy-safe aggregate reporting are already live
- evidence-promotion authority is machine-readable
- router prompt bodies are canonical DB content, not repo markdown fixtures or ontology content
- ontology verification now fails closed if seed-contract metadata starts carrying prompt-body content or if `ontology/index.md` stops stating the DB-only authoring boundary explicitly
- the repo-native v4 prompt-authoring boundary note exists:
  - `docs/dev/v4-prompt-authoring-review-input-boundary.md`
- the Prompt Vault-side shared runtime registry / execution-observability boundary note exists:
  - `docs/dev/shared-runtime-registry-and-execution-observability-boundary.md`
- the repo-local reusable procedure layer now includes:
  - `concern-first-review-fanout`
  - `owner-repo-boundary-note`
- the project direction cascade has been refreshed:
  - `docs/project/vision.md`
  - `docs/project/strategic_goals.md`
  - `docs/project/tactical_goals.md`
  - `docs/project/operating_plan.md`
- aggregate-only multi-valued router-semantic reporting is live:
  - `./scripts/pv quality rollup selection_principles`
  - router-only bucketing is enforced
  - private output text remains non-previewable in the rollup surface
- focused validation covers multi-valued router-semantic rollups, privacy boundaries, ontology boundary drift, and the new TG3 procedure slice:
  - `tests/pv-quality.bats`
  - `tests/pv-commands.bats`
  - `tests/pv-ontology-contract.bats`
  - `tests/pv-owner-repo-boundary-note-template.bats`

If you need detail, read `README.md`, the project direction docs, the boundary notes, and run the current deterministic checks instead of expanding this handoff into a second status document.

## What should not be redone
- do **not** replay the controlled-vocabulary router slice as if it is still pending
- do **not** treat schema version as `3`; current target is `9`
- do **not** put prompt bodies back into repo fixture markdown just to satisfy docs/tooling
- do **not** put prompt bodies into `ontology/`
- do **not** reintroduce legacy `type` or semantic tags as compatibility shortcuts
- do **not** resume vault-client product work from stale standalone or live-copy locations
- do **not** let blocked cross-repo boundary work displace the active repo-local operating wave
- do **not** reopen tasks `#264` or `#265`; they are completed slices, not the next step

## Current goal
Keep this handoff repo-local and DRY:
1. use repo docs + deterministic validation for current truth (`README.md`, project direction docs, boundary notes, ontology contracts, repo checks)
2. use AK for actionable backlog
3. only do Prompt Vault work from this repo session

The most recent Prompt Vault repo-local waves are now complete:
- `#247` — aggregate-only `selection_principles` rollup support landed in `pv-quality`
- `#248` — focused validation for multi-valued router-semantic rollups and privacy boundaries landed
- `#246` — docs and handoff were refreshed for the rollup surface
- `#245` — Prompt Vault boundary versus shared runtime registry and exported prompt execution observability landed
- `#264` — ontology contract verification now rejects prompt-body leakage and keeps the ontology index boundary statement explicit
- `#265` — the reusable owner-repo boundary-note procedure template now exists in the vault with focused validation and docs/handoff refresh

That means the next session should **reassess the next repo-local slice from AK** instead of replaying any of those finished waves.

Do **not** restate foreign-repo implementation backlog here.
Cross-repo extension/client follow-through remains tracked in AK history under `#229` in `softwareco/owned/pi-extensions`, but it is not the next Prompt Vault repo-local step.

## If work shifts to the broader semantic-organism / AK bridge direction
Do not invent that architecture separately in this repo.
Use the canonical focused note in agent-kernel:
- `~/ai-society/softwareco/owned/agent-kernel/docs/project/prompt-vault-ak-capability-bridge.md`

Also use the repo-native v4 boundary note instead of re-deriving prompt-authoring ownership from session memory:
- `docs/dev/v4-prompt-authoring-review-input-boundary.md`

Prompt Vault should remain the prompt-body / authoring substrate in that design, not the sole operational organism.

## Read first
1. `AGENTS.md`
2. `README.md`
3. `docs/project/strategic_goals.md`
4. `docs/project/tactical_goals.md`
5. `docs/project/operating_plan.md`
6. `docs/reference/db-stage-backup-policy.md`
7. `ontology/v2-contract.json`
8. `ontology/controlled-vocabulary-contract.json`
9. `ontology/company-visibility-contract.json`
10. `ontology/index.md`
11. `schema/schema.sql`
12. `scripts/pv`
13. `scripts/pv-verify-ontology-contract`
14. `docs/dev/vault-client-relocation-interface.md`
15. `docs/dev/v4-prompt-authoring-review-input-boundary.md`
16. `docs/dev/shared-runtime-registry-and-execution-observability-boundary.md`
17. `diary/2026-03-22--procedure-governance-behavior-fanout-template.md`
18. `diary/2026-03-22--docs-direction-cascade-refresh.md`
19. `diary/2026-03-22--operating-plan-router-semantic-rollups.md`
20. `diary/2026-03-23--ontology-boundary-verification-hardening.md`
21. `diary/2026-03-23--owner-repo-boundary-note-template.md`

## Recommended work order
1. Check AK before choosing work:
   - confirm the completed repo-local wave `#247` -> `#248` -> `#246`
   - confirm the completed boundary-doc follow-through `#245`
   - confirm the completed ontology-boundary hardening slice `#264`
   - confirm the completed first TG3 procedure-layer slice `#265`
   - inspect whether any new Prompt Vault-ready task exists
   - keep foreign-repo follow-through `#229` out of scope for this repo session unless the operator explicitly asks for cross-repo work
2. Re-run the current deterministic checks if you need to confirm the shipped surface quickly.
3. Choose the next repo-local task from AK + current docs rather than from stale session memory.
4. Update `README.md`, `docs/project/operating_plan.md`, diary/handoff notes, and this handoff in the same pass if repo-local reality changes again.

## Practical warnings
- The main failure mode is resuming from stale handoff text instead of current repo reality.
- Ontology should describe governed semantics and contracts, not carry prompt bodies.
- Keep low-risk data edits in `db-dev`; escalate stages only when blast radius or restore expectations increase.
- Keep privacy considerations explicit before storing execution outputs.
- Treat router prompts as canonical DB content, not docs and not ontology artifacts.
- Keep multi-valued router reporting aggregate-first; private output text must remain non-previewable unless a separate explicit public boundary says otherwise.
- Do **not** treat projection-only surfaces as proof of authority cutover.

## Validation
From `~/ai-society/core/prompt-vault`:
```bash
./scripts/db-change-preflight.sh --stage db-dev
./scripts/pv show template owner-repo-boundary-note
./scripts/pv-bats tests/pv-owner-repo-boundary-note-template.bats
./scripts/pv-verify-ontology-contract
./scripts/pv-bats tests/pv-ontology-contract.bats
./scripts/pv-bats tests/pv-quality.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future DB-vs-ontology or procedure-layer regressions in the same slice.

## Explicit deferrals
- No ROCS-backed contract compiler in this pass.
- No rollback to legacy `type` or tag semantics.
- No broad raw-output dashboard push that normalizes exposing captured text beyond the explicit public-preview boundary.
- No moving vault-client implementation work back into Prompt Vault beyond boundary-document updates.
- No reopening the completed `#245`, `#264`, or `#265` slices unless the underlying ownership/export/privacy or DB-vs-ontology boundary changes again.

## Canonical next slice after this one
Decide from AK + current repo docs, not from handoff prose memory:
- the `#247` -> `#248` -> `#246` wave is complete
- boundary-doc follow-through `#245` is complete
- ontology-boundary hardening `#264` is complete
- the first TG3 procedure-layer slice `#265` is complete
- reassess whether TG3 needs another bounded local follow-through or whether SG1 is materially complete and SG2 should be promoted next
- do not infer a synthetic next task from this handoff alone if AK does not currently show one

## First concrete next action
From `~/ai-society/core/prompt-vault`:
1. read `README.md`, `docs/project/tactical_goals.md`, and `docs/project/operating_plan.md`
2. check repo-local AK task state (`ak task ready -F json` / `ak task list -F json --verbose`)
3. choose the next repo-local task only after confirming it is not just a replay of the completed rollup, boundary-hardening, or first TG3 procedure-layer waves

Foreign-repo follow-through reference only:
- AK task `#229`
- repo root: `~/ai-society/softwareco/owned/pi-extensions`
- package path: `~/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`

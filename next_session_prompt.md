---
summary: "Prompt Vault is now on schema v9 with governed facets, controlled vocabulary, company visibility, feedback uniqueness, and execution output capture; next session should focus on analytics surfaces, remaining downstream doc alignment, and any still-stale boundary guidance rather than replaying old cutover work."
read_when:
  - "Starting the next session in prompt-vault"
  - "Before choosing the next post-cutover implementation slice"
system4d:
  container: "Prompt Vault v9 stabilization and delivery planning; separate from vault-client package implementation work"
  compass: "Keep ontology/contracts clean, keep prompt seed content out of ontology, and advance the next real product slice instead of replaying already-finished cutovers"
  engine: "Confirm current schema-v9 reality -> clean stale guidance/contracts -> validate downstream boundaries -> implement the next truthful product slice"
  fog: "Main risks are stale docs sending work backward, reintroducing legacy type/tag thinking, or mixing prompt seed content into ontology again"
---

# Next Session Prompt — Prompt Vault v9 Stabilization + Post-Capture Follow-Through

## Scope boundary
- Start in `~/ai-society/core/prompt-vault`.
- Treat Prompt Vault as the canonical source of truth for schema/contracts/data behavior.
- Keep vault-client implementation work in its relocated package home unless you are updating boundary docs only.
- Do **not** reopen the hard-cut ontology, controlled-vocabulary, or company-visibility decisions unless validation shows a real defect.
- Keep prompt seed content out of `ontology/`; ontology should hold contracts and governed semantics, not prompt bodies.

## What is already done
Prompt Vault has moved well beyond the old v2 cutover note:
- live schema version is `9`
- canonical ontology facets are live:
  - `artifact_kind`
  - `control_mode`
  - `formalization_level`
- governed router controlled vocabulary is live
- company ownership + visibility boundary is live:
  - `owner_company`
  - `visibility_companies`
- feedback cardinality is live and schema-enforced:
  - one row per `execution_id`
- execution output capture is live with explicit policy in the DB:
  - `output_capture_mode` = `none | private | public`
  - `output_text` is nullable and populated only when capture is explicitly requested
- free-form prompt tags are no longer part of the canonical prompt model
- the 3 seeded router prompts exist and are active in the DB:
  - `analysis-router`
  - `post-review-router`
  - `review-closeout-router`
- router prompt bodies are canonical DB content, not repo markdown fixtures
- low-risk exact-name row/content edits now have an explicit local preflight path:
  - `./scripts/db-change-preflight.sh --stage db-dev`
- `extension-sop` was updated in the vault to be repo-local / pi-package-generic rather than tied to a single package layout

## What should not be redone
- do **not** replay the controlled-vocabulary router slice as if it is still pending
- do **not** treat schema version as `3`; current target is `9`
- do **not** put prompt bodies back into repo fixture markdown just to satisfy docs/tooling
- do **not** put prompt bodies into `ontology/`
- do **not** reintroduce legacy `type` or semantic tags as compatibility shortcuts
- do **not** resume vault-client product work from stale standalone or live-copy locations

## Current goal
Focus the next session on the next truthful product slice after execution capture landed:
1. verify downstream docs/clients reflect schema v9 execution capture semantics
2. build the first analytics/quality surfaces that responsibly use captured execution outputs
3. keep ontology/contracts distinct from prompt seed content
4. finish remaining extension rate limiting work and validation updates

This aligns with the current tactical goals more than replaying already-landed router metadata work.

## If work shifts to the broader semantic-organism / AK bridge direction
Do not invent that architecture separately in this repo.
Use the canonical focused note in agent-kernel:
- `~/ai-society/softwareco/owned/agent-kernel/docs/project/prompt-vault-ak-capability-bridge.md`

Prompt Vault should remain the prompt-body / authoring substrate in that design, not the sole operational organism.

## Read first
1. `AGENTS.md`
2. `README.md`
3. `docs/dev/status.md`
4. `docs/reference/db-stage-backup-policy.md`
5. `ontology/v2-contract.json`
6. `ontology/controlled-vocabulary-contract.json`
7. `ontology/company-visibility-contract.json`
8. `schema/schema.sql`
9. `scripts/pv`
10. `scripts/pv-verify-ontology-contract`
11. `docs/dev/vault-client-relocation-interface.md`

## Recommended work order
1. Confirm that no repo guidance/tooling still assumes markdown prompt fixtures are the source of truth for seeded router content.
2. Clean up any remaining stale guidance that still describes the pre-v8 state.
3. Design the smallest safe slice for execution output capture:
   - decide where output is stored
   - add a privacy flag / opt-out boundary
   - keep capture policy explicit and auditable
4. Update schema/scripts/tests only as needed for that slice.
5. Update docs/status/handoff in the same pass.

## Practical warnings
- The main failure mode is resuming from stale handoff text instead of current repo reality.
- Ontology should describe governed semantics and contracts, not carry prompt bodies.
- Keep low-risk data edits in `db-dev`; escalate stages only when blast radius or restore expectations increase.
- Keep privacy considerations explicit before storing execution outputs.
- Treat router prompts as canonical DB content, not docs and not ontology artifacts.

## Validation
From `~/ai-society/core/prompt-vault`:
```bash
./scripts/db-change-preflight.sh --stage db-dev
./scripts/pv-verify-ontology-contract
bats tests/pv-ontology-contract.bats
bats tests/pv-v2-facets.bats
bats tests/pv-feedback.bats
bats tests/pv-exec-output-capture.bats
bats tests/pv-controlled-vocabulary.bats
bats tests/pv-company-visibility.bats
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

If the next slice changes execution capture, add focused tests for privacy/control behavior as part of the same change.

## Explicit deferrals
- No ROCS-backed contract compiler in this pass.
- No rollback to legacy `type` or tag semantics.
- No broad analytics/dashboard push before execution output capture semantics are settled.
- No moving vault-client implementation work back into Prompt Vault beyond boundary-document updates.

## Canonical next slice after this one
Once guidance drift is cleaned up and execution output capture/privacy control is in place, move on to richer analytics/quality surfaces that use the new execution data responsibly.

## First concrete next action
Open `docs/dev/status.md` and downstream client/docs boundary notes, confirm schema v9 execution capture semantics are represented consistently, then scope the smallest analytics surface that consumes captured outputs without weakening privacy defaults.

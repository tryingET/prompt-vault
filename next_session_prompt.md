---
summary: "Prompt Vault is now on schema v9 with governed facets, controlled vocabulary, company visibility, feedback uniqueness, execution output capture, and a first privacy-safe analytics surface; next session should focus on richer quality surfaces, remaining downstream doc alignment, and any still-stale boundary guidance rather than replaying old cutover work."
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
- the first privacy-safe output analytics surface is live and hardened:
  - `./scripts/pv analytics outputs`
  - private captures are aggregated-only
  - only explicitly public captures render previews
  - previews strip ANSI/control escapes before rendering
  - analytics/quality name paths now fail closed on injected names or bad subcommands
- richer quality evidence coverage is now live without widening raw-output exposure:
  - `./scripts/pv quality coverage`
  - `./scripts/pv quality dashboard` highlights the biggest evidence gaps
  - template/skill quality views now show feedback/capture coverage rates and last evidence timestamps
- aggregate quality rollups are now live without normalizing raw output exposure:
  - `./scripts/pv quality rollup control_mode`
  - supported dimensions currently include `artifact_kind`, `control_mode`, `formalization_level`, `owner_company`
  - rollups stay metadata-only and facet/governance aligned
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
Focus the next session on the next truthful product slice after the first privacy-safe analytics + quality coverage surfaces landed:
1. verify downstream docs/clients still reflect schema v9 execution capture semantics consistently
2. extend quality reporting only where it stays aggregate-first for private captures
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
3. Extend the new analytics/quality layer using capture metadata only where privacy posture stays explicit:
   - prefer aggregate counts and coverage metrics for private captures
   - render text previews only for explicitly public captures
   - avoid broad dashboarding that normalizes raw output exposure
4. Update scripts/tests/docs only as needed for that slice.
5. Update status/handoff in the same pass.

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
- No broad raw-output dashboard push that normalizes exposing captured text beyond the explicit public-preview boundary.
- No moving vault-client implementation work back into Prompt Vault beyond boundary-document updates.

## Canonical next slice after this one
With docs drift cleaned up and coverage-aware + rollup quality surfaces now in place, move on to any remaining extension rate-limiting follow-through plus deeper aggregate reporting that still avoids normalizing raw private output exposure.

## First concrete next action
Open the remaining extension/client boundary notes, confirm no downstream rate-limiting or validation guidance still assumes pre-v9 behavior, then scope the next aggregate-only reporting improvement after rollups before considering any broader dashboard work.

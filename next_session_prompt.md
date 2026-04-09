---
summary: "Repo-local Prompt Vault handoff: SG1 is materially complete, the first SG2 company-visibility evidence slice is complete, the coordination-only teacher-prep prompt-authority follow-through is closed, ROCS now resolves through shared-core workspace layer paths, and the next session should reassess AK instead of replaying finished work."
read_when:
  - "Starting the next session in prompt-vault"
  - "Before choosing the next post-SG2 implementation slice"
system4d:
  container: "Prompt Vault SG2 privacy-safe evidence and downstream usability planning after SG1 stabilization"
  compass: "Keep ontology/contracts clean, keep prompt seed content out of ontology, and expand privacy-safe evidence surfaces without weakening ownership or visibility boundaries"
  engine: "Confirm current schema-v9 + SG2 reality -> verify the completed SG1/TG3 and first SG2/TG5 slices -> reassess the next repo-local slice from AK -> update handoff truthfully"
  fog: "Main risks are stale docs sending work backward, reintroducing prompt bodies into ontology/contracts, replaying completed waves, or widening private-output exposure while improving evidence reporting"
---

# Next Session Prompt — Prompt Vault Post-SG2/TG5 Reassessment

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
- aggregate-only rollups now include multi-valued `selection_principles` and `visibility_companies`
- evidence-promotion authority is machine-readable
- router prompt bodies are canonical DB content, not repo markdown fixtures or ontology content
- ontology verification fails closed if seed-contract metadata starts carrying prompt-body content or if `ontology/index.md` stops stating the DB-only authoring boundary explicitly
- ROCS repo checks now flow through `./scripts/rocs.sh` to the shared workspace `core/rocs-cli` package with workspace-local ontology layer paths in `ontology/manifest.yaml`; the repo no longer depends on a vendored GitLab baseline-resolution compatibility path
- the repo-native v4 prompt-authoring boundary note exists:
  - `docs/dev/v4-prompt-authoring-review-input-boundary.md`
- the Prompt Vault-side shared runtime registry / execution-observability boundary note exists:
  - `docs/dev/shared-runtime-registry-and-execution-observability-boundary.md`
- the teacher-prep live-runner prompt-authority boundary note exists:
  - `docs/dev/teacher-prep-media-prompt-authority-boundary.md`
- the repo-local reusable procedure layer includes:
  - `concern-first-review-fanout`
  - `owner-repo-boundary-note`
- the project direction cascade is refreshed for SG2:
  - `docs/project/vision.md`
  - `docs/project/strategic_goals.md`
  - `docs/project/tactical_goals.md`
  - `docs/project/operating_plan.md`
- focused validation covers router/company rollups, privacy boundaries, ontology boundary drift, the reusable procedure layer, the teacher-prep prompt-authority layer, and ROCS workspace-path resolution via the shared core runner:
  - `tests/pv-quality.bats`
  - `tests/pv-commands.bats`
  - `tests/pv-ontology-contract.bats`
  - `tests/pv-owner-repo-boundary-note-template.bats`
  - `tests/pv-teacher-prep-media-templates.bats`
  - `scripts/rocs.sh`
  - `scripts/ci/full.sh`

If you need detail, read `README.md`, the project direction docs, the boundary notes, and run the current deterministic checks instead of expanding this handoff into a second status document.

## What should not be redone
- do **not** replay the controlled-vocabulary router slice as if it is still pending
- do **not** treat schema version as `3`; current target is `9`
- do **not** put prompt bodies back into repo fixture markdown just to satisfy docs/tooling
- do **not** put prompt bodies into `ontology/`
- do **not** reintroduce legacy `type` or semantic tags as compatibility shortcuts
- do **not** resume vault-client product work from stale standalone or live-copy locations
- do **not** let blocked cross-repo boundary work displace the active repo-local operating wave
- do **not** reintroduce legacy `<gitlab:...>` ROCS locators or prefer a repo-local vendored ROCS runner over `./scripts/rocs.sh`
- do **not** reopen task `#458` unless the live teacher-prep runner boundary changes again and a real reusable prompt-authority defect appears
- do **not** reopen tasks `#245`, `#264`, `#265`, `#270`, or `#280`; they are completed slices, not the next step

## Current goal
Keep this handoff repo-local and DRY:
1. use repo docs + deterministic validation for current truth (`README.md`, project direction docs, boundary notes, ontology contracts, repo checks)
2. use AK for actionable backlog
3. only do Prompt Vault work from this repo session

The most recent Prompt Vault repo-local waves are now complete:
- `#247` — aggregate-only `selection_principles` rollup support landed in `pv-quality`
- `#248` — focused validation for multi-valued router-semantic rollups and privacy boundaries landed
- `#246` — docs and handoff were refreshed for the original rollup surface
- `#245` — Prompt Vault boundary versus shared runtime registry and exported prompt execution observability landed
- `#264` — ontology contract verification now rejects prompt-body leakage and keeps the ontology index boundary statement explicit
- `#265` — the reusable owner-repo boundary-note procedure template now exists in the vault with focused validation and docs/handoff refresh
- `#270` — aggregate-only `visibility_companies` rollup support landed with focused validation and docs/handoff refresh
- `#280` — the repo-local ROCS GitLab baseline-resolution compatibility path is gone; ontology checks now resolve through the shared workspace `core/rocs-cli` runner using workspace-local layer paths
- `#458` — the coordination-only teacher-prep prompt-authority follow-through is closed: the live runner already resolves canonical Prompt Vault template/version truth, pack-local prompt-like artifacts stay derived-only, and no new repo-local authoring change was needed

That means the next session should **reassess the next repo-local slice from AK** instead of replaying any of those finished waves.

At the moment there is no pending repo-local AK task in this repo. If AK still shows no new Prompt Vault-ready item, stop rather than synthesizing work from stale handoff prose.

Do **not** restate foreign-repo implementation backlog here.
Cross-repo extension/client follow-through remains tracked elsewhere, but it is not the next Prompt Vault repo-local step.

## AK note
- Prefer `./scripts/ak.sh ...`; it resolves through vendored or workspace-core Agent Kernel CLI paths before falling back to `ak` on `PATH`.
- Plain `ak` on `PATH` may still fail against `~/ai-society/society.v2.db` with a schema-version mismatch, which is why the wrapper should be the default entrypoint.
- If the wrapper cannot resolve AK for some reason, use the workspace Agent Kernel CLI directly:
  ```bash
  cargo run --quiet --manifest-path ~/ai-society/softwareco/owned/agent-kernel/crates/ak-cli/Cargo.toml --bin ak -- <args...>
  ```
- Keep Prompt Vault task operations repo-scoped even when invoking AK from that external manifest path.

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
13. `scripts/pv-quality`
14. `scripts/pv-verify-ontology-contract`
15. `docs/dev/vault-client-relocation-interface.md`
16. `docs/dev/v4-prompt-authoring-review-input-boundary.md`
17. `docs/dev/shared-runtime-registry-and-execution-observability-boundary.md`
18. `docs/dev/teacher-prep-media-prompt-authority-boundary.md`
19. `diary/2026-03-22--procedure-governance-behavior-fanout-template.md`
20. `diary/2026-03-23--ontology-boundary-verification-hardening.md`
21. `diary/2026-03-23--owner-repo-boundary-note-template.md`
22. `diary/2026-03-23--visibility-companies-rollup.md`
23. `diary/2026-03-30--rocs-workspace-path-contract-adoption.md`
24. `diary/2026-04-09--teacher-prep-prompt-authority-confirmation.md`

## Recommended work order
1. Check AK before choosing work:
   - confirm the completed repo-local wave `#247` -> `#248` -> `#246`
   - confirm the completed boundary-doc follow-through `#245`
   - confirm the completed ontology-boundary hardening slice `#264`
   - confirm the completed first TG3 procedure-layer slice `#265`
   - confirm the completed first SG2/TG5 slice `#270`
   - confirm the completed ROCS workspace-path cleanup slice `#280`
   - confirm the completed coordination-only closeout `#458`
   - inspect whether any new Prompt Vault-ready task exists
2. Re-run the current deterministic checks if you need to confirm the shipped surface quickly.
3. Choose the next repo-local task from AK + current docs rather than from stale session memory.
4. Update `README.md`, `docs/project/strategic_goals.md`, `docs/project/operating_plan.md`, diary/handoff notes, and this handoff in the same pass if repo-local reality changes again.

## Practical warnings
- The main failure mode is resuming from stale handoff text instead of current repo reality.
- Ontology should describe governed semantics and contracts, not carry prompt bodies.
- Keep low-risk data edits in `db-dev`; escalate stages only when blast radius or restore expectations increase.
- Keep privacy considerations explicit before storing execution outputs.
- Treat router prompts as canonical DB content, not docs and not ontology artifacts.
- Keep multi-valued evidence reporting aggregate-first; private output text must remain non-previewable unless a separate explicit public boundary says otherwise.
- Do **not** treat projection-only surfaces as proof of authority cutover.

## Validation
From `~/ai-society/core/prompt-vault`:
```bash
./scripts/db-change-preflight.sh --stage db-dev
./scripts/pv quality rollup visibility_companies
./scripts/pv-bats tests/pv-quality.bats
./scripts/pv-bats tests/pv-commands.bats
./scripts/pv-bats tests/pv-teacher-prep-media-templates.bats
./scripts/pv-verify-ontology-contract
./scripts/rocs.sh --doctor
./scripts/ci/full.sh
./verify.sh
node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict
```

Add any focused tests needed for future aggregate-evidence or visibility-boundary regressions in the same slice.

## Explicit deferrals
- No ROCS-backed contract compiler in this pass.
- No rollback to legacy `type` or tag semantics.
- No broad raw-output dashboard push that normalizes exposing captured text beyond the explicit public-preview boundary.
- No moving vault-client implementation work back into Prompt Vault beyond boundary-document updates.
- No reintroducing repo-local vendored ROCS GitLab locator fallback into the active repo contract.
- No reopening the completed `#245`, `#264`, `#265`, `#270`, `#280`, or `#458` slices unless the underlying ownership/export/privacy, visibility-reporting, workspace-path, or teacher-prep prompt-authority boundary changes again.

## Canonical next slice after this one
Decide from AK + current repo docs, not from handoff prose memory:
- the `#247` -> `#248` -> `#246` wave is complete
- boundary-doc follow-through `#245` is complete
- ontology-boundary hardening `#264` is complete
- the first TG3 procedure-layer slice `#265` is complete
- the first SG2/TG5 visibility rollup slice `#270` is complete
- repo-local ROCS compatibility cleanup `#280` is complete
- coordination-only teacher-prep prompt-authority closeout `#458` is complete
- reassess whether TG5 needs another bounded local follow-through, whether downstream contract/usability should be promoted next, or whether no repo-local task is currently ready
- do not infer a synthetic next task from this handoff alone if AK does not currently show one

## First concrete next action
From `~/ai-society/core/prompt-vault`:
1. read `README.md`, `docs/project/strategic_goals.md`, `docs/project/tactical_goals.md`, and `docs/project/operating_plan.md`
2. check repo-local AK task state (use `./scripts/ak.sh task ready -F json` / `./scripts/ak.sh task list -F json --verbose`; fall back to the direct cargo invocation above only if the wrapper cannot resolve AK)
3. choose the next repo-local task only after confirming it is not just a replay of the completed rollup, boundary-hardening, reusable procedure, ROCS compatibility-cleanup, or teacher-prep prompt-authority closeout waves

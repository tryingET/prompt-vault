---
summary: "Prompt-vault v2 handoff: add 3 router prompts, then hard-cut ontology to artifact_kind/control_mode/formalization_level."
read_when:
  - "Starting the next session in prompt-vault"
  - "Before changing Prompt Vault schema, scripts, or vault-client for v2 ontology work"
system4d:
  container: "Prompt Vault v2 ontology cutover; separate from agent-kernel runtime work"
  compass: "Replace overloaded prompt type with orthogonal facets and add router exemplars"
  engine: "Router prompts first -> hard schema/tool cutover -> validate/export/reload"
  fog: "vault-client, scripts, and exported prompts are coupled to legacy type; stale runtime copies can mislead"
---

# Next Session Prompt — Prompt Vault v2

## Scope boundary
- This work is separate from `softwareco/owned/agent-kernel`.
- Start in `~/ai-society/core/prompt-vault`.
- Do **not** continue the prompt-vault v2 ontology/tooling work from the agent-kernel repo.
- Defer ROCS contract-compiler ambitions for now; ROCS may later clarify semantics, but it is **not** a blocker for Prompt Vault v2.

## Decision snapshot
- Do a **clean hard break**, not a compatibility transition.
- No slow dual-write, no compatibility view, no legacy fallback.
- Do **not** add `workflow` as another prompt `type`.
- Replace the overloaded `type` axis with canonical facets:
  - `artifact_kind`: `cognitive | procedure | session`
  - `control_mode`: `one_shot | router | loop`
  - `formalization_level`: `napkin | bounded | structured | workflow`
- Classification rule:
  - routers are `procedure + router`
  - iterative orchestrators are `procedure + loop`
  - `workflow` belongs to `formalization_level`, not to prompt `type`

## Seed prompts to add first
Add these three prompts before the schema cutover:
- `analysis-router` -> `procedure / router / structured`
- `post-review-router` -> `procedure / router / structured`
- `review-closeout-router` -> `procedure / router / structured`

Their job:
1. take the output of `deep-review` / inversion / telescopic / nexus / audit style prompts
2. determine the next mode:
   - `DECIDE`
   - `DIVERGE`
   - `PLAN`
   - `IMPLEMENT`
   - `VERIFY`
3. emit the exact next prompt for that mode

## Hard-break implications
- `type` is no longer the governing ontology axis.
- Prompt Vault scripts must become facet-native.
- pi-facing vault tools must become facet-native too:
  - `vault_query`
  - `vault_retrieve`
  - `vault_insert`
  - `vault_vocabulary`
- `vault_insert` should become ontology-native; do **not** preserve the muddy legacy `source/type` semantics.
- vault-client should fail fast on schema mismatch instead of limping.

## Read first
1. `AGENTS.md`
2. `README.md`
3. `docs/WORKFLOWS.md`
4. `schema/schema.sql`
5. `migrations/002_add_loop_type.sql`
6. `scripts/pv`
7. `scripts/export-to-pi.sh`
8. `~/.pi/agent/extensions/vault-client/extensions/vault.ts`

## Work order
1. Add the 3 router prompts as concrete exemplars.
2. Design and apply the Prompt Vault v2 schema migration around the 3 canonical facets.
3. Rewrite Prompt Vault scripts/import/export/tagging flows to use the new fields directly.
4. Rewrite `vault-client` queries, inserts, labels, stats, and framework retrieval to use the new facets directly.
5. Update docs/tests/examples in the same cutover.
6. Export to pi, ensure stale runtime prompt files do not survive, then `/reload` pi.

## Practical warnings
- `scripts/export-to-pi.sh` exports active prompts but does **not** clean stale files; use a clean export target or explicitly clean managed outputs before re-export.
- `vault-client` currently depends on legacy `type` in multiple query and UI paths; treat extension rewrites as part of the same atomic cutover.
- Do not get sidetracked into a ROCS contract compiler during this pass.

## Validation
From `~/ai-society/core/prompt-vault`:
```bash
./verify.sh
./scripts/pv migrate status
```
If `vault-client` work resumes, first read `docs/dev/vault-client-relocation-interface.md` and continue in the relocated canonical package home rather than the old standalone/live copies.

## Explicit deferrals
- No ROCS-backed contract compiler in this pass.
- No compatibility adapter/view for legacy `type`.
- No new prompt-loop template until the 3 routers land and the facet model is in place.

## First concrete next action
Create the 3 router prompt templates and write down their exact metadata using the new facet model, then start the Prompt Vault v2 schema migration from that grounded example set.

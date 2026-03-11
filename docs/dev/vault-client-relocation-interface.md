---
summary: "Prompt-vault side boundary note for the relocated vault-client package on the current schema-v9 contract."
read_when:
  - "You need to understand what Prompt Vault already changed before aligning the relocated vault-client package."
  - "You are updating downstream client/docs behavior against the current Prompt Vault boundary."
system4d:
  container: "Prompt Vault as ontology/data source; vault-client implementation lives elsewhere."
  compass: "Preserve current schema-v9 semantics while avoiding duplicate migration work in the wrong extension repo."
  engine: "Read this from prompt-vault, then switch to the canonical vault-client package location."
  fog: "The old standalone vault-client repo and active ~/.pi copy contain partial exploratory work that is not the long-term target."
---

# Prompt Vault → vault-client relocation interface handoff

## What is already true in Prompt Vault
The Prompt Vault hard cutover is now real in this repo:

- `prompt_templates.type` has been removed from the live DB
- canonical ontology facets are now:
  - `artifact_kind`
  - `control_mode`
  - `formalization_level`
- live DB schema version is `9`
- seeded router prompts exist in the DB:
  - `analysis-router`
  - `post-review-router`
  - `review-closeout-router`
- those routers are seeded as:
  - `procedure / router / structured`
- prompt bodies are canonical DB content, not ontology files
- ontology contract pack exists and is verified

## Files here that define the source-of-truth behavior
Read these in this repo:

1. `ontology/v2-contract.json`
2. `ontology/controlled-vocabulary-contract.json`
3. `ontology/company-visibility-contract.json`
4. `schema/schema.sql`
5. `migrations/003_hard_cut_prompt_facets.sql`
6. `scripts/pv`
7. `scripts/export-to-pi.sh`
8. `scripts/pv-verify-ontology-contract`
9. `tests/pv-ontology-contract.bats`
10. `tests/pv-v2-facets.bats`

## What changed at the Prompt Vault boundary
Any client integrating with Prompt Vault must now assume:

- schema version must be exactly `9` for the facet + controlled-vocabulary + company-visibility + execution capture client path
- feedback cardinality is one row per `execution_id`, enforced by the schema
- executions now expose:
  - `output_capture_mode` (`none`, `private`, `public`)
  - `output_text` (nullable, present only when captured)
- queries must use facet fields and `controlled_vocabulary` instead of legacy `type` or tags
- visibility/query boundaries must use:
  - `owner_company`
  - `visibility_companies`
- vocabulary/discovery surfaces must understand:
  - ontology facets (`artifact_kind`, `control_mode`, `formalization_level`)
  - governed controlled vocabulary (`controlled_vocabulary`)
  - governance boundary (`owner_company`, `visibility_companies`)
- inserts must be ontology-native:
  - require `artifact_kind`
  - require `control_mode`
  - require `formalization_level`
- `workflow` is valid only in `formalization_level`
- routers classify as `procedure + router`
- iterative orchestrators classify as `procedure + loop`

## Validation already passing in this repo
From `~/ai-society/core/prompt-vault`:

```bash
./verify.sh
./scripts/pv migrate status
bats tests/pv-ontology-contract.bats
bats tests/pv-v2-facets.bats
```

## Important boundary decision
Do **not** treat either of these as canonical implementation targets for future vault-client work:

- `~/.pi/agent/extensions/vault-client/`
- `~/programming/pi-extensions/vault-client/`

Those locations were used during an exploratory mid-session pass and may contain partial or now-misaligned work.

## Canonical next target for vault-client work
Switch to the new monorepo package home:

- `~/ai-society/softwareco/owned/pi-extensions/packages/`

Find the relocated `vault-client` package there and align current client behavior to the live Prompt Vault schema-v9 contract.

## What to port conceptually, not mechanically
Port these behaviors into the relocated client:

- schema version fail-fast for Prompt Vault facet + controlled-vocabulary + company-visibility path (`version = 9`)
- facet-native template model
- company-aware template visibility filtering (`owner_company`, `visibility_companies`)
- facet-native `vault_query`
- facet-native `vault_retrieve`
- facet-native `vault_insert`
- facet-aware vocabulary output
- facet-aware picker/list/search/stats labels
- framework retrieval logic using `artifact_kind = cognitive`

Do **not** assume the old standalone client’s file boundaries or trigger integrations still exist.

## Additional implementation boundary
For the concrete schema-v9 boundary including company-aware query filtering, execution capture, and execution-bound feedback guarantees, read:

- `docs/dev/vault-client-company-visibility-boundary.md`

## Cross-repo handoff
For the vault-client-specific relocation plan and warnings, read:

- `~/programming/pi-extensions/vault-client/docs/dev/prompt-vault-v2-relocation-handoff.md`

That file should be treated as the extension-side relocation note; this file is the Prompt Vault side of the boundary.

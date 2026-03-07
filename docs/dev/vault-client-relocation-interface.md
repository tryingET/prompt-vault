---
summary: "Prompt-vault side handoff for the vault-client relocation after the v2 facet cutover."
read_when:
  - "You need to understand what Prompt Vault already changed before porting vault-client to its new monorepo home."
  - "You are implementing Prompt Vault v2 support in the relocated vault-client package."
system4d:
  container: "Prompt Vault as ontology/data source; vault-client relocation handled elsewhere."
  compass: "Preserve v2 facet semantics while avoiding duplicate migration work in the wrong extension repo."
  engine: "Read this from prompt-vault, then switch to the canonical vault-client package location."
  fog: "The old standalone vault-client repo and active ~/.pi copy contain partial exploratory work that is not the long-term target."
---

# Prompt Vault → vault-client relocation interface handoff

## What is already true in Prompt Vault
The Prompt Vault v2 hard cutover is now real in this repo:

- `prompt_templates.type` has been removed from the live DB
- canonical ontology facets are now:
  - `artifact_kind`
  - `control_mode`
  - `formalization_level`
- live DB schema version is `3`
- seeded router prompts exist in the DB:
  - `analysis-router`
  - `post-review-router`
  - `review-closeout-router`
- those routers are seeded as:
  - `procedure / router / structured`
- ontology contract pack exists and is verified

## Files here that define the source-of-truth behavior
Read these in this repo:

1. `ontology/v2-contract.json`
2. `ontology/fixtures/prompt-templates/*.md`
3. `schema/schema.sql`
4. `migrations/003_hard_cut_prompt_facets.sql`
5. `scripts/pv`
6. `scripts/export-to-pi.sh`
7. `scripts/pv-verify-ontology-contract`
8. `tests/pv-ontology-contract.bats`
9. `tests/pv-v2-facets.bats`

## What changed at the Prompt Vault boundary
Any client integrating with Prompt Vault must now assume:

- schema version must be exactly `3` for the v2 facet-native client path
- queries must use facet fields instead of legacy `type`
- vocabulary/discovery surfaces must understand both:
  - ontology facets (`artifact_kind`, `control_mode`, `formalization_level`)
  - namespaced tags (`action:*`, `phase:*`, etc.)
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

Find the relocated `vault-client` package there and port the Prompt Vault v2 behavior into the new extension architecture.

## What to port conceptually, not mechanically
Port these behaviors into the relocated client:

- schema version fail-fast for Prompt Vault v2 (`version = 3`)
- facet-native template model
- facet-native `vault_query`
- facet-native `vault_retrieve`
- facet-native `vault_insert`
- facet-aware vocabulary output
- facet-aware picker/list/search/stats labels
- framework retrieval logic using `artifact_kind = cognitive`

Do **not** assume the old standalone client’s file boundaries or trigger integrations still exist.

## Cross-repo handoff
For the vault-client-specific relocation plan and warnings, read:

- `~/programming/pi-extensions/vault-client/docs/dev/prompt-vault-v2-relocation-handoff.md`

That file should be treated as the extension-side relocation note; this file is the Prompt Vault side of the boundary.

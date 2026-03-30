---
summary: "Historical vendored ROCS snapshot; Prompt Vault now uses the shared workspace core/rocs-cli runner instead."
read_when:
  - "You are checking why Prompt Vault no longer routes ROCS commands through a repo-local vendored tool."
  - "You found this vendored snapshot while tracing old ROCS history in Prompt Vault."
---

# Vendored rocs-cli snapshot (historical only)

This directory is no longer the active ROCS entrypoint for Prompt Vault.

Use the repo wrapper instead:

- `./scripts/rocs.sh --doctor`
- `./scripts/rocs.sh build --repo . --resolve-refs --clean`
- `./scripts/rocs.sh validate --repo . --resolve-refs`
- `./scripts/rocs.sh pack <ont_id> --repo . --resolve-refs`

Active contract:
- Prompt Vault delegates to the shared workspace package at `~/ai-society/core/rocs-cli`.
- `ontology/manifest.yaml` uses workspace-local ontology layer paths.
- Legacy `<gitlab:...>` ref locators are not part of the active Prompt Vault contract.

If you need the current ROCS command/reference surface, read:
- `~/ai-society/core/rocs-cli/README.md`

---
summary: "Manual navigation index for repo-local ontology assets."
read_when:
  - "Browsing ontology files manually"
  - "Finding bridge/concepts/manifest entrypoints"
---

# Ontology Index (repo)

Start here when browsing manually.

- `ontology/manifest.yaml` — which layers apply
- `ontology/v2-contract.json` — Prompt Vault v2 ontology contract and golden query expectations
- `ontology/fixtures/prompt-templates/` — seeded router fixtures for the v2 facet model
- `ontology/src/system4d.yaml` — repo-local System4D (implementation)
- `ontology/src/reference/concepts/` — repo-local concepts (only when needed)
- `ontology/src/bridge/mapping.yaml` — map concepts to code symbols
- `ontology/dist/` — generated artifacts (tool-first)

Tip: Use `uvx --from ./tools/rocs-cli rocs pack <concept_id>` instead of opening many files.

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
- `ontology/controlled-vocabulary-contract.json` — governed router semantics + semantic metamodel
- `ontology/company-visibility-contract.json` — owner/visibility governance boundary across companies
- prompt bodies are **not** part of ontology; inspect the canonical DB content with `./scripts/pv show template <name>` when you need seeded router text
- `ontology/src/system4d.yaml` — repo-local System4D (implementation)
- `ontology/src/reference/concepts/` — repo-local concepts (only when needed)
- `ontology/src/bridge/mapping.yaml` — map concepts to code symbols
- `ontology/dist/` — generated artifacts (tool-first)

Tip: Use `./scripts/rocs.sh pack <concept_id> --repo . --resolve-refs` instead of opening many files.

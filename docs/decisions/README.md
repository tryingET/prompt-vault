---
summary: "How to record project decisions (ADRs)."
read_when:
  - "When making a decision that should be durable"
---

# Decisions (ADRs)

## Key Decisions

See [CRYSTALLIZED.md](../CRYSTALLIZED.md) for the full set of patterns and design decisions.

| Decision | Rationale |
|----------|-----------|
| Dolt as database | Git-for-data semantics, per-entity versioning |
| JSON over CSV | CSV parsing fails on edge cases |
| Schema versioning | Enables safe migrations |
| No output capture | Privacy-first, optional future |
| [ADR-0001: Unified FZF Selection](./ADR-0001-unified-fzf-selection-ptx-vault-client.md) | Eliminate PTX/vault-client editor conflicts with shared fuzzy selection flow |

## Template

Use the core ADR template from `docs/_core/` for new decisions.

## Propagation

Decisions that apply to other projects should be proposed as TIPs.

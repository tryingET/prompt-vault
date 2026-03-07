---
summary: "Single registry for explicit deferral contracts (DRY source of truth)."
read_when:
  - "Deciding whether to defer a surfaced issue"
  - "Checking if any hardening contracts remain open"
---

# Deferred Contracts Registry

Canonical source for all deferred items in this repo.

## Policy
A deferral is valid only if it includes:
- rationale (why blocked)
- owner
- trigger to resume
- deadline/review date
- blast radius if missed

If this contract cannot be written, do not defer.

## Open Contracts

None.

## Closed Contracts

| ID | Item | Closed On | Evidence |
|---|---|---|---|
| DC-2026-03-04-01 | Vault-client hardening follow-up contract | 2026-03-04 | [[docs/dev/live-trigger-helper-validation-matrix.md]] |

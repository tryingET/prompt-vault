---
summary: "System4D: Fog (risks/assumptions/exceptions/debt) for this project."
read_when:
  - "When tracking uncertainty"
---

# System4D — Fog

## Risks

- Dolt not widely adopted — may have ecosystem gaps
- Single-user model limits team collaboration
- No output capture breaks full feedback loop

## Assumptions

- Users have Dolt installed
- Users are comfortable with SQL
- Templates are text-only (no binary assets)

## Exceptions

- Execution logs can grow unbounded (mitigated by `pv cleanup`)
- Large templates (>1MB) rejected at import

## Debt

| Item | Status |
|------|--------|
| HTTP API abstraction | Deferred until third client |
| Output capture | Planned |
| Rate limiting | Planned |
| Template validation | Planned |

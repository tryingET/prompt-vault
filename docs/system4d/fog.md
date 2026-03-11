---
summary: "System4D: Fog (risks/assumptions/exceptions/debt) for this project."
read_when:
  - "When tracking uncertainty"
---

# System4D — Fog

## Risks

- Dolt not widely adopted — may have ecosystem gaps
- Single-user model limits team collaboration
- Private execution outputs need explicit handling discipline to avoid accidental disclosure

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
| Rate limiting | Planned |
| Template validation | Planned |

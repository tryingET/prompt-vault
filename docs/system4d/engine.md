---
summary: "System4D: Engine (states/invariants/lifecycle) for this project."
read_when:
  - "When defining invariants and lifecycle"
---

# System4D — Engine

## Invariants

- Every template has unique `name`
- Every template has `status` (draft → active → deprecated → archived)
- Every execution references a valid template
- Schema version is tracked and migrations are explicit

## Lifecycle

```
Template: draft → active → deprecated → archived
Execution: created → (optional: rated)
```

## States

| Entity | States |
|--------|--------|
| prompt_templates | draft, active, deprecated, archived |
| executions | created |
| feedback | created |

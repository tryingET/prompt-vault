---
summary: "System4D: Container (boundary/constraints) for this project."
read_when:
  - "When scoping project work"
---

# System4D — Container

## Boundary

**In scope:**
- Template storage and versioning
- Execution tracking
- Feedback/ratings
- A/B testing via branches
- Multi-format export
- Pi integration

**Out of scope:**
- LLM execution (delegated to pi or other tools)
- Multi-tenant SaaS (for now)
- Web UI (future)

## Constraints

- Single-user local model (Dolt)
- bash-based CLI
- TypeScript extension for pi

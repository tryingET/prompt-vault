---
summary: "Tactical goals (current quarter)."
read_when:
  - "When planning sprints or weeks"
---

# Tactical Goals

## Q1 2026

### Completed
- [x] Deep review completed (v1.1.0)
- [x] Schema versioning added
- [x] JSON parsing (fixes CSV corruption)
- [x] Execution cleanup command
- [x] Documentation crystallized
- [x] LLM tools for autonomous vault access (v1.2.0)
- [x] Tag vocabulary for all templates
- [x] `pv vocabulary` command

### In Progress
- [ ] Add output capture to executions (with privacy flag)
- [ ] Add rate limiting to extension
- [ ] Set up DoltHub remote

### Planned
- [ ] Build quality dashboard
- [ ] Template validation at import ($VAR syntax)
- [ ] HTTP API for third-party clients
- [ ] Enhance `vault-stats` to show full metrics:
  - Per-template: avg rating, success rate, avg latency, token usage
  - Tag-based: most used tags, best rated tags
  - Trend: rating over time, usage patterns
  - Health: low-rated templates, high errors, unused templates
- [ ] **Resolve ptx autocomplete conflict:** Update prompt-template-accelerator to use the autocomplete wrapper registry pattern (see `~/.pi/agent/extensions/vault-client/autocompleteRegistry.ts`)

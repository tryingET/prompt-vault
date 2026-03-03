---
summary: "Current project status."
read_when:
  - "When checking project health"
---

# Status

**Last Updated:** 2026-03-03

## Health

| Metric | Status |
|--------|--------|
| Verification | ✅ 34/34 checks pass |
| Templates | 50 (30 cognitive, 20 task) |
| Tagged | 50/50 (100%) |
| Schema Version | 1 |
| Extension | ✅ 5 LLM tools + human commands |

## Recent Changes

- **Unified selector transition (slice 4 complete)** — ADR-0001 slices 0-4 implemented across PTX + vault-client (fzf-ranked fuzzy selector, deterministic fallback, editor-conflict pathways removed)
- **Validation evidence captured** — `docs/dev/fzf-spike-slice0.md`, `docs/dev/slice4-validation-matrix.md`
- **v1.2.0** — LLM tools, tag vocabulary, pv-tag-templates
- **v1.1.0** — Deep review fixes (CSV→JSON, schema versioning, escaping)

## Blockers

None currently.

## Dependencies

- Dolt 0.40+
- bash 4.0+
- jq
- pi (for extension)

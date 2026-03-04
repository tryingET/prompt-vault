---
summary: "Current project status."
read_when:
  - "When checking project health"
---

# Status

**Last Updated:** 2026-03-04

## Health

| Metric | Status |
|--------|--------|
| Verification | ✅ 34/34 checks pass |
| Templates | 50 (30 cognitive, 20 task) |
| Tagged | 50/50 (100%) |
| Schema Version | 1 |
| Extension | ✅ 5 LLM tools + human commands |
| Vault Recovery | ✅ archive restore + session refinements reapplied |

## Recent Changes

- **Live trigger helper rewrite complete** — `pi-input-triggers` now owns and exports a reusable interaction helper (live matching/debounce/backspace-safe cancellation/fuzzy ranking/picker UI), and `vault-client` registers `/vault:` via that helper with `::context` parsing, non-TTY fallback, and telemetry hooks.
- **Validation matrix captured** — [[docs/dev/live-trigger-helper-validation-matrix.md]] is the canonical evidence record for lint/typecheck/tests + runtime checks.
- **Vault selector UX polish** — `/vault` now surfaces full picker inventory, `/vault:<query>` uses full suffix (not first-token only), explicit `::` context separator added, picker title exposes ranking mode/count, `/vault-browse` presents a visible ranked browser before selection, and optional live `/vault:` typing trigger is integrated via `pi-input-triggers`.
- **Vault-client hardening closeout complete** — Post-`/reload` runtime checks confirmed `vault_query` low-limit keyword lookup (`meta-orchestration`, `limit=5`) and explicit backend failure signaling (`Vault query failed: ...` / `Vault search failed: ...`). See [[docs/dev/live-trigger-helper-validation-matrix.md]].
- **Vault recovery checkpoint complete** — Canonical `prompt-vault-db` restored from archive, namespaced tags rebuilt for all 50 templates, and `next-10-expert-suggestions` framework-grounding refinements recovered from session history.
- **Unified selector transition (slice 4 complete)** — ADR-0001 slices 0-4 implemented across PTX + vault-client (fzf-ranked fuzzy selector, deterministic fallback, editor-conflict pathways removed)
- **Validation evidence captured** — `docs/dev/fzf-spike-slice0.md`, `docs/dev/slice4-validation-matrix.md`
- **v1.2.0** — LLM tools, tag vocabulary, pv-tag-templates
- **v1.1.0** — Deep review fixes (CSV→JSON, schema versioning, escaping)

## Deferred Contracts

See canonical registry: [[docs/dev/deferred-contracts.md]]

## Blockers

None currently.

## Dependencies

- Dolt 0.40+
- bash 4.0+
- jq
- pi (for extension)

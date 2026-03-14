---
summary: "Current project status."
read_when:
  - "When checking project health"
---

# Status

**Last Updated:** 2026-03-14

## Health

| Metric | Status |
|--------|--------|
| Verification | ✅ 40/40 checks pass |
| Templates | 82 total (81 active; 32 cognitive, 49 procedure) |
| Controlled vocabulary | 4 active controlled-vocabulary templates |
| Company visibility boundary | 7 governed companies |
| Schema Version | 9 |
| Extension | ✅ current monorepo vault-client package + diagnostics/query/mutation/execution tools |
| Vault Recovery | ✅ archive restore + session refinements reapplied |

## Recent Changes

- **Quality rollups landed** — `pv quality rollup <dimension>` now provides aggregate-only quality/evidence reporting by governed template facet (`artifact_kind`, `control_mode`, `formalization_level`, `owner_company`) without widening raw-output exposure.
- **Quality evidence coverage landed** — `pv quality coverage` now shows per-entity feedback/capture rates, `pv quality dashboard` surfaces the biggest evidence gaps, and template/skill quality views expose richer capture-aware coverage without rendering raw output text.
- **QUICKSTART schema-v9 alignment landed** — quickstart guidance now reflects governed vocabulary, current `/vault` command semantics, privacy-safe output capture, and no longer describes legacy tags or `/vaults`.
- **Analytics + quality hardening landed** — `pv analytics` / `pv quality` now fail closed on bad subcommands and injected names, quality scoring no longer depends on external `bc`, overview uses typed entity identity, and public previews strip ANSI/control escapes before rendering.
- **Safe output-capture analytics landed** — `pv analytics outputs` now summarizes capture coverage by entity, `pv analytics recent` includes capture mode + output length, `pv analytics template <name>` shows capture evidence, and only explicitly public captures render text previews.
- **Execution output capture added in schema v9** — `executions` now records `output_capture_mode` (`none`/`private`/`public`) plus optional `output_text`, and `pv-exec` supports `--output-file` / `--output-text` with privacy-defaulted capture and explicit public opt-in.
- **Feedback uniqueness preserved into schema v9** — `feedback.execution_id` remains unique at the DB layer, and downstream clients should continue to bind ratings to exact execution rows.
- **Vault-client schema-v9 alignment complete** — the canonical client now expects schema `9`, understands execution output capture columns, and exposes detailed diagnostics rather than only a boolean startup gate.
- **Diagnostic-mode startup now exists in the client** — on schema mismatch, the client can still expose `/vault-check` and `vault_schema_diagnostics()` while gating risky query/mutation surfaces.
- **Current live selector contract** — `/vault` opens the full visible picker, `/vault <exact-name>` exact-loads, and live `/vault:` uses the shared interaction runtime with explicit `::context` support; `/vault-browse` is no longer part of the current client contract.
- **Prompt Vault hard cutover is complete** — live schema is facet-native (`artifact_kind`, `control_mode`, `formalization_level`), legacy `prompt_templates.type` is gone, and the three router exemplars are seeded as `procedure / router / structured`.
- **Company visibility boundary complete** — Prompts and skills now carry `owner_company` + `visibility_companies`, with `core` artifacts visible across all governed companies by default.
- **Tag hard cut complete** — Free-form prompt tags were removed from schema and governed router prompts; governed semantics now live only in facets + controlled vocabulary.
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

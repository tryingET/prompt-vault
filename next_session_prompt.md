---
summary: "Post-cleanup handoff: docs are strict-compliant and DRY; continue source-first extension work only if new runtime issues appear."
read_when:
  - "Starting the next session in prompt-vault"
  - "Before editing vault-client or pi-input-triggers again"
system4d:
  container: "Prompt-vault docs normalized; selector/hardening contracts currently closed"
  compass: "Preserve DRY docs + source-first extension workflow"
  engine: "Validate first, then patch minimally, then re-validate"
  fog: "Terminal-specific key behavior can still vary by emulator"
---

# Next Session Prompt — Stable Baseline

## Current baseline

- Docs metadata strict check passes:
  - `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`
- DRY canonical references established:
  - Validation evidence: [[docs/dev/live-trigger-helper-validation-matrix.md]]
  - Deferred contracts: [[docs/dev/deferred-contracts.md]]
- Redundant selector draft docs removed; cross-doc duplication reduced.

## If no new bug report arrives

1. Do not churn extension code.
2. Keep docs updates link-first (canonical source + `[[...]]` references).
3. Maintain diary entries for any non-trivial change.

## If a new `/vault:` or selector issue appears

1. Reproduce with terminal details (`echo $TERM`, key sequence, path to failure).
2. Edit source repos first:
   - `~/programming/pi-extensions/pi-input-triggers`
   - `~/programming/pi-extensions/vault-client`
3. Sync source -> runtime copies:
   - `~/.pi/agent/extensions/pi-input-triggers`
   - `~/.pi/agent/extensions/vault-client`
4. Re-run validation and record evidence in:
   - [[docs/dev/live-trigger-helper-validation-matrix.md]]
   - `diary/YYYY-MM-DD--...md`

## Guardrails

- Source-first edits only (never start from runtime copies).
- Prefer minimal, reversible patches.
- No duplicated numeric validation claims across docs; link to canonical evidence instead.
- Track any new deferral only in [[docs/dev/deferred-contracts.md]] with full contract fields (rationale, owner, trigger, deadline, blast radius).

---
summary: "Completed Prompt Vault task #245 by clarifying the repo-side boundary versus shared runtime registry discovery and exported prompt execution observability."
read_when:
  - "You are resuming after task #245 in prompt-vault."
  - "You need the exact Prompt Vault-side authority split between stored execution observability and runtime-local receipt/telemetry surfaces."
system4d:
  container: "Repo-local diary capture for the shared runtime registry / observability boundary slice."
  compass: "Keep Prompt Vault authoritative for stored execution truth, keep registry bridges projection-only, and keep privacy posture explicit."
  engine: "Confirm dependency cleared -> author boundary note -> align orientation/handoff docs -> validate -> close task."
  fog: "Main risk is conflating DB-backed execution observability with package-local receipts or live runtime registry discovery."
---

# 2026-03-22 — Shared runtime registry and execution-observability boundary

## What changed
- Added `docs/dev/shared-runtime-registry-and-execution-observability-boundary.md`
- Updated `README.md` to point operators at the new boundary note and summarize the authority split
- Updated `docs/dev/vault-client-relocation-interface.md` and `docs/dev/v4-prompt-authoring-review-input-boundary.md` so the new note is part of the Prompt Vault-side boundary chain
- Updated `docs/project/operating_plan.md` and `next_session_prompt.md` so task `#245` is no longer described as blocked/pending

## Boundary codified
The Prompt Vault-side rule is now explicit:

- Prompt Vault canonically exports stored prompt execution observability through schema-owned execution/feedback facts and privacy-safe aggregate analytics
- `pi-vault-client` remains the canonical home for local execution receipts, replay, and live trigger telemetry
- shared runtime registry entries are process-local discovery/projection surfaces, not durable Prompt Vault authority

## Why this mattered
Recent pi-runtime-registry work made it easier for operators to discover receipt and telemetry accessors in-process.
Without a Prompt Vault-side note, that convenience layer could be misread as if Prompt Vault had widened its own exported observability surface or runtime ownership.

The new note keeps these concerns separate:

- stored DB-backed execution truth stays in Prompt Vault
- package-local receipt/replay truth stays in `pi-vault-client`
- registry discovery stays non-authoritative
- private captured output remains non-previewable by default unless an explicit public boundary says otherwise

## Validation
- `./verify.sh`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## Next move
- Re-check AK for the next repo-local Prompt Vault slice instead of inferring a follow-up from this boundary doc alone.
- Do not reopen task `#245` unless the actual ownership/export/privacy boundary changes again.

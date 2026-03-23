---
summary: "Reassessed Prompt Vault after the completed TG4 wave, promoted TG2 locally, and hardened ontology verification so prompt bodies stay DB-only."
read_when:
  - "Reviewing how Prompt Vault moved from the completed router-semantic reporting wave into TG2 boundary hardening"
  - "Checking why AK task #264 exists and what it changed"
date: "2026-03-23"
---

# 2026-03-23 — ontology boundary verification hardening

## Scope
- Reassess the next repo-local Prompt Vault slice from AK after the completed router-semantic/privacy wave.
- Promote a bounded TG2 follow-through instead of replaying finished work.
- Harden deterministic verification around the DB-vs-ontology authoring boundary.

## Evidence
- `next_session_prompt.md`
- `README.md`
- `docs/project/tactical_goals.md`
- `docs/project/operating_plan.md`
- `ontology/index.md`
- `scripts/pv-verify-ontology-contract`
- `tests/pv-ontology-contract.bats`
- `ak task list -F json --verbose`
- `ak task ready -F json`

## What I Did
- Confirmed from AK that the recent Prompt Vault tasks `#245`, `#246`, `#247`, and `#248` were complete and that no new repo-local ready task already existed.
- Created and claimed repo-local AK task `#264` for the next bounded follow-through: keeping prompt bodies out of ontology/contracts.
- Hardened `scripts/pv-verify-ontology-contract` so it now:
  - accepts override paths for focused testing
  - rejects extra seed metadata keys such as prompt-body fields
  - rejects multiline/oversized seed `purpose` values that look like prompt-body leakage
  - verifies the ontology index keeps the DB-only authoring boundary explicit
  - rejects extra metadata keys in controlled-vocabulary and company fixture expectations
- Expanded `tests/pv-ontology-contract.bats` with focused regression coverage for prompt-body key leakage and ontology-index boundary drift.
- Refreshed `README.md`, `docs/project/tactical_goals.md`, `docs/project/operating_plan.md`, and `next_session_prompt.md` so the active tactical reality now points to TG2 boundary hardening rather than the completed TG4 wave.

## Interpretation
- Prompt Vault now has a deterministic guardrail against the specific drift called out repeatedly in docs and handoffs: prompt bodies leaking back into ontology-shaped surfaces.
- The direction cascade is truthful again: TG4 is treated as complete, TG2 is active, and the finished local slice is linked to an explicit AK task.
- The next session should not infer another automatic task from this note; it should go back to AK + current docs and reassess the next repo-local slice.

## Crystallization Candidates
- → docs/learnings/ if "promote the next tactical goal, materialize it in AK, and harden the deterministic verifier in the same pass" becomes a repeatable repo-governance pattern

---
summary: "Promoted SG2 locally by adding a governed company-visibility quality rollup with focused privacy-safe validation and truthful docs/handoff updates."
read_when:
  - "Reviewing how Prompt Vault moved from the completed SG1/TG3 wave into the first SG2 privacy-safe evidence slice"
  - "Checking why AK task #270 exists and what it changed"
date: "2026-03-23"
---

# 2026-03-23 — visibility_companies quality rollup

## Scope
- Reassess Prompt Vault after the completed SG1/TG3 procedure-layer wave.
- Promote the first bounded SG2 follow-through instead of replaying finished work.
- Add a privacy-safe aggregate evidence surface for governed company visibility.

## Evidence
- `README.md`
- `docs/project/strategic_goals.md`
- `docs/project/tactical_goals.md`
- `docs/project/operating_plan.md`
- `next_session_prompt.md`
- `ontology/company-visibility-contract.json`
- `scripts/pv-quality`
- `tests/pv-quality.bats`
- `tests/pv-commands.bats`
- `./scripts/pv quality rollup visibility_companies`
- `./scripts/pv-bats tests/pv-quality.bats`
- `./scripts/pv-bats tests/pv-commands.bats`
- `./verify.sh`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## What I Did
- Confirmed from current docs and AK task state that Prompt Vault had no new repo-local ready task after completed tasks `#245`, `#246`, `#247`, `#248`, `#264`, and `#265`.
- Noted that plain `ak` on `PATH` currently fails against `~/ai-society/society.v2.db` due to schema drift, then used the vendored Agent Kernel CLI from `softwareco/owned/agent-kernel` to keep repo-local tasking truthful.
- Created and claimed repo-local AK task `#270` for the first SG2 slice: aggregate-only quality/evidence rollups by `visibility_companies`.
- Extended `scripts/pv-quality` so `rollup visibility_companies` now reads governed company buckets from `ontology/company-visibility-contract.json` and counts each active template in every governed visibility bucket it declares.
- Kept the surface aggregate-only so private captured output remains summarized and non-previewable.
- Added focused bats coverage for privacy posture, governed multi-bucket counting, and the top-level `pv quality rollup visibility_companies` command path.
- Refreshed `README.md`, `docs/project/strategic_goals.md`, `docs/project/tactical_goals.md`, `docs/project/operating_plan.md`, and `next_session_prompt.md` so the direction cascade now points at SG2/TG5 instead of the completed SG1/TG3 wave.

## Interpretation
- Prompt Vault now exposes another privacy-safe aggregate evidence surface aligned to a governed contract dimension that downstream consumers already rely on: company visibility.
- The repo direction cascade is truthful again: SG1 is treated as materially complete, SG2 is active, and the first bounded SG2 slice is linked to explicit AK coverage.
- The next session should not assume an automatic follow-up task; it should go back to AK + current docs and reassess the next repo-local slice.

## Crystallization Candidates
- → `docs/learnings/` if governed multi-valued rollups beyond router semantics become a recurring design pattern
- → Agent Kernel / workflow docs if the vendored-AK fallback becomes the standard temporary operator path during PATH-binary schema drift

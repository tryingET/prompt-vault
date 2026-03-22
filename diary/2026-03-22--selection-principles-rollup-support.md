---
summary: "Shipped aggregate-only selection_principles rollups in pv-quality, added focused multi-valued/privacy tests, and refreshed repo docs/handoff for the completed router-semantic reporting wave."
read_when:
  - "Reviewing how Prompt Vault completed AK tasks #247, #248, and #246."
  - "Checking why selection_principles now appears as a governed pv-quality rollup dimension."
date: "2026-03-22"
---

# 2026-03-22 — selection_principles rollup support

## Scope
- Complete the active Prompt Vault operating wave for aggregate-first router-semantic reporting:
  - `#247` — add aggregate-only `selection_principles` rollup support to `pv-quality`
  - `#248` — add focused validation for multi-valued router-semantic rollups and privacy boundaries
  - `#246` — refresh docs and handoff for the shipped surface

## Evidence
- `./scripts/pv-bats tests/pv-quality.bats`
- `./scripts/pv-bats tests/pv-commands.bats`
- `./scripts/pv-verify-ontology-contract`
- `./verify.sh`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## What I Did
- Extended `scripts/pv-quality` so `pv quality rollup selection_principles` aggregates by each governed selection principle even though the underlying router metadata is multi-valued.
- Kept the rollup router-only and aggregate-only; no raw private output text is rendered.
- Added focused tests for:
  - private-output non-leakage in the new rollup
  - multi-bucket contribution when one router declares multiple selection principles
  - fail-closed router-only filtering for non-router templates carrying matching JSON keys
  - CLI coverage for the new dimension
- Refreshed README, operating-plan, and handoff docs so they describe the shipped surface rather than the pre-implementation plan.

## Interpretation
- This closes the repo-local router-semantic reporting wave named in the handoff and operating plan.
- Multi-valued governed router semantics can now be inspected from `pv-quality` without inventing a raw-output dashboard or weakening the privacy boundary.
- The next session should reassess the next repo-local slice from AK instead of replaying `#247`/`#248`/`#246`.

## Crystallization Candidates
- → `docs/CRYSTALLIZED.md` if multi-valued governed rollups become a recurring pattern worth naming explicitly
- → future Prompt Vault/client boundary notes if downstream consumers start depending on aggregate-only multi-valued router-semantic reporting

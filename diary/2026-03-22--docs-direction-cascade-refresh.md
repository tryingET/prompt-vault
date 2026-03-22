---
summary: "Reframed Prompt Vault vision/strategy around schema-v9 governed prompt-authoring reality and added the missing tactical-goals layer."
read_when:
  - "Reviewing why docs/project/vision.md and strategic goals changed on 2026-03-22"
  - "Checking how the repo's direction cascade was refreshed after task #87"
date: "2026-03-22"
---

# 2026-03-22 — direction cascade refresh

## Scope
- Refresh stale project-direction docs so they reflect current Prompt Vault reality.
- Add the missing `docs/project/tactical_goals.md` layer.

## Evidence
- `README.md`
- `next_session_prompt.md`
- `docs/dev/v4-prompt-authoring-review-input-boundary.md`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## What I Did
- Rewrote `docs/project/vision.md` around Prompt Vault as the governed prompt-authoring substrate.
- Replaced the older generic strategic-goal list with 2 ranked strategic goals aligned to current repo truth.
- Added `docs/project/tactical_goals.md` for the active strategic goal.
- Updated `docs/project/model.md` so the direction cascade links to tactical goals explicitly.

## Interpretation
- The old strategy docs were stale because they still centered speculative expansion (for example multi-tenant / dashboards) over the repo's current strongest reality: governed prompt authoring, privacy-safe evidence, and clean downstream boundaries.
- The new direction surfaces should reduce false signals when AK has little or no repo-local pending work.

## Crystallization Candidates
- → docs/learnings/ if direction-cascade refresh becomes a recurring repo-governance pattern
- → a future operating-plan surface once the next active tactical slice is chosen and materialized cleanly

---
summary: "DRY cleanup of overlapping selector/runtime docs and normalization to canonical validation evidence."
read_when:
  - "Reviewing why overlapping selector docs were removed"
  - "Auditing DRY normalization decisions from 2026-03-04"
date: "2026-03-04"
---

# Diary — Docs DRY Cleanup

## Actions
- Removed redundant/contradictory draft docs:
  - `docs/dev/IMPLEMENTATION_COMPLETE.md`
  - `docs/dev/tree-selector-alignment-architecture.md`
  - `docs/dev/tree-selector-deep-review.md`
  - `docs/dev/tree-selector-implementation-summary.md`
- Normalized verification references to canonical source:
  - `docs/dev/status.md` now points to [[docs/dev/live-trigger-helper-validation-matrix.md]]
  - `next_session_prompt.md` now points to [[docs/dev/live-trigger-helper-validation-matrix.md]] and avoids duplicated numeric test counts
- Fixed stale troubleshooting example:
  - `docs/reference/fuzzy-selector-troubleshooting.md` now uses generic `mode=fzf [visible/total]`

## Rationale
- Reduce drift and contradictory test-count claims across files.
- Keep evidence in one place, with other docs linking to it.

## Follow-up
- If desired: apply the same DRY pattern to changelog/status language whenever validation numbers are mentioned.

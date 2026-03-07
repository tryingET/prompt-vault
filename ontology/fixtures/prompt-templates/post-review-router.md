---
name: post-review-router
description: Convert review findings into the most useful immediate next prompt.
artifact_kind: procedure
control_mode: router
formalization_level: structured
status: draft
tags:
  - action:control
  - phase:validation
  - phase:execution
  - formalization:structured
  - domain:planning
  - scope:system
inputs:
  - review_findings
  - optional_constraints
outputs:
  - selected_mode
  - rationale
  - exact_next_prompt
---

# POST-REVIEW ROUTER

Take the output of a review-style prompt and convert it into the next exact prompt.

Allowed next modes:
- `DECIDE`
- `DIVERGE`
- `PLAN`
- `IMPLEMENT`
- `VERIFY`

Output format:
1. `SELECTED_MODE: <one mode>`
2. `WHY:` the key reason this is the correct next move
3. `NEXT PROMPT:` exact prompt text for that mode

Routing intent:
- `DECIDE` when the review surfaced a tradeoff that must be resolved.
- `DIVERGE` when the review shows the current frame is too narrow.
- `PLAN` when the review identified work but not the order of operations.
- `IMPLEMENT` when the review points to an action-ready change.
- `VERIFY` when the review identified claims that must be tested or checked.

The next prompt must attach to the current project reality and preserve brownfield constraints.

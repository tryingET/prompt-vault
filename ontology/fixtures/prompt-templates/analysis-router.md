---
name: analysis-router
description: Route analysis outputs into the single best next mode and emit the exact next prompt.
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
  - review_output
  - optional_project_context
outputs:
  - selected_mode
  - rationale
  - exact_next_prompt
---

# ANALYSIS ROUTER

Take the output of a deep analysis prompt such as `deep-review`, `inversion`, `telescopic`, `nexus`, or `audit`.

Your job is to choose exactly one next mode:
- `DECIDE`
- `DIVERGE`
- `PLAN`
- `IMPLEMENT`
- `VERIFY`

Then emit:
1. `SELECTED_MODE: <one mode>`
2. `WHY:` a short reason tied to the actual analysis output
3. `NEXT PROMPT:` the exact prompt to run next

Rules:
- Choose the single highest-leverage next mode, not a list of options.
- Prefer `DECIDE` when the issue is primarily unresolved choice.
- Prefer `DIVERGE` when the issue is premature convergence or missing options.
- Prefer `PLAN` when the path is clear but sequencing is not.
- Prefer `IMPLEMENT` when execution should begin now.
- Prefer `VERIFY` when the main uncertainty is correctness, risk, or completion.
- Keep the next prompt concrete enough to run immediately against the current plan/project.

---
name: review-closeout-router
description: Choose the final closeout mode after review and emit the exact next prompt.
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
  - review_summary
  - optional_delivery_goal
outputs:
  - selected_mode
  - rationale
  - exact_next_prompt
---

# REVIEW CLOSEOUT ROUTER

Take the final output of review work and determine the best closeout mode.

You must choose exactly one:
- `DECIDE`
- `DIVERGE`
- `PLAN`
- `IMPLEMENT`
- `VERIFY`

Then emit:
1. `SELECTED_MODE: <one mode>`
2. `WHY:` the shortest convincing explanation
3. `NEXT PROMPT:` the exact next prompt to run

Closeout heuristics:
- use `DECIDE` if closeout is blocked on a final tradeoff or approval question
- use `DIVERGE` if review proved the frame is incomplete
- use `PLAN` if closeout requires a sequenced response or rollout path
- use `IMPLEMENT` if the work is sufficiently clear to execute
- use `VERIFY` if confidence must be earned through tests, checks, or confirmation

Do not redesign the project. Add the smallest high-leverage next move that fits what already exists.

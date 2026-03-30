---
summary: "Scored backlog and safe local draft artifacts for refreshing exported high-concept prompts."
read_when:
  - "Reviewing the 2026-03-30 prompt refresh planning pass for telescopic, temporal-degradation, and transcendent-iteration."
  - "Looking for non-destructive draft direction before shared vault prompt edits."
type: "diary"
---

# 2026-03-30 — prompt refresh backlog and safe draft artifacts

## Why
Reviewed the Pi-exported prompts `telescopic`, `temporal-degradation`, and `transcendent-iteration` after exporting them from Prompt Vault. They are strong conceptually, but they still read like earlier-generation prompts: high signal, lighter execution contract.

This note captures a scored backlog plus non-destructive draft direction before any shared vault mutation.

## Candidate tasks

| Task | I | U | D | Quadrant | Notes |
|------|---|---|---|----------|-------|
| Refresh `telescopic` with grounding/evidence mode | 5 | 4 | 2 | Q1 | Highest-value reliability fix |
| Add mode selector to `telescopic` (`code-review|architecture|plan-review`) | 4 | 3 | 2 | Q2 | Reduces invocation ambiguity |
| Replace `underground-time` ranking dependency in `telescopic` with explicit fallback | 4 | 4 | 2 | Q1 | Prevents misuse outside blame-grounded review |
| Add artifact-type calibration to `temporal-degradation` | 5 | 4 | 2 | Q1 | Time-failure shape differs by artifact |
| Add prioritization table to `temporal-degradation` | 4 | 3 | 1 | Q2 | Converts projections into action |
| Normalize `temporal-degradation` formatting / nested fences | 3 | 3 | 1 | Q2 | Small clarity win |
| Add explicit phase semantics to `transcendent-iteration` | 5 | 3 | 3 | Q2 | Clarifies analyze vs execute vs verify |
| Add fail-closed missing-tool behavior to `transcendent-iteration` | 5 | 4 | 2 | Q1 | Important for runtime safety |
| Split `transcendent-iteration` into short invocation + long contract | 4 | 2 | 3 | Q2 | Better operator ergonomics |
| Create a reusable retrofit checklist for older prompts | 5 | 4 | 1 | Q1 | Reusable across exported prompts |
| Run comparative prompt eval on refreshed variants | 4 | 2 | 3 | Q2 | Best after drafting |
| Update vault + export + reload once drafts are accepted | 5 | 3 | 2 | Q2 | Rollout step, not first move |

## Draft update suggestions

### `telescopic`
Add:
- a scope line clarifying whether the task is grounded review or abstract analysis
- a rule: concrete bug claims require inspected evidence; otherwise label as hypothesis
- a fallback ranking mode when blame/time data is unavailable
- optional invocation modes:
  - `code-review`
  - `architecture`
  - `plan-review`

Minimal draft direction:

```md
Scope: use for simultaneous micro/macro analysis of code, architecture, or plans.
If repo state was inspected, ground concrete defect claims in cited files/lines.
If evidence was not inspected, label concrete failure claims as hypotheses.

Rank by:
- grounded review: severity × underground-time × fix-compound-value
- ungrounded analysis: severity × recurrence-risk × fix-leverage
```

### `temporal-degradation`
Add:
- first-step artifact calibration (`prompt|runtime|codebase|process|docs`)
- explicit early-warning signals
- a prioritization table for present-day actions
- cleaner formatting without nested fences

Minimal draft direction:

```md
Before projecting, classify the artifact under review:
- prompt
- runtime
- codebase
- process
- documentation

For each horizon, include:
- failing assumption
- visible consequence
- earliest warning signal

## Prevention Priorities
| Risk | Horizon | Early Signal | Preventive Move | Priority |
```

### `transcendent-iteration`
Add:
- phase tags: thinking / execution / judgment gate
- explicit unavailable-tool fallback rule
- clearer distinction between conceptual loop and runner contract

Minimal draft direction:

```md
If a named tool/framework is unavailable, either:
1. substitute the nearest grounded equivalent and say so, or
2. stop and report the missing dependency

Tag each phase as:
- THINK
- TRANSFORM
- VERIFY
- RECORD
```

## Safe leaves executed now
- Created `docs/dev/prompt-retrofit-checklist.md`
- Created this diary note as local execution memory

## Deferred until explicit approval
- shared Prompt Vault content updates
- prompt export rerun after content mutation
- Pi `/reload` as rollout validation

## Validation to run after shared updates
- `./scripts/pv show template telescopic`
- `./scripts/pv show template temporal-degradation`
- `./scripts/pv show template transcendent-iteration`
- `./scripts/export-to-pi.sh`
- verify via Pi RPC `get_commands` or interactive `/reload`

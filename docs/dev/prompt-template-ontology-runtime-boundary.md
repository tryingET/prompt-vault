---
summary: "Clarifies Prompt Vault template ontology terms that are easy to confuse with runtime sessions, workflow executors, and orchestration bindings."
read_when:
  - "Deciding whether a Prompt Vault template should use artifact_kind=session"
  - "Clarifying whether formalization_level=workflow implies workflow_execute"
  - "Designing vault-client or orchestrator dispatch from Prompt Vault metadata"
system4d:
  container: "Prompt Vault template ontology versus runtime execution surfaces."
  compass: "Keep reusable prompt artifacts, runtime sessions, forensic evidence, and executor bindings separate."
  engine: "Name the artifact -> name the control topology -> name the representation grade -> require an explicit execution binding before automatic runtime dispatch."
  fog: "Ambiguous names such as workflow or session can make retrieval look like execution, or make forensic logs look like canonical template/runtime truth."
---

# Prompt Template Ontology / Runtime Boundary

## Purpose

This note clarifies two Prompt Vault terms whose plain-language meanings overlap with runtime concepts:

- `formalization_level=workflow`
- `artifact_kind=session`

It also names the missing middle concept needed for safe automatic execution:

- `execution_binding` / `orchestration_contract`

Prompt Vault currently stores reusable prompt artifacts and governed metadata. It does not yet store a machine-readable binding from each template to a Pi/orchestrator executor such as `loop_execute` or `workflow_execute`.

For the separate question of whether an active export-enabled template has actually been materialized into local Pi prompt files, read [Pi Export Projection Boundary](./pi-export-projection-boundary.md).

## Current schema facts

Current Prompt Vault template facets are:

```text
artifact_kind: cognitive | procedure | session
control_mode: one_shot | router | loop
formalization_level: napkin | bounded | structured | workflow
```

These facets answer different questions:

| Facet | Question | Example answer |
|---|---|---|
| `artifact_kind` | What kind of reusable prompt artifact is this? | `procedure` |
| `control_mode` | What control topology does the prompt impose? | `loop` |
| `formalization_level` | How completely is the prompt specified as an artifact? | `workflow` |

They do **not** answer:

```text
Which runtime executor must run this template?
```

That answer needs a separate execution binding.

## `workflow` means workflow-grade specification

In the current schema, `formalization_level=workflow` means:

```text
This prompt is specified at workflow-grade detail.
```

It does **not** by itself mean:

```text
Call workflow_execute(...).
```

Reason: current DB usage includes workflow-grade templates whose runtime shape differs:

- cognitive review stacks such as `deep-review`
- one-shot operational procedures such as release or documentation flows
- loop procedures such as `transcendent-iteration`

A loop-shaped workflow-grade template should route by its control topology and explicit execution binding, not by the word `workflow` alone.

## `session` is reserved until positively defined

`artifact_kind=session` exists in the schema for compatibility with the legacy `type=session` axis, but current Prompt Vault docs and DB rows do not define a stable positive use. Do not use it for any of these:

- a live Pi or orchestrator session
- a Pi session JSONL file
- a transcript or raw conversation log
- an execution receipt
- a diary entry
- a KES learning
- an evidence-promotion ledger row
- one-off session context, task ids, or runtime state

Those are runtime events, forensic evidence, curated knowledge artifacts, or authority records. They are not reusable Prompt Vault template kinds.

Until the ontology introduces a narrower term, classify reusable session-related prompts as `artifact_kind=procedure` when they prescribe action. Examples:

```text
repo-next-session -> procedure / one_shot / workflow
session-closeout-capture prompt -> procedure unless explicitly redefined as a session scaffold
```

If a future positive category is needed, prefer a less ambiguous name such as:

```text
session_scaffold
session_context_template
session_handoff_template
```

and define it before creating rows.

## Runtime execution is a separate occurrence

A Prompt Vault template is an information artifact. A runtime execution is an event/occurrence. A session may be a runtime container for such events. A session JSONL file is forensic evidence about the occurrence.

Keep these distinct:

| Thing | Ontological role | Prompt Vault facet today |
|---|---|---|
| Prompt markdown | reusable information artifact | row `content` |
| Cognitive/procedure classification | artifact kind | `artifact_kind` |
| One-shot/router/loop topology | process/control type | `control_mode` |
| Napkin/bounded/structured/workflow grade | representation quality | `formalization_level` |
| Binding to `loop_execute` / `workflow_execute` | runtime relator | not modeled yet |
| Actual run | execution occurrence | `executions` row or runtime receipt |
| Live Pi session | runtime container/context | not a Prompt Vault template |
| Pi session JSONL | forensic evidence | not a Prompt Vault template |

## Dispatch implication

When an operator asks to inspect, list, compare, or explain templates, retrieval-only behavior is lawful.

When an operator asks to use, run, apply, execute, continue, or improve with a template:

1. `control_mode=loop` must enter an orchestrator loop gate.
2. `formalization_level=workflow` must enter an orchestrator dispatch/gating path.
3. Neither condition should silently degrade to text-only assistant interpretation.
4. If no explicit execution binding exists, the runtime should fail closed or ask for a binding/safe synthesized plan.

For example:

```text
transcendent-iteration
  artifact_kind=procedure
  control_mode=loop
  formalization_level=workflow
```

should bind to a loop executor, e.g.:

```text
loop_execute(loop="transcendent", objective=<operator objective>)
```

not to generic `workflow_execute` solely because its formalization level is `workflow`.

## Needed future field

The missing schema/runtime concept is an explicit binding, for example:

```json
{
  "execution_required": true,
  "execution_surface": "loop_execute",
  "execution_args": {
    "loop": "transcendent"
  },
  "on_missing_binding": "fail_closed"
}
```

For generic executor workflows:

```json
{
  "execution_required": true,
  "execution_surface": "workflow_execute",
  "execution_args": {
    "mode": "chain"
  },
  "on_missing_binding": "fail_closed"
}
```

Do not overload `formalization_level`, `artifact_kind`, owner company, visibility, or prompt names to carry this binding.

## Practical rule

Use the existing facets this way:

- use `artifact_kind=procedure` for reusable action procedures, including session-start or session-closeout procedures
- use `control_mode=loop` for iterative/phase-gated procedures that require loop semantics
- use `formalization_level=workflow` for workflow-grade specifications
- reserve `artifact_kind=session` until a narrower positive category is introduced
- add or consult an execution binding before automatic runtime dispatch

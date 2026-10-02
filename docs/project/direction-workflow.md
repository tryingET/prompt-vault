---
summary: "Native strategic-frame, implementation-wave and execution-task authority for Prompt Vault; legacy SG/TG/OP records are historical only."
read_when:
  - "Starting or resuming work in Prompt Vault"
  - "Changing repo direction or assessing unfinished obligations"
type: "reference"
---

# Native direction workflow

## Authority, not a renamed Markdown ladder

Prompt Vault uses the existing AK-native direction/task substrate:

```text
purpose / mission -> vision
-> strategic frame
-> discovery / design / decision when required
-> implementation wave
-> exact execution task / contract
-> evidence
```

- `ak strategy` reads strategic frames; their native direction kind is `strategic_frame`.
- `ak wave` reads implementation waves; their native direction kind is `work_wave`.
- `ak direction` owns native direction authoring, relationships and task links.
- `ak task`, contracts and evidence own execution leaves and completion facts.
- Repo vision/docs explain intent or source-owned artifacts. They are not a second direction/task store.
- Prompt Vault's Dolt store owns reusable bodies, skill assets and governed metadata; Pi/runtime owns execution bindings and local projections.

There is no current SG/TG/OP authoring path and no tactical-goal layer.
Do not recreate the old ladder with new filenames or mirror live queues in docs.

## Start with native reads

From this repo, use the installed/gated `ak` interface:

```bash
ak strategy list -F json
ak wave list -F json
ak direction check -F json
ak task ready -F json
ak task list -F json --verbose
```

Inspect exact frame/wave/task records when selecting work; `ak direction export`
is a derived readback, not a Markdown import instruction. A failed check, empty
queue or missing direction record is not completion. Reconcile with the owner;
do not synthesize new work from an old handoff or completed historical task.

Read `AGENTS.md`, [README](../../README.md), [vision](vision.md), and the
[stable startup contract](../../next_session_prompt.md). Native direction selects
current work; vision preserves the durable intended outcome.

## Authorized changes

An explicit owner request and exact scoped AK task are required before mutation.
Use native `ak direction create|update|link-task` for admitted direction changes,
then `ak direction check` plus exact strategy/wave/task-link readbacks. Stable
repo-local keys use `SF...` / `IW...`; titles and live state stay in AK.

Do not run `ak direction import` because docs changed. Legacy import is a
separate migration operation, not this repo's routine workflow. Do not use a
checkout binary/cargo fallback against the canonical runtime or add a repo wrapper.

Check readiness and authorization separately: a passing consistency check is
not permission to execute, close a frame/wave, promote knowledge, publish, merge,
import skills or settle the Dolt working set. Keep source-owner actions separate.

## Historical records and completion evidence

[Strategic goals](strategic_goals.md), [tactical goals](tactical_goals.md), and
[operating plan](operating_plan.md) are retained historical records. Their old
“active”, “next” and verification language refers to their earlier planning
period, not today's authority. Do not import them or replay their instructions.
Consult exact native tasks/evidence when checking their recorded completion.

The October 2, 2026 adoption is tracked by AK6470. It preserves the former SG2
privacy-safe downstream-usability intent in native SF1, with IW1 for startup
adoption. Existing publication/branch/transport obligations are linked as frame
anchors, not silently completed or folded into this task's execution authority.
This is adoption provenance, not a current-state/next-task ledger.

## Prompt, skill and loop facts

Use `./scripts/pv templates`, `./scripts/pv skills`, `./scripts/pv vocabulary`,
and current schema/quality readbacks for capability facts. `skills` and
`skill_assets` support multi-file skills; presence of tables/import code does
not prove skill population, synchronization or downstream adoption. Workflows
and loops are classified template rows, not a store of running executors.
Follow downstream dispatch checks before applying retrieved bodies.

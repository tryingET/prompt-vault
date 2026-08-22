---
summary: "Prompt Vault-side handoff contract for downstream consumers that combine Prompt Vault provenance with infra-owned workstation posture machine snapshots."
read_when:
  - "A downstream repo wants to use lane-op posture machine snapshots while still reading prompts/provenance from Prompt Vault."
  - "You need to know what prompt-side facts may travel in a machine-aware handoff packet without turning the snapshot into prompt authority."
  - "You are deciding whether a workstation posture gate belongs in Prompt Vault, infra/workstation, or a downstream workflow repo."
system4d:
  container: "Prompt Vault as prompt/provenance canon; workstation posture snapshots as infra-owned machine-state packets."
  compass: "Keep machine gating useful while preventing prompt bodies, visibility canon, or private output observability from leaking into downstream machine snapshots."
  engine: "State the owner split -> define the minimum truthful handoff -> list what must not be copied -> route future changes to the correct repo."
  fog: "Main risks are treating machine snapshots as prompt authority, copying prompt/private output into runtime packets, or letting downstream gating logic redefine Prompt Vault canon."
---

# Workstation posture machine-snapshot handoff

## Purpose

`infra/workstation` now exposes a versioned machine snapshot through:

```bash
python3 scripts/phasee/lane-op.py snapshot posture --timeline-limit <n>
```

That snapshot is useful to downstream runtime-aware consumers such as `pi-autoresearch` and `workstation-capabilities`.
This note defines the **Prompt Vault side** of the handoff when a downstream workflow needs both:

- machine-state guidance from the workstation posture snapshot
- exact prompt/provenance truth from Prompt Vault

This note does **not** create a new Prompt Vault snapshot surface.
It explains how downstream repos may combine two existing authorities without collapsing them.

## Complementary references

Read this note together with:

- `~/ai-society/softwareco/infra/workstation/docs/project/2026-04-14-workstation-posture-tui.md`
- `~/ai-society/softwareco/infra/workstation/diary/2026-04-18--posture-machine-snapshot-surface.md`
- [Shared runtime registry and execution-observability boundary](./shared-runtime-registry-and-execution-observability-boundary.md)
- [Teacher-prep media prompt-authority boundary](./teacher-prep-media-prompt-authority-boundary.md)

Those documents explain the workstation-side snapshot transport and adjacent Prompt Vault boundaries.
This note answers the narrower question:
**what Prompt Vault facts may travel with a workstation posture machine snapshot, and what must stay owned by Prompt Vault instead of being copied into machine-facing packets.**

## Canonical split

| Concern | Canonical owner | Current bounded truth |
|---|---|---|
| Workstation posture snapshot transport/schema | `infra/workstation` | `surface=posture`, `view=machine-snapshot`, `schema_version`, `captured_at`, and the nested posture payload come from `lane-op` |
| Prompt bodies, governed metadata, and visibility canon | Prompt Vault | templates, ontology facets, `controlled_vocabulary`, `owner_company`, and `visibility_companies` remain canonical here |
| Stored execution + feedback truth | Prompt Vault | `entity_version`, optional execution rows, capture policy, and feedback rows remain Prompt Vault facts |
| Local workflow gating / stop-or-proceed logic | downstream consumer repo | a consumer may react to the machine snapshot, but it does not redefine either canonical source |

## Minimum truthful handoff

When a downstream repo records or prints a bounded packet that combines both sides, it should preserve **two blocks** rather than flattening everything into one fake source of truth.

### 1. Prompt Vault block

Minimum fields:

- exact prompt/template name or ID used
- exact `entity_version` resolved from Prompt Vault
- exact `execution_id` only if a real Prompt Vault execution row was created; otherwise `null` plus an honest note
- the lookup company / visibility outcome only as the bounded result needed for the current workflow, not as copied governance canon
- any local note explaining why live lookup or execution logging was skipped, unavailable, or intentionally disabled

### 2. Workstation snapshot block

Minimum fields:

- `surface: posture`
- `view: machine-snapshot`
- `schema_version`
- `captured_at`
- `summary.result`
- `summary.summary`
- bounded `summary.next_actions` if the downstream workflow surfaces operator follow-through
- `sources.gpu_budget_policy.reconcile_recommended`
- `sources.gpu_budget_policy.recommended_command` when present

Downstream repos may wrap those fields in a local schema, but they must preserve which values came from Prompt Vault and which came from the workstation snapshot.

## What downstream repos may conclude

Allowed:

- stop or degrade a workflow because the workstation snapshot says machine posture is degraded, stale, or reconciliation is recommended
- continue a planning-only or prompt-only flow while leaving runtime apply work blocked or deferred
- report that a prompt was resolved live from Prompt Vault at `entity_version = X` while the workstation snapshot captured posture `Y` at time `Z`
- attach a local workflow verdict such as `apply_deferred`, `planning_only`, or `retry_later` as downstream repo truth

Not allowed:

- claim the workstation snapshot is authoritative for prompt wording, prompt version history, company visibility semantics, or feedback
- claim Prompt Vault stored a runtime or machine result just because a downstream repo bundled snapshot data alongside prompt provenance
- treat a null `execution_id` as proof that prompt authority moved downstream
- expose private Prompt Vault `output_text` or feedback bodies in a machine snapshot or derivative handoff packet
- copy prompt bodies, `controlled_vocabulary`, or full governance arrays into a workstation posture snapshot as shadow canon

## Explicit no-copy list

A workstation posture machine snapshot or its local derivative must not become a second Prompt Vault export surface.
Do **not** copy any of:

- prompt template bodies or long prompt excerpts
- `artifact_kind`, `control_mode`, or `formalization_level` as if the snapshot owns classification
- `controlled_vocabulary` blobs
- full `owner_company` / `visibility_companies` arrays unless a downstream file is explicitly acting as a bounded Prompt Vault query receipt and labels them as copied query results rather than new authority
- private `output_text`
- feedback notes or issues
- replay-local receipt verdicts as if they were Prompt Vault DB facts

## Routing rule for future changes

| If the change is about… | Change it in… | Why |
|---|---|---|
| workstation snapshot schema, source fields, or reconcile semantics | `infra/workstation` | it owns machine posture transport and runtime truth |
| prompt wording, governed metadata, visibility rules, or stored execution rows | Prompt Vault | it owns prompt/provenance canon |
| how a workflow gates, defers, or annotates its own steps from snapshot + prompt data | the downstream consumer repo | that repo owns the local product/operator flow |
| promoting a local combined handoff into a wider durable cross-repo contract | a new bounded decision / contract slice | this note only defines the current Prompt Vault side |

## Practical operator rule

When in doubt, ask two separate questions:

1. What prompt/provenance fact is canonical in Prompt Vault?
2. What machine-state fact is canonical in the workstation posture snapshot?

Only after both answers are explicit may a downstream repo record a local workflow decision that combines them.

## Completion signal

This note is sufficient when a cold-start operator can answer all of the following:

1. what part of the combined packet comes from Prompt Vault
2. what part comes from the workstation posture snapshot
3. which prompt-side facts are safe to hand off
4. which fields must not be copied into machine-facing packets
5. which repo owns the next change

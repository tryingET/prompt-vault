---
summary: "Prompt Vault-side boundary for shared runtime registry interactions and exported prompt execution observability."
read_when:
  - "Clarifying what Prompt Vault exports versus what pi-vault-client or the shared runtime registry owns."
  - "Deciding whether receipt, telemetry, or registry-discovered runtime facts are canonical Prompt Vault observability."
  - "Documenting privacy-safe execution observability without widening live runtime ownership."
system4d:
  container: "Prompt Vault as canonical prompt/body + stored execution authority; runtime registry as downstream discovery only."
  compass: "Keep stored execution truth explicit, keep registry bridges projection-only, and do not widen private-output exposure while improving observability."
  engine: "State authority split -> define exported observability surface -> define non-exported runtime/registry surface -> preserve privacy and promotion rules."
  fog: "Main risk is collapsing DB execution truth, local receipts, and shared runtime discovery into one fake observability layer."
---

# Shared runtime registry and execution-observability boundary

## Purpose

This note states the Prompt Vault side of a boundary that is easy to blur:

- Prompt Vault is the canonical owner of prompt templates, governed metadata, and stored execution/feedback facts in this repo's schema
- `pi-vault-client` owns Pi-side local receipt/replay behavior and the current runtime-registry bridges for receipt and telemetry access
- the shared runtime registry is a process-local discovery surface, not a durable Prompt Vault authority surface

This note complements, rather than replaces:

- [Prompt Vault → vault-client relocation interface handoff](./vault-client-relocation-interface.md)
- [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md)
- [V4 prompt-authoring review-input boundary](./v4-prompt-authoring-review-input-boundary.md)

Use this note when the question is specifically:
**what execution observability Prompt Vault exports canonically, and what remains runtime-local or projection-only elsewhere.**

## Canonical authority split

### Prompt Vault canonically owns

Prompt Vault is the source of truth for:

- prompt template content and version history
- ontology-native prompt classification
  - `artifact_kind`
  - `control_mode`
  - `formalization_level`
- governed router semantics in `controlled_vocabulary`
- ownership and sharing boundary
  - `owner_company`
  - `visibility_companies`
- stored execution rows in `executions`
- stored feedback rows in `feedback`
- output-capture policy recorded per execution via `output_capture_mode`
- privacy-safe aggregate analytics and quality surfaces derived from those stored rows

If an operator needs the canonical stored answer to **what prompt existed, who could see it, what executed, and what feedback/coverage was recorded**, Prompt Vault is the authority.

### pi-vault-client canonically owns

The current Pi-side runtime package owns:

- local execution receipts/replay workflow
- package-local receipt storage
- live `/vault:` trigger telemetry
- shared runtime registry bridges that expose receipt or telemetry accessors in-process

Those runtime concerns may depend on Prompt Vault data, but they are not stored or governed here as Prompt Vault-native authority.

### Shared runtime registry owns neither canonically

The shared runtime registry is only a live discovery/projection mechanism.
It may help other runtime components find `pi-vault-client` receipt or telemetry accessors, but it does **not** become:

- canonical Prompt Vault execution history
- canonical governance visibility truth
- canonical long-lived observability storage
- canonical review evidence just because it is discoverable in one process

From the Prompt Vault side, registry-discovered facts are observational until they cross a canonical durable membrane.

## What Prompt Vault exports as execution observability

Prompt Vault exports a bounded, schema-governed observability surface.

### 1. Exact stored execution facts

These are the canonical DB-backed execution facts:

- exact execution identity in `executions`
- execution target binding (`entity_type`, `entity_id`, entity version where available)
- success/latency/token metrics when stored
- `output_capture_mode`
- captured `output_text` only when explicitly stored
- one-feedback-per-execution binding in `feedback`

These facts are durable Prompt Vault observability because they live in Prompt Vault-owned storage and schema contracts.

### 2. Privacy-aware output observability

Prompt Vault exports output observability only through explicit capture policy.

- `output_capture_mode=none` means no output body is exported as stored output text
- `output_capture_mode=private` means the capture exists for bounded/private use only and must not be treated as a default preview surface
- `output_capture_mode=public` may participate in explicit public-preview paths

The critical rule is:

> stored output presence is not permission to widen preview or cross-surface disclosure

### 3. Aggregate reporting surfaces

Prompt Vault also exports aggregate observability over stored execution and feedback facts, for example:

- `./scripts/pv analytics outputs`
- `./scripts/pv quality coverage`
- `./scripts/pv quality rollup <dimension>`
- router-semantic aggregate rollups such as `selection_principles`

These surfaces are canonical because they are derived from Prompt Vault-owned stored facts and contract-aware CLI behavior.
They must stay aggregate-first where privacy requires it.

### 4. Governed consumer/tool reads over stored facts

Downstream consumers may read canonical stored observability through governed surfaces such as:

- repo CLI commands over the Prompt Vault DB
- schema-aware consumer queries against `executions` / `feedback`
- package/tool reads that intentionally consume Prompt Vault execution rows as canonical stored truth

That is still Prompt Vault observability because the durable fact source remains the Prompt Vault schema.

## What Prompt Vault does **not** export as canonical observability

The following are **not** Prompt Vault-native exported observability, even if they are related to Prompt Vault executions.

### Not canonical here

- package-local JSONL execution receipts
- replay match/drift/unavailable classifications produced from local receipts
- live trigger debounce/rate-limit telemetry
- shared runtime registry capability entries
- process-local accessors for receipt lookup or telemetry stats
- the fact that a capability bridge is currently registered in one Pi process

Those are real and useful surfaces.
They are just not Prompt Vault's canonical exported observability surface.

## Durable promotion rule

If a runtime-local observation matters beyond the current process, it must be promoted through a canonical durable path instead of being treated as truth because it appeared in the registry.

Allowed pattern:

1. observe something through `pi-vault-client` runtime behavior or a shared runtime registry bridge
2. decide that the fact matters durably
3. record it through the correct canonical owner surface
   - Prompt Vault DB rows/analytics when it is stored prompt execution truth
   - package-local receipt storage when it is receipt-local package truth
   - AK evidence/artifacts when it is governance or cross-session operational truth
4. apply the owner's normal privacy and validation rules

Forbidden pattern:

1. observe a receipt or telemetry fact through the shared runtime registry
2. treat that observation itself as canonical exported Prompt Vault observability
3. use it as if Prompt Vault had durably recorded it

## Practical operator split

Use this decision table.

| Question | Canonical place to look | Why |
|---|---|---|
| What prompt body/version/classification is canonical? | Prompt Vault | prompt authoring and governed metadata live here |
| What durable execution row and feedback row were recorded? | Prompt Vault | stored execution/feedback truth is in schema-owned tables |
| Can I inspect aggregate quality/coverage safely? | Prompt Vault | aggregate observability is exported here intentionally |
| Can I inspect a local receipt or replay one exact execution in Pi? | `pi-vault-client` | receipt/replay behavior is package-local |
| Can I discover a live receipt/telemetry accessor in the current process? | shared runtime registry | discovery convenience only, not durable authority |
| Can registry presence prove Prompt Vault exported a durable fact? | No | registry discovery is not canonical storage |

## Privacy boundary

Prompt Vault observability remains valid only if privacy stays explicit.

Required posture:

- private captured outputs remain non-previewable by default
- aggregate quality/coverage surfaces do not widen into raw private-output dashboards
- shared runtime registry access does not imply broader visibility than the owning runtime/package already allows
- downstream docs must not describe private output presence as a public observability guarantee

This means exported observability is intentionally narrower than "anything the runtime can currently see."

## Relationship to the shared runtime registry boundary elsewhere

The AK-side canonical statement for the registry itself lives at:

- `~/ai-society/softwareco/owned/agent-kernel/docs/project/shared-runtime-registry-boundary.md`

Read both notes together as:

- **Prompt Vault side:** what stored execution observability Prompt Vault exports canonically
- **AK side:** why shared runtime registry observations remain projection-only until they cross an AK-native durable path

## Out of bounds for this note

This note must not be read as approval for any of the following:

- moving Prompt Vault execution authority into the shared runtime registry
- treating package-local receipts as if Prompt Vault stored them canonically
- widening aggregate observability into raw private-output preview surfaces
- claiming Prompt Vault owns live trigger telemetry or runtime debounce behavior
- using registry-discovered runtime state as a substitute for DB-backed execution or feedback truth

## Completion signal

This note is good enough when a cold-start operator can answer all of the following:

1. what Prompt Vault exports canonically as execution observability
2. what remains package-local runtime observability instead
3. why shared runtime registry discovery is not Prompt Vault authority
4. how privacy limits the exported observability surface

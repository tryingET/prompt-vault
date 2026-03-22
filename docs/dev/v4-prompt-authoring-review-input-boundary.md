---
summary: "Repo-native boundary note for the bounded v4 prompt_authoring concern: Prompt Vault remains canonical for prompt-body authoring and review inputs while AK bindings stay projection-only."
read_when:
  - "Reviewing the first-wave v4 boundary notes for concern `prompt_authoring`."
  - "Deciding what prompt/provenance and review-input facts AK may consume from Prompt Vault without implying authoring cutover."
  - "Checking whether Prompt Vault or AK is the current canonical owner for prompt-authoring truth in the bounded v4 slice."
system4d:
  container: "Repo-scoped v4 boundary note for prompt authoring."
  compass: "Keep Prompt Vault sovereign for prompt bodies, ontology/governance metadata, and review-input truth while making AK-visible bindings explicit and non-canonical."
  engine: "State current authority -> enumerate bounded consumable prompt/review inputs -> name projection-only bindings -> preserve warning posture -> name out-of-bounds."
  fog: "Main risk is mistaking passport visibility for authoring ownership, duplicating prompt bodies into AK, or widening review inputs into raw-output/runtime authority."
initiative_id: "v4-source-artifact-graph-control-plane"
decision_id: 4
type: "reference"
concern_id: "prompt_authoring"
owner_repo: "/home/tryinget/ai-society/core/prompt-vault"
---

# V4 prompt-authoring review-input boundary

## Purpose

This note is the repo-native boundary note for the first-wave v4 concern `prompt_authoring`.
It preserves the current truth for the bounded slice:

- `prompt-vault` is still the canonical prompt-authoring surface
- Agent Kernel may project that authority into initiative/passport outputs
- those AK-visible bindings are **not** prompt-authoring cutover

This note complements, rather than replaces:

- [Prompt Vault → vault-client relocation interface handoff](./vault-client-relocation-interface.md)
- [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md)

Those notes already define the schema-v9 and consumer boundary truthfully.
This note adds the v4-specific answer to a different question:
what prompt/provenance and review-input facts the initiative may consume while Prompt Vault remains canonical.

## Governing context

This repo-native note is the owner-repo follow-through named by the v4 fan-out material in Agent Kernel:

- `agent-kernel/docs/project/2026-03-21-cross-repo-fanout-v4-source-artifact-graph-control-plane-boundary-note-wave.md`
- `agent-kernel/docs/project/2026-03-21-conformance-suite-v4-source-artifact-graph-control-plane-first-slice.md`

Those initiative artifacts stay coordination-only.
They point back to Prompt Vault for prompt-authoring truth rather than replacing it.

## Concern and authority snapshot

| Field | Current bounded truth |
|---|---|
| Concern | `prompt_authoring` |
| Current canonical authority | `prompt-vault` |
| Current authority status | `canonical` |
| Emerging authority in v4 outputs | Agent Kernel passport/projection surfaces |
| Emerging authority status | `passport_projection` |
| Target authority read for the bounded slice | `prompt-vault-plus-ak-bindings` |
| Target authority status | `bound_external_truth` |
| Blocking posture | `warn_only` |

The distinction above is mandatory.
This note does **not** collapse current, emerging, and target authority into one owner string.

## Why Prompt Vault remains canonical today

Prompt Vault is still the strongest current home for the facts that matter to this concern:

- prompt template content lives here as canonical DB content
- prompt-body version history and authoring workflow live here
- ontology-native prompt classification lives here:
  - `artifact_kind`
  - `control_mode`
  - `formalization_level`
- governed retrieval/orchestration semantics live here in `controlled_vocabulary`
- ownership and sharing/governance visibility live here:
  - `owner_company`
  - `visibility_companies`
- prompt execution/feedback evidence is attached here to exact execution rows, with explicit privacy posture

The current Prompt Vault source-of-truth documents already make that split explicit:

- [Prompt Vault → vault-client relocation interface handoff](./vault-client-relocation-interface.md) states that Prompt Vault is the schema-v9 and prompt-authoring source of truth and that downstream packages must consume that contract rather than re-owning it.
- [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md) defines the canonical prompt model, ontology layer, controlled-vocabulary layer, governance layer, and exact schema-v9 compatibility expectations.

Because those authoring, classification, governance, and execution-bound prompt facts are still maintained here, AK is not the canonical owner for `prompt_authoring` today.

## Bounded facts the v4 initiative may consume now

The bounded v4 slice may rely on the following Prompt Vault facts without pretending AK owns prompt authoring.

| Fact category | Safe bounded read for v4 | Canonical anchor |
|---|---|---|
| Concern owner | `prompt_authoring` is currently owned by Prompt Vault | this note + [Prompt Vault → vault-client relocation interface handoff](./vault-client-relocation-interface.md) |
| Prompt-body truth | template bodies are canonical DB content in Prompt Vault, not AK-native copies and not ontology fixtures | [Prompt Vault → vault-client relocation interface handoff](./vault-client-relocation-interface.md#what-is-already-true-in-prompt-vault) |
| Version/provenance truth | prompt versions and authoring history remain Prompt Vault facts | this note + repo contract in `schema/schema.sql` / Dolt-backed workflow |
| Ontology classification | `artifact_kind`, `control_mode`, and `formalization_level` define what a prompt is | `ontology/v2-contract.json` + [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md#boundary-layers) |
| Governed orchestration semantics | router semantics come from `controlled_vocabulary`, not from tags or AK inference | `ontology/controlled-vocabulary-contract.json` + [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md#boundary-layers) |
| Governance visibility | `owner_company` and `visibility_companies` remain the canonical company/visibility boundary | `ontology/company-visibility-contract.json` + [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md#default-company-aware-query-behavior) |
| Review evidence posture | feedback and output-capture metadata may inform review, but privacy posture remains explicit and private captures stay non-previewable by default | [Vault-client boundary for Prompt Vault v9](./vault-client-company-visibility-boundary.md#execution-capture-contract) |
| Aggregate quality inputs | coverage/rollup surfaces may be consumed as aggregate review input without widening raw private output exposure | `./scripts/pv quality coverage`; `./scripts/pv quality rollup <dimension>` |

These are the facts the initiative may surface and reason about.
They are not permission to reimplement prompt authoring elsewhere.

## Review-input contract for the bounded slice

For the bounded v4 slice, Prompt Vault is not only the prompt-body authority but also the review-input authority for prompt-side facts.
That means downstream initiative/passport work may consume the following inputs from Prompt Vault:

### Allowed review inputs

| Input | Why it is allowed | Boundary |
|---|---|---|
| template identity (`name`, `status`, `version`) | identifies exactly which authored prompt is under discussion | Prompt Vault remains canonical |
| prompt body at the referenced template/version | enables human review of the authored source when needed | review may read it from Prompt Vault; AK must not become the canonical storage home |
| ontology facets | tell the initiative what kind of prompt/capability input it is looking at | use canonical facet fields; do not infer from tags/text |
| controlled vocabulary | tells the initiative the governed routing semantics for router prompts | consume as governed semantics, not as free-form labels |
| owner/visibility metadata | tells the initiative who owns the prompt and who may see it | governance stays separate from ontology |
| aggregate evidence coverage or quality rollups | helps evaluate whether prompt-side evidence is thin or healthy | must stay aggregate-first for private captures |
| repo-native boundary docs and ontology contracts | anchor cold-start operator understanding | these docs are evidence, not cutover proof |

### Not allowed as implicit review inputs

The bounded slice must **not** silently treat any of the following as routine initiative inputs:

- AK-owned shadow copies of prompt bodies or authoring history
- tag-derived or text-inferred prompt meaning when canonical facets/vocabulary already exist
- raw `output_text` from private execution captures as generalized review material
- client/runtime debounce or trigger behavior as if it were part of prompt-authoring authority
- ontology files used as prompt-body fixtures

If a later slice needs broader prompt-side inputs, it must justify that widening explicitly instead of smuggling it in through passport projections.

## AK-visible bindings that remain projection-only

AK may expose `prompt_authoring` in initiative/passport materials only as a projection of Prompt Vault truth.
For the bounded first slice, the following surfaces remain non-canonical bindings:

- authority snapshot and decision-passport projections that name Prompt Vault as the current concern owner
- cross-repo fan-out and boundary-note artifacts that point operators to this repo and these docs
- later initiative/passport references to prompt review inputs that still depend on Prompt Vault docs, schema, and repo-native behavior to stay truthful
- any AK-visible concern map that shows Prompt Vault as the source of prompt-body truth for the initiative

What AK may **not** claim from these bindings:

- that prompt bodies or authoring history are canonically stored in AK
- that AK can redefine prompt ontology/governance semantics independently of Prompt Vault contracts
- that this boundary note means prompt-authoring cutover has already happened
- that review-input visibility in the passport is equivalent to runtime-native authoring ownership

## Required warning posture

The v4 slice stays valid only if these warnings remain visible for `prompt_authoring`:

| Warning code | Why it still applies |
|---|---|
| `projection_only_authority` | AK may render `prompt_authoring` in initiative outputs, but canonical ownership remains in Prompt Vault |
| `external_binding_not_runtime_native` | truthful prompt-authoring visibility still depends on Prompt Vault docs/contracts/runtime bindings rather than an AK-native authoring surface |

For this concern, these warnings are **truth surfaces**, not automatic blockers.
They should remain report-only until a later bounded decision proves that stronger runtime-native integration is actually justified.

`hybrid_governance_authority` does **not** apply to this concern directly.
That warning belongs to the governance concern, not to Prompt Vault prompt-authoring truth itself.

## Out of bounds for this note

This note must not be read as approval for any of the following:

- moving canonical prompt-body authoring history into AK
- treating passport projections as permission to duplicate prompt bodies into initiative-native storage
- widening prompt review into generalized access to private execution outputs
- inferring concern semantics from tags, naming conventions, or company ownership when canonical facets/vocabulary already exist
- replacing Prompt Vault contracts with AK-local prompt schema for this first slice
- claiming that vault-client runtime behavior, receipt semantics, or governance cutover are solved by this note

If any later slice needs one of those moves, it must open a new bounded decision or implementation contract explicitly.

## Completion signal

This boundary note is good enough for the bounded first slice when a cold-start operator can answer all of the following without reopening the whole v4 ADR chain:

1. who currently owns `prompt_authoring`
2. which prompt/provenance and review-input facts v4 may consume safely
3. which AK-visible surfaces are still projection-only
4. which warnings must remain visible for this concern
5. why this note does **not** mean prompt-authoring cutover into AK has happened

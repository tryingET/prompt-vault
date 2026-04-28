---
summary: "Canonical Prompt Vault naming and placement contract for layer-aware templates and skills, including Layer-12 stage-indexed procedure names."
read_when:
  - "Creating, renaming, importing, exporting, or reviewing Prompt Vault templates or skills."
  - "Deciding whether an artifact should be a prompt template, a Pi skill, an AK runtime surface, a ROCS semantic object, or documentation."
  - "Normalizing Layer-aware names such as layer12-000-router without treating them as runtime queue authority."
type: "reference"
---

# Layer-Aware Prompt Template and Skill Naming

## Purpose

This is the canonical Prompt Vault-side naming and placement contract for reusable prompt templates and skills.

It answers:

```text
How should we name Prompt Vault templates and skills when they support a numbered AI Society layer such as Layer 12?
```

It is intentionally about **authoring and catalog names**. It does not create runtime state, rename live templates, create skills, mutate AK, or define ontology semantics by itself.

Read this with:

- [[README.md|Prompt Vault README]] — Prompt Vault schema, commands, and current reality.
- [[docs/dev/vault-client-company-visibility-boundary.md|Vault-client boundary for Prompt Vault v9]] — schema/facet/visibility contract used by downstream consumers.
- [[docs/dev/shared-runtime-registry-and-execution-observability-boundary.md|Shared runtime registry and execution-observability boundary]] — what Prompt Vault exports canonically versus runtime-local facts.
- [[/home/tryinget/ai-society/holdingco/governance-kernel/docs/core/definitions/ai-society-stack-map.md|AI Society Stack Map]] — source-owner and altitude map.
- [[/home/tryinget/ai-society/softwareco/owned/agent-kernel/docs/project/ai-society-convergence-architecture.md|AI Society Convergence Architecture]] — 10,000 ft system assembly and Layer-12 owner-boundary placement.
- [[/home/tryinget/ai-society/softwareco/owned/agent-kernel/docs/project/layer-12-protocol.md|Layer-12 Protocol — Start Here]] — agent-kernel's Layer-12 operator front door.
- [[/home/tryinget/ai-society/softwareco/owned/agent-kernel/docs/project/2026-04-27-layer12-protocol-procedure-skill-map.md|Layer-12 Protocol Procedure / Skill Routing Map]] — phase-by-phase procedure/skill support map.
- [[/home/tryinget/ai-society/softwareco/owned/agent-kernel/docs/project/prompt-vault-ak-capability-bridge.md|Prompt Vault ↔ Agent-Kernel Capability Bridge]] — target bridge from prompt bodies to runtime capabilities without collapsing ownership.

## Authority split

Prompt Vault is the source of truth for reusable prompt/skill authoring facts:

| Prompt Vault canonically owns | Prompt Vault does not own |
|---|---|
| Template and skill names | Live AK task/decision/packet/evidence state |
| Prompt bodies and skill README/assets stored here | ROCS ontology meaning |
| Governed prompt facets and router controlled vocabulary | Pi/ASC/orchestrator live execution truth |
| Owner/visibility metadata for Prompt Vault rows | DSPx/Oracle empirical conclusions |
| Prompt/skill version history and Dolt provenance | KES promotion or steward runtime authority |
| Stored Prompt Vault execution/feedback rows | Long-form source-owner docs outside Prompt Vault |

Therefore a name such as:

```text
layer12-050-discovery-router
```

means:

```text
Prompt Vault has a reusable procedure for the Layer-12 discovery stage.
```

It does **not** mean:

```text
Prompt Vault owns canonical discovery state or the live runtime queue.
```

## Canonical naming pattern

Use this pattern for layer-aware Prompt Vault templates and Prompt Vault-stored skills:

```text
layer<N>-<stage-index>-<stage-or-domain>[-<function>[-<variant>]]
```

Examples:

```text
layer12-000-router
layer12-030-product-posture-synthesis
layer12-050-discovery-router
layer12-060-design-router
layer12-070-decision-rfc-review
layer12-090-execution-handoff
layer12-120-learning-crystallization
layer12-150-publication-outreach-runner
```

Human-facing labels may use the shorter display form:

```text
L12.000 Router
L12.030 Product Posture Synthesis
L12.050 Discovery Router
L12.150 Publication / Outreach Runner
```

Do not use uppercase `L12-*` as the canonical Prompt Vault row name. Keep machine names lowercase kebab-case.

## Why three digits

Use `000`, `010`, `020`, ... rather than `0`, `1`, `2`.

Reasons:

1. lexical sorting stays truthful;
2. future insertions do not require mass renames;
3. routers and procedures group by protocol stage;
4. other numbered layers can reuse the convention.

Bad:

```text
layer12-1-vision
layer12-10-execution
layer12-2-product-posture
```

Good:

```text
layer12-020-vision
layer12-030-product-posture
layer12-090-execution
```

Reserve `000` for the layer's umbrella/front-door router.

## Generic vs layer-aware templates

Keep a template generic when it intentionally works across layers and does not depend on one layer's stage semantics.

Generic examples:

```text
analysis-router
post-review-router
review-closeout-router
many-of-the-greats
commit
implicit-explicit
crisis
decision
```

Use a layer-aware name when the procedure knows a numbered layer's ladder, stop rules, or source-owner boundaries.

Layer-aware examples:

```text
layer12-000-router
layer12-050-discovery-router
layer12-060-design-router
layer12-070-decision-rfc-review
layer12-070-review-followup-router
layer12-090-execution-handoff
```

Layer-aware overlays should usually wrap, specialize, or route toward generic core procedures rather than replacing them globally.

If one router legitimately spans several stages, keep it as an umbrella/subrouter until a catalog audit proves a clean stage-specific split.

## Layer-12 stage index

Layer 12 is the direction-to-execution workflow, not the owner of every system it touches. The index below is the Prompt Vault / skill catalog order for Layer-12-aware reusable procedures.

| Index | Human label | Stage | Typical Prompt Vault names | Typical skill / runner names |
|---:|---|---|---|---|
| `000` | L12.000 Router | Umbrella stage selector | `layer12-000-router` | Usually none; the router emits the next prompt. |
| `010` | L12.010 Purpose / Mission | Repo/system purpose and mission | `layer12-010-purpose-mission-review` when needed | Steward/doc review skill only if repeated. |
| `020` | L12.020 Vision | Durable north-star | `layer12-020-vision-review` when needed | Steward/doc review skill only if repeated. |
| `030` | L12.030 Product Posture | Current-vs-target maturity bridge | `layer12-030-product-posture-synthesis` | `layer12-030-product-posture-runner` only if multi-file/tool support is needed. |
| `040` | L12.040 Strategy | Strategic frame / direction selection | `layer12-040-direction-to-execution-ak-native` | `layer12-040-strategy-runner` only if repeated workflow support is needed. |
| `050` | L12.050 Discovery | What exists and who owns it? | `layer12-050-discovery-router` | `layer12-050-discovery-runner` for multi-file scouting/repo-router support. |
| `060` | L12.060 Design | What bounded shape should change? | `layer12-060-design-router` | `layer12-060-design-runner` for multi-file design workflows. |
| `070` | L12.070 Decision | Governance / review / ADR membrane | `layer12-070-decision-router`, `layer12-070-decision-rfc-review` | Review-lane skill only if it packages a multi-file review method. |
| `080` | L12.080 Wave | Bounded implementation/publication grouping | `layer12-080-wave-planning` | `layer12-080-wave-runner` if wave setup becomes operationally repeatable. |
| `090` | L12.090 Execution | Claimable execution leaf / handoff | `layer12-090-execution-handoff`, `layer12-090-analysis-router` | `layer12-090-execution-runner` only for multi-step execution recipes. |
| `100` | L12.100 Evidence / Receipts | Verification and proof | `layer12-100-evidence-receipts-checklist` | `layer12-100-evidence-runner` if evidence capture needs helper scripts. |
| `110` | L12.110 Oracle Analysis | Empirical behavior analysis after evidence | `layer12-110-oracle-analysis-router` | `layer12-110-oracle-analysis-runner` if it packages DSPx/Oracle workflow details. |
| `120` | L12.120 Learning / Crystallization | Durable lesson capture | `layer12-120-learning-crystallization` | `layer12-120-learning-runner` if it packages KES steps and checks. |
| `130` | L12.130 Activation | Promotion into active guidance / precedent | `layer12-130-activation-router` | `layer12-130-activation-runner` if promotion has repeatable tooling. |
| `140` | L12.140 Steward Explanation | Human-facing explanation / jurisdiction membrane | `layer12-140-steward-explanation` | `layer12-140-steward-explanation-runner` if it packages diagrams/workbench steps. |
| `150` | L12.150 Publication / Outreach | Broad communication output | `layer12-150-publication-outreach-router` | `layer12-150-publication-outreach-runner` for multi-artifact publication workflows. |

A stage does not require a template or skill. Create one only when repeated work proves the abstraction.

## Function suffix vocabulary

Use a small suffix vocabulary so names stay predictable.

| Suffix | Meaning | Usually belongs in |
|---|---|---|
| `router` | Selects the next exact procedure/prompt; does not execute it. | Prompt Vault template |
| `synthesis` | Produces a consolidated artifact from sources. | Prompt Vault template |
| `review` | Reviews an artifact and emits findings or a legal next move. | Prompt Vault template |
| `closeout` | Chooses the final closeout move after review/execution. | Prompt Vault template |
| `handoff` | Translates one artifact/state into an owner-side next step. | Prompt Vault template |
| `checklist` | Produces or applies a bounded checklist. | Prompt Vault template or doc |
| `runner` | Multi-step operational package with read order, tools, scripts, or assets. | Pi skill / Prompt Vault `skills` row if imported |
| `guide` | Human/operator documentation, not executable procedure truth. | Docs or AK read-only guide |
| `audit` | Discovery/checking procedure over existing state. | Prompt Vault template or deterministic tool |
| `migration` | Bounded transition plan between old and new names/contracts. | Docs / AK task / decision if authority-changing |

Avoid clever names for stage-specific procedures unless the template is truly generic cognition. Names should sort, route, and age well.

## Template, skill, AK surface, or doc?

Use this placement rule before creating anything.

| If the artifact is... | Put it in... | Name shape |
|---|---|---|
| One reusable prompt/procedure/router | Prompt Vault `prompt_templates` | `layer12-050-discovery-router` |
| Multi-file instructions, scripts, assets, read order, or tool recipes | Pi skill; optionally Prompt Vault `skills` + `skill_assets` when import/export is verified | `layer12-050-discovery-runner` |
| Canonical state, task, decision, packet, evidence, direction, lifecycle, or accepted knowledge | AK / `society.v2.db` | AK command/schema names, not prompt names |
| Long-form rationale, packet prose, maps, diagrams, or migration notes | Docs | wiki-linked Markdown |
| Semantic concept/relation meaning | ROCS / ontology owner | ontology ids, not Prompt Vault names |
| Empirical analysis over receipts/traces | DSPx / Oracle | Oracle/DSPx artifact names |

Prompt Vault schema v9 already includes:

```text
prompt_templates
skills
skill_assets
executions(entity_type = 'template' | 'skill')
collections(template_ids, skill_ids)
```

However, Prompt Vault's most-used Pi client/tooling path is currently template-first. Before relying on Prompt Vault as a live skill distribution path, verify the current import/export behavior in this repo.

## Creation checklist: Prompt Vault template

Before creating a new layer-aware template:

1. Confirm the generic procedure does not already exist.
2. Confirm the layer and stage are defined by the owning layer docs.
3. Choose the canonical name:

   ```text
   layer<N>-<stage-index>-<stage-or-domain>-<function>
   ```

4. Keep the description explicit about source ownership.
5. Pick Prompt Vault facets truthfully:
   - `artifact_kind`: usually `procedure`, sometimes `cognitive`; treat `session` as reserved until a positive session-scaffold contract exists.
   - `control_mode`: `router` only when it selects a next prompt/procedure; `loop` only when the procedure is iterative/phase-gated.
   - `formalization_level`: `structured` or workflow-grade `workflow` for protocol procedures; this does not imply automatic `workflow_execute(...)` binding.
6. For routers, set controlled vocabulary rather than burying routing semantics only in prose.
7. Do not encode runtime state, task ids, one-off session context, transcripts, or session JSONL evidence into the template name.
8. If the template should automatically run through an executor, record or reference an explicit execution binding/orchestration contract instead of relying on `workflow` or the template name.
9. Link the template from the owning doc or router only after visibility/ownership are correct.

## Creation checklist: skill

Before creating a layer-aware skill:

1. Confirm it needs more than one prompt.
2. Identify the runtime/tool/read-order content that makes it a skill.
3. Use `runner` or another capability word rather than `skill` in the name:

   ```text
   layer12-050-discovery-runner
   ```

4. Put stable reusable prompt text in Prompt Vault templates when it can stand alone.
5. Put operational read-order, helper scripts, examples, and assets in the skill.
6. Keep AK state and source-owner facts out of the skill body except as explicit read/reference instructions.
7. If the skill should be stored in Prompt Vault, verify `./scripts/pv new-skill`, `./scripts/pv import`, `./scripts/pv export`, and the `skills` / `skill_assets` rows before treating it as distributed.

## Domain and company overlays

When a procedure is both layer-aware and domain/company-specific, keep the layer and stage first. Put the domain late.

Preferred:

```text
layer12-150-publication-outreach-runner-teaching
layer12-090-execution-handoff-software
layer12-030-product-posture-synthesis-health
```

Avoid:

```text
teaching-layer12-publication-outreach-router
software-layer12-execution-handoff
```

Reason: the primary sorting and routing dimension is protocol layer and stage. Domain/company specialization is a later qualifier.

Check name length before creating Prompt Vault rows; Prompt Vault currently constrains template and skill names to 64 characters.

## Migration policy for existing names

Do not destructively rename live templates just to satisfy this naming contract.

Safe migration sequence:

1. **Catalog** current templates and skills.
2. Classify each item:
   - `generic-core`
   - `layer-aware-current-name`
   - `layer-aware-rename-candidate`
   - `skill-candidate`
   - `legacy-keep`
   - `legacy-deprecate`
3. Create new indexed names only when the old name creates real routing confusion.
4. Update routers/docs to prefer the new name.
5. Preserve old names as compatibility entries or deprecate only after references are gone.
6. Keep execution/feedback history and governance ownership intact.

Current non-indexed Layer-12 names remain valid until a bounded migration lands.

| Current name | Future indexed candidate | Migration posture |
|---|---|---|
| `layer12-router` | `layer12-000-router` | Candidate alias/replacement; do not break current refs. |
| `product-posture-synthesis` | `layer12-030-product-posture-synthesis` | Candidate Layer-12 overlay; current name may remain if used outside Layer 12. |
| `repo-direction-to-execution-ak-native` | `layer12-040-direction-to-execution-ak-native` | Candidate Layer-12 overlay; preserve current references during migration. |
| `layer12-analysis-router` | audit before renaming | This router can route an analysis artifact to the earliest lawful stage; do not force a single stage index without testing. |
| `layer12-post-review-router` | `layer12-070-review-followup-router` if decision-membrane-specific | Candidate indexed rename only if audit confirms it stays inside RFC/review/ADR follow-up. |
| `layer12-review-closeout-router` | audit before renaming | This router can route toward plan, verify, learning, activation, steward explanation, publication, or no mutation; split or index only after audit. |

## Generalization to other layers

This contract is reusable for other numbered AI Society layers, but do not invent layer prefixes casually.

Before creating `layer<N>-...` names, confirm:

1. the layer exists in the owning stack/model docs;
2. the layer has a stable enough stage vocabulary;
3. the artifact is layer-aware rather than generic;
4. the owning source layer agrees with Prompt Vault or skill placement.

Example shape only:

```text
layer11-000-router
layer11-020-context-map
layer10-000-router
layer10-040-runtime-handoff
```

Those examples are not claims that Layer 10 or Layer 11 procedures already exist. They show the naming grammar.

## Anti-patterns

Avoid:

```text
L12-1-vision                         # uppercase and unstable sorting
layer12-something-cool                # not stage-indexed or descriptive
teaching-layer12-publication-router   # domain before layer/stage
layer12-050-discovery-state           # suggests runtime state in Prompt Vault
layer12-050-discovery-skill           # says artifact kind instead of capability
layer12-050-discovery-run             # implies execution authority
```

Prefer:

```text
layer12-020-vision-review
layer12-050-discovery-router
layer12-050-discovery-runner
layer12-150-publication-outreach-runner-teaching
```

## Stop rule

This document authorizes naming and placement vocabulary only.

It does not authorize:

- Prompt Vault DB mutation;
- skill import/export rollout;
- AK schema changes;
- `ak discovery/design run`;
- lifecycle aliases;
- automatic router execution;
- destructive template renames;
- or an AK capability bridge implementation.

Use the owning layer's discovery/design/decision membrane before changing authority boundaries.

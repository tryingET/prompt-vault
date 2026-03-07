---
summary: "Backlog and execution plan for adding a controlled vocabulary layer above the Prompt Vault v2 ontology facets."
read_when:
  - "Planning the next Prompt Vault v2 slice after facet cutover."
  - "Designing governed retrieval/orchestration metadata for routers and loops."
system4d:
  container: "Prompt Vault controlled vocabulary layer planning."
  compass: "Add a governed semantic layer without collapsing back into tag sprawl or schema overreach."
  engine: "Contract first -> router exemplars -> validation -> query/insert exposure -> loop exemplars."
  fog: "The main failure mode is recreating legacy type overload in tags or premature schema sprawl."
---

# Controlled vocabulary layer plan

## Intent
Add a governed metadata layer above the v2 core ontology facets:

- `artifact_kind`
- `control_mode`
- `formalization_level`

The controlled vocabulary layer should improve:
- LLM querying
- router prompt selection
- future loop orchestration
- insert validation
- semantic consistency across prompts

## Boundary rule
Keep hard ontology in first-class facets.
Use controlled vocabularies for governed retrieval/orchestration semantics.
Use free tags only for lower-trust or residual annotation.

## Recommended first-wave dimensions
- `intent_family`
- `activity_phase`
- `input_kind`
- `output_kind`
- `concern_set`
- `transition_target` (required for routers)

## Staged rollout
1. Add contract artifact for controlled vocabularies
2. Apply to the 3 seeded router fixtures first
3. Extend verifier/tests for vocabulary membership and required-dimension coverage
4. Expose controlled vocabularies to query/insert surfaces
5. Add loop exemplars using the same governed dimensions

## Deferred until after router fit is proven
- broad schema explosion into many dedicated columns
- uncontrolled growth of vocabulary dimensions
- replacing all tags immediately
- loop prompt seeding before router metadata proves out

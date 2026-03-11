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
Do not use free tags for prompt semantics; if a meaning matters, it belongs in facets or controlled vocabulary.

## Recommended first-wave dimensions
Initial draft dimensions were:
- `intent_family`
- `activity_phase`
- `input_kind`
- `output_kind`
- `concern_set`
- `transition_target` (required for routers)

After semantic-metamodel review, the router slice was normalized to:
- `routing_context`
- `activity_phase`
- `input_artifact`
- `transition_target_type`
- `selection_principles`
- `output_commitment`

## Chosen minimal router slice
For the 3 seeded router exemplars, use the smallest governed set that meaningfully improves retrieval/orchestration without recreating legacy `type`.

### Semantic metamodel rule
Each controlled dimension must declare what *kind of thing* it is before values are expanded. This keeps function, phase, artifact type, criteria, and output obligation from collapsing into one overloaded tag bucket.

### Current metamodel-backed dimensions
- `routing_context` — functional context
- `activity_phase` — process position
- `input_artifact` — upstream information object type
- `transition_target_type` — downstream target class
- `selection_principles` — routing decision criteria
- `output_commitment` — required emitted deliverable

Why this cut:
- `routing_context` distinguishes analysis followup vs review followup vs review closeout without smuggling in phase/order semantics
- `activity_phase` captures where the router sits in the workflow
- `input_artifact` keeps router selection tied to the upstream artifact shape
- `transition_target_type` makes next-mode semantics explicit and required for routers
- `selection_principles` captures decision criteria without mixing in output obligations
- `output_commitment` cleanly governs the exact-next-prompt obligation

Deferred for now:
- `output_kind` because all 3 routers already share the same explicit output structure in-body (`SELECTED_MODE`, `WHY`, `NEXT PROMPT`), and `output_commitment` is enough for the first proof slice
- broader value expansion until the semantic metamodel proves stable

## Staged rollout
1. Add contract artifact for controlled vocabularies
2. Apply to the 3 seeded router prompts in the DB first
3. Extend verifier/tests for vocabulary membership and required-dimension coverage
4. Expose controlled vocabularies to query/insert surfaces
5. Add loop exemplars using the same governed dimensions

## Deferred until after router fit is proven
- broad schema explosion into many dedicated columns
- uncontrolled growth of vocabulary dimensions
- reintroducing any free-form semantic tag layer
- loop prompt seeding before router metadata proves out

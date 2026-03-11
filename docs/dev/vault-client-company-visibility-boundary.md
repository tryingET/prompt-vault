---
summary: "Concrete implementation boundary for vault-client against Prompt Vault schema v9, including ontology, controlled vocabulary, company visibility governance, execution output capture, and execution-bound feedback guarantees."
read_when:
  - "Implementing vault-client against Prompt Vault v9"
  - "Adding company-aware query filtering in vault-client"
  - "Defining fail-fast compatibility checks for Prompt Vault integration"
system4d:
  container: "Prompt Vault as semantic/governance source of truth; vault-client as consumer."
  compass: "Keep client logic thin: consume validated fields, apply company visibility defaults, avoid inventing semantics client-side."
  engine: "Fail fast on schema mismatch -> read canonical fields -> apply visibility filter -> render/query without reinterpreting ontology."
  fog: "Main failure modes are reintroducing tags, mixing governance with ontology, or hardcoding semantics not present in the contracts."
---

# Vault-client boundary for Prompt Vault v9

## Purpose
This document defines the exact boundary vault-client should implement against after the Prompt Vault v9 cutovers:

- facet-native ontology
- semantic controlled vocabulary
- company ownership/visibility governance
- no prompt tags
- execution output capture with explicit privacy mode

## Required schema compatibility
Vault-client must fail fast unless the connected Prompt Vault schema version is exactly:

- `9`

Minimal startup check:

```sql
SELECT MAX(version) AS version FROM schema_version;
```

Expected result:

- `9`

If not `9`, do not silently degrade into partial behavior.

## Canonical prompt model
Vault-client should treat `prompt_templates` as having this logical shape:

```ts
type Company =
  | "core"
  | "software"
  | "finance"
  | "house"
  | "health"
  | "teaching"
  | "holding"

type ArtifactKind = "cognitive" | "procedure" | "session"
type ControlMode = "one_shot" | "router" | "loop"
type FormalizationLevel = "napkin" | "bounded" | "structured" | "workflow"

type RouterControlledVocabulary = {
  routing_context: "analysis_followup" | "review_followup" | "review_closeout"
  activity_phase: "post_analysis" | "post_review" | "closeout"
  input_artifact: "analysis_output" | "review_findings" | "review_summary"
  transition_target_type: "framework_mode"
  selection_principles: Array<"evidence_based" | "constraint_preserving" | "minimal_change">
  output_commitment: "exact_next_prompt"
}

type PromptTemplate = {
  name: string
  description: string | null
  content: string
  artifact_kind: ArtifactKind
  control_mode: ControlMode
  formalization_level: FormalizationLevel
  owner_company: Company
  visibility_companies: Company[]
  controlled_vocabulary: RouterControlledVocabulary | null
  status: "draft" | "active" | "deprecated" | "archived"
  export_to_pi: boolean
  version: number
}
```

## Boundary layers
Treat these layers as distinct.

### 1. Ontology layer
What the prompt is:
- `artifact_kind`
- `control_mode`
- `formalization_level`

### 2. Controlled-vocabulary layer
Governed retrieval/orchestration semantics:
- `controlled_vocabulary`

### 3. Governance layer
Who owns it and who can see it:
- `owner_company`
- `visibility_companies`

Do not collapse these layers into one label system.

## Explicitly absent
Vault-client must assume these are **not** part of the canonical boundary:

- prompt tags
- namespaced tags
- legacy `type`
- tag-derived semantics

## Startup contract checks
At startup, validate all of the following.

### Schema version
```sql
SELECT MAX(version) AS version FROM schema_version;
```
Must equal `9`.

### Prompt columns exist
```sql
SHOW COLUMNS FROM prompt_templates;
```
Must include:
- `artifact_kind`
- `control_mode`
- `formalization_level`
- `owner_company`
- `visibility_companies`
- `controlled_vocabulary`
- `export_to_pi`

Must not expect:
- `type`
- `tags`

### Execution capture contract
`executions` now includes:
- `output_capture_mode` with allowed values `none`, `private`, `public`
- `output_text` as nullable captured output content

Client behavior:
- default to `output_capture_mode = none` unless the operator explicitly opts into capture
- treat `private` as non-shareable/private-by-default UI data
- never assume `output_text` is present just because an execution exists

### Feedback contract
`feedback.execution_id` is unique at the schema level.
Client feedback paths should treat one execution as permitting exactly one feedback row.

### Optional contract artifacts if accessible
If the integration can read repo artifacts or equivalent tool surfaces, prefer also checking:
- `ontology/v2-contract.json`
- `ontology/controlled-vocabulary-contract.json`
- `ontology/company-visibility-contract.json`

## Default company-aware query behavior
Vault-client should run with a current company context.

```ts
type VaultClientContext = {
  currentCompany: Company
}
```

### Default visibility rule
Only return prompts whose `visibility_companies` contains `currentCompany`.

Example SQL predicate:

```sql
JSON_SEARCH(visibility_companies, 'one', '<currentCompany>') IS NOT NULL
```

### Resulting behavior
If vault-client starts in `software`:
- it sees `software` prompts
- it sees `core` prompts that are visible to `software`
- it does not see `finance`, `health`, etc. unless explicitly shared to `software`

With current repo defaults, seeded `core` routers are visible to all companies.

## Recommended query interface
Keep visibility separate from ontology and controlled vocabulary.

```ts
type VaultQuery = {
  artifact_kind?: ArtifactKind[]
  control_mode?: ControlMode[]
  formalization_level?: FormalizationLevel[]
  owner_company?: Company[]
  visibility_company?: Company
  controlled_vocabulary?: {
    routing_context?: string[]
    activity_phase?: string[]
    input_artifact?: string[]
    transition_target_type?: string[]
    selection_principles?: string[]
    output_commitment?: string[]
  }
  include_content?: boolean
  limit?: number
}
```

### Important rule
`visibility_company` should normally be implicit from client context, not a user-controlled free parameter in ordinary use.

## Query examples
### What software can see
```sql
SELECT name, owner_company, artifact_kind, control_mode, formalization_level
FROM prompt_templates
WHERE status = 'active'
  AND JSON_SEARCH(visibility_companies, 'one', 'software') IS NOT NULL
ORDER BY name;
```

### Software-visible structured routers
```sql
SELECT name, owner_company, controlled_vocabulary
FROM prompt_templates
WHERE status = 'active'
  AND control_mode = 'router'
  AND formalization_level = 'structured'
  AND JSON_SEARCH(visibility_companies, 'one', 'software') IS NOT NULL
ORDER BY name;
```

### Software-visible review followup routers
```sql
SELECT name, owner_company, controlled_vocabulary
FROM prompt_templates
WHERE status = 'active'
  AND JSON_SEARCH(visibility_companies, 'one', 'software') IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.routing_context')) = 'review_followup'
ORDER BY name;
```

## Insert/update validation rules
When vault-client inserts prompts, it must validate:

### Always required
- `artifact_kind`
- `control_mode`
- `formalization_level`
- `owner_company`
- `visibility_companies`

### Governance rules
- `owner_company` must be one of the governed companies
- `visibility_companies` must be non-empty
- every entry in `visibility_companies` must be governed
- `visibility_companies` must include `owner_company`

### Router-specific rules
If `control_mode === "router"`, require:
- `controlled_vocabulary.routing_context`
- `controlled_vocabulary.activity_phase`
- `controlled_vocabulary.input_artifact`
- `controlled_vocabulary.transition_target_type`
- `controlled_vocabulary.selection_principles` with length >= 1
- `controlled_vocabulary.output_commitment`

## Rendering guidance
Vault-client UI should render three clearly separated sections.

### Core classification
- artifact kind
- control mode
- formalization level

### Governed semantics
- routing context
- phase
- input artifact
- target type
- selection principles
- output commitment

### Governance
- owner company
- visible to companies

This separation is important. Governance is not ontology.

## What vault-client must not do
Do not:
- infer prompt meaning from owner company
- infer visibility from ontology fields
- derive missing controlled-vocabulary fields from prompt text
- treat company membership as a tag
- reintroduce tag-based search or compatibility logic
- hardcode semantics not present in the contracts

## Minimal implementation algorithm
1. Read schema version.
2. Refuse to run non-v9 path.
3. Determine `currentCompany` from runtime/project context.
4. Apply implicit visibility predicate to all prompt queries.
5. Apply ontology filters.
6. Apply controlled-vocabulary filters.
7. Treat feedback as one row per execution.
8. Render ontology, semantics, and governance separately.

## Current seeded-router expectation
For the 3 seeded routers, vault-client can currently assume:
- `owner_company = core`
- `visibility_companies = [core, software, finance, house, health, teaching, holding]`

Therefore all company contexts currently see these routers.

## Recommended future extension point
If later needed, add richer governance policy via a separate layer, e.g.:
- selected-company sharing policies
- inherited package visibility
- role-based restrictions within a company

Do not overload ontology or controlled vocabulary to do that work.

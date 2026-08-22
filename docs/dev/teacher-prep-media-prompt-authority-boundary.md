---
summary: "Prompt Vault-side boundary note for the teacher-prep-media live runner: reusable prompt authority stays canonical here even when downstream Teaching Packs record live provenance."
read_when:
  - "Checking whether teacher-prep-media live-runner work changed reusable prompt authority."
  - "Deciding whether Prompt Vault, workstation-capabilities, or infra/workstation owns a teacher-prep prompt/provenance change."
  - "Closing or reassessing FCOS-M29 prompt-authority follow-through from the Prompt Vault side."
system4d:
  container: "Prompt Vault as the reusable teacher-prep prompt-authoring substrate while workstation-capabilities emits pack-local derived artifacts."
  compass: "Keep reusable prompt canon, exact template/version provenance, and authority boundaries explicit without turning local Teaching Pack files into shadow prompt storage."
  engine: "State the current split -> define what the live runner proves now -> separate provenance from authoring ownership -> route future changes to the correct repo."
  fog: "Main risks are mistaking pack-local markdown for reusable prompt canon, treating missing execution rows as authoring drift, or moving downstream renderer/runtime concerns into Prompt Vault by accident."
---

# Teacher-prep media prompt-authority boundary

## Purpose

This note closes the Prompt Vault side of the conditional FCOS-M29 follow-through:
if the live `teacher-prep-media` runner changed how reusable prompts are owned or proved, operators needed one repo-native answer.

Current answer:

- Prompt Vault remains the canonical home for reusable teacher-prep prompts.
- `workstation-capabilities` may record live Prompt Vault provenance in a Teaching Pack.
- pack-local prompt-like markdown remains derived output only.
- optional missing `execution_id` values do **not** mean prompt authority moved downstream.

## Canonical split for the current bounded slice

| Concern | Canonical owner | Current bounded truth |
|---|---|---|
| Reusable teacher-prep prompt bodies | Prompt Vault | canonical templates live here as DB content |
| Teacher-prep workflow / Teaching Pack product contract | `workstation-capabilities` | the runner, manifest, and pack-local outputs live there |
| Runtime / model bring-up and asset generation | `infra/workstation` | machine/runtime integration remains infra-owned |
| Pack-local markdown artifacts | downstream derived output | useful for teachers/reviewers, but not reusable prompt canon |

The reusable Prompt Vault template IDs for this lane are:

- `teacher-prep-media-image-pack`
- `teacher-prep-media-storyboard`
- `teacher-prep-media-video-prompt`

Those names are the canonical reusable prompt references for the current lane.

## What the live runner proves now

The downstream live runner in `workstation-capabilities/apps/teacher-prep-media` already proves the bounded authority split truthfully:

- it resolves the canonical template identity from Prompt Vault by exact template name
- it records real `entity_version` values in Teaching Pack `prompt_provenance`
- it may record a real `execution_id` only when bounded Prompt Vault execution logging is intentionally enabled and the DB preflight passes
- it keeps pack-local outputs such as `image-prompts.md`, `storyboard/storyboard.md`, and `video-prompts/*.md` as derived artifacts rather than canonical reusable prompt storage
- it states this boundary explicitly in the downstream README/ADR and in the adapter implementation comments

That means the live runner did **not** expose a reusable prompt-authority gap that required new Prompt Vault schema or template storage changes.

## Important non-conclusions

### `execution_id = null` is not authority drift

In the current bounded bridge, `execution_id` may remain `null` when Prompt Vault execution logging is disabled.
That is a provenance/evidence posture choice, not a signal that prompt authority moved into `workstation-capabilities`.

Prompt authority is still anchored by:

- canonical template ID
- canonical Prompt Vault template body
- canonical template `entity_version`

### Local deterministic rendering does not move prompt canon

The current downstream adapter core still renders structured Teaching Pack outputs deterministically after resolving canonical Prompt Vault identity/version.
So editing a Prompt Vault template body alone does not yet fully redefine downstream rendering semantics.

That does **not** mean prompt canon moved.
It means the current downstream rendering contract is still partly code-shaped.
If future work wants template-body changes to drive more of the rendered Teaching Pack structure directly, that is a downstream bridge/renderer evolution task, not permission to create local prompt canon.

## Routing rule for future changes

Use this table before changing anything.

| If the change is about… | Change it in… | Why |
|---|---|---|
| reusable teacher-prep prompt wording, scope, or intent | Prompt Vault templates | canonical prompt-authoring truth lives here |
| exact Teaching Pack manifest shape, derived markdown formatting, or structured renderer behavior | `workstation-capabilities` | that repo owns the teacher-facing product/workflow contract |
| model/runtime health checks, asset generation, or bounded runtime bridge behavior | `infra/workstation` | runtime integration remains infra-owned |
| stronger execution-row capture guarantees for live runs | bounded Prompt Vault ↔ runner bridge work | evidence capture may expand without moving prompt canon |

## Operator rules

- Do **not** copy reusable teacher-prep prompt bodies into `workstation-capabilities` example packs, contracts, or docs as a new canonical source.
- Do **not** treat pack-local prompt-like markdown as reusable prompt authority.
- Do **not** treat a null `execution_id` as proof that the downstream repo owns prompt history.
- If a future live-runner change really requires new reusable prompt bodies or new governed authoring metadata, make that change here in Prompt Vault and keep downstream files as consumers.

## Completion signal

This note is sufficient when a cold-start operator can answer all of the following without reopening the whole FCOS/ADR chain:

1. where reusable teacher-prep prompts are canonical
2. what provenance the live runner may record truthfully today
3. why pack-local prompt-like artifacts remain derived only
4. why null `execution_id` values do not imply authoring cutover
5. which repo should own the next change depending on whether it is prompt, product, or runtime work

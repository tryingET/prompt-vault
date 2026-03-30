---
summary: "Checklist for modernizing older high-concept prompts before vault updates or Pi export."
read_when:
  - "Refreshing older prompt templates with lighter execution contracts."
  - "Deciding how much structure to add to an exported prompt."
type: "reference"
---

# Prompt retrofit checklist

Use this when modernizing older high-concept prompts before updating Prompt Vault or exporting to Pi.

## Goals
- keep the original cognitive force
- add enough contract to reduce execution drift
- avoid over-formalizing prompts that work best as concise lenses

## Required checks

### 1. Scope declaration
- What artifact is this for?
  - code review
  - architecture review
  - planning
  - runtime execution
  - document critique
- Is the prompt one-shot, iterative, or loop-oriented?
- Does it assume inspected repo state, or can it run abstractly?

### 2. Grounding expectations
- If it makes concrete bug claims, does it require file/line grounding?
- If evidence is absent, does it tell the model to label claims as hypotheses?
- Does it distinguish inspected reality from speculative diagnosis?

### 3. Output determinism
- Is there an explicit output format?
- Are ranking terms defined tightly enough to be used consistently?
- If the prompt uses custom scoring, is there a fallback when one dimension is unavailable?

### 4. Failure / fallback behavior
- What should happen if required tools, frameworks, or inputs are missing?
- Does the prompt fail closed, degrade gracefully, or switch to a bounded fallback mode?
- Are unavailable dependencies reported explicitly?

### 5. Operator ergonomics
- Is the prompt short enough to invoke comfortably from Pi?
- If not, should there be a short operator-facing version plus a long canonical contract?
- Are nested code fences or formatting likely to degrade editor UX?

### 6. Formalization threshold
Promote a prompt from evocative to more structured when at least one is true:
- repeated misexecution
- hidden assumptions that cause drift
- output shape matters for downstream automation
- missing inputs cause silent failure
- ranking/prioritization language is too ambiguous in practice

## Retrofit moves

### Light
- add scope line
- add assumptions block
- add output format
- add fallback rule

### Medium
- add mode selector
- add artifact-type calibration
- add prioritization table
- define rank dimensions explicitly

### Heavy
- split into short prompt + long contract
- convert to loop/procedure with phase semantics
- add companion evaluator or router

## Suggested vault-era defaults
- scope first
- grounding rule when evidence matters
- exact output format when downstream use matters
- explicit fallback when named tools/frameworks may be unavailable
- avoid inventing evidence

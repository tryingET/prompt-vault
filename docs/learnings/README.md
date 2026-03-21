---
summary: "How to capture and structure durable learnings in this repo."
read_when:
  - "Writing a new learning entry"
  - "Converting diary signals into crystallized learnings"
---

# Learnings

Capture crystallized reusable knowledge derived from repo work, not raw session logs and not canonical operational state.

## Authority boundary

- `docs/learnings/` stores **crystallized reusable knowledge**.
- It is derived from evidence such as session output, diary entries, validation results, and implementation artifacts.
- Promotion status itself should be tracked in `docs/dev/evidence-promotion-ledger.md` rather than inferred from whether a learning file exists.
- It is **not** a substitute for canonical operational state or external systems of record.
- When a learning needs to become normative or authoritative, promote it into the appropriate authority surface explicitly.

## Structure

- `YYYY-MM-DD-topic.md` — dated learning entries
- Link to TIPs if learning should propagate

## Template

```markdown
# [Topic]

## Context
What situation triggered this learning?

## Discovery
What did we learn?

## Evidence
How do we know it's true?

## Application
Where else does this apply?

## TIP Candidate
Should this become a TIP? Why/why not?
```

## Propagation

Learnings that apply beyond this project should be proposed as TIPs to the parent L1 templates.

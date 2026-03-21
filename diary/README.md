---
summary: "How to record repo-local diary entries as curated extraction for KES crystallization."
read_when:
  - "Starting a new diary entry"
  - "Reviewing diary filename and content conventions"
---

# Diary

Repo-local curated work log for KES (Knowledge Evolution System) crystallization.

## Authority contract

Use `./diary/` as the repo-local extraction layer for this repository.

- `./diary/` is **not** canonical KES state.
- Pi session JSONL is **forensic evidence**, not canonical state.
- `./diary/` entries are **human-curated extraction/work logs** derived from work performed in this repo.
- Canonical state must live only in **explicitly designated authority surfaces** (for example governed decision docs, contracts, or operational systems of record).

## Flow

```text
deep-review / working session
  -> Pi session JSONL (forensic evidence)
  -> docs/dev/evidence-promotion-ledger.md (explicit promotion state)
  -> diary entry (repo-local curated extraction)
  -> docs/learnings/ (crystallized reusable knowledge)
  -> TIPs or other authority surfaces when promotion is warranted
```

Promotion is never automatic: logs do not become canonical by convenience.
Promotion state should be recorded explicitly in `docs/dev/evidence-promotion-ledger.md`, not inferred from folder presence.

## Rules

- Entry file: `YYYY-MM-DD--type-scope-summary.md`
- Multiple sessions/day: `YYYY-MM-DD--type-scope-summary--2.md`
- Crystallize durable patterns to `docs/learnings/` and TIP proposals when they generalize
- Link to session evidence when useful, but label uncertainty instead of implying authority

Filename convention:
- Start from a commit-style header: `type(scope): summary`
- Slug it into filename-safe form: `type-scope-summary`

## Entry template

```markdown
# YYYY-MM-DD — [Session Focus]

## Scope
- [What repo-local problem this entry covers]

## Evidence
- [Relevant session JSONL, commands, outputs, or artifacts]

## What I Did
- [Actions]

## Interpretation
- [What matters, what remains uncertain, what should not be treated as canonical]

## Crystallization Candidates
- → docs/learnings/
- → TIP proposal
- → explicit authority surface (name it)
```

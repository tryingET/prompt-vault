---
summary: "Authority contract and operator guide for the evidence-promotion ledger JSON surface."
read_when:
  - "Clarifying whether a session has only evidence, diary extraction, learnings crystallization, or an intentional stop"
  - "Auditing what is automatic versus manual in the KES promotion flow"
---

# Evidence Promotion Ledger

This document explains the evidence-promotion authority contract.
The **canonical machine-readable ledger** lives at:

- `docs/dev/evidence-promotion-ledger.json`

Validate it with:

```bash
./scripts/pv-verify-evidence-promotion-ledger
```

## Authority contract

- Pi session JSONL remains **raw historical evidence**.
- `diary/` remains the **repo-local curated extraction layer**.
- `docs/learnings/` remains **crystallized reusable knowledge**.
- `docs/dev/evidence-promotion-ledger.json` is the **canonical repo-local record of promotion state** for this flow.
- Promotion state is explicit there, not inferred from folder presence or reconstructed from logs.

## What is automatic vs manual

### Automatic
- Pi writes session JSONL under `~/.pi/agent/sessions/**`.
- Operators may later inspect those logs as evidence.

### Manual
- Deciding that a session matters to the repo.
- Creating or updating a diary entry.
- Crystallizing a reusable learning.
- Escalating to TIPs or any stronger authority surface.
- Marking a session as intentionally skipped, partial, or superseded.

## Minimal sufficient model

Each ledger row records one session- or evidence-centered item and its current promotion state.
The goal is not to mirror all session content.
The goal is to make authority and workflow status explicit.

## Status vocabulary

- `evidence_only` — raw evidence exists; no deliberate repo promotion yet
- `diary_promoted` — evidence has been curated into a repo diary entry
- `learning_crystallized` — reusable knowledge was promoted into `docs/learnings/`
- `authority_promoted` — promoted further into a stronger authority surface
- `intentionally_skipped` — reviewed and deliberately not promoted further
- `superseded` — replaced by a later ledger item or stronger artifact

## JSON shape

```json
[
  {
    "id": "example-session-1",
    "repo": "core/prompt-vault",
    "evidence": {
      "type": "pi-session-jsonl",
      "session_id": "example-session-1",
      "path": "/absolute/path/to/session.jsonl"
    },
    "status": "learning_crystallized",
    "diary": ["diary/2026-03-21--example.md"],
    "learnings": ["docs/learnings/2026-03-21-example.md"],
    "authority_surfaces": [],
    "notes": "Short explanation of why this row has its current state.",
    "updated_at": "2026-03-21"
  }
]
```

## Rules

- Keep the authoritative state in the JSON file, not duplicated in Markdown.
- Use exact evidence file paths, not wildcard hints.
- Keep ids unique.
- Referenced repo paths in `diary`, `learnings`, and `authority_surfaces` must exist.
- If a stronger authority surface takes over, update the ledger row instead of relying on prose drift.

## Current authority surface

For the live rows, read:

- `docs/dev/evidence-promotion-ledger.json`

Do not duplicate the live ledger contents into this Markdown file; that recreates drift.

## Next high-leverage changes

1. Add a tiny repo-local helper that appends/updates ledger rows deterministically instead of hand-editing JSON.
2. Mirror this contract in adjacent AI Society repos where Pi session evidence and local KES artifacts coexist.
3. If the pattern recurs across repos, promote the contract into a TIP or Agent Kernel-level authority surface.

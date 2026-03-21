---
summary: "Machine-readable authority surface for promotion state across session evidence, diary extraction, and learnings crystallization."
read_when:
  - "Clarifying whether a session has only evidence, diary extraction, learnings crystallization, or an intentional stop"
  - "Auditing what is automatic versus manual in the KES promotion flow"
---

# Evidence Promotion Ledger

This file is the repo-visible authority surface for **promotion status**.
It exists to prevent Pi session JSONL recovery from being mistaken for canonical KES state.

## Authority contract

- Pi session JSONL remains **raw historical evidence**.
- `diary/` remains the **repo-local curated extraction layer**.
- `docs/learnings/` remains **crystallized reusable knowledge**.
- This ledger is the **canonical repo-local record of promotion state** for this flow.
- Promotion state is explicit here, not inferred from folder presence or reconstructed from logs.

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

Each row records one session- or evidence-centered item and its current promotion state.
The goal is not to mirror all session content.
The goal is to make authority and workflow status explicit.

## Status vocabulary

- `evidence_only` — raw evidence exists; no deliberate repo promotion yet
- `diary_promoted` — evidence has been curated into a repo diary entry
- `learning_crystallized` — reusable knowledge was promoted into `docs/learnings/`
- `authority_promoted` — promoted further into a stronger authority surface
- `intentionally_skipped` — reviewed and deliberately not promoted further
- `superseded` — replaced by a later ledger item or stronger artifact

## Ledger format

Keep the ledger as JSON for machine-readability and low ceremony.

```json
[
  {
    "id": "transcendent-1774084798685",
    "repo": "core/prompt-vault",
    "evidence": {
      "type": "pi-session-jsonl",
      "session_id": "transcendent-1774084798685",
      "path_hint": "~/.pi/agent/sessions/.../2026-03-21...jsonl"
    },
    "status": "learning_crystallized",
    "diary": [
      "diary/2026-03-21--loop-transcendent-start--2.md",
      "diary/2026-03-21--loop-transcendent-phase.md",
      "diary/2026-03-21--loop-transcendent-phase--2.md",
      "diary/2026-03-21--loop-transcendent-phase--3.md",
      "diary/2026-03-21--loop-transcendent-phase--4.md",
      "diary/2026-03-21--loop-transcendent-phase--5.md",
      "diary/2026-03-21--loop-transcendent-phase--6.md",
      "diary/2026-03-21--loop-transcendent-phase--7.md",
      "diary/2026-03-21--loop-transcendent-phase--8.md"
    ],
    "learnings": [
      "docs/learnings/2026-03-21-session-jsonl-is-forensic-evidence-not-kes-state.md"
    ],
    "authority_surfaces": [],
    "notes": "Transcendent loop established the authority boundary and identified the need for an explicit promotion ledger.",
    "updated_at": "2026-03-21"
  }
]
```

## Current ledger

```json
[
  {
    "id": "transcendent-1774077372012",
    "repo": "core/prompt-vault",
    "evidence": {
      "type": "pi-session-jsonl",
      "session_id": "transcendent-1774077372012",
      "path_hint": "~/.pi/agent/sessions/--home-tryinget-ai-society-core-prompt-vault--/*.jsonl"
    },
    "status": "superseded",
    "diary": [
      "diary/2026-03-21--loop-transcendent-start.md",
      "diary/2026-03-21--loop-transcendent-phase.md",
      "diary/2026-03-21--loop-transcendent-phase--2.md",
      "diary/2026-03-21--loop-transcendent-phase--3.md",
      "diary/2026-03-21--loop-transcendent-phase--4.md",
      "diary/2026-03-21--loop-transcendent-phase--5.md",
      "diary/2026-03-21--loop-transcendent-complete.md"
    ],
    "learnings": [],
    "authority_surfaces": [],
    "notes": "First transcendent pass identified the authority problem but ended in a failed completion state and was superseded by the refined second pass.",
    "updated_at": "2026-03-21"
  },
  {
    "id": "transcendent-1774084798685",
    "repo": "core/prompt-vault",
    "evidence": {
      "type": "pi-session-jsonl",
      "session_id": "transcendent-1774084798685",
      "path_hint": "~/.pi/agent/sessions/--home-tryinget-ai-society-core-prompt-vault--/*.jsonl"
    },
    "status": "learning_crystallized",
    "diary": [
      "diary/2026-03-21--loop-transcendent-start--2.md",
      "diary/2026-03-21--loop-transcendent-phase--6.md",
      "diary/2026-03-21--loop-transcendent-phase--7.md",
      "diary/2026-03-21--loop-transcendent-phase--8.md",
      "diary/2026-03-21--loop-transcendent-phase--9.md",
      "diary/2026-03-21--loop-transcendent-phase--10.md",
      "diary/2026-03-21--loop-transcendent-complete--2.md"
    ],
    "learnings": [
      "docs/learnings/2026-03-21-session-jsonl-is-forensic-evidence-not-kes-state.md"
    ],
    "authority_surfaces": [],
    "notes": "Second transcendent pass clarified that JSONL is evidence only and that promotion state must be explicit rather than reconstructed.",
    "updated_at": "2026-03-21"
  }
]
```

## Next high-leverage changes

1. Add a tiny repo-local helper that appends/updates ledger rows deterministically instead of hand-editing JSON.
2. Mirror this contract in adjacent AI Society repos where Pi session evidence and local KES artifacts coexist.
3. If the pattern recurs across repos, promote the contract into a TIP or Agent Kernel-level authority surface.

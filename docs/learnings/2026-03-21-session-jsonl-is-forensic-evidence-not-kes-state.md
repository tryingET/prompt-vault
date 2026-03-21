---
summary: "Session JSONL is forensic evidence; diary and learnings remain deliberate KES promotion steps."
date: "2026-03-21"
read_when:
  - "Clarifying whether Pi session JSONL counts as KES state"
  - "Defining evidence vs diary vs learning authority boundaries"
---

# Session JSONL is forensic evidence, not KES state

## Context
We reviewed how `/deep-review` output is stored and propagated in the current Prompt Vault / AI Society stack.
The practical question was whether deep-review findings in `~/.pi/agent/sessions/*.jsonl` automatically become diary entries, KES artifacts, or crystallized learnings.

## Discovery
Pi session JSONL is an automatically captured historical record, but it is not KES completion by itself.

The current implemented flow is:

```text
deep-review / working session
  -> Pi session JSONL (forensic evidence)
  -> docs/dev/evidence-promotion-ledger.md (explicit promotion state)
  -> diary entry (repo-local curated extraction)
  -> docs/learnings/ (crystallized reusable knowledge)
  -> TIPs or other authority surfaces when promotion is warranted
```

The important boundary is:
- session JSONL = raw forensic evidence / conversation history
- `diary/` = repo-local curated extraction
- `docs/learnings/` = crystallized reusable knowledge
- canonical operational or normative state must live in explicitly designated authority surfaces

## Evidence
- Pi session docs describe `~/.pi/agent/sessions/` as auto-saved session JSONL history.
- Real deep-review sessions in `~/.pi/agent/sessions/--home-tryinget-ai-society-core-prompt-vault--/` contain deep-review output and crystallized-learning sections as assistant message text, not as KES-native records.
- This repo already has a repo-local KES structure:
  - `diary/README.md`
  - `docs/learnings/README.md`
- Prior guidance in AI Society template/KES docs says session output must be deliberately moved through diary and then into learnings.

## Application
Use this rule whenever a session log is tempting to treat as “good enough” authority:
- cite session JSONL as evidence when useful
- do not treat it as canonical KES state
- create a diary entry when the session matters locally
- create a learnings doc when the pattern is reusable
- promote to TIPs or stronger authority surfaces only when warranted

## TIP Candidate
Maybe.
This likely generalizes beyond Prompt Vault because the same confusion can recur anywhere Pi session logs, diary capture, and authority surfaces coexist.
A TIP would be justified if the same session-log/authority confusion appears in multiple repos or tooling surfaces.

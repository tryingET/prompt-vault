---
summary: "Prompt Vault overview, architecture, and usage entrypoint."
read_when:
  - "Onboarding to this repository"
  - "Looking for command and integration overview"
---

# Prompt Vault

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dolt](https://img.shields.io/badge/Database-Dolt-blue)](https://www.dolthub.com/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

**Version-controlled prompt templates with SQL, Git semantics, and analytics.**

Prompt Vault now treats prompt semantics as ontology, not tags: primary classification lives in facets, governed orchestration semantics live in `controlled_vocabulary`, and organizational visibility lives in `owner_company` + `visibility_companies`.

Prompts are programs. They deserve the same rigor as code: version control, testing, metrics, and collaborative review.

Prompt Vault treats prompts as structured data in a SQL database with Git-style version control. Every prompt has a history. Every change is tracked. Every execution measured.

## Current reality

- Prompt Vault is now facet-native on schema v9 (`artifact_kind`, `control_mode`, `formalization_level`) with governed router vocabulary and company visibility.
- Aggregate-only quality rollups now cover multi-valued router semantics (`selection_principles`) and company visibility (`visibility_companies`) without previewing private captured output.
- Ontology verification now fails closed if seed-contract metadata starts carrying prompt-body content or if the ontology index stops stating the DB-only authoring boundary explicitly.
- Reusable procedure coverage now includes `concern-first-review-fanout` and `owner-repo-boundary-note` for recurring governance and authority-boundary workflows.
- The canonical Pi integration lives in `~/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`.
- Shared runtime registry bridges and Pi-side local receipts/telemetry are downstream runtime concerns, not Prompt Vault authority surfaces; Prompt Vault exports schema-governed execution facts and privacy-safe aggregate observability.
- The teacher-prep media live runner still points reusable prompt authority back to Prompt Vault: downstream Teaching Packs may record live `entity_version` and optional `execution_id` provenance, but pack-local prompt-like artifacts remain derived output only.
- Current health should be derived from deterministic checks and analytics commands, not from a separate `status.md` mirror.
- ROCS repo checks now run through `./scripts/rocs.sh` against workspace-local ontology layer paths; the repo no longer depends on a vendored GitLab-locator compatibility path.
- Repo-local Agent Kernel task/work-item access now goes through `./scripts/ak.sh`, which prefers vendored or workspace-core Agent Kernel CLI paths before falling back to `ak` on `PATH`.
- Keep repo-level orientation DRY in this `README.md`; keep live execution/task authority in AK or other canonical machine surfaces.

## The Problem

You have dozens of prompts scattered across files, chat history, and notes. You iterate on them constantly but can't answer:

- Which version performed best?
- What changed between last week and today?
- Who wrote this and why?
- Which prompts need work?

Flat files can't answer these. Git gives you file history, not prompt history. There's no feedback loop.

## The Solution

A Dolt database where prompts are rows, not files.

```
prompt_templates: id, name, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, controlled_vocabulary, version, status
executions:       id, entity_type, entity_id, output_capture_mode, output_text, latency_ms, success, input_tokens, output_tokens
feedback:         id, execution_id, rating, notes, issues
```

Dolt is Git for data. You get branches, merges, diffs, and rollback—per prompt, not per file. Query history with SQL. Collaborate via DoltHub PRs. Track what works.

## Quick Start

```bash
./scripts/pv init        # Create the database
./scripts/pv import      # Pull in existing pi templates
./scripts/pv templates   # List what you have
./scripts/pv search review                 # Find by content
./scripts/pv templates visibility_company=software  # What software can see

./scripts/pv branch experiment/faster-review   # Try something new
./scripts/pv edit-template code-review         # Make changes
./scripts/pv diff main experiment/faster-review # Compare
./scripts/pv merge experiment/faster-review    # Ship it

./scripts/pv exec code-review "Button.tsx"  # Run with tracking
./scripts/pv rate 42 4 "Good but missed error handling"  # Leave feedback
./scripts/pv stats       # See what's working
```

## Mental Model

**Prompts are intellectual property that compound.** Every execution teaches you something. Without a system, that knowledge evaporates.

```
┌─────────────────────────────────────────────────────────┐
│                     FEEDBACK LOOP                        │
│                                                          │
│   write ──► execute ──► measure ──► learn ──► iterate   │
│     ▲                                              │      │
│     └──────────────────────────────────────────────┘      │
│                                                          │
│   Each cycle makes every prompt better.                  │
│   Vault closes the loop.                                 │
└─────────────────────────────────────────────────────────┘
```

**Three primitives:**

| Primitive | Purpose | Command |
|-----------|---------|---------|
| Template | A reusable prompt | `pv templates`, `pv show`, `pv edit-template` |
| Execution | A template invocation with metrics | `pv exec`, `pv stats` |
| Feedback | Human judgment on quality | `pv rate`, `pv quality` |

**Version control at entity level:**

```bash
./scripts/pv history template code-review      # See the tracked history for this prompt
./scripts/pv rollback template code-review HEAD~1   # Restore from a prior Dolt commit
./scripts/pv diff HEAD~1 HEAD                  # What changed in the last commit
./scripts/pv tag release v1.2.0                # Snapshot for reproducibility
```

## Schema

Six tables. Everything you need, nothing you don't.

```
prompt_templates ──► executions ──► feedback
        │
        └──► collections (grouping)

skills ──► skill_assets
```

| Table | Purpose |
|-------|---------|
| `prompt_templates` | The prompts themselves |
| `skills` | Complex multi-file capabilities |
| `skill_assets` | Supporting files for skills |
| `executions` | Every time a prompt runs |
| `feedback` | Human ratings and notes |
| `collections` | Logical groupings |

## Commands

**Daily use:**
```bash
./scripts/pv templates              # List all
./scripts/pv show template review   # View one
./scripts/pv search "security"      # Find by content
./scripts/pv edit-template review   # Modify
./scripts/pv commit "clarify steps" # Save
```

**Experimentation:**
```bash
./scripts/pv branch experiment/x    # Try something
./scripts/pv diff main experiment/x # Compare
./scripts/pv merge experiment/x     # Ship winner
```

**Analytics:**
```bash
./scripts/pv stats                  # Usage overview
./scripts/pv analytics outputs      # Safe output-capture summary + public previews only
./scripts/pv quality dashboard      # Health scores + evidence gaps
./scripts/pv quality coverage       # Feedback/capture coverage by active entity
./scripts/pv quality rollup control_mode  # Aggregate quality/evidence by facet
./scripts/pv quality rollup routing_context  # Aggregate quality/evidence by exact-one router vocabulary
./scripts/pv quality rollup selection_principles  # Aggregate quality/evidence by multi-valued router semantics
./scripts/pv quality rollup visibility_companies  # Aggregate quality/evidence by multi-valued company visibility
./scripts/pv exec x "arg"           # Run with tracking
./scripts/pv rate <id> 4 "notes"    # Record feedback
```

**Export:**
```bash
./scripts/pv export                    # pi format
./scripts/pv export-fmt typescript     # TS constants
./scripts/pv export-fmt python         # Python module
./scripts/pv integrate langchain out   # LangChain ready
```

## Requirements

- Dolt 0.40+ — `brew install dolt`
- bash 4.0+
- jq
- fzf (optional, for TUI)

## Verification

```bash
./verify.sh                              # quick contract smoke suite
PV_VERIFY_FULL=1 ./verify.sh             # quick suite + full bats suite
./scripts/ak.sh --doctor                 # repo-local AK launcher resolution
./scripts/pv-verify-evidence-promotion-ledger
./scripts/pv-bats tests/                 # full suite with repo-local TMPDIR
```

## Documentation

| File | When to Read |
|------|--------------|
| [QUICKSTART.md](QUICKSTART.md) | Get started in 5 minutes |
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes |
| [WORKFLOWS.md](docs/WORKFLOWS.md) | Team collaboration, CI/CD, advanced patterns |
| [COMPARISON.md](docs/COMPARISON.md) | Deciding vault vs flat files |
| [CRYSTALLIZED.md](docs/CRYSTALLIZED.md) | Patterns, anti-patterns, lessons learned |
| [Runtime-registry + observability boundary](docs/dev/shared-runtime-registry-and-execution-observability-boundary.md) | What Prompt Vault exports canonically versus runtime-local receipt/telemetry discovery |
| [Teacher-prep media prompt-authority boundary](docs/dev/teacher-prep-media-prompt-authority-boundary.md) | Clarify how the live teacher-prep runner records Prompt Vault provenance without creating local shadow prompt canon |
| [Fuzzy selector troubleshooting](docs/reference/fuzzy-selector-troubleshooting.md) | PTX or vault selectors report "selection unavailable" / fzf issues |

## Pi Integration

The canonical pi integration now lives in the monorepo package:

- `~/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`

**Human Commands:**
```
/vault                         # Open picker with all visible templates
/vault meta-orchestration      # Exact-name load into the editor
/vault:meta-orchestration      # Live picker / exact-name transform path
/vault-search bug              # Search visible template content
/route I'm stuck on X          # Load routing prompt via meta-orchestration
/vault-stats                   # Show visible execution statistics
/vault-check                   # Show schema/company/visibility diagnostics
/vault-live-telemetry          # Show recent live /vault: trigger telemetry
/vault-fzf-spike              # Probe selector runtime viability
```

**Picker UX:** `/vault` opens the full visible picker, `/vault <query>` falls back to picker mode with that query, and `/vault:<query>` uses the shared interaction runtime for live or exact-name selection. Use explicit `::context` when you want additional context injected into the prepared prompt.

**Live typing trigger (optional):** if the pi-interaction trigger surfaces are loaded (`@tryinget/pi-trigger-adapter` / `@tryinget/pi-interaction`), typing `/vault:` in the editor can open the live picker after a short debounce. `/vault` still works without the live trigger.

**LLM Tools (autonomous access):**
```
vault_schema_diagnostics()
vault_query({ artifact_kind: ["cognitive"], limit: 3 })
vault_retrieve({ names: ["inversion", "nexus"], include_content: true })
vault_vocabulary()
vault_insert({ name: "my-tool", content: "...", artifact_kind: "procedure", control_mode: "one_shot", formalization_level: "structured", owner_company: "core", visibility_companies: ["core"] })
vault_update({ name: "my-tool", description: "Refined description" })
vault_executions({ template_name: "inversion", limit: 10 })
vault_rate({ execution_id: 42, rating: 4, success: true })
```

**Governed Vocabulary:**
Use `./scripts/pv vocabulary` to inspect ontology facets, controlled vocabulary, and company visibility contracts.

## Maintenance

```bash
./scripts/pv cleanup 30             # Remove executions older than 30 days
./scripts/pv cleanup 30 --dry-run   # Preview cleanup
./scripts/pv migrate status         # Check schema version
./scripts/pv backup create          # Create backup
./scripts/pv backup list            # List backups
```

## Philosophy

Most prompt engineering is faith-based. You write a prompt, use it, hope it works. No metrics. No history. No learning.

Vault closes the loop. Every prompt has a past. Every execution leaves evidence. Every judgment gets recorded. Over time, patterns emerge. Weak prompts reveal themselves. Strong ones compound.

The database is small. The impact is not.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Contributing

1. Read [CRYSTALLIZED.md](docs/CRYSTALLIZED.md) for patterns and conventions
2. Run `./verify.sh` before submitting changes
3. Follow conventional commit format

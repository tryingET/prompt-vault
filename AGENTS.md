---
summary: "Repo-specific operating guardrails and command references for prompt-vault."
read_when:
  - "Starting work in prompt-vault"
  - "Before running repo-specific workflows or changing docs policy"
---

# AGENTS.md — prompt-vault

## Intent
Version-controlled prompt templates using Dolt SQL database with Git semantics, analytics, and A/B testing.

## Current State
- **Verification:** derive current health from `README.md`, `./verify.sh`, and the quality/analytics commands rather than a `status.md` mirror
- **Schema:** v13; retrieval telemetry lives in a SQLite sidecar (`analytics.db`, append-only) rather than the versioned store, alongside ontology facets (`artifact_kind` / `control_mode` / `formalization_level`), governed `controlled_vocabulary`, company visibility, and execution output capture

## Guardrails
- No secrets in git.
- Treat `docs/_core/**` as immutable.
- Run `./verify.sh` before committing changes.

## Project-Specific

### Core Commands
```bash
./scripts/pv templates              # List all templates
./scripts/pv show template <name>   # View template
./scripts/pv search <query>         # Search content
./scripts/pv vocabulary             # Show governed vocabulary / contract values
./scripts/pv cleanup 30             # Remove old execution logs
./scripts/pv migrate status         # Check schema version
```

### Schema
```
prompt_templates: id, name, content, description, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, controlled_vocabulary, version, status
executions:       id, entity_type, entity_id, output_capture_mode, output_text, latency_ms, success
feedback:         id, execution_id, rating, notes, issues
schema_version:   id, version, description, applied_at
```

### Pi Integration
The canonical vault-client package now lives at:

- `~/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`

**Human Commands:**
- `/vault` — Open picker with all visible templates or exact-load a visible name
- live `/vault:` — Use the shared interaction runtime for exact-name/live selection
- `/vault-search <query>` — Search visible template content
- `/route <context>` — Load routing prompt
- `/vault-stats` — Usage statistics
- `/vault-check` — Schema/company/visibility diagnostics
- `/vault-live-telemetry` — Live trigger telemetry
- `/vault-fzf-spike` — Selector runtime probe

**LLM Tools:**
- `vault_schema_diagnostics()` — Report schema compatibility details
- `vault_query({ artifact_kind, control_mode, formalization_level, owner_company, visibility_company, controlled_vocabulary, intent_text, limit, include_content })` — Query by governed facets/visibility semantics
- `vault_retrieve({ names, include_content })` — Get templates by name
- `vault_vocabulary()` — List governed ontology, controlled-vocabulary, and company values
- `vault_insert({ name, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, ... })` — Insert with governed validation
- `vault_update({ name, ...patch })` — Explicit in-place update path
- `vault_executions({ template_name, limit })` — List execution provenance rows
- `vault_rate({ execution_id, rating, success, notes })` — Rate an exact execution row

### Governed Vocabulary
Templates are governed by:
- ontology facets (`artifact_kind`, `control_mode`, `formalization_level`)
- controlled vocabulary for routers (`controlled_vocabulary`)
- company visibility (`owner_company`, `visibility_companies`)

### Key Files
| File | Purpose |
|------|---------|
| `scripts/pv` | Main CLI |
| `scripts/pv-tag-templates` | Bulk tag templates |
| `schema/schema.sql` | Database schema |
| `verify.sh` | Quick verification suite |
| `docs/CRYSTALLIZED.md` | Patterns and learnings |

## Deterministic tooling policy (ROCS-first)
- Prefer `./scripts/rocs.sh <args...>` before ad-hoc inline scripting.
- Use `./scripts/pv` for all vault operations.
- Use `./verify.sh` for validation.
- Any surface described as machine-readable authority must live in a parseable machine file, not only in Markdown fences.
- Rollups over governed dimensions must encode the governing entity-class predicate explicitly (for example router vocabulary implies `control_mode=router`).

## Agent discoverability
- Repo-specific operator knowledge should live primarily in repo-owned skills under `.pi/skills/`.
- Repo-specific explicit invocation helpers should live under `.pi/prompts/` when a named entrypoint is useful.
- Keep this `AGENTS.md` focused on repo policy and canonical references; do not duplicate the full operator playbook here when a repo-owned skill or canonical doc is the better home.

## Knowledge Crystallization Flow

```
Session → evidence-promotion-ledger.json (explicit state) → diary/ (curated extraction) → docs/learnings/ (crystallized) → TIPs (propagated)
```

See `docs/CRYSTALLIZED.md` for extracted patterns and anti-patterns.

## Recursion policy (explicit)
Allowed:
- L1 -> L2

Forbidden:
- L1 -> L0
- L2 -> L1
- any cycle


## Direction workflow
- When this repo's direction docs under `docs/project/` change, or when current posture needs verification, use `ak direction import|check|export` from the repo root.
- Treat `ak direction check` as the authority-reconciliation gate between repo direction docs and AK's structured direction substrate.

## Read order
1) `README.md` — Project overview + current reality
2) `QUICKSTART.md` — Get started in 5 minutes
3) `docs/CRYSTALLIZED.md` — Design decisions and patterns
4) `docs/WORKFLOWS.md` — Team collaboration patterns
5) `next_session_prompt.md` — Current handoff and next slice

## Quick reference for agents

**To find templates by purpose:**
```
vault_query({ artifact_kind: ["cognitive"], limit: 5 })
vault_query({ control_mode: ["router"], formalization_level: ["structured"] })
vault_query({ intent_text: "security review hardening" })
```

**To get a template:**
```
vault_retrieve({ names: ["inversion"], include_content: true })
```

**To inspect governed values:**
```
vault_vocabulary()
```

# AGENTS.md — prompt-vault

## Intent
Version-controlled prompt templates using Dolt SQL database with Git semantics, analytics, and A/B testing.

## Current State
- **Templates:** 50 (30 cognitive, 20 task) — all tagged
- **Verification:** 34/34 checks pass
- **Version:** v1.2.0

## Guardrails
- No secrets in git.
- Never push to `main`; MRs only.
- Treat `docs/_core/**` as immutable.
- Run `./verify.sh` before committing changes.

## Project-Specific

### Core Commands
```bash
./scripts/pv templates              # List all templates
./scripts/pv show template <name>   # View template
./scripts/pv search <query>         # Search content
./scripts/pv vocabulary             # Show tag vocabulary
./scripts/pv cleanup 30             # Remove old execution logs
./scripts/pv migrate status         # Check schema version
```

### Schema
```
prompt_templates: id, name, content, description, tags (JSON), type, version, status
executions:       id, entity_type, entity_id, latency_ms, success
feedback:         id, execution_id, rating, notes, issues
schema_version:   id, version, description, applied_at
```

### Pi Integration
The vault-client extension at `~/.pi/agent/extensions/vault-client/` connects pi directly:

**Human Commands:**
- `/vaults` — List all templates
- `/vault:name` — Load template (Tab for autocomplete)
- `/vault-search query` — Search content
- `/route <context>` — Get tool recommendation
- `/vault-stats` — Usage statistics

**Autocomplete:** Type `/vault:` and press Tab to see template suggestions.

**LLM Tools:**
- `vault_query({ tags, keywords, limit, include_content })` — Query by tags/keywords
- `vault_retrieve({ names, include_content })` — Get templates by name
- `vault_vocabulary()` — List tag vocabulary
- `vault_insert({ name, content, description, tags, source, confirm_new_tags })` — Insert with validation
- `vault_rate({ template_name, rating, success, notes })` — Rate for feedback

### Tag Vocabulary
Templates are tagged with namespaced values:

| Namespace | Purpose | Values |
|-----------|---------|--------|
| `action:` | What the tool does | invert, reduce, expand, generate, validate, project, crystallize, control, mode |
| `phase:` | When to apply | sensemaking, hypothesis, probing, validation, execution |
| `formalization:` | Rigor level | napkin (0-1), bounded (2), structured (3), workflow (4) |
| `domain:` | Subject area | backend, frontend, infrastructure, security, governance, planning |
| `scope:` | Application level | self, code, system, portfolio |

### Key Files
| File | Purpose |
|------|---------|
| `scripts/pv` | Main CLI |
| `scripts/pv-tag-templates` | Bulk tag templates |
| `schema/schema.sql` | Database schema |
| `verify.sh` | 34 verification checks |
| `docs/CRYSTALLIZED.md` | Patterns and learnings |

## Deterministic tooling policy (ROCS-first)
- Prefer `./scripts/rocs.sh <args...>` before ad-hoc inline scripting.
- Use `./scripts/pv` for all vault operations.
- Use `./verify.sh` for validation.

## Knowledge Crystallization Flow

```
Session → diary/ (raw) → docs/learnings/ (crystallized) → TIPs (propagated)
```

See `docs/CRYSTALLIZED.md` for extracted patterns and anti-patterns.

## Recursion policy (explicit)
Allowed:
- L1 -> L2

Forbidden:
- L1 -> L0
- L2 -> L1
- any cycle

## Read order
1) `README.md` — Project overview
2) `QUICKSTART.md` — Get started in 5 minutes
3) `docs/CRYSTALLIZED.md` — Design decisions and patterns
4) `docs/project/tactical_goals.md` — Current work items
5) `docs/WORKFLOWS.md` — Team collaboration patterns
6) `docs/dev/status.md` — Health metrics

## Quick reference for agents

**To find templates by purpose:**
```
vault_query({ tags: ["action:invert"] })     # Find inversion tools
vault_query({ tags: ["phase:validation"] })  # Find validation tools
vault_query({ keywords: ["security"] })      # Search by keyword
```

**To get a template:**
```
vault_retrieve({ names: ["inversion"], include_content: true })
```

**To see available tags:**
```
vault_vocabulary()
```

# AGENTS.md — prompt-vault

## Intent
Version-controlled prompt templates using Dolt SQL database with Git semantics, analytics, and A/B testing.

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
./scripts/pv cleanup 30             # Remove old execution logs
./scripts/pv migrate status         # Check schema version
```

### Schema
```
prompt_templates: id, name, content, description, tags, version, status
executions:       id, entity_type, entity_id, latency_ms, success
feedback:         id, execution_id, rating, notes, issues
schema_version:   id, version, description, applied_at
```

### Pi Integration
The vault-client extension at `~/.pi/agent/extensions/vault-client/` connects pi directly:
- `/vaults` — List all templates
- `/vault:name` — Load template
- `/route <context>` — Get tool recommendation

### Key Files
| File | Purpose |
|------|---------|
| `scripts/pv` | Main CLI |
| `schema/schema.sql` | Database schema |
| `verify.sh` | 33 verification checks |
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
3) `docs/CRYSTALLIZED.md` — Design decisions
4) `docs/WORKFLOWS.md` — Team collaboration patterns
5) `docs/_core/` — Vendored governance
6) `diary/` — Recent work sessions

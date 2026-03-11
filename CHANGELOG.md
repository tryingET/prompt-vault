---
summary: "Versioned record of notable project changes."
read_when:
  - "Preparing releases"
  - "Auditing what changed between versions"
---

# Changelog

> [← Back to README](README.md) · [Workflows](docs/WORKFLOWS.md) · [Patterns](docs/CRYSTALLIZED.md)

All notable changes to prompt-vault are documented here.

## [Unreleased]

### Added

- `docs/dev/fzf-spike-slice0.md` with cross-context fzf viability evidence for ADR-0001.
- `docs/dev/slice4-validation-matrix.md` with mixed-session smoke and failure-mode evidence.

### Changed

- Prompt-vault-side client boundary docs were normalized to the current schema-v9 contract (commands, diagnostics, execution-bound rating, and trigger-surface wording).
- Historical validation and relocation notes were marked more explicitly as historical where they still reference pre-monorepo or pre-v9 integration phases.
- Canonical `prompt-vault-db` recovered from `~/programming/archive/prompt-vault-db` after reinit drift (50 active templates restored).
- Namespaced tag vocabulary reapplied across all templates (`action:`, `phase:`, `formalization:`, `domain:`, `scope:`) and revalidated via `pv vocabulary`.
- `next-10-expert-suggestions` recovered from session history with command-first framework-grounding refinements.
- `docs/decisions/ADR-0001-unified-fzf-selection-ptx-vault-client.md` updated to reflect Slice 0-4 completion and validated checklist.
- Vault-client query hardening closeout verified post-`/reload` (live `limit=5` keyword lookup success, explicit backend failure signaling contract, fresh extension test pass).
- `next_session_prompt.md` and `docs/dev/status.md` updated to reflect that no deferred hardening contract items remain.
- Added canonical deferred-contract registry at [[docs/dev/deferred-contracts.md]] to keep deferrals DRY and auditable.
- Pi integration command/selector docs were normalized and de-duplicated across [[README.md]], [[QUICKSTART.md]], and [[docs/reference/fuzzy-selector-troubleshooting.md]] (current picker UX, `/vault-browse`, and optional live `/vault:` trigger).
## [1.2.0] - 2026-03-03

### LLM Tools & Tag Vocabulary

Added autonomous LLM access to the vault and comprehensive tagging system.

### Added

- **5 LLM Tools for autonomous vault access:**
  - `vault_query({ tags, keywords, limit, include_content })` — Query templates by tags and/or keywords
  - `vault_retrieve({ names, include_content })` — Retrieve templates by exact names
  - `vault_vocabulary()` — List all tags grouped by namespace
  - `vault_insert({ name, content, description, tags, source, confirm_new_tags })` — Insert with vocabulary validation
  - `vault_rate({ template_name, rating, success, notes })` — Rate template for feedback loop

- **Tag vocabulary for all 50 templates:**
  - `action:` — What the tool does (invert, reduce, expand, generate, validate, project, crystallize, control, mode)
  - `phase:` — When to apply (sensemaking, hypothesis, probing, validation, execution)
  - `formalization:` — Rigor level (napkin, bounded, structured, workflow)
  - `domain:` — Subject area (backend, frontend, infrastructure, security, governance, planning)
  - `scope:` — Application level (self, code, system, portfolio)

- **`pv vocabulary` command** — Show tag vocabulary with counts

- **`pv-tag-templates` script** — Bulk tag templates with vocabulary

### Changed

- **import-cognitive-tools.sh** — Now reads tags from YAML frontmatter

- **vault-client extension** — Added 5 new tools alongside existing human commands

- **AGENTS.md** — Updated with tools reference and tag vocabulary

### Files Changed

```
~/.pi/.../vault-client/index.ts   +350 (5 new LLM tools)
scripts/pv-tag-templates          new (bulk tagging)
scripts/pv                        +35 (vocabulary command)
scripts/import-cognitive-tools.sh +25 (frontmatter tags)
AGENTS.md                         updated
README.md                         updated
QUICKSTART.md                     updated
```

---

## [1.1.0] - 2026-02-27

### Deep Review Session

Applied full adversarial stack (INVERSION + TELESCOPIC + NEXUS + AUDIT + BLAST RADIUS + ESCAPE HATCH + KNOWLEDGE CRYSTALLIZATION).

### Fixed

#### Critical
- **CSV parser silent corruption** — Switched vault-client from CSV to JSON output (`dolt sql -r json`). The naive `line.split(",")` parser corrupted any content containing commas, quotes, or newlines. ([#critical](docs/CRYSTALLIZED.md#anti-patterns-found))

- **No schema versioning** — Added `schema_version` table to track migrations. Without this, schema changes would corrupt existing databases with no recovery path.

#### High
- **Incomplete SQL escaping** — Fixed `sql_escape()` in pv-lib.sh to handle backslash-quote sequences (`\'`) and null bytes (`\x00`). Previous implementation only handled single quotes.

- **No template validation** — Added validation at import time with size limits (1MB max) and proper escaping.

#### Medium
- **No execution cleanup** — Added `pv cleanup` command to remove old execution logs.

- **Hardcoded paths** — Made `VAULT_DIR` configurable via environment variable in vault-client extension.

### Added

- **`pv cleanup` command** — Remove execution logs older than N days
  ```bash
  ./scripts/pv cleanup 30           # Delete executions older than 30 days
  ./scripts/pv cleanup 30 --dry-run # Preview what would be deleted
  ```

- **Schema version tracking** — New `schema_version` table with migration support
  ```bash
  ./scripts/pv migrate status       # Check current schema version
  ./scripts/pv migrate up           # Run pending migrations
  ./scripts/pv migrate create <name> # Create new migration file
  ```

- **`migrations/` directory** — For future database migrations

- **Adversarial test cases** — Tests for edge cases: commas, unicode, backslash-quote, null bytes, long strings

- **docs/CRYSTALLIZED.md** — Patterns, anti-patterns, heuristics, and lessons learned from development

### Changed

- **vault-client extension** — Complete rewrite with:
  - JSON parsing instead of CSV (prevents silent corruption)
  - Proper SQL escaping (handles all edge cases)
  - Schema version checking on load
  - Configurable `VAULT_DIR` via environment variable
  - Better error logging

- **import-cognitive-tools.sh** — Improved with:
  - Template validation (size limits)
  - Proper SQL escaping via `sql_escape()`
  - Tag extraction from content
  - Import statistics reporting

- **pv-migrate** — Rewritten to use `schema_version` table instead of separate `schema_migrations` table

- **pv-lib.sh** — Enhanced `sql_escape()` to handle:
  - Backslash escaping (`\` → `\\`)
  - Null byte removal
  - Added `sql_decode_base64()` for round-trip testing

- **README.md** — Added Pi Integration and Maintenance sections

- **SKILL.md** — Added cleanup and migrate commands to essentials

### Documentation

- **docs/CRYSTALLIZED.md** — New file documenting:
  - Patterns discovered (Dolt as app DB, JSON over CSV, schema versioning)
  - Anti-patterns found (naive CSV parsing, error swallowing, hardcoded paths)
  - Surprises (test data too tame, Dolt commit errors common)
  - Heuristics validated
  - Caveats and breaking conditions
  - Codification actions for contributors

### Files Changed

```
schema/schema.sql                 +18  (schema_version table)
scripts/import-cognitive-tools.sh +107 (validation, escaping)
scripts/pv                        +62  (cleanup command)
scripts/pv-lib.sh                 +14  (better escaping)
scripts/pv-migrate                +68  (schema_version support)
tests/pv-lib.bats                 +40  (adversarial tests)
docs/CRYSTALLIZED.md              +145 (new)
migrations/.gitkeep               (new)
README.md                         +14  (integration, maintenance)
SKILL.md                          +4   (cleanup, migrate)
next_session_prompt.md            updated

~/.pi/.../vault-client/index.ts   rewritten (393 lines)
```

### Rollback

```bash
# If extension breaks pi
rm -rf ~/.pi/agent/extensions/vault-client

# If vault corrupted
cd prompt-vault-db && dolt reset --hard HEAD~1

# Full reset
rm -rf prompt-vault-db && ./scripts/pv init && ./scripts/import-cognitive-tools.sh
```

---

## [1.0.0] - 2026-02-27

### Initial Release

- Dolt-backed prompt template storage
- 50 templates (30 cognitive, 20 task)
- Pi integration via vault-client extension
- CLI with 30+ commands
- Execution tracking and feedback
- Branch/merge for A/B testing
- Export to multiple formats
- Verification suite (34 checks)

### Pi Commands

- `/vaults` — List all templates
- `/vault:name` — Load template
- `/route <context>` — Get tool recommendation
- `/vault-stats` — Show usage statistics

### CLI Commands

- `pv init` — Initialize vault
- `pv import` — Import from pi templates
- `pv templates` — List templates
- `pv search` — Search content
- `pv branch/merge` — A/B testing
- `pv exec` — Execute with tracking
- `pv rate` — Rate execution
- `pv stats` — Usage statistics
- `pv export` — Export to pi format
- `pv backup` — Backup/restore

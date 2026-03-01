# Changelog

> [← Back to README](README.md) · [Workflows](docs/WORKFLOWS.md) · [Patterns](docs/CRYSTALLIZED.md)

All notable changes to prompt-vault are documented here.

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
- 48 templates (28 cognitive, 20 task)
- Pi integration via vault-client extension
- CLI with 30+ commands
- Execution tracking and feedback
- Branch/merge for A/B testing
- Export to multiple formats
- Verification suite (33 checks)

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

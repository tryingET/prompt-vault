# Changelog

All notable changes to Prompt Vault will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-02-27

### Added
- **vault-client extension** for pi with `/vault:name`, `/vaults`, `/route`, `/vault-search`, `/vault-stats` commands
- **Schema versioning** with `schema_version` table for migration tracking
- **`pv cleanup`** command to remove old execution logs (with `--dry-run` preview)
- **`pv migrate`** command for schema migration management
- **docs/CRYSTALLIZED.md** documenting patterns, anti-patterns, and lessons learned
- **migrations/** directory for future database migrations
- **Adversarial test cases** for SQL escaping (commas, quotes, unicode, backslashes, nulls)
- **Environment variable** `VAULT_DIR` for configurable vault location

### Fixed
- **CRITICAL: CSV parsing bug** — Switched to JSON output in vault-client to prevent silent data corruption on content with commas/quotes
- **CRITICAL: Schema versioning** — Added `schema_version` table to enable safe schema migrations
- **HIGH: SQL escaping** — Proper handling of backslash-quote sequences and null bytes in `sql_escape()`
- **HIGH: Template validation** — Added size limits and validation at import time

### Changed
- vault-client extension rewritten to use `dolt sql -r json` instead of CSV
- `pv-lib.sh` improved with better SQL escaping and `sql_decode_base64()` function
- `pv-migrate` rewritten to use `schema_version` table
- `import-cognitive-tools.sh` improved with validation, proper escaping, and tag extraction
- README.md updated with Pi integration and maintenance sections

### Security
- Improved SQL escaping prevents injection through backslash-quote sequences
- Null byte removal prevents potential issues with malformed input

## [1.0.0] - 2026-02-27

### Added
- Initial release of Prompt Vault
- Dolt-based versioned storage for prompt templates and skills
- **48 templates** imported (28 cognitive tools, 20 task templates)
- **Core CLI commands**: `init`, `import`, `export`, `templates`, `skills`, `search`
- **Version control**: `branch`, `merge`, `diff`, `rollback`, `history`, `tag`
- **Execution tracking**: `exec`, `rate`, `stats`, `analytics`
- **Quality tools**: `lint`, `quality`, `scaffold`
- **Integration**: `export-fmt`, `integrate`, `watch`
- **Backup/restore**: `backup create`, `backup list`, `backup restore`
- **TUI**: Interactive terminal UI via `pv tui`
- **Schema**: 6 tables (prompt_templates, skills, skill_assets, executions, feedback, collections, changelog)
- **Verification**: 33 automated checks via `verify.sh`
- **Documentation**: README.md, SKILL.md, WORKFLOWS.md, COMPARISON.md

### Schema
```
prompt_templates: id, name, content, description, type, tags, version, status
skills:           id, name, description, readme, compatibility, license, status
skill_assets:     id, skill_id, path, content, binary_content
executions:       id, entity_type, entity_id, latency_ms, success, model, tokens
feedback:         id, execution_id, rating, notes, issues
collections:      id, name, description, template_ids, skill_ids
changelog:        id, entity_type, entity_id, change_type, summary
```

---

## Version Summary

| Version | Date | Highlights |
|---------|------|------------|
| 1.1.0 | 2026-02-27 | Deep review fixes, schema versioning, cleanup command |
| 1.0.0 | 2026-02-27 | Initial release with 48 templates, full CLI, pi extension |

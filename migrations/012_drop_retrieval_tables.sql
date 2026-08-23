-- Migration 012: Drop retrieval analytics tables (moved to SQLite sidecar)
-- Retrieval telemetry is machine-local exhaust, not governed content: it needs
-- none of Dolt's versioning/branching, and its append-only write pattern grew
-- the versioned repo's history monotonically. It now lives in a WAL-mode
-- SQLite sidecar at $VAULT_DIR/analytics.db (see analytics_ensure in
-- pv-lib.sh). Export any legacy rows to the sidecar BEFORE applying this.

DROP TABLE IF EXISTS retrieval_rollups;
DROP TABLE IF EXISTS retrievals;

INSERT INTO schema_version (version, description) VALUES (12, 'Drop retrieval analytics tables; moved to SQLite sidecar (analytics.db)');

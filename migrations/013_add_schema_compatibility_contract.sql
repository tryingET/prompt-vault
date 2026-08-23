-- Migration 013: Add an explicit client-compatibility epoch contract
--
-- `schema_version` tracks every migration and is intentionally allowed to
-- advance without breaking forward-compatible clients. `compatibility_epoch`
-- changes only when a consumer-facing semantic contract breaks. Clients gate
-- on minimum version + required structure + exact epoch, never migration
-- equality. SQLite retrieval analytics have their own independent version.

CREATE TABLE IF NOT EXISTS schema_contract (
    id TINYINT PRIMARY KEY,
    compatibility_epoch INT NOT NULL,
    analytics_schema_version INT NOT NULL,
    minimum_client_schema_version INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO schema_contract
    (id, compatibility_epoch, analytics_schema_version, minimum_client_schema_version)
VALUES (1, 1, 1, 9)
ON DUPLICATE KEY UPDATE
    compatibility_epoch = 1,
    analytics_schema_version = 1,
    minimum_client_schema_version = 9;

INSERT INTO schema_version (version, description)
VALUES (13, 'Add explicit client compatibility epoch contract');

-- Migration 011: Add retrieval_rollups for bounded retention of raw retrievals
-- Lifecycle (tiered): raw `retrievals` rows live inside the cleanup window;
-- when `pv cleanup` expires them it first folds them into day-grain rollups
-- that persist permanently. Rollups serve trend/A-B analytics; raw rows serve
-- recent-behavior questions. Dolt history still grows monotonically — cleanup
-- bounds the working set, not repo bytes.

CREATE TABLE IF NOT EXISTS retrieval_rollups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day DATE NOT NULL,                        -- grain: one row per entity/company/tool/day
    entity_type ENUM('template', 'skill') NOT NULL DEFAULT 'template',
    entity_id INT NOT NULL,
    company VARCHAR(100) NOT NULL DEFAULT '', -- COALESCE(company,'') to keep the unique key total
    tool ENUM('vault_query', 'vault_retrieve', 'other') NOT NULL,
    retrieval_count INT NOT NULL DEFAULT 0,
    rank_sum BIGINT NOT NULL DEFAULT 0,       -- SUM(selected_rank); avg = rank_sum / retrieval_count
    result_count_sum BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_rollup_day (day, entity_type, entity_id, company, tool),
    INDEX idx_rollup_entity (entity_type, entity_id)
);

INSERT INTO schema_version (version, description) VALUES (11, 'Add retrieval_rollups table for bounded retrievals retention');

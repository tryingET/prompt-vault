-- Migration 010: Add retrievals table for query/retrieve usage analytics
-- Logs every vault_query / vault_retrieve tool call (retrieval ≠ execution):
-- which templates were surfaced, at what rank, for which filters/names, when.

CREATE TABLE IF NOT EXISTS retrievals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('template', 'skill') NOT NULL DEFAULT 'template',
    entity_id INT NOT NULL,
    entity_version INT,
    tool ENUM('vault_query', 'vault_retrieve', 'other') NOT NULL,
    query_context TEXT,                       -- JSON: filters or requested names (bounded)
    selected_rank INT,                        -- 1-based rank in the returned list
    result_count INT,                         -- total templates in that tool result
    company VARCHAR(100),                     -- resolved company context
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_tool (tool),
    INDEX idx_created (created_at)
);

INSERT INTO schema_version (version, description) VALUES (10, 'Add retrievals table for retrieval-usage analytics');

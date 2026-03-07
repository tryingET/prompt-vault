-- Migration 002: Add 'loop' template type
-- Loops orchestrate multiple cognitive tools across phases

INSERT INTO schema_version (version, description) VALUES (2, 'Add loop template type for phase-gated iteration patterns');

ALTER TABLE prompt_templates MODIFY COLUMN type ENUM('cognitive', 'task', 'session', 'loop') DEFAULT 'task';

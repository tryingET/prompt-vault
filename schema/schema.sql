-- Prompt Vault Schema
-- Run with: dolt sql < schema/schema.sql
--
-- Design principles:
-- - Every entity has version tracking via parent_id chain
-- - Status lifecycle: draft → active → deprecated → archived
-- - Executions/feedback enable the quality feedback loop
-- - Collections provide logical grouping without hierarchy

-- Core entity: reusable prompt templates
-- Variables use pi syntax: $1, $2, $@, ${@:N}
-- Types: cognitive (epistemic frameworks), task (domain-specific), session (state)
CREATE TABLE IF NOT EXISTS prompt_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,        -- kebab-case identifier
    description VARCHAR(1024),                -- shown in listings
    content TEXT NOT NULL,                    -- the actual prompt
    type ENUM('cognitive', 'task', 'session') DEFAULT 'task',  -- categorization
    variables JSON,                           -- extracted ["$1", "$@"]
    tags JSON,                                -- ["code-review", "security"]
    version INT DEFAULT 1,                    -- increments on edit
    parent_id INT,                            -- previous version for history
    status ENUM('draft', 'active', 'deprecated', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_status (status),
    INDEX idx_type (type)
);

-- Complex multi-file capabilities (Agent Skills spec)
-- Assets stored separately in skill_assets table
CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,         -- must match Agent Skills spec
    description VARCHAR(1024) NOT NULL,       -- max 1024 chars per spec
    readme TEXT NOT NULL,                     -- full SKILL.md content
    compatibility VARCHAR(500),               -- environment requirements
    license VARCHAR(100),
    metadata JSON,
    tags JSON,
    version INT DEFAULT 1,
    parent_id INT,
    status ENUM('draft', 'active', 'deprecated', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_status (status)
);

-- Supporting files for skills (scripts, references, assets)
-- Binary files base64-encoded in binary_content
CREATE TABLE IF NOT EXISTS skill_assets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skill_id INT NOT NULL,
    path VARCHAR(255) NOT NULL,               -- relative: scripts/foo.sh
    content LONGTEXT,                         -- text content
    binary_content BLOB,                      -- for images, binaries
    is_binary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    UNIQUE KEY unique_skill_path (skill_id, path)
);

-- Execution tracking: every template/skill invocation
-- This is the "measure" in the feedback loop
CREATE TABLE IF NOT EXISTS executions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('template', 'skill') NOT NULL,
    entity_id INT NOT NULL,
    entity_version INT,                       -- which version was used
    input_args TEXT,                          -- JSON: ["arg1", "arg2"]
    input_context TEXT,                       -- truncated context snapshot
    output_tokens INT,
    input_tokens INT,
    latency_ms INT,                           -- wall-clock time
    model VARCHAR(100),                       -- claude-3-sonnet, gpt-4, etc
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created (created_at)
);

-- Human judgment: the "learn" in the feedback loop
-- High ratings → keep. Low ratings → iterate.
CREATE TABLE IF NOT EXISTS feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    execution_id INT NOT NULL,
    rating TINYINT,                           -- 1-5 stars
    notes TEXT,                               -- freeform explanation
    issues JSON,                              -- ["hallucination", "too-verbose"]
    would_use_again BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (execution_id) REFERENCES executions(id) ON DELETE CASCADE,
    INDEX idx_rating (rating)
);

-- Audit trail: who changed what when
-- Redundant with Dolt history but queryable without dolt CLI
CREATE TABLE IF NOT EXISTS changelog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('template', 'skill') NOT NULL,
    entity_id INT NOT NULL,
    old_version INT,
    new_version INT,
    change_type ENUM('create', 'update', 'deprecate', 'archive', 'reactivate') NOT NULL,
    summary VARCHAR(255),
    dolt_commit_hash CHAR(32),                -- link to Dolt commit
    author VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_type, entity_id)
);

-- Logical grouping without hierarchy
-- Example: "security-prompts" collection with related templates
CREATE TABLE IF NOT EXISTS collections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    template_ids JSON,                        -- [1, 5, 12]
    skill_ids JSON,                           -- [2, 7]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

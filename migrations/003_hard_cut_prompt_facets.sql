-- Migration 003: Hard-cut prompt ontology facets
-- Replace legacy prompt_templates.type with artifact_kind/control_mode/formalization_level

ALTER TABLE prompt_templates
    ADD COLUMN artifact_kind ENUM('cognitive', 'procedure', 'session') NULL AFTER content,
    ADD COLUMN control_mode ENUM('one_shot', 'router', 'loop') NULL AFTER artifact_kind,
    ADD COLUMN formalization_level ENUM('napkin', 'bounded', 'structured', 'workflow') NULL AFTER control_mode;

UPDATE prompt_templates
SET artifact_kind = CASE
    WHEN type = 'cognitive' THEN 'cognitive'
    WHEN type = 'session' THEN 'session'
    WHEN type IN ('task', 'loop') THEN 'procedure'
    ELSE 'procedure'
END
WHERE artifact_kind IS NULL;

UPDATE prompt_templates
SET control_mode = CASE
    WHEN type = 'loop' THEN 'loop'
    ELSE 'one_shot'
END
WHERE control_mode IS NULL;

UPDATE prompt_templates
SET formalization_level = CASE
    WHEN tags IS NOT NULL AND tags LIKE '%formalization:workflow%' THEN 'workflow'
    WHEN tags IS NOT NULL AND tags LIKE '%formalization:structured%' THEN 'structured'
    WHEN tags IS NOT NULL AND tags LIKE '%formalization:bounded%' THEN 'bounded'
    WHEN tags IS NOT NULL AND tags LIKE '%formalization:napkin%' THEN 'napkin'
    ELSE 'structured'
END
WHERE formalization_level IS NULL;

ALTER TABLE prompt_templates
    MODIFY COLUMN artifact_kind ENUM('cognitive', 'procedure', 'session') NOT NULL DEFAULT 'procedure',
    MODIFY COLUMN control_mode ENUM('one_shot', 'router', 'loop') NOT NULL DEFAULT 'one_shot',
    MODIFY COLUMN formalization_level ENUM('napkin', 'bounded', 'structured', 'workflow') NOT NULL DEFAULT 'structured';

CREATE INDEX IF NOT EXISTS idx_artifact_kind ON prompt_templates (artifact_kind);
CREATE INDEX IF NOT EXISTS idx_control_mode ON prompt_templates (control_mode);
CREATE INDEX IF NOT EXISTS idx_formalization_level ON prompt_templates (formalization_level);

ALTER TABLE prompt_templates DROP COLUMN IF EXISTS type;

SELECT 'Migration complete' AS status;

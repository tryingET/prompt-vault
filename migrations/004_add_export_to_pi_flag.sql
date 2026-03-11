-- Migration 004: Add explicit publish/export switch for pi prompt export
-- Keep lifecycle status separate from pi publishing intent.

ALTER TABLE prompt_templates
    ADD COLUMN export_to_pi BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_export_to_pi ON prompt_templates (export_to_pi);

-- Preserve existing export behavior for current active templates.
-- New templates default to export_to_pi = FALSE and must be explicitly published.
UPDATE prompt_templates
SET export_to_pi = TRUE
WHERE status = 'active';

SELECT 'Migration complete' AS status;

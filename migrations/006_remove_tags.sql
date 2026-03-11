-- Migration: remove free-form tags from prompts and skills
ALTER TABLE prompt_templates DROP COLUMN tags;
ALTER TABLE skills DROP COLUMN tags;

SELECT 'tags removed from prompt_templates and skills' AS status;

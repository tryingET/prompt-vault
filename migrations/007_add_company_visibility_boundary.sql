-- Migration: add owner_company + visibility_companies governance boundary
ALTER TABLE prompt_templates
    ADD COLUMN owner_company ENUM('core', 'software', 'finance', 'house', 'health', 'teaching', 'holding') NOT NULL DEFAULT 'core' AFTER formalization_level,
    ADD COLUMN visibility_companies JSON NULL AFTER owner_company;

ALTER TABLE skills
    ADD COLUMN owner_company ENUM('core', 'software', 'finance', 'house', 'health', 'teaching', 'holding') NOT NULL DEFAULT 'core' AFTER metadata,
    ADD COLUMN visibility_companies JSON NULL AFTER owner_company;

UPDATE prompt_templates
SET visibility_companies = JSON_ARRAY('core','software','finance','house','health','teaching','holding')
WHERE visibility_companies IS NULL;

UPDATE skills
SET visibility_companies = JSON_ARRAY('core','software','finance','house','health','teaching','holding')
WHERE visibility_companies IS NULL;

ALTER TABLE prompt_templates
    MODIFY COLUMN visibility_companies JSON NOT NULL;

ALTER TABLE skills
    MODIFY COLUMN visibility_companies JSON NOT NULL;

SELECT 'company visibility boundary added' AS status;

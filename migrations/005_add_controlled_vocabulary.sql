-- Migration: add controlled_vocabulary governed metadata layer
ALTER TABLE prompt_templates
    ADD COLUMN controlled_vocabulary JSON NULL AFTER tags;

SELECT 'controlled_vocabulary column added' AS status;

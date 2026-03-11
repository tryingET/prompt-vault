-- Migration: add optional execution output capture with explicit privacy mode

ALTER TABLE executions
    ADD COLUMN output_capture_mode ENUM('none', 'private', 'public') NOT NULL DEFAULT 'none' AFTER model,
    ADD COLUMN output_text LONGTEXT AFTER output_capture_mode;

SELECT 'execution output capture columns added' AS status;

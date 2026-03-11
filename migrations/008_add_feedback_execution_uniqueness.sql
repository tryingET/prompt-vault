-- Migration: enforce one feedback row per execution
-- This fails closed if duplicate feedback rows already exist for any execution.

ALTER TABLE feedback
    ADD UNIQUE KEY unique_feedback_execution (execution_id);

SELECT 'feedback execution uniqueness added' AS status;

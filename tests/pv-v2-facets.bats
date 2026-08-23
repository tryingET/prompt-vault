#!/usr/bin/env bats
# Verify Prompt Vault v2 facet schema + seeded router prompts

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "prompt_templates exposes v2 facet columns plus export flag, controlled vocabulary, and company visibility" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SHOW COLUMNS FROM prompt_templates"
    [ "$status" -eq 0 ]
    [[ "$output" == *"artifact_kind"* ]]
    [[ "$output" == *"control_mode"* ]]
    [[ "$output" == *"formalization_level"* ]]
    [[ "$output" == *"owner_company"* ]]
    [[ "$output" == *"visibility_companies"* ]]
    [[ "$output" == *"controlled_vocabulary"* ]]
    [[ "$output" == *"export_to_pi"* ]]
    [[ "$output" != *"tags"* ]]
}

@test "schema version is 11 after bounded retrieval retention cutover" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT MAX(version) FROM schema_version"
    [ "$status" -eq 0 ]
    [[ "$output" == *$'11' ]]
}

@test "feedback enforces one row per execution at schema level" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SHOW INDEX FROM feedback"
    [ "$status" -eq 0 ]
    [[ "$output" == *"feedback,0,unique_feedback_execution,1,execution_id"* ]]
}

@test "seeded routers exist with canonical facets" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM prompt_templates WHERE artifact_kind='procedure' AND control_mode='router' AND formalization_level='structured' AND name IN ('analysis-router','post-review-router','review-closeout-router')"
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

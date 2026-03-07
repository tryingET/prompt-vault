#!/usr/bin/env bats
# Verify Prompt Vault v2 facet schema + seeded router prompts

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "prompt_templates exposes v2 facet columns" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SHOW COLUMNS FROM prompt_templates"
    [ "$status" -eq 0 ]
    [[ "$output" == *"artifact_kind"* ]]
    [[ "$output" == *"control_mode"* ]]
    [[ "$output" == *"formalization_level"* ]]
}

@test "schema version is 3 after v2 cutover" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT MAX(version) FROM schema_version"
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

@test "seeded routers exist with canonical facets" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM prompt_templates WHERE artifact_kind='procedure' AND control_mode='router' AND formalization_level='structured' AND name IN ('analysis-router','post-review-router','review-closeout-router')"
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

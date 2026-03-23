#!/usr/bin/env bats
# Verify the owner-repo boundary-note procedure template exists with the intended authority-preserving contract

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "owner-repo boundary-note template exists with canonical metadata" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT COUNT(*)
        FROM prompt_templates
        WHERE name = 'owner-repo-boundary-note'
          AND artifact_kind = 'procedure'
          AND control_mode = 'one_shot'
          AND formalization_level = 'workflow'
          AND owner_company = 'core'
          AND status = 'active'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'1' ]]
}

@test "owner-repo boundary-note template keeps authority, projection-only, and anti-cutover rules visible" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT content FROM prompt_templates WHERE name = 'owner-repo-boundary-note' LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"projection-only surfaces"* ]]
    [[ "$output" == *"Keep current-vs-target truth explicit."* ]]
    [[ "$output" == *"Do **not** collapse current authority, projection surfaces, and target authority into one owner string."* ]]
    [[ "$output" == *"why the note does **not** prove authority cutover"* ]]
}

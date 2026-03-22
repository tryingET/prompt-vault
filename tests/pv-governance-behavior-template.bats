#!/usr/bin/env bats
# Verify the cross-repo governance-behavior review/fan-out template exists with the intended contract

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "concern-first governance-behavior template exists with canonical metadata" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT COUNT(*)
        FROM prompt_templates
        WHERE name = 'concern-first-review-fanout'
          AND artifact_kind = 'procedure'
          AND control_mode = 'one_shot'
          AND formalization_level = 'workflow'
          AND owner_company = 'core'
          AND status = 'active'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'1' ]]
}

@test "concern-first governance-behavior template keeps the concern-first + coordination-only contract visible" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SELECT content FROM prompt_templates WHERE name = 'concern-first-review-fanout' LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"native governed concern"* ]]
    [[ "$output" == *"authoritative coordination/task/decision substrate"* ]]
    [[ "$output" == *"coordination_only_fanout"* ]]
    [[ "$output" == *"Do **not** invent a second coordination substrate beside AK."* ]]
}

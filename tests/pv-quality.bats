#!/usr/bin/env bats
# Tests for quality surfaces and fail-closed behavior

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(mktemp -d)"
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    cp -R "$VAULT_DIR" "$TEST_VAULT_DIR"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv-quality check performs a real health check" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality checks passed"* ]]
    [[ "$output" == *"Active templates:"* ]]
}

@test "pv-quality rejects unknown subcommands" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" does-not-exist
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown command"* ]]
}

@test "pv-quality template rejects injected names" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" template "analysis-router' OR 1=1 -- "
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "pv-quality uses rating contribution without external bc dependency" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            status
        ) VALUES (
            'quality-proof',
            'This description is comfortably longer than fifty characters for deterministic scoring.',
            REPEAT('x', 150),
            'procedure',
            'one_shot',
            'structured',
            'core',
            '[\"core\"]',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    template_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM prompt_templates WHERE name = 'quality-proof'" | tail -1)
    [ -n "$template_id" ]

    for _ in $(seq 1 10); do
        run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('template', $template_id, 1, 'test-model', TRUE)"
        [ "$status" -eq 0 ]
    done

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template' AND entity_id = $template_id" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'excellent', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" template quality-proof
    [ "$status" -eq 0 ]
    [[ "$output" == *"Score: 100/100"* ]]
    [[ "$output" == *"Grade: A"* ]]
}

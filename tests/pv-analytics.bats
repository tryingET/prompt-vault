#!/usr/bin/env bats
# Tests for analytics surfaces, including safe output-capture reporting

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv-analytics outputs summarizes capture coverage without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "top secret private answer"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "shareable public answer" --public-output
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" outputs 10
    [ "$status" -eq 0 ]
    [[ "$output" == *"Output Capture Analytics"* ]]
    [[ "$output" == *"private_captures"* ]]
    [[ "$output" == *"public_captures"* ]]
    [[ "$output" == *"shareable public answer"* ]]
    [[ "$output" != *"top secret private answer"* ]]
}

@test "pv-analytics recent shows capture mode and output length without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "classified internal answer"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" recent 5
    [ "$status" -eq 0 ]
    [[ "$output" == *"output_capture_mode"* ]]
    [[ "$output" == *"output_chars"* ]]
    [[ "$output" == *"private"* ]]
    [[ "$output" != *"classified internal answer"* ]]
}

@test "pv-analytics template shows capture evidence and only public previews" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "private template output"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "public template output" --public-output
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" template analysis-router
    [ "$status" -eq 0 ]
    [[ "$output" == *"captured_executions"* ]]
    [[ "$output" == *"private_captures"* ]]
    [[ "$output" == *"public_captures"* ]]
    [[ "$output" == *"public template output"* ]]
    [[ "$output" != *"private template output"* ]]
}

@test "pv-analytics template rejects injected names" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" template "analysis-router' OR 1=1 -- "
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "pv-analytics strips terminal escape sequences from public previews" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text $'hello \e[31mRED\e[0m world' --public-output
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" outputs 5
    [ "$status" -eq 0 ]
    [[ "$output" == *"hello RED world"* ]]
    [[ "$output" != *$'\e'* ]]
    [[ "$output" != *"[31m"* ]]
}

@test "pv-analytics overview counts unique entities by typed identity" {
    colliding_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MIN(entity_id) FROM executions WHERE entity_type = 'template'" | tail -1)
    [ -n "$colliding_id" ]

    baseline_typed=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(DISTINCT CONCAT(entity_type, ':', entity_id)) FROM executions" | tail -1)
    baseline_id_only=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(DISTINCT entity_id) FROM executions" | tail -1)

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO skills (id, name, description, readme, compatibility, license, metadata, owner_company, visibility_companies, status)
        VALUES ($colliding_id, 'skill-collision', 'test skill description', 'readme', '', 'MIT', '{}', 'core', '[\"core\"]', 'active');
        INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('skill', $colliding_id, 1, 'test-model', TRUE)
    "
    [ "$status" -eq 0 ]

    expected_typed=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(DISTINCT CONCAT(entity_type, ':', entity_id)) FROM executions" | tail -1)
    expected_id_only=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(DISTINCT entity_id) FROM executions" | tail -1)
    [ "$expected_typed" -eq $((baseline_typed + 1)) ]
    [ "$expected_id_only" -eq "$baseline_id_only" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" overview
    [ "$status" -eq 0 ]
    [[ "$output" == *"unique_entities"* ]]
    [[ "$output" == *"| $expected_typed "* ]]
}

@test "pv-analytics rejects unknown subcommands" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" does-not-exist
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown command"* ]]
}

@test "pv-analytics compare rejects injected names" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-analytics" compare "analysis-router' OR 1=1 -- " review-closeout-router
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

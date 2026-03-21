#!/usr/bin/env bats
# Tests for execution output capture and privacy controls

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

@test "executions exposes output capture columns" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "SHOW COLUMNS FROM executions"
    [ "$status" -eq 0 ]
    [[ "$output" == *"output_capture_mode"* ]]
    [[ "$output" == *"output_text"* ]]
}

@test "pv-exec stores private output by default when output text is provided" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "secret answer"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Output capture: private"* ]]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT output_capture_mode, output_text FROM executions ORDER BY id DESC LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"private,secret answer"* ]]
}

@test "pv-exec stores public output when explicitly requested" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "shareable answer" --public-output
    [ "$status" -eq 0 ]
    [[ "$output" == *"Output capture: public"* ]]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT output_capture_mode, output_text FROM executions ORDER BY id DESC LIMIT 1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"public,shareable answer"* ]]
}

@test "pv-exec rejects public-output without captured output" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --public-output
    [ "$status" -ne 0 ]
    [[ "$output" == *"--public-output requires --output-file or --output-text"* ]]
}

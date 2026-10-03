#!/usr/bin/env bats
# Tests for execution output capture and privacy controls

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"
    mkdir -p "$TMP_DIR/home" "$TMP_DIR/tmp" "$TMP_DIR/prompts"
    export HOME="$TMP_DIR/home" TMPDIR="$TMP_DIR/tmp" PI_PROMPTS_DIR="$TMP_DIR/prompts"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "executions exposes output capture columns" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SHOW COLUMNS FROM executions"
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

@test "prompt preparation never creates a simulated successful execution" {
    before=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q 'SELECT COUNT(*) FROM executions' | tail -1)
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" napkin "resume preparation" --model "selected-model"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Prepared template"* ]]
    [[ "$output" == *"no model call performed"* ]]
    [[ "$output" == *"no execution record created"* ]]
    [[ "$output" != *"Execution logged"* ]]
    after=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q 'SELECT COUNT(*) FROM executions' | tail -1)
    [ "$before" = "$after" ]
}

@test "supplied output preserves arguments safely and records an unknown outcome" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" napkin $'quoted\x27 argument\nsecond line' --model "caller'label" --output-text "private result"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Outcome: unknown"* ]]
    row=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q 'SELECT input_args,input_context,model,success,input_tokens,output_tokens,latency_ms FROM executions ORDER BY id DESC LIMIT 1')
    [ "$(printf '%s' "$row" | jq -r '.rows[0].model')" = "caller'label" ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].input_args | fromjson | .[0]')" = $'quoted\x27 argument\nsecond line' ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].input_context | fromjson | .event')" = caller_supplied_output ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].success // "unknown"')" = unknown ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].latency_ms // "unknown"')" = unknown ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].input_tokens // "unknown"')" = unknown ]
}

@test "explicit empty output remains private with no invented default model" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" napkin --output-text ""
    [ "$status" -eq 0 ]
    row=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q 'SELECT model,output_capture_mode,output_text,success FROM executions ORDER BY id DESC LIMIT 1')
    [ "$(printf '%s' "$row" | jq -r '.rows[0].output_capture_mode')" = private ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].output_text')" = "" ]
    [ "$(printf '%s' "$row" | jq -r '.rows[0].model // "unknown"')" = unknown ]
}

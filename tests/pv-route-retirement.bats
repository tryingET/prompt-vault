#!/usr/bin/env bats
# Exercise the real lifecycle helpers only against an isolated Dolt copy.
load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/vault"
    copy_test_vault "$TEST_VAULT_DIR"
    mkdir -p "$TMP_DIR/home" "$TMP_DIR/prompts" "$TMP_DIR/tmp"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "retiring a selected procedure refuses before row or projection mutation" {
    before=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT * FROM prompt_templates WHERE name='layer12-040-direction-to-execution-ak-native'")
    run env HOME="$TMP_DIR/home" TMPDIR="$TMP_DIR/tmp" PI_PROMPTS_DIR="$TMP_DIR/prompts" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" deprecate template layer12-040-direction-to-execution-ak-native
    [ "$status" -ne 0 ]
    [[ "$output" == *"Cannot retire referenced template"* ]]
    after=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT * FROM prompt_templates WHERE name='layer12-040-direction-to-execution-ak-native'")
    [ "$before" = "$after" ]
    [ -z "$(ls -A "$TMP_DIR/prompts")" ]
}

@test "unexporting a selected procedure refuses before row or projection mutation" {
    before=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT * FROM prompt_templates WHERE name='layer12-040-direction-to-execution-ak-native'")
    run env HOME="$TMP_DIR/home" TMPDIR="$TMP_DIR/tmp" PI_PROMPTS_DIR="$TMP_DIR/prompts" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" unpublish layer12-040-direction-to-execution-ak-native
    [ "$status" -ne 0 ]
    [[ "$output" == *"Cannot unexport referenced template"* ]]
    after=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT * FROM prompt_templates WHERE name='layer12-040-direction-to-execution-ak-native'")
    [ "$before" = "$after" ]
    [ -z "$(ls -A "$TMP_DIR/prompts")" ]
}

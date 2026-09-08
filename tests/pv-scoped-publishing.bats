#!/usr/bin/env bats

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TEST_ROOT="$(make_test_tmpdir)"
    copy_test_vault "$TEST_ROOT/source/prompt-vault-db"
    mkdir -p "$TEST_ROOT/home" "$TEST_ROOT/tmp" "$TEST_ROOT/prompts" "$TEST_ROOT/skills"
    export HOME="$TEST_ROOT/home" TMPDIR="$TEST_ROOT/tmp"
    export VAULT_DIR="$TEST_ROOT/source/prompt-vault-db"
    export TEMPLATES_DIR="$TEST_ROOT/prompts" SKILLS_DIR="$TEST_ROOT/skills"
    export PV_SCOPED_TEST_ROOT="$TEST_ROOT" PYTHONDONTWRITEBYTECODE=1
}

teardown() {
    rm -rf "$TEST_ROOT"
}

@test "canonical pv registers scoped operator command and requires explicit guards" {
    run "$SCRIPTS_DIR/pv" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"scoped <update|export|check>"* ]]
    run "$SCRIPTS_DIR/pv" scoped update --name commit --apply
    [ "$status" -eq 2 ]
    [[ "$output" == *"--expected-owner"* ]]
}

@test "scoped publishing isolated integration and adversarial contracts" {
    run python3 "$BATS_TEST_DIRNAME/test_scoped_publishing.py" -v
    printf '%s\n' "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
}

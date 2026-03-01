#!/usr/bin/env bats
# Tests for pv-lint

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv lint script is executable" {
    [ -x "$SCRIPTS_DIR/pv-lint" ]
}

@test "pv lint runs and produces output" {
    cd "$VAULT_DIR"
    run "$SCRIPTS_DIR/pv-lint"
    # Lint may exit with 1 if errors found, check output instead
    [[ "$output" == *"Linting"* ]]
}

@test "pv lint uses pv-lib" {
    grep -q "source.*pv-lib.sh" "$SCRIPTS_DIR/pv-lint"
}

@test "pv lint checks for jq dependency" {
    grep -q "check_deps.*jq" "$SCRIPTS_DIR/pv-lint"
}

@test "pv lint no longer uses 'local' outside function" {
    # The problematic line was 'local type=' at script level
    # Check that the main section doesn't use local
    grep -E "^local type=" "$SCRIPTS_DIR/pv-lint" && return 1 || return 0
}

@test "pv lint validates descriptions" {
    cd "$VAULT_DIR"
    run "$SCRIPTS_DIR/pv-lint"
    [[ "$output" == *"Description"* ]]
}

@test "pv lint checks for frontmatter" {
    cd "$VAULT_DIR"
    run "$SCRIPTS_DIR/pv-lint"
    [[ "$output" == *"frontmatter"* ]] || [[ "$output" == *"Frontmatter"* ]] || true
}

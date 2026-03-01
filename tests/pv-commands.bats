#!/usr/bin/env bats
# Tests for pv CLI commands

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv --help shows usage" {
    run "$SCRIPTS_DIR/pv" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]] || [[ "$output" == *"pv"* ]]
}

@test "pv --version returns version" {
    run "$SCRIPTS_DIR/pv" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0"* ]]
}

@test "pv list-commands shows available commands" {
    run "$SCRIPTS_DIR/pv" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"templates"* ]]
    [[ "$output" == *"skills"* ]]
}

@test "pv templates lists templates" {
    run "$SCRIPTS_DIR/pv" templates
    [ "$status" -eq 0 ]
}

@test "pv skills lists skills" {
    run "$SCRIPTS_DIR/pv" skills
    [ "$status" -eq 0 ]
}

@test "pv search requires query argument" {
    run "$SCRIPTS_DIR/pv" search
    [ "$status" -ne 0 ]
}

@test "pv tag list works" {
    run "$SCRIPTS_DIR/pv" tag list
    [ "$status" -eq 0 ]
}

@test "pv quality check runs" {
    run "$SCRIPTS_DIR/pv" quality check
    [ "$status" -eq 0 ]
}

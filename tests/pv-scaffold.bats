#!/usr/bin/env bats
# Tests for pv-scaffold

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv scaffold --help works" {
    run "$SCRIPTS_DIR/pv-scaffold" --help
    [ "$status" -eq 0 ]
}

@test "pv scaffold shows usage without args" {
    run "$SCRIPTS_DIR/pv-scaffold"
    [ "$status" -ne 0 ] || [[ "$output" == *"Usage"* ]]
}

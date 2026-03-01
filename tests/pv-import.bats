#!/usr/bin/env bats
# Tests for import-from-pi.sh

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv import script is executable" {
    [ -x "$SCRIPTS_DIR/import-from-pi.sh" ]
}

@test "pv import uses pv-lib" {
    grep -q "source.*pv-lib.sh" "$SCRIPTS_DIR/import-from-pi.sh"
}

@test "pv import handles missing vault gracefully" {
    # Create temp dir without vault
    export VAULT_DIR=$(mktemp -d)
    run "$SCRIPTS_DIR/import-from-pi.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Vault not initialized"* ]]
    rm -rf "$VAULT_DIR"
}

@test "pv import uses temp file for SQL execution" {
    grep -q "mktemp.*sql" "$SCRIPTS_DIR/import-from-pi.sh"
}

@test "pv import stores binary as base64" {
    grep -q "FROM_BASE64" "$SCRIPTS_DIR/import-from-pi.sh"
    grep -q "binary_content" "$SCRIPTS_DIR/import-from-pi.sh"
}

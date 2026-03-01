#!/usr/bin/env bash
# Shared test setup for BATS tests

export SCRIPTS_DIR="$BATS_TEST_DIRNAME/../scripts"
export VAULT_DIR="$BATS_TEST_DIRNAME/../prompt-vault-db"

# Check if vault is initialized
vault_exists() {
    [ -d "$VAULT_DIR/.dolt" ]
}

# Check if dolt is available
has_dolt() {
    command -v dolt &>/dev/null
}

# Skip if dependencies missing
skip_if_no_dolt() {
    if ! has_dolt; then
        skip "dolt not installed"
    fi
}

skip_if_no_vault() {
    if ! vault_exists; then
        skip "vault not initialized"
    fi
}

#!/usr/bin/env bash
# Shared test setup for BATS tests

export SCRIPTS_DIR="$BATS_TEST_DIRNAME/../scripts"
export VAULT_DIR="$BATS_TEST_DIRNAME/../prompt-vault-db"
export TEST_TMP_ROOT="$BATS_TEST_DIRNAME/../.tmp-tests"

mkdir -p "$TEST_TMP_ROOT"

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

make_test_tmpdir() {
    mktemp -d "$TEST_TMP_ROOT/pv-tests.XXXXXX"
}

copy_test_vault() {
    local dest="$1"
    local attempt

    command -v rsync &>/dev/null || {
        echo "rsync is required for stable vault test copies" >&2
        return 1
    }

    for attempt in 1 2 3; do
        rm -rf "$dest"
        mkdir -p "$dest"
        if rsync -a "$VAULT_DIR/" "$dest/" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done

    echo "failed to create stable test vault copy after 3 attempts: $dest" >&2
    return 1
}

#!/usr/bin/env bats
# Tests for Prompt Vault DB change preflight policy

setup() {
    TEST_TMP_ROOT="$BATS_TEST_DIRNAME/../.tmp-tests"
    mkdir -p "$TEST_TMP_ROOT"
    TMP_DIR="$(mktemp -d "$TEST_TMP_ROOT/pv-tests.XXXXXX")"
    SCRIPT_PATH="$BATS_TEST_DIRNAME/../scripts/db-change-preflight.sh"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "db-change-preflight: db-dev requires only db identity" {
    mkdir -p "$TMP_DIR/prompt-vault-db/.dolt"

    run bash -c "cd '$TMP_DIR' && '$SCRIPT_PATH' --stage db-dev"

    [ "$status" -eq 0 ]
    [[ "$output" == *"OK   db identity present"* ]]
    [[ "$output" == *"db-dev mode: backup quorum not required"* ]]
    [[ "$output" == *"result: PASS"* ]]
}

@test "db-change-preflight: db-test still requires backup quorum" {
    mkdir -p "$TMP_DIR/prompt-vault-db/.dolt"

    run bash -c "cd '$TMP_DIR' && '$SCRIPT_PATH' --stage db-test"

    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL local backup missing"* ]]
    [[ "$output" == *"FAIL DS1621 backup missing"* ]]
    [[ "$output" == *"FAIL offsite backup missing"* ]]
    [[ "$output" == *"result: FAIL"* ]]
}

@test "db-change-preflight: db-test passes when backup quorum paths are provided" {
    mkdir -p "$TMP_DIR/prompt-vault-db/.dolt"
    mkdir -p "$TMP_DIR/backups/local" "$TMP_DIR/backups/ds1621" "$TMP_DIR/backups/offsite"

    run bash -c "cd '$TMP_DIR' && PV_BACKUP_LOCAL_PATH='./backups/local' PV_BACKUP_DS1621_PATH='./backups/ds1621' PV_BACKUP_OFFSITE_PATH='./backups/offsite' '$SCRIPT_PATH' --stage db-test"

    [ "$status" -eq 0 ]
    [[ "$output" == *"OK   local backup: ./backups/local"* ]]
    [[ "$output" == *"OK   DS1621 backup: ./backups/ds1621"* ]]
    [[ "$output" == *"OK   offsite backup: ./backups/offsite"* ]]
    [[ "$output" == *"result: PASS"* ]]
}

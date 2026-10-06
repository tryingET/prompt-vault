#!/usr/bin/env bats
# Executable Given/When/Then scenarios for refusals; positive exact-state admission is
# exercised against real Dolt fixtures in tests/test_backup_assurance.py.

setup() {
    TEST_TMP_ROOT="${PV_TEST_TMP_ROOT:-${TMPDIR:?}/pv-preflight-tests}"
    mkdir -p "$TEST_TMP_ROOT"
    TMP_DIR="$(mktemp -d "$TEST_TMP_ROOT/pv-preflight.XXXXXX")"
    SCRIPT_PATH="$BATS_TEST_DIRNAME/../scripts/db-change-preflight.sh"
    mkdir -p "$TMP_DIR/prompt-vault-db/.dolt"
    export PV_BACKUP_LOCAL_PATH="$TMP_DIR/absent-local"
    export PV_BACKUP_DS1621_PATH="$TMP_DIR/absent-primary"
    export PV_BACKUP_OFFSITE_PATH="$TMP_DIR/absent-offsite"
    export PV_BACKUP_IMMUTABLE_PATH="$TMP_DIR/absent-immutable"
}

teardown() {
    rm -rf -- "$TMP_DIR"
}

when_preflight() {
    run bash -c 'cd "$1" && shift && exec "$@"' _ "$TMP_DIR" "$SCRIPT_PATH" "$@"
}

then_assurance_refused() {
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL backup assurance unable_to_verify"* ]]
    [[ "$output" == *"no admission granted"* ]]
    [[ "$output" == *"result: FAIL"* ]]
    [[ "$output" != *"result: PASS"* ]]
    [[ "$output" != *"backup missing"* ]]
}

@test "Given a Dolt identity When db-dev preflight runs Then existing low-risk admission remains" {
    when_preflight --stage db-dev
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK   db identity present"* ]]
    [[ "$output" == *"db-dev mode: backup quorum not required"* ]]
    [[ "$output" == *"result: PASS"* ]]
}

@test "Given a SQLite identity When db-dev runs Then existing compatibility remains" {
    rmdir "$TMP_DIR/prompt-vault-db/.dolt" "$TMP_DIR/prompt-vault-db"
    touch "$TMP_DIR/prompt-vault.db"
    when_preflight --stage db-dev
    [ "$status" -eq 0 ]
}

@test "Given no database identity When db-dev runs Then admission refuses" {
    rmdir "$TMP_DIR/prompt-vault-db/.dolt" "$TMP_DIR/prompt-vault-db"
    when_preflight --stage db-dev
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL db identity missing"* ]]
}

@test "Given absent mounts When higher stages run Then unverified is not reported as absent backups" {
    for stage in db-test db-stage db-prod; do
        when_preflight --stage "$stage"
        then_assurance_refused
    done
}

@test "Given three empty directories When higher stages run Then path existence never admits" {
    mkdir -p "$PV_BACKUP_LOCAL_PATH" "$PV_BACKUP_DS1621_PATH" "$PV_BACKUP_OFFSITE_PATH"
    for stage in db-test db-stage db-prod; do
        when_preflight --stage "$stage"
        then_assurance_refused
    done
}

@test "Given ordinary files at all backup paths When db-test runs Then it refuses" {
    touch "$PV_BACKUP_LOCAL_PATH" "$PV_BACKUP_DS1621_PATH" "$PV_BACKUP_OFFSITE_PATH"
    when_preflight --stage db-test
    then_assurance_refused
}

@test "Given three aliases of one failure domain When db-test runs Then it refuses" {
    mkdir "$TMP_DIR/same-domain"
    ln -s "$TMP_DIR/same-domain" "$PV_BACKUP_LOCAL_PATH"
    ln -s "$TMP_DIR/same-domain" "$PV_BACKUP_DS1621_PATH"
    ln -s "$TMP_DIR/same-domain" "$PV_BACKUP_OFFSITE_PATH"
    when_preflight --stage db-test
    then_assurance_refused
}

@test "Given local database-looking copies When db-test runs Then copies alone are not assurance" {
    for path in "$PV_BACKUP_LOCAL_PATH" "$PV_BACKUP_DS1621_PATH" "$PV_BACKUP_OFFSITE_PATH"; do
        cp -a "$TMP_DIR/prompt-vault-db" "$path"
    done
    when_preflight --stage db-test
    then_assurance_refused
}

@test "Given an immutable path and exception note When db-prod runs Then neither bypasses assurance" {
    mkdir "$PV_BACKUP_LOCAL_PATH" "$PV_BACKUP_DS1621_PATH" "$PV_BACKUP_OFFSITE_PATH" "$PV_BACKUP_IMMUTABLE_PATH"
    printf '%s\n' 'An arbitrary exception is not recovery evidence.' > "$TMP_DIR/exception.md"
    when_preflight --stage db-prod --exception-file "$TMP_DIR/exception.md"
    then_assurance_refused
    rmdir "$PV_BACKUP_IMMUTABLE_PATH"
    when_preflight --stage db-prod --exception-file "$TMP_DIR/exception.md"
    then_assurance_refused
}

@test "Given arbitrary protected flags and generic pass rows When db-test runs Then no receipt authority is invented" {
    printf '%s\n' '{"protected":true,"result":"pass","task_id":6495}' > "$TMP_DIR/assertion.json"
    export PV_BACKUP_ASSURANCE_FILE="$TMP_DIR/assertion.json"
    export PV_BACKUP_ASSURANCE_VERIFIER=/bin/true
    when_preflight --stage db-test
    then_assurance_refused
}

@test "Given wrong-vault stale corrupt or drifted claims When db-test runs Then unbound evidence cannot admit" {
    # These are adversarial assertions, not an accepted producer format or parser test.
    for claim in wrong-vault stale corrupt current-drift partial-capture primary-only propagation-only authentication-unavailable; do
        printf '{"claim":"%s","protected":true}\n' "$claim" > "$TMP_DIR/assertion.json"
        export PV_BACKUP_ASSURANCE_FILE="$TMP_DIR/assertion.json"
        when_preflight --stage db-test
        then_assurance_refused
    done
}

@test "Given arbitrary JSON passed as an assurance receipt When db-test runs Then it is not a receipt" {
    printf '%s\n' '{"protected":true,"result":"pass","task_id":6495}' > "$TMP_DIR/assertion.json"
    when_preflight --stage db-test --assurance-receipt "$TMP_DIR/assertion.json"
    then_assurance_refused
    [[ "$output" == *"not a backup assurance receipt"* ]]
    export PV_BACKUP_ASSURANCE_RECEIPT="$TMP_DIR/absent-receipt.json"
    when_preflight --stage db-test
    then_assurance_refused
}

@test "Given a receipt and only a SQLite identity When db-test runs Then exact-state assurance refuses" {
    rmdir "$TMP_DIR/prompt-vault-db/.dolt" "$TMP_DIR/prompt-vault-db"
    touch "$TMP_DIR/prompt-vault.db" "$TMP_DIR/receipt.json"
    when_preflight --stage db-test --assurance-receipt "$TMP_DIR/receipt.json"
    then_assurance_refused
    [[ "$output" == *"needs a Dolt vault"* ]]
}

@test "Given no receipt When db-test runs Then the refusal names the missing receipt" {
    when_preflight --stage db-test
    then_assurance_refused
    [[ "$output" == *"no assurance receipt supplied"* ]]
}

@test "Given legacy path variables When db-test runs Then they are identified as non-authoritative" {
    when_preflight --stage db-test
    then_assurance_refused
    [[ "$output" == *"path variables are not recovery evidence"* ]]
}

@test "Given missing argument values When parsing Then usage error is explicit" {
    when_preflight --stage
    [ "$status" -eq 2 ]
    [[ "$output" == *"requires a value"* ]]
    when_preflight --stage db-prod --exception-file
    [ "$status" -eq 2 ]
    [[ "$output" == *"requires a value"* ]]
    when_preflight --stage db-test --assurance-receipt
    [ "$status" -eq 2 ]
    [[ "$output" == *"requires a value"* ]]
}

@test "Given repeated stage arguments When a lower stage follows Then refuse ambiguity" {
    when_preflight --stage db-test --stage db-dev
    [ "$status" -eq 2 ]
    [[ "$output" == *"--stage may be supplied only once"* ]]
    when_preflight --stage db-dev --stage db-test
    [ "$status" -eq 2 ]
}

@test "Given invalid stages or unknown options When parsing Then no admission occurs" {
    when_preflight --stage unknown
    [ "$status" -eq 2 ]
    when_preflight --stage db-dev --unrecognized
    [ "$status" -eq 2 ]
    when_preflight
    [ "$status" -eq 2 ]
}

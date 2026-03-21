#!/usr/bin/env bats
# Tests for evidence-promotion ledger authority validation

load 'setup'

setup() {
    TMP_DIR="$(mktemp -d)"
    TEST_LEDGER_JSON="$TMP_DIR/evidence-promotion-ledger.json"
    cp "$BATS_TEST_DIRNAME/../docs/dev/evidence-promotion-ledger.json" "$TEST_LEDGER_JSON"
    export LEDGER_DOC_PATH="$BATS_TEST_DIRNAME/../docs/dev/evidence-promotion-ledger.md"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv-verify-evidence-promotion-ledger validates the canonical JSON ledger" {
    run env LEDGER_JSON_PATH="$TEST_LEDGER_JSON" LEDGER_DOC_PATH="$LEDGER_DOC_PATH" "$SCRIPTS_DIR/pv-verify-evidence-promotion-ledger"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Evidence promotion ledger verified"* ]]
}

@test "pv-verify-evidence-promotion-ledger rejects wildcard evidence paths" {
    run jq '.[0].evidence.path = "~/.pi/agent/sessions/*.jsonl"' "$TEST_LEDGER_JSON"
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" > "$TEST_LEDGER_JSON"

    run env LEDGER_JSON_PATH="$TEST_LEDGER_JSON" LEDGER_DOC_PATH="$LEDGER_DOC_PATH" "$SCRIPTS_DIR/pv-verify-evidence-promotion-ledger"
    [ "$status" -ne 0 ]
}

@test "pv-verify-evidence-promotion-ledger rejects duplicate ids" {
    run jq '.[1].id = .[0].id' "$TEST_LEDGER_JSON"
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" > "$TEST_LEDGER_JSON"

    run env LEDGER_JSON_PATH="$TEST_LEDGER_JSON" LEDGER_DOC_PATH="$LEDGER_DOC_PATH" "$SCRIPTS_DIR/pv-verify-evidence-promotion-ledger"
    [ "$status" -ne 0 ]
}

#!/usr/bin/env bats
# Exact caller transport is a production prompt contract, not newest-file discovery.
load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    content=$(dolt --data-dir "$VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name='close-session' AND status='active'")
    template=$(printf '%s' "$content" | jq -er '.rows | select(length == 1) | .[0].content')
}

header_check() {
    local code
    code=$(printf '%s\n' "$template" | awk '/<!-- close-session-header-check:start -->/{inside=1;next} /<!-- close-session-header-check:end -->/{inside=0} inside && !/^```/{print}')
    [ -n "$code" ] || return 64
    CALLER_SESSION_FILE="$1" CALLER_SESSION_ID="$2" bash -eu -c "$code"
}

fixture() {
    jq -cn --arg id "$2" --arg cwd "$BATS_TEST_TMPDIR" --arg parent "${3:-}" '{type:"session",version:3,id:$id,cwd:$cwd,parentSession:$parent}' > "$1"
}

@test "close-session uses the host gate, never a newest-cwd selector" {
    [[ "$template" == *'session_closeout({ action: "open" })'* ]]
    [[ "$template" == *'sessionId'* && "$template" == *'sessionFile'* ]]
    [[ "$template" != *'Resolve the newest session JSONL'* ]]
    [[ "$template" != *'modified within the last'* ]]
    [[ "$template" == *'BLOCKED'* ]]
}

@test "newer same-cwd audit child cannot replace the explicitly supplied caller" {
    fixture "$BATS_TEST_TMPDIR/caller.jsonl" caller
    fixture "$BATS_TEST_TMPDIR/newer-audit.jsonl" audit "$BATS_TEST_TMPDIR/caller.jsonl"
    touch -d '+1 hour' "$BATS_TEST_TMPDIR/newer-audit.jsonl"
    run header_check "$BATS_TEST_TMPDIR/caller.jsonl" caller
    [ "$status" -eq 0 ]
    [[ "$output" == *'"id":"caller"'* ]]
    run header_check "$BATS_TEST_TMPDIR/newer-audit.jsonl" caller
    [ "$status" -ne 0 ]
}

@test "child environment cannot substitute its own identity for passed caller values" {
    fixture "$BATS_TEST_TMPDIR/caller.jsonl" caller
    fixture "$BATS_TEST_TMPDIR/child.jsonl" child
    export PI_SESSION_FILE="$BATS_TEST_TMPDIR/child.jsonl" PI_SESSION_ID=child
    run header_check "$BATS_TEST_TMPDIR/caller.jsonl" caller
    [ "$status" -eq 0 ]
    [[ "$output" == *'"id":"caller"'* ]]
}

@test "fork ancestry does not authorize substituting a parent session" {
    fixture "$BATS_TEST_TMPDIR/parent.jsonl" parent
    fixture "$BATS_TEST_TMPDIR/fork.jsonl" fork "$BATS_TEST_TMPDIR/parent.jsonl"
    run header_check "$BATS_TEST_TMPDIR/fork.jsonl" fork
    [ "$status" -eq 0 ]
    run header_check "$BATS_TEST_TMPDIR/parent.jsonl" fork
    [ "$status" -ne 0 ]
}

@test "compaction and later inherited-looking entries do not replace header identity" {
    fixture "$BATS_TEST_TMPDIR/caller.jsonl" caller
    jq -cn '{type:"compaction",id:"c1",parentId:null,summary:"another session",firstKeptEntryId:"u1"}' >> "$BATS_TEST_TMPDIR/caller.jsonl"
    run header_check "$BATS_TEST_TMPDIR/caller.jsonl" caller
    [ "$status" -eq 0 ]
    [[ "$output" == *'"id":"caller"'* ]]
}

@test "missing file, malformed header and non-session header fail closed" {
    run header_check "$BATS_TEST_TMPDIR/missing.jsonl" caller
    [ "$status" -ne 0 ]
    printf 'broken\n' > "$BATS_TEST_TMPDIR/broken.jsonl"
    run header_check "$BATS_TEST_TMPDIR/broken.jsonl" caller
    [ "$status" -ne 0 ]
    printf '%s\n' '{"type":"message","id":"caller","cwd":"/"}' > "$BATS_TEST_TMPDIR/wrong.jsonl"
    run header_check "$BATS_TEST_TMPDIR/wrong.jsonl" caller
    [ "$status" -ne 0 ]
}

@test "closeout retains operator-only approval and actual outcome requirements" {
    [[ "$template" == *'action: "freeze"'* ]]
    [[ "$template" == *'action: "seal"'* ]]
    [[ "$template" == *'Never approve on the operator'* ]]
    [[ "$template" == *'print/RPC'* ]]
    [[ "$template" == *'pi.closeout-handoff.v1'* ]]
    [[ "$template" == *'No reference'* ]]
    [[ "$template" == *'SAFE_TO_CLOSE'* ]]
    [[ "$template" == *'30 obligations'* ]]
}

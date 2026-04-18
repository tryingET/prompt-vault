#!/usr/bin/env bats
# Verify the Prompt Vault-side workstation posture machine-snapshot handoff stays bounded

load 'setup'

setup() {
    NOTE_PATH="$BATS_TEST_DIRNAME/../docs/dev/workstation-posture-machine-snapshot-handoff.md"
}

@test "workstation posture handoff note keeps the owner split explicit" {
    [ -f "$NOTE_PATH" ]

    run grep -F "This note does **not** create a new Prompt Vault snapshot surface." "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F '| `infra/workstation` |' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F "Prompt bodies, governed metadata, and visibility canon | Prompt Vault" "$NOTE_PATH"
    [ "$status" -eq 0 ]
}

@test "workstation posture handoff note names the minimum truthful handoff fields" {
    run grep -F 'exact `entity_version` resolved from Prompt Vault' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F 'exact `execution_id` only if a real Prompt Vault execution row was created' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F '`captured_at`' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F '`sources.gpu_budget_policy.reconcile_recommended`' "$NOTE_PATH"
    [ "$status" -eq 0 ]
}

@test "workstation posture handoff note keeps prompt canon and private output out of machine packets" {
    run grep -F 'prompt template bodies or long prompt excerpts' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F 'private `output_text`' "$NOTE_PATH"
    [ "$status" -eq 0 ]

    run grep -F 'No widening workstation posture machine snapshots into a second Prompt Vault export surface.' "$BATS_TEST_DIRNAME/../next_session_prompt.md"
    [ "$status" -eq 0 ]
}

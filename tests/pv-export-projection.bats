#!/usr/bin/env bats

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TEST_ROOT="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TEST_ROOT/vault"
    TEST_PROMPTS_DIR="$TEST_ROOT/prompts"
    TEST_SKILLS_DIR="$TEST_ROOT/skills"
    copy_test_vault "$TEST_VAULT_DIR"
    mkdir -p "$TEST_PROMPTS_DIR" "$TEST_SKILLS_DIR"
}

teardown() {
    rm -rf "$TEST_ROOT"
}

@test "export-to-pi writes a projection receipt and freshness passes" {
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/export-to-pi.sh"
    [ "$status" -eq 0 ]
    [ -f "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json" ]

    run jq -e '.schema == "prompt-vault/pi-export-receipt/v1" and (.template_count | type == "number") and (.templates | type == "array")' "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK: Pi prompt projection fresh"* ]]
}

@test "freshness check fails closed when an exported prompt file is stale" {
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/export-to-pi.sh"
    [ "$status" -eq 0 ]

    first_prompt="$(jq -r '.templates[0].path' "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json")"
    [ -n "$first_prompt" ]
    printf 'stale\n' > "$TEST_PROMPTS_DIR/$first_prompt"

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Pi prompt projection is stale"* ]]
    [[ "$output" == *"Run: ./scripts/pv export"* ]]
}

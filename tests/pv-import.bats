#!/usr/bin/env bats
# Tests for import-from-pi.sh

load 'setup'

setup() {
    skip_if_no_dolt
    TMP_DIR="$(make_test_tmpdir)"
    TEST_HOME="$TMP_DIR/home"
    TEST_VAULT_DIR="$TMP_DIR/vault"
    mkdir -p "$TEST_HOME/.pi/agent/prompts" "$TEST_HOME/.pi/agent/skills"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv import script is executable" {
    [ -x "$SCRIPTS_DIR/import-from-pi.sh" ]
}

@test "pv import handles missing vault gracefully" {
    export VAULT_DIR="$TMP_DIR/missing-vault"
    run "$SCRIPTS_DIR/import-from-pi.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Vault not initialized"* ]]
}

@test "pv import imports templates with apostrophes in file names" {
    printf 'template body\n' > "$TEST_HOME/.pi/agent/prompts/o'hare.md"

    run env HOME="$TEST_HOME" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]

    run env HOME="$TEST_HOME" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/import-from-pi.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Imported template: o'hare"* ]]

    count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM prompt_templates WHERE name = 'o''hare'" | tail -1)
    [ "$count" -eq 1 ]
}

@test "pv import imports skills with apostrophes in directory names and links assets" {
    skill_dir="$TEST_HOME/.pi/agent/skills/o'hare-skill"
    mkdir -p "$skill_dir"
    cat > "$skill_dir/SKILL.md" <<'EOF'
---
description: demo skill
license: MIT
compatibility: any
---
# Demo
EOF
    printf 'asset body\n' > "$skill_dir/notes.txt"

    run env HOME="$TEST_HOME" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]

    run env HOME="$TEST_HOME" VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/import-from-pi.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Imported skill: o'hare-skill"* ]]
    [[ "$output" != *"Error parsing SQL"* ]]

    count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM skills WHERE name = 'o''hare-skill'" | tail -1)
    [ "$count" -eq 1 ]

    skill_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM skills WHERE name = 'o''hare-skill' LIMIT 1" | tail -1)
    asset_count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM skill_assets WHERE skill_id = $skill_id" | tail -1)
    [ "$asset_count" -eq 1 ]
}

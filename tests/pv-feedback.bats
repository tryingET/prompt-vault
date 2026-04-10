#!/usr/bin/env bats
# Tests for feedback cardinality and CLI behavior

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv-rate rejects duplicate feedback for the same execution" {
    template_row=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id, version FROM prompt_templates WHERE status = 'active' ORDER BY id LIMIT 1" | tail -1)
    template_id=$(echo "$template_row" | cut -d',' -f1)
    template_version=$(echo "$template_row" | cut -d',' -f2)

    [ -n "$template_id" ]
    [ -n "$template_version" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('template', $template_id, $template_version, 'test-model', TRUE)"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions" | tail -1)
    [ -n "$exec_id" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-rate" "$exec_id" 5 "first note"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Recorded feedback for execution $exec_id"* ]]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-rate" "$exec_id" 4 "second note"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Feedback already exists for execution $exec_id"* ]]
}

@test "pv-rate rejects non-numeric execution ids" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-rate" "1 OR 1=1" 5 "note"
    [ "$status" -ne 0 ]
    [[ "$output" == *"execution-id must be a non-negative integer"* ]]
}

@test "pv-rate suggests the correct follow-up surface for skill executions" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO skills (name, description, readme, owner_company, visibility_companies, status)
        VALUES ('skill-feedback-test', 'desc', 'readme', 'core', '[\"core\"]', 'active')
    "
    [ "$status" -eq 0 ]

    skill_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM skills WHERE name = 'skill-feedback-test'" | tail -1)
    [ -n "$skill_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('skill', $skill_id, 1, 'test-model', TRUE)"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions" | tail -1)
    [ -n "$exec_id" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-rate" "$exec_id" 5 "solid"
    [ "$status" -eq 0 ]
    [[ "$output" == *"View skill: pv show skill skill-feedback-test"* ]]
}

#!/usr/bin/env bats
# Fast contract tests for fail-closed operator surfaces

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

seed_old_execution() {
    local vault_dir="$1"
    local template_row template_id template_version

    template_row=$(dolt --data-dir "$vault_dir" sql -r csv -q "SELECT id, version FROM prompt_templates WHERE status = 'active' ORDER BY id LIMIT 1" | tail -1)
    template_id=$(printf '%s' "$template_row" | cut -d',' -f1)
    template_version=$(printf '%s' "$template_row" | cut -d',' -f2)

    dolt --data-dir "$vault_dir" sql -q "
        INSERT INTO executions (entity_type, entity_id, entity_version, input_args, output_capture_mode, success, created_at)
        VALUES ('template', $template_id, $template_version, '[]', 'none', TRUE, DATE_SUB(NOW(), INTERVAL 40 DAY))
    "
}

@test "pv search rejects missing --type value" {
    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv" search review --type
    [ "$status" -ne 0 ]
    [[ "$output" == *"--type requires a value"* ]]
    [[ "$output" == *"Usage: pv-search <query> [--type template|skill|all]"* ]]
}

@test "pv search rejects unsupported type values" {
    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv" search review --type templte
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unsupported search type: templte"* ]]
    [[ "$output" == *"Usage: pv-search <query> [--type template|skill|all]"* ]]
}

@test "pv cleanup rejects unknown options without deleting executions" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"
    seed_old_execution "$TEST_VAULT_DIR"

    before_count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM executions" | tail -1)
    before_head=$(cd "$TEST_VAULT_DIR" && dolt log -n 1 --oneline)

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30 --oops
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option: --oops"* ]]
    [[ "$output" == *"Usage: pv cleanup [days] [--dry-run]"* ]]

    after_count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM executions" | tail -1)
    after_head=$(cd "$TEST_VAULT_DIR" && dolt log -n 1 --oneline)
    [ "$after_count" -eq "$before_count" ]
    [ "$after_head" = "$before_head" ]
}

@test "pv cleanup rejects trailing args after dry-run without deleting executions" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"
    seed_old_execution "$TEST_VAULT_DIR"

    before_count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM executions" | tail -1)

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30 --dry-run --extra
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown option: --extra"* ]]
    [[ "$output" == *"Usage: pv cleanup [days] [--dry-run]"* ]]

    after_count=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM executions" | tail -1)
    [ "$after_count" -eq "$before_count" ]
}

@test "pv push defaults to the current branch" {
    REMOTE_VAULT_DIR="$TMP_DIR/remote-vault"
    TEST_VAULT_DIR="$TMP_DIR/work-vault"

    run env VAULT_DIR="$REMOTE_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]

    run bash -lc '
        set -euo pipefail
        work_vault="$1"
        remote_vault="$2"
        cd "$work_vault"
        dolt remote add origin "file://$remote_vault"
        dolt checkout -b feature/test >/dev/null
    ' _ "$TEST_VAULT_DIR" "$REMOTE_VAULT_DIR"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" push origin
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pushed feature/test to origin"* ]]

    remote_branches=$(cd "$TEST_VAULT_DIR" && dolt branch -a)
    [[ "$remote_branches" == *"remotes/origin/feature/test"* ]]
}

@test "pv-migrate backfills current schema version when schema_version is empty" {
    TEST_VAULT_DIR="$TMP_DIR/migrate-vault"

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "DELETE FROM schema_version"

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-migrate" up
    [ "$status" -eq 0 ]
    [[ "$output" == *"Backfilled schema version to v10 from current schema shape"* ]]
    [[ "$output" == *"No pending migrations"* ]]

    current_version=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(version) FROM schema_version" | tail -1)
    [ "$current_version" -eq 10 ]
}

@test "pv-migrate create uses the highest existing migration number" {
    MIGRATIONS_TMP_DIR="$TMP_DIR/migrations"
    mkdir -p "$MIGRATIONS_TMP_DIR"
    touch "$MIGRATIONS_TMP_DIR/002_alpha.sql" "$MIGRATIONS_TMP_DIR/009_beta.sql"

    run env VAULT_DIR="$VAULT_DIR" MIGRATIONS_DIR="$MIGRATIONS_TMP_DIR" EDITOR=true "$SCRIPTS_DIR/pv-migrate" create gamma
    [ "$status" -eq 0 ]
    [[ "$output" == *"010-gamma.sql"* ]]
    [ -f "$MIGRATIONS_TMP_DIR/010-gamma.sql" ]
}

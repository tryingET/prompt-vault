#!/usr/bin/env bats
# Tests for the retrieval analytics SQLite sidecar (analytics.db):
# lazy schema init, append-only writes, aggregate views, cleanup independence.

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_sqlite3
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/vault"
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]
    export VAULT_DIR="$TEST_VAULT_DIR"
    # shellcheck disable=SC1091
    source "$SCRIPTS_DIR/pv-lib.sh"
}

teardown() {
    rm -rf "$TMP_DIR"
}

skip_if_no_sqlite3() {
    command -v sqlite3 >/dev/null 2>&1 || skip "sqlite3 not installed"
}

insert_event() {
    local days_ago="$1" rank="$2" entity_id="${3:-1}"
    sqlite3 "$TEST_VAULT_DIR/analytics.db" "
        INSERT INTO retrieval_events
            (entity_type, entity_id, entity_version, tool, query_context, selected_rank, result_count, company, created_at)
        VALUES
            ('template', $entity_id, 3, 'vault_query', '{}', $rank, 5, 'core',
             datetime('now', '-$days_ago days'));
    "
}

@test "analytics_ensure creates WAL sidecar schema idempotently" {
    analytics_ensure
    analytics_ensure  # second run must be a no-op
    [ -f "$TEST_VAULT_DIR/analytics.db" ]

    local mode
    mode=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "PRAGMA journal_mode;")
    [ "$mode" = "wal" ]

    local objects
    objects=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "
        SELECT count(*) FROM sqlite_master
        WHERE name IN ('retrieval_events', 'v_retrievals_daily', 'v_retrievals_by_entity');")
    [ "$objects" -eq 3 ]
}

@test "sidecar accepts append-only events and aggregates via views" {
    analytics_ensure
    insert_event 1 1
    insert_event 1 2
    insert_event 40 3 2

    local total
    total=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "SELECT COUNT(*) FROM retrieval_events;")
    [ "$total" -eq 3 ]

    local agg
    agg=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "
        SELECT retrieval_count, avg_rank, top_rank_count
        FROM v_retrievals_by_entity WHERE entity_id = 1;")
    [ "$agg" = "2|1.5|1" ]

    local days
    days=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "SELECT COUNT(*) FROM v_retrievals_daily;")
    [ "$days" -eq 2 ]
}

@test "pv retrievals summary reports from the sidecar" {
    analytics_ensure
    insert_event 1 1

    run "$SCRIPTS_DIR/pv" retrievals summary
    [ "$status" -eq 0 ]
    [[ "$output" == *"Retrieval Analytics"* ]]
    [[ "$output" == *"Total events: 1"* ]]
}

@test "pv cleanup no longer touches retrieval analytics" {
    analytics_ensure
    insert_event 100 1  # old event that the dolt-era cleanup would have expired

    run "$SCRIPTS_DIR/pv" cleanup 30
    [ "$status" -eq 0 ]
    [[ "$output" != *"retrieval records"* ]]

    local total
    total=$(sqlite3 "$TEST_VAULT_DIR/analytics.db" "SELECT COUNT(*) FROM retrieval_events;")
    [ "$total" -eq 1 ]
}

@test "dolt schema no longer contains retrieval tables" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SHOW TABLES"
    [ "$status" -eq 0 ]
    [[ "$output" != *"retrievals"* ]]
    [[ "$output" != *"retrieval_rollups"* ]]
}

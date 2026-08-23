#!/usr/bin/env bats
# Tests for pv cleanup retrieval retention: rollup-then-expire lifecycle

load 'setup'

setup() {
    skip_if_no_dolt
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/vault"
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/init-vault.sh"
    [ "$status" -eq 0 ]
}

teardown() {
    rm -rf "$TMP_DIR"
}

seed_retrieval() {
    local days_ago="$1" rank="$2" result_count="$3" company="${4:-core}"
    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO retrievals
            (entity_type, entity_id, tool, query_context, selected_rank, result_count, company, created_at)
        VALUES
            ('template', 1, 'vault_query', '{}', $rank, $result_count, '$company',
             DATE_SUB(NOW(), INTERVAL $days_ago DAY));
    " >/dev/null
}

@test "cleanup keeps fresh raw retrievals and reports rollup posture" {
    seed_retrieval 1 2 5

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30
    [ "$status" -eq 0 ]
    [[ "$output" == *"No records to clean up"* ]]

    raw=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM retrievals" | tail -1)
    [ "$raw" -eq 1 ]
    rollups=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM retrieval_rollups" | tail -1)
    [ "$rollups" -eq 0 ]
}

@test "cleanup expires old raw retrievals into day-grain rollups preserving aggregates" {
    seed_retrieval 100 1 5
    seed_retrieval 99 2 5
    seed_retrieval 98 3 7 software

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30
    [ "$status" -eq 0 ]

    raw=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM retrievals" | tail -1)
    [ "$raw" -eq 0 ]
    rollups=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT COUNT(*) FROM retrieval_rollups" | tail -1)
    [ "$rollups" -eq 3 ]

    # Each rollup row keeps its day grain and exact aggregates
    agg=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "
        SELECT retrieval_count, rank_sum, result_count_sum FROM retrieval_rollups
        WHERE company = 'software'" | tail -1)
    [ "$agg" = "1,3,7" ]
}

@test "cleanup merges repeat expirations into existing rollup rows without loss" {
    seed_retrieval 100 1 5
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30
    [ "$status" -eq 0 ]

    # Same day grain as the first seeded row: DATE(NOW() - 100d) minus one day offset
    # is not guaranteed identical, so re-seed using the exact stored day.
    local day
    day=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT day FROM retrieval_rollups LIMIT 1" | tail -1)

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO retrievals
            (entity_type, entity_id, tool, query_context, selected_rank, result_count, company, created_at)
        VALUES
            ('template', 1, 'vault_query', '{}', 4, 5, 'core', '$day 12:00:00');
    " >/dev/null

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" cleanup 30
    [ "$status" -eq 0 ]

    agg=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "
        SELECT retrieval_count, rank_sum FROM retrieval_rollups WHERE day = '$day'" | tail -1)
    [ "$agg" = "2,5" ]
}

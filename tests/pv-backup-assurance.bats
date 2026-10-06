#!/usr/bin/env bats
# Exact-state backup assurance runs against isolated real Dolt fixtures and a fixture `ak`.

@test "exact-state receipts admit db-test only for the recovered captured state and refuse falsifiers" {
    run env PYTHONDONTWRITEBYTECODE=1 python3 "$BATS_TEST_DIRNAME/test_backup_assurance.py"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
}

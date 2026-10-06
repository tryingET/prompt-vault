#!/usr/bin/env bats
# Native skill snapshot tests use isolated real Dolt fixtures; no live state writes.

@test "exact skill snapshots preserve bundles and reject unsafe/partial/drifted inputs" {
    run env PYTHONDONTWRITEBYTECODE=1 python3 "$BATS_TEST_DIRNAME/test_skill_bundles.py"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK"* ]]
}

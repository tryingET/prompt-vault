#!/usr/bin/env bats
# Verify company ownership and visibility boundary

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "seeded routers are core-owned and visible to all governed companies" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT COUNT(*)
        FROM prompt_templates
        WHERE name IN ('analysis-router','post-review-router','review-closeout-router')
          AND owner_company = 'core'
          AND JSON_SEARCH(visibility_companies, 'one', 'core') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'software') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'finance') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'house') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'health') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'teaching') IS NOT NULL
          AND JSON_SEARCH(visibility_companies, 'one', 'holding') IS NOT NULL
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

@test "company visibility filter returns core routers for software" {
    run "$SCRIPTS_DIR/pv" templates visibility_company=software
    [ "$status" -eq 0 ]
    [[ "$output" == *"analysis-router"* ]]
    [[ "$output" == *"post-review-router"* ]]
    [[ "$output" == *"review-closeout-router"* ]]
}

#!/usr/bin/env bats
# Verify controlled vocabulary coverage for seeded router prompts

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "seeded routers have semantic metamodel controlled vocabulary metadata" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT COUNT(*)
        FROM prompt_templates
        WHERE name IN ('analysis-router','post-review-router','review-closeout-router')
          AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.transition_target_type')) = 'framework_mode'
          AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.routing_context')) IS NOT NULL
          AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.activity_phase')) IS NOT NULL
          AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.input_artifact')) IS NOT NULL
          AND JSON_UNQUOTE(JSON_EXTRACT(controlled_vocabulary, '$.output_commitment')) = 'exact_next_prompt'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *$'3' ]]
}

@test "selection principles stay separate from output commitments" {
    run dolt --data-dir "$VAULT_DIR" sql -r csv -q "
        SELECT JSON_SEARCH(controlled_vocabulary, 'one', 'constraint_preserving', NULL, '$.selection_principles[*]')
        FROM prompt_templates
        WHERE name = 'post-review-router'
        LIMIT 1
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"selection_principles"* ]]
}

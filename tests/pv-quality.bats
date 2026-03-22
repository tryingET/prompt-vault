#!/usr/bin/env bats
# Tests for quality surfaces and fail-closed behavior

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

@test "pv-quality check performs a real health check" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality checks passed"* ]]
    [[ "$output" == *"Active templates:"* ]]
}

@test "pv-quality rejects unknown subcommands" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" does-not-exist
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unknown command"* ]]
}

@test "pv-quality template rejects injected names" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" template "analysis-router' OR 1=1 -- "
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "pv-quality coverage summarizes evidence without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "do not leak this private output"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template'" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 4, 'solid', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" coverage 200
    [ "$status" -eq 0 ]
    [[ "$output" == *"Evidence Coverage by Active Entity"* ]]
    [[ "$output" == *"feedback_rate_pct"* ]]
    [[ "$output" == *"capture_rate_pct"* ]]
    [[ "$output" == *"private_captures"* ]]
    [[ "$output" == *"analysis-router"* ]]
    [[ "$output" != *"do not leak this private output"* ]]
}

@test "pv-quality rollup aggregates by allowed dimensions without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "never show this private rollup payload"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template'" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'great', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup control_mode
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality Rollup by control_mode"* ]]
    [[ "$output" == *"bucket"* ]]
    [[ "$output" == *"avg_quality_score"* ]]
    [[ "$output" == *"router"* ]]
    [[ "$output" != *"never show this private rollup payload"* ]]
}

@test "pv-quality rollup supports controlled-vocabulary dimensions without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "never show this private routing payload"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template'" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'great', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup routing_context
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality Rollup by routing_context"* ]]
    [[ "$output" == *"analysis_followup"* ]]
    [[ "$output" == *"avg_quality_score"* ]]
    [[ "$output" != *"never show this private routing payload"* ]]
}

@test "pv-quality selection_principles rollup supports multi-valued router semantics without leaking private output text" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" analysis-router "sample context" --output-text "never show this private selection principle payload"
    [ "$status" -eq 0 ]

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template'" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'great', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup selection_principles
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality Rollup by selection_principles"* ]]
    [[ "$output" == *"evidence_based"* ]]
    [[ "$output" == *"avg_quality_score"* ]]
    [[ "$output" != *"never show this private selection principle payload"* ]]
}

@test "pv-quality selection_principles rollup counts a router in every governed principle bucket it declares" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup selection_principles
    [ "$status" -eq 0 ]
    baseline_evidence=$(printf '%s\n' "$output" | awk -F'|' '/evidence_based/ {gsub(/ /, "", $3); print $3; exit}')
    baseline_minimal=$(printf '%s\n' "$output" | awk -F'|' '/minimal_change/ {gsub(/ /, "", $3); print $3; exit}')
    [ -n "$baseline_evidence" ]
    [ -n "$baseline_minimal" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            controlled_vocabulary,
            status
        ) VALUES (
            'multi-principle-router',
            'This router proves that one active router can contribute to multiple selection-principle buckets.',
            REPEAT('m', 150),
            'procedure',
            'router',
            'structured',
            'core',
            '[\"core\"]',
            '{\"routing_context\":\"analysis_followup\",\"activity_phase\":\"post_analysis\",\"input_artifact\":\"analysis_output\",\"transition_target_type\":\"framework_mode\",\"selection_principles\":[\"evidence_based\",\"minimal_change\"],\"output_commitment\":\"exact_next_prompt\"}',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup selection_principles
    [ "$status" -eq 0 ]
    after_evidence=$(printf '%s\n' "$output" | awk -F'|' '/evidence_based/ {gsub(/ /, "", $3); print $3; exit}')
    after_minimal=$(printf '%s\n' "$output" | awk -F'|' '/minimal_change/ {gsub(/ /, "", $3); print $3; exit}')
    [ "$after_evidence" = "$((baseline_evidence + 1))" ]
    [ "$after_minimal" = "$((baseline_minimal + 1))" ]
}

@test "pv-quality router-vocabulary rollups ignore non-router templates with matching JSON keys" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup routing_context
    [ "$status" -eq 0 ]
    baseline_count=$(printf '%s\n' "$output" | awk -F'|' '/analysis_followup/ {gsub(/ /, "", $3); print $3; exit}')
    [ -n "$baseline_count" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            controlled_vocabulary,
            status
        ) VALUES (
            'not-a-router-but-has-routing-context',
            'This active template should never contaminate router-only rollups.',
            'content',
            'procedure',
            'one_shot',
            'structured',
            'core',
            '[\"core\"]',
            '{\"routing_context\":\"analysis_followup\"}',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup routing_context
    [ "$status" -eq 0 ]
    after_count=$(printf '%s\n' "$output" | awk -F'|' '/analysis_followup/ {gsub(/ /, "", $3); print $3; exit}')
    [ "$after_count" = "$baseline_count" ]
}

@test "pv-quality selection_principles rollup ignores non-router templates with matching JSON keys" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup selection_principles
    [ "$status" -eq 0 ]
    baseline_count=$(printf '%s\n' "$output" | awk -F'|' '/evidence_based/ {gsub(/ /, "", $3); print $3; exit}')
    [ -n "$baseline_count" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            controlled_vocabulary,
            status
        ) VALUES (
            'not-a-router-but-has-selection-principles',
            'This active template should never contaminate selection_principles rollups.',
            'content',
            'procedure',
            'one_shot',
            'structured',
            'core',
            '[\"core\"]',
            '{\"selection_principles\":[\"evidence_based\",\"minimal_change\"]}',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup selection_principles
    [ "$status" -eq 0 ]
    after_count=$(printf '%s\n' "$output" | awk -F'|' '/evidence_based/ {gsub(/ /, "", $3); print $3; exit}')
    [ "$after_count" = "$baseline_count" ]
}

@test "pv-quality rollup avg_rating is weighted by feedback rows" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "UPDATE prompt_templates SET status = 'archived' WHERE name = 'review-closeout-router'"
    [ "$status" -eq 0 ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            controlled_vocabulary,
            status
        ) VALUES
        (
            'weighted-rollup-a',
            'This router exists to prove weighted rating rollup behavior for review closeout.',
            REPEAT('a', 150),
            'procedure',
            'router',
            'structured',
            'core',
            '[\"core\"]',
            '{\"routing_context\":\"review_closeout\",\"activity_phase\":\"closeout\",\"input_artifact\":\"review_summary\",\"transition_target_type\":\"framework_mode\",\"selection_principles\":[\"minimal_change\"],\"output_commitment\":\"exact_next_prompt\"}',
            'active'
        ),
        (
            'weighted-rollup-b',
            'This router also exists to prove weighted rating rollup behavior for review closeout.',
            REPEAT('b', 150),
            'procedure',
            'router',
            'structured',
            'core',
            '[\"core\"]',
            '{\"routing_context\":\"review_closeout\",\"activity_phase\":\"closeout\",\"input_artifact\":\"review_summary\",\"transition_target_type\":\"framework_mode\",\"selection_principles\":[\"minimal_change\"],\"output_commitment\":\"exact_next_prompt\"}',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    template_a=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM prompt_templates WHERE name = 'weighted-rollup-a'" | tail -1)
    template_b=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM prompt_templates WHERE name = 'weighted-rollup-b'" | tail -1)
    [ -n "$template_a" ]
    [ -n "$template_b" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('template', $template_a, 1, 'test-model', TRUE)"
    [ "$status" -eq 0 ]
    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template' AND entity_id = $template_a" | tail -1)
    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'excellent', '[]', TRUE)"
    [ "$status" -eq 0 ]

    for _ in $(seq 1 10); do
        run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('template', $template_b, 1, 'test-model', TRUE)"
        [ "$status" -eq 0 ]
        exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template' AND entity_id = $template_b" | tail -1)
        run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 1, 'poor', '[]', FALSE)"
        [ "$status" -eq 0 ]
    done

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup routing_context
    [ "$status" -eq 0 ]
    weighted_avg=$(printf '%s\n' "$output" | awk -F'|' '/review_closeout/ {gsub(/ /, "", $12); print $12; exit}')
    [ "$weighted_avg" = "1.36" ]
}

@test "pv-quality rollup rejects unsupported dimensions" {
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" rollup "owner_company; DROP TABLE prompt_templates;"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Unsupported rollup dimension"* ]]
}

@test "pv-quality uses rating contribution without external bc dependency" {
    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (
            name,
            description,
            content,
            artifact_kind,
            control_mode,
            formalization_level,
            owner_company,
            visibility_companies,
            status
        ) VALUES (
            'quality-proof',
            'This description is comfortably longer than fifty characters for deterministic scoring.',
            REPEAT('x', 150),
            'procedure',
            'one_shot',
            'structured',
            'core',
            '[\"core\"]',
            'active'
        )
    "
    [ "$status" -eq 0 ]

    template_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT id FROM prompt_templates WHERE name = 'quality-proof'" | tail -1)
    [ -n "$template_id" ]

    for _ in $(seq 1 10); do
        run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO executions (entity_type, entity_id, entity_version, model, success) VALUES ('template', $template_id, 1, 'test-model', TRUE)"
        [ "$status" -eq 0 ]
    done

    exec_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT MAX(id) FROM executions WHERE entity_type = 'template' AND entity_id = $template_id" | tail -1)
    [ -n "$exec_id" ]

    run dolt --data-dir "$TEST_VAULT_DIR" sql -q "INSERT INTO feedback (execution_id, rating, notes, issues, would_use_again) VALUES ($exec_id, 5, 'excellent', '[]', TRUE)"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-quality" template quality-proof
    [ "$status" -eq 0 ]
    [[ "$output" == *"Score: 100/100"* ]]
    [[ "$output" == *"Grade: A"* ]]
    [[ "$output" == *"feedback_rate_pct"* ]]
    [[ "$output" == *"capture_rate_pct"* ]]
}

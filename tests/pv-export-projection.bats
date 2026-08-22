#!/usr/bin/env bats

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TEST_ROOT="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TEST_ROOT/vault"
    TEST_PROMPTS_DIR="$TEST_ROOT/prompts"
    TEST_SKILLS_DIR="$TEST_ROOT/skills"
    copy_test_vault "$TEST_VAULT_DIR"
    mkdir -p "$TEST_PROMPTS_DIR" "$TEST_SKILLS_DIR"
}

teardown() {
    rm -rf "$TEST_ROOT"
}

@test "export-to-pi writes a projection receipt and freshness passes" {
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/export-to-pi.sh"
    [ "$status" -eq 0 ]
    [ -f "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json" ]

    run jq -e '.schema == "prompt-vault/pi-export-receipt/v2" and (.candidate_count == (.exported_count + .quarantined_count)) and (.templates | type == "array") and (.quarantined | type == "array")' "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json"
    [ "$status" -eq 0 ]

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 0 ]
    [[ "$output" == *"OK: Pi prompt projection fresh"* ]]
}

@test "gated and unbound templates are quarantined from raw Pi prompt files" {
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/export-to-pi.sh"
    [ "$status" -eq 0 ]

    gated="$(jq -r '.quarantined[] | select(.reason == "gated" or .reason == "unbound") | .name' "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json" | head -1)"
    [ -n "$gated" ]
    [ ! -e "$TEST_PROMPTS_DIR/$gated.md" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 0 ]

    printf 'unsafe bypass\n' > "$TEST_PROMPTS_DIR/$gated.md"
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 1 ]
    [[ "$output" == *"quarantined template has raw projection"* ]]
}

@test "projection policy quarantines routers with unknown controlled vocabulary" {
    fixture='{"rows":[{"name":"unsafe-router","version":1,"content":"x","artifact_kind":"procedure","control_mode":"router","formalization_level":"structured","owner_company":"core","visibility_companies":["core"],"controlled_vocabulary":{"routing_context":"analysis_followup","activity_phase":"post_analysis","input_artifact":"analysis_output","transition_target_type":"framework_mode","selection_principles":["evidence_based"],"output_commitment":"future_unsafe_value"}}]}'
    project_root="$(dirname "$SCRIPTS_DIR")"
    run bash -c 'printf "%s" "$1" | "$2/pv-export-policy.py" --controlled-vocabulary-contract "$3/ontology/controlled-vocabulary-contract.json"' _ "$fixture" "$SCRIPTS_DIR" "$project_root"
    [ "$status" -eq 0 ]
    run jq -e '.exported_count == 0 and .quarantined_count == 1 and .quarantined[0].reason == "unknown"' <<< "$output"
    [ "$status" -eq 0 ]
}

@test "freshness check fails closed when an exported prompt file is stale" {
    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/export-to-pi.sh"
    [ "$status" -eq 0 ]

    first_prompt="$(jq -r '.templates[0].path' "$TEST_PROMPTS_DIR/.prompt-vault-export-state.json")"
    [ -n "$first_prompt" ]
    printf 'stale\n' > "$TEST_PROMPTS_DIR/$first_prompt"

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Pi prompt projection is stale"* ]]
    [[ "$output" == *"Run: ./scripts/pv export"* ]]
}

@test "publishing an active template auto-refreshes the Pi projection by default" {
    candidate="$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT name FROM prompt_templates WHERE status='active' AND export_to_pi=false AND control_mode IN ('one_shot','router') AND formalization_level <> 'workflow' AND artifact_kind <> 'session' ORDER BY name LIMIT 1" | tail -1)"
    [ -n "$candidate" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/pv" publish "$candidate"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pi prompt projection fresh"* ]]
    [ -f "$TEST_PROMPTS_DIR/$candidate.md" ]

    run env VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" "$SCRIPTS_DIR/pv-export-freshness"
    [ "$status" -eq 0 ]
}

@test "PV_AUTO_EXPORT=0 fails closed when a publish would leave projection stale" {
    candidate="$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT name FROM prompt_templates WHERE status='active' AND export_to_pi=false AND control_mode IN ('one_shot','router') AND formalization_level <> 'workflow' AND artifact_kind <> 'session' ORDER BY name LIMIT 1" | tail -1)"
    [ -n "$candidate" ]

    run env PV_AUTO_EXPORT=0 VAULT_DIR="$TEST_VAULT_DIR" TEMPLATES_DIR="$TEST_PROMPTS_DIR" SKILLS_DIR="$TEST_SKILLS_DIR" "$SCRIPTS_DIR/pv" publish "$candidate"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Pi projection is stale after template publish"* ]]
    [[ "$output" == *"Run: ./scripts/pv export"* ]]
}

#!/usr/bin/env bats
# Static startup/authority regressions. No AK or Vault mutations, no shared fixture setup.

setup() {
    REPO_DIR="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "AGENTS uses native frame/wave authority and no routine import or removed launcher" {
    run grep -F 'AK-native strategic frames (`strategic_frame`) and implementation waves (`work_wave`)' "$REPO_DIR/AGENTS.md"
    [ "$status" -eq 0 ]
    run grep -F 'ak direction import|check|export' "$REPO_DIR/AGENTS.md"
    [ "$status" -ne 0 ]
    run grep -F './scripts/ak.sh' "$REPO_DIR/README.md"
    [ "$status" -ne 0 ]
}

@test "all operational entrypoints route to native direction instead of a legacy operating plan" {
    for file in AGENTS.md README.md QUICKSTART.md next_session_prompt.md .pi/skills/prompt-vault-operator/SKILL.md docs/project/model.md; do
        run grep -F 'direction-workflow.md' "$REPO_DIR/$file"
        [ "$status" -eq 0 ]
    done
    run grep -F '/docs/project/operating_plan.md' "$REPO_DIR/.pi/skills/prompt-vault-operator/SKILL.md"
    [ "$status" -ne 0 ]
    run grep -F 'schema v9' "$REPO_DIR/.pi/skills/prompt-vault-operator/SKILL.md"
    [ "$status" -ne 0 ]
}

@test "legacy SG TG OP documents remain explicitly historical rather than active authoring" {
    for file in strategic_goals.md tactical_goals.md operating_plan.md; do
        run grep -F '**Historical only — retired from current authoring' "$REPO_DIR/docs/project/$file"
        [ "$status" -eq 0 ]
        run grep -F 'direction-workflow.md' "$REPO_DIR/docs/project/$file"
        [ "$status" -eq 0 ]
    done
}

@test "stable startup reads native strategy waves checks and tasks without hardcoding next work" {
    for command in 'ak strategy list -F json' 'ak wave list -F json' 'ak direction check -F json' 'ak task ready -F json'; do
        run grep -F "$command" "$REPO_DIR/next_session_prompt.md"
        [ "$status" -eq 0 ]
    done
    run grep -F 'not a mutable handoff, status mirror or next-task ledger' "$REPO_DIR/next_session_prompt.md"
    [ "$status" -eq 0 ]
    run grep -E 'cargo run|Active strategic goal:|Active tactical goal:|ak direction import\|' "$REPO_DIR/next_session_prompt.md"
    [ "$status" -ne 0 ]
}

@test "native workflow separates consistency from completion and preserves content/runtime boundaries" {
    run grep -F 'not permission to execute, close a frame/wave' "$REPO_DIR/docs/project/direction-workflow.md"
    [ "$status" -eq 0 ]
    run grep -F 'Skill storage support does not imply skills have been imported' "$REPO_DIR/AGENTS.md"
    [ "$status" -eq 0 ]
    run grep -F 'Loop/workflow bodies are template rows; downstream runtime bindings are separate facts.' "$REPO_DIR/.pi/skills/prompt-vault-operator/SKILL.md"
    [ "$status" -eq 0 ]
    run grep -F 'No widening workstation posture machine snapshots into a second Prompt Vault export surface.' "$REPO_DIR/next_session_prompt.md"
    [ "$status" -eq 0 ]
}

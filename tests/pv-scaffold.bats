#!/usr/bin/env bats
# Tests for pv-scaffold

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
}

@test "pv scaffold --help works" {
    run "$SCRIPTS_DIR/pv-scaffold" --help
    [ "$status" -eq 0 ]
}

@test "pv scaffold shows usage without args" {
    run "$SCRIPTS_DIR/pv-scaffold"
    [ "$status" -ne 0 ] || [[ "$output" == *"Usage"* ]]
}

@test "pv scaffold create template writes a governed draft" {
    TMP_DIR="$(make_test_tmpdir)"
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    editor_script="$TMP_DIR/noop-editor.sh"
    cat > "$editor_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF
    chmod +x "$editor_script"

    run env VAULT_DIR="$TEST_VAULT_DIR" EDITOR="$editor_script" "$SCRIPTS_DIR/pv-scaffold" create template scaffold-review
    [ "$status" -eq 0 ]
    [[ "$output" == *"Created template 'scaffold-review' (draft)"* ]]

    row=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r csv -q "SELECT artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status FROM prompt_templates WHERE name = 'scaffold-review'" | tail -1)
    [[ "$row" == procedure,one_shot,structured,core,* ]]
    [[ "$row" == *draft ]]

    rm -rf "$TMP_DIR"
}

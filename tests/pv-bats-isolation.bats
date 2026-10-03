#!/usr/bin/env bats
load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "runner protects caller Vault and projection roots from default edit/export side effects" {
    source_vault="$TMP_DIR/caller-vault"
    copy_test_vault "$source_vault"
    mkdir -p "$TMP_DIR/caller-home" "$TMP_DIR/caller-prompts" "$TMP_DIR/caller-skills"
    printf 'operator prompt sentinel\n' > "$TMP_DIR/caller-prompts/inversion.md"
    before=$(dolt --data-dir "$source_vault" sql -r json -q "SELECT content,version FROM prompt_templates WHERE name='inversion'")
    cat > "$TMP_DIR/child.bats" <<'BATS'
@test "private defaults" {
    [ "$HOME" != "$EXPECTED_HOME" ]
    [ "$VAULT_DIR" != "$EXPECTED_VAULT" ]
    [ "$TEMPLATES_DIR" != "$EXPECTED_PROMPTS" ]
    editor="$TMPDIR/editor"
    printf '#!/usr/bin/env bash\nprintf "fixture edit only\\n" > "$1"\n' > "$editor"
    chmod +x "$editor"
    run env EDITOR="$editor" "$SCRIPTS_DIR/pv" edit-template inversion
    [ "$status" -eq 0 ]
    [ "$(cat "$TEMPLATES_DIR/inversion.md")" = "fixture edit only" ]
}
BATS
    run env HOME="$TMP_DIR/caller-home" TEMPLATES_DIR="$TMP_DIR/caller-prompts" SKILLS_DIR="$TMP_DIR/caller-skills" VAULT_DIR="$source_vault" PV_TEST_VAULT_DIR="$source_vault" EXPECTED_HOME="$TMP_DIR/caller-home" EXPECTED_VAULT="$source_vault" EXPECTED_PROMPTS="$TMP_DIR/caller-prompts" "$SCRIPTS_DIR/pv-bats" "$TMP_DIR/child.bats"
    printf '%s\n' "$output"
    [ "$status" -eq 0 ]
    after=$(dolt --data-dir "$source_vault" sql -r json -q "SELECT content,version FROM prompt_templates WHERE name='inversion'")
    [ "$before" = "$after" ]
    [ "$(cat "$TMP_DIR/caller-prompts/inversion.md")" = "operator prompt sentinel" ]
    [ -z "$(ls -A "$TMP_DIR/caller-home")" ]
    [ -z "$(ls -A "$TMP_DIR/caller-skills")" ]
}

#!/usr/bin/env bats
# Tests for pv CLI commands

load 'setup'

setup() {
    skip_if_no_dolt
    skip_if_no_vault
    TMP_DIR="$(make_test_tmpdir)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "pv --help shows usage" {
    run "$SCRIPTS_DIR/pv" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]] || [[ "$output" == *"pv"* ]]
}

@test "pv --version returns version" {
    run "$SCRIPTS_DIR/pv" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0"* ]]
}

@test "pv list-commands shows available commands" {
    run "$SCRIPTS_DIR/pv" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"templates"* ]]
    [[ "$output" == *"skills"* ]]
}

@test "pv templates lists templates" {
    run "$SCRIPTS_DIR/pv" templates
    [ "$status" -eq 0 ]
}

@test "pv skills lists skills" {
    run "$SCRIPTS_DIR/pv" skills
    [ "$status" -eq 0 ]
}

@test "pv search requires query argument" {
    run "$SCRIPTS_DIR/pv" search
    [ "$status" -ne 0 ]
}

@test "pv tag list works" {
    run "$SCRIPTS_DIR/pv" tag list
    [ "$status" -eq 0 ]
}

@test "pv quality check runs" {
    run "$SCRIPTS_DIR/pv" quality check
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality checks passed"* ]]
}

@test "pv quality coverage runs" {
    run "$SCRIPTS_DIR/pv" quality coverage 5
    [ "$status" -eq 0 ]
    [[ "$output" == *"Evidence Coverage by Active Entity"* ]]
}

@test "pv quality rollup runs" {
    run "$SCRIPTS_DIR/pv" quality rollup control_mode
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality Rollup by control_mode"* ]]
}

@test "pv quality rollup selection_principles runs" {
    run "$SCRIPTS_DIR/pv" quality rollup selection_principles
    [ "$status" -eq 0 ]
    [[ "$output" == *"Quality Rollup by selection_principles"* ]]
}

@test "pv-diff summary runs without shell local errors" {
    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv-diff" HEAD HEAD summary
    [ "$status" -eq 0 ]
    [[ "$output" == *"Summary: HEAD..HEAD"* ]]
    [[ "$output" != *"local: can only be used in a function"* ]]
}

@test "pv rollback preserves multiline template content" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    before=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name = 'inversion' AND status = 'active' LIMIT 1" | jq -r '.rows[0].content')
    [[ "$before" == *"What must be true for this system to appear healthy while actually being sick?"* ]]

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv" rollback template inversion HEAD
    [ "$status" -eq 0 ]

    after=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name = 'inversion' AND status = 'active' LIMIT 1" | jq -r '.rows[0].content')
    [ "$after" = "$before" ]
}

@test "pv edit-template updates content without stored procedure dependency" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    editor_script="$TMP_DIR/mock-editor.sh"
    cat > "$editor_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat <<'CONTENT' > "$1"
Updated prompt body
with multiple lines
CONTENT
EOF
    chmod +x "$editor_script"

    before_version=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT version FROM prompt_templates WHERE name = 'inversion' LIMIT 1" | jq -r '.rows[0].version')

    run env VAULT_DIR="$TEST_VAULT_DIR" EDITOR="$editor_script" "$SCRIPTS_DIR/pv" edit-template inversion
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated template 'inversion'"* ]]

    after_content=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name = 'inversion' LIMIT 1" | jq -r '.rows[0].content')
    after_version=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT version FROM prompt_templates WHERE name = 'inversion' LIMIT 1" | jq -r '.rows[0].version')
    [ "$after_content" = $'Updated prompt body\nwith multiple lines' ]
    [ "$after_version" -eq $((before_version + 1)) ]
}

@test "pv edit-template requires jq explicitly" {
    tempbin="$TMP_DIR/no-jq-edit-bin"
    mkdir -p "$tempbin"
    ln -s "$(command -v dirname)" "$tempbin/dirname"
    ln -s "$(command -v mkdir)" "$tempbin/mkdir"

    run env PATH="$tempbin" VAULT_DIR="$VAULT_DIR" /bin/bash "$SCRIPTS_DIR/pv" edit-template inversion
    [ "$status" -ne 0 ]
    [[ "$output" == *"Missing required dependencies: jq"* ]]
}

@test "pv edit-template supports existing empty template content" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('empty-template', 'desc', '', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    editor_script="$TMP_DIR/fill-empty-template.sh"
    cat > "$editor_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'Now filled in' > "$1"
EOF
    chmod +x "$editor_script"

    run env VAULT_DIR="$TEST_VAULT_DIR" EDITOR="$editor_script" "$SCRIPTS_DIR/pv" edit-template empty-template
    [ "$status" -eq 0 ]
    [[ "$output" == *"Updated template 'empty-template'"* ]]

    after_content=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name = 'empty-template' LIMIT 1" | jq -r '.rows[0].content')
    [ "$after_content" = "Now filled in" ]
}

@test "pv edit-template cleans temp file when editor fails" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    editor_script="$TMP_DIR/failing-editor.sh"
    cat > "$editor_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 42
EOF
    chmod +x "$editor_script"

    temp_workspace="$TMP_DIR/editor-tmp"
    mkdir -p "$temp_workspace"

    run env VAULT_DIR="$TEST_VAULT_DIR" TMPDIR="$temp_workspace" EDITOR="$editor_script" "$SCRIPTS_DIR/pv" edit-template inversion
    [ "$status" -eq 42 ]

    run find "$temp_workspace" -maxdepth 1 -name '*.md' -type f
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "pv-export-formats markdown preserves multiline prompt content" {
    output_dir="$TMP_DIR/export-markdown"
    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv-export-formats" markdown "$output_dir"
    [ "$status" -eq 0 ]

    exported_file="$output_dir/templates/inversion.md"
    [ -f "$exported_file" ]
    exported_content=$(python3 - <<'PY' "$exported_file"
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
marker = "## Prompt\n\n"
print(text.split(marker, 1)[1], end="")
PY
)
    canonical=$(dolt --data-dir "$VAULT_DIR" sql -r json -q "SELECT content FROM prompt_templates WHERE name = 'inversion' AND status = 'active' LIMIT 1" | jq -r '.rows[0].content')
    [ "$exported_content" = "$canonical" ]
}

@test "pv-integrate semantic-kernel preserves multiline prompt content" {
    output_dir="$TMP_DIR/semantic-kernel"
    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv-integrate" semantic-kernel "$output_dir"
    [ "$status" -eq 0 ]

    exported_file="$output_dir/inversion.txt"
    [ -f "$exported_file" ]
    [[ "$(python3 - <<'PY' "$exported_file"
import pathlib, sys
text = pathlib.Path(sys.argv[1]).read_text()
print(text, end="")
PY
)" == *"What must be true for this system to appear healthy while actually being sick?"* ]]
}

@test "pv-integrate api-server honors CLI port and rejects injected search" {
    command -v curl >/dev/null 2>&1 || skip "curl not installed"

    port=$((20000 + RANDOM % 10000))
    server_log="$TMP_DIR/api-server.log"

    run bash -lc '
        set -euo pipefail
        port="$1"
        server_log="$2"
        export VAULT_DIR="$3"
        export PV_API_VISIBILITY_COMPANY=software
        "$4/pv-integrate" api-server "$port" >"$server_log" 2>&1 &
        server_pid=$!
        cleanup() {
            child_pids=$(pgrep -P "$server_pid" || true)
            if [ -n "$child_pids" ]; then
                kill $child_pids 2>/dev/null || true
            fi
            kill "$server_pid" 2>/dev/null || true
            wait "$server_pid" 2>/dev/null || true
        }
        trap cleanup EXIT

        for _ in $(seq 1 10); do
            if curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done

        health=$(curl -fsS "http://127.0.0.1:${port}/health")
        injected=$(curl -fsS "http://127.0.0.1:${port}/api/templates?search=%27%20OR%201%3D1%20--%20")

        printf "health=%s\n" "$health"
        printf "injected_rows=%s\n" "$(printf "%s" "$injected" | jq ".rows | length")"
    ' _ "$port" "$server_log" "$VAULT_DIR" "$SCRIPTS_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *'health={"status": "ok", "visibility_company": "software"}'* ]]
    [[ "$output" == *'injected_rows=0'* ]]
}

@test "pv-integrate api-server shuts down on TERM" {
    command -v curl >/dev/null 2>&1 || skip "curl not installed"

    port=$((20000 + RANDOM % 10000))
    server_log="$TMP_DIR/api-server-term.log"

    run bash -lc '
        set -euo pipefail
        port="$1"
        server_log="$2"
        export VAULT_DIR="$3"
        "$4/pv-integrate" api-server "$port" >"$server_log" 2>&1 &
        server_pid=$!
        cleanup() {
            child_pids=$(pgrep -P "$server_pid" || true)
            if [ -n "$child_pids" ]; then
                kill $child_pids 2>/dev/null || true
            fi
            kill "$server_pid" 2>/dev/null || true
            wait "$server_pid" 2>/dev/null || true
        }
        trap cleanup EXIT

        for _ in $(seq 1 10); do
            if curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done

        curl -fsS "http://127.0.0.1:${port}/health" >/dev/null
        kill -TERM "$server_pid"

        for _ in $(seq 1 10); do
            if ! ps -p "$server_pid" >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done

        if ps -p "$server_pid" >/dev/null 2>&1; then
            echo "server still running after TERM" >&2
            exit 1
        fi

        if curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
            echo "health endpoint still reachable after TERM" >&2
            exit 1
        fi

        echo "terminated"
    ' _ "$port" "$server_log" "$VAULT_DIR" "$SCRIPTS_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *'terminated'* ]]
}

@test "pv-template-vars document and usage keep dollar-at arguments visible" {
    expected="\`\$@\` - All arguments joined"

    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv-template-vars" document e3d-htn
    [ "$status" -eq 0 ]
    [[ "$output" == *"$expected"* ]]

    run env VAULT_DIR="$VAULT_DIR" "$SCRIPTS_DIR/pv-template-vars" usage e3d-htn
    [ "$status" -eq 0 ]
    [[ "$output" == *'e3d-htn <args...>'* ]]
}

@test "pv-template-vars validate flags invalid named variables" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('bad-var-test', 'desc', '\$S and \$1', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-template-vars" validate bad-var-test
    [ "$status" -eq 0 ]
    [[ "$output" == *"UNSUPPORTED_VAR:\$S"* ]]
}

@test "pv-template-vars validate ignores escaped named variables" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('escaped-var-test', 'desc', CONCAT('literal ', CHAR(92), CHAR(36), 'HOME and ', CHAR(92), CHAR(36), '1'), 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-template-vars" validate escaped-var-test
    [ "$status" -eq 0 ]
    [[ "$output" == *"✓ escaped-var-test"* ]]
    [[ "$output" != *"UNSUPPORTED_VAR"* ]]
}

@test "pv-template-vars validate flags unsupported brace variables" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('brace-var-test', 'desc', 'literal \${HOME} and \${PATH}', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-template-vars" validate brace-var-test
    [ "$status" -eq 0 ]
    [[ "$output" == *'UNSUPPORTED_VAR:${HOME}'* ]]
    [[ "$output" == *'UNSUPPORTED_VAR:${PATH}'* ]]
}

@test "pv-exec preserves escaped vars and expands slices with shared semantics" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES (
            'exec-var-test',
            'desc',
            CONCAT('literal ', CHAR(92), CHAR(36), 'ARGUMENTS | first=', CHAR(36), '1', ' | rest=', CHAR(36), '{@:2:2} | unsupported=', CHAR(36), '{HOME} | slash=', CHAR(92), CHAR(92)),
            'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active'
        )
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-exec" exec-var-test alpha beta gamma delta
    [ "$status" -eq 0 ]
    [[ "$output" == *'literal $ARGUMENTS | first=alpha | rest=beta gamma | unsupported=${HOME} | slash=\'* ]]
}

@test "pv-lint targets the requested template" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('lint-target-test', 'description long enough for targeted linting', 'hello world', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-lint" lint-target-test
    [ "$status" -eq 0 ]
    [[ "$output" != *'=== Linting all templates ==='* ]]
    [[ "$output" == *'=== Template: lint-target-test ==='* ]]
}

@test "pv-lint handles quoted template names" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('quote''name', 'description long enough for quoted name linting', 'hello world', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-lint" "quote'name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"=== Template: quote'name ==="* ]]
}

@test "pv-export-formats python escapes triple quotes in generated module" {
    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('triple-quote-test', 'desc', 'contains '''''' quotes', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "

    output_file="$TMP_DIR/prompts.py"
    run env VAULT_DIR="$TEST_VAULT_DIR" "$SCRIPTS_DIR/pv-export-formats" python "$output_file"
    [ "$status" -eq 0 ]
    [ -f "$output_file" ]

    run python3 -m py_compile "$output_file"
    [ "$status" -eq 0 ]
}

@test "pv-integrate api-server stats scope executions by visibility" {
    command -v curl >/dev/null 2>&1 || skip "curl not installed"

    TEST_VAULT_DIR="$TMP_DIR/prompt-vault-db"
    copy_test_vault "$TEST_VAULT_DIR"

    dolt --data-dir "$TEST_VAULT_DIR" sql -q "DELETE FROM executions"
    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES
          ('visible-template', 'desc', 'visible', 'procedure', 'one_shot', 'structured', 'software', '[\"software\"]', 'active'),
          ('hidden-template', 'desc', 'hidden', 'procedure', 'one_shot', 'structured', 'core', '[\"core\"]', 'active')
    "
    visible_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT id FROM prompt_templates WHERE name = 'visible-template'" | jq -r '.rows[0].id')
    hidden_id=$(dolt --data-dir "$TEST_VAULT_DIR" sql -r json -q "SELECT id FROM prompt_templates WHERE name = 'hidden-template'" | jq -r '.rows[0].id')
    dolt --data-dir "$TEST_VAULT_DIR" sql -q "
        INSERT INTO executions (entity_type, entity_id, entity_version, success)
        VALUES
          ('template', $visible_id, 1, TRUE),
          ('template', $hidden_id, 1, TRUE)
    "

    port=$((20000 + RANDOM % 10000))
    server_log="$TMP_DIR/api-stats.log"

    run bash -lc '
        set -euo pipefail
        port="$1"
        server_log="$2"
        export VAULT_DIR="$3"
        export PV_API_VISIBILITY_COMPANY=software
        "$4/pv-integrate" api-server "$port" >"$server_log" 2>&1 &
        server_pid=$!
        cleanup() {
            child_pids=$(pgrep -P "$server_pid" || true)
            if [ -n "$child_pids" ]; then
                kill $child_pids 2>/dev/null || true
            fi
            kill "$server_pid" 2>/dev/null || true
            wait "$server_pid" 2>/dev/null || true
        }
        trap cleanup EXIT

        for _ in $(seq 1 10); do
            if curl -fsS "http://127.0.0.1:${port}/health" >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done

        curl -fsS "http://127.0.0.1:${port}/api/stats"
    ' _ "$port" "$server_log" "$TEST_VAULT_DIR" "$SCRIPTS_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"executions": 1'* ]]
    [[ "$output" == *'"visibility_company": "software"'* ]]
}

@test "pv-integrate help does not require jq" {
    tempbin="$TMP_DIR/no-jq-bin"
    mkdir -p "$tempbin"
    ln -s "$(command -v dirname)" "$tempbin/dirname"
    ln -s "$(command -v mkdir)" "$tempbin/mkdir"
    ln -s "$(command -v cat)" "$tempbin/cat"

    run env PATH="$tempbin" /bin/bash "$SCRIPTS_DIR/pv-integrate" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: pv-integrate"* ]]
}

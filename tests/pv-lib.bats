#!/usr/bin/env bats
# Tests for pv-lib.sh shared functions

load 'setup'

setup() {
    source "$SCRIPTS_DIR/pv-lib.sh"
}

@test "pv-lib: info function outputs blue arrow" {
    run info "test message"
    [[ "$output" == *"▶"* ]]
    [[ "$output" == *"test message"* ]]
}

@test "pv-lib: success function outputs green check" {
    run success "passed"
    [[ "$output" == *"✓"* ]]
    [[ "$output" == *"passed"* ]]
}

@test "pv-lib: warn function outputs yellow exclamation" {
    run warn "warning"
    [[ "$output" == *"!"* ]]
    [[ "$output" == *"warning"* ]]
}

@test "pv-lib: error function outputs red X" {
    run error "failed"
    [[ "$output" == *"✗"* ]]
    [[ "$output" == *"failed"* ]]
}

@test "pv-lib: check_deps passes for existing commands" {
    run check_deps bash
    [ "$status" -eq 0 ]
}

@test "pv-lib: check_deps fails for missing commands" {
    run check_deps nonexistent_command_xyz_123
    [ "$status" -eq 1 ]
    [[ "$output" == *"Missing required dependencies"* ]]
}

@test "pv-lib: sql_escape handles single quotes" {
    result=$(sql_escape "it's a test")
    [[ "$result" == *"''"* ]]
}

@test "pv-lib: sql_escape handles multi-line content" {
    result=$(sql_escape "line1
line2")
    [[ "$result" == *"line1"* ]]
    [[ "$result" == *"line2"* ]]
}

@test "pv-lib: sql_escape handles backslashes" {
    result=$(sql_escape "path\\to\\file")
    [[ "$result" == "path\\\\to\\\\file" ]]
}

@test "pv-lib: sql_escape handles backslash-quote sequences" {
    result=$(sql_escape "test\\'s value")
    # Should escape both backslash and quote
    [[ "$result" == *"\\\\''"* ]]
}

@test "pv-lib: sql_escape removes null bytes" {
    result=$(printf 'line1\0line2' | sql_escape)
    [[ "$result" == "line1line2" ]]
}

@test "pv-lib: sql_escape handles commas" {
    result=$(sql_escape "a, b, c")
    [[ "$result" == *"a, b, c"* ]]
}

@test "pv-lib: sql_escape handles unicode" {
    result=$(sql_escape "Hello 世界 🌍")
    [[ "$result" == *"世界"* ]]
    [[ "$result" == *"🌍"* ]]
}

@test "pv-lib: sql_escape handles mixed adversarial content" {
    result=$(sql_escape "it's a\\test, with 'quotes', \\backslashes\\, and commas")
    [[ "$result" == *"''"* ]]      # Escaped quotes
    [[ "$result" == *"a\\\\test"* ]]
    [[ "$result" == *"\\\\backslashes\\\\"* ]]
    [[ "$result" == *","* ]]       # Commas preserved
}

@test "pv-lib: sql_escape_base64 produces valid base64" {
    result=$(sql_escape_base64 "test content")
    # Base64 only contains alphanumeric, +, /, and = for padding
    [[ "$result" =~ ^[A-Za-z0-9+/=]+$ ]]
}

@test "pv-lib: sql_escape_base64 roundtrip preserves content" {
    original="it's a test\\with\\backslashes, commas, and \"quotes\""
    encoded=$(sql_escape_base64 "$original")
    decoded=$(sql_decode_base64 "$encoded")
    [[ "$decoded" == "$original" ]]
}

@test "pv-lib: require_numeric rejects non-numeric values" {
    run require_numeric "12x" "limit"
    [ "$status" -eq 1 ]
    [[ "$output" == *"limit must be a non-negative integer"* ]]
}

@test "pv-lib: terminal_safe_preview strips ansi sequences" {
    result=$(printf 'hello \033[31mRED\033[0m world' | terminal_safe_preview 120)
    [[ "$result" == "hello RED world" ]]
}

@test "pv-lib: terminal_safe_preview strips osc hyperlinks and tabs" {
    result=$(printf 'hello \033]8;;https://example.com\aLINK\033]8;;\a\tworld' | terminal_safe_preview 120)
    [[ "$result" == "hello LINK world" ]]
}

@test "pv-lib: ensure_vault fails when vault missing" {
    # Temporarily override VAULT_DIR
    export VAULT_DIR="/nonexistent/path"
    run ensure_vault
    [ "$status" -eq 1 ]
    [[ "$output" == *"Vault not initialized"* ]]
}

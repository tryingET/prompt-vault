#!/usr/bin/env bash
# pv-lib.sh - Shared library for Prompt Vault scripts
set -euo pipefail

# Resolve VAULT_DIR relative to scripts directory
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "${VAULT_DIR:-}" ]; then
    VAULT_DIR="$SCRIPTS_DIR/../prompt-vault-db"
fi
if [ -z "${TMPDIR:-}" ]; then
    export TMPDIR="$SCRIPTS_DIR/../.tmp"
fi
mkdir -p "$TMPDIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}▶${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Ensure vault is initialized
ensure_vault() {
    if [ ! -d "$VAULT_DIR/.dolt" ]; then
        error "Vault not initialized. Run: pv init"
        exit 1
    fi
    cd "$VAULT_DIR"
}

# Check for required dependencies
check_deps() {
    local missing=()
    local dep
    for dep in "$@"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing[*]}"
        error "Install with: apt install ${missing[*]} || brew install ${missing[*]}"
        exit 1
    fi
}

# Safely escape content for SQL
# Handles: single quotes, backslashes, null bytes, newlines
# Accepts either a single argument or raw stdin for byte-preserving paths.
sql_escape() {
    if [ "$#" -gt 0 ]; then
        printf '%s' "$1"
    else
        cat
    fi | tr -d '\0' | sed 's/\\/\\\\/g; s/'\''/'\'''\''/g'
}

require_numeric() {
    local value="${1:-}"
    local label="${2:-value}"

    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        error "$label must be a non-negative integer"
        exit 1
    fi
}

float_gt() {
    local left="${1:-0}"
    local right="${2:-0}"
    awk -v left="$left" -v right="$right" 'BEGIN { exit !(left > right) }'
}

sanitize_terminal_text() {
    python3 -c "import re, sys; text = sys.stdin.read(); text = re.sub(r'\\x1B\\][^\\x07]*(?:\\x07|\\x1B\\\\)', '', text); text = re.sub(r'\\x1B\\[[0-9;]*[A-Za-z]', '', text); text = text.replace('\\r', ' ').replace('\\n', ' ').replace('\\t', ' '); text = re.sub(r'[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]', ' ', text); print(text, end='')"
}

terminal_safe_preview() {
    local max_len="${1:-120}"

    sanitize_terminal_text | python3 -c "import sys; max_len = int(sys.argv[1]); text = sys.stdin.read(); text = text[:max_len] + ('…' if len(text) > max_len else ''); print(text, end='')" "$max_len"
}

# Alternative: Use base64 encoding for complex content
# Decodes in SQL with: FROM_BASE64('<encoded>')
sql_escape_base64() {
    local content="$1"
    printf '%s' "$content" | base64 -w0
}

# Decode base64 in bash (for round-trip testing)
sql_decode_base64() {
    local encoded="$1"
    printf '%s' "$encoded" | base64 -d
}

# JSON-safe Dolt query helpers for multiline / quoted content
dolt_json_query() {
    local sql="$1"
    dolt sql -r json -q "$sql"
}

json_first_field() {
    local sql="$1"
    local field="$2"
    dolt_json_query "$sql" | jq -r --arg field "$field" '(.rows // [])[0][$field] // empty'
}

json_first_field_record() {
    local sql="$1"
    local field="$2"
    dolt_json_query "$sql" | jq -c --arg field "$field" '{found: ((.rows // []) | length > 0), value: ((.rows // [])[0][$field] // "")}'
}

json_all_field() {
    local sql="$1"
    local field="$2"
    dolt_json_query "$sql" | jq -r --arg field "$field" '(.rows // [])[][$field] // empty'
}

json_rows_base64() {
    local sql="$1"
    dolt_json_query "$sql" | jq -r '(.rows // [])[] | @base64'
}

json_decode_base64() {
    local encoded="$1"
    printf '%s' "$encoded" | base64 -d
}

cleanup_temp_paths() {
    local path
    for path in "$@"; do
        [ -n "$path" ] || continue
        rm -f -- "$path"
    done
}

declare -ag PV_REGISTERED_TEMP_PATHS=()
PV_REGISTERED_TEMP_TRAP_INSTALLED=0
PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_BODY=""

_decode_trap_body() {
    local trap_definition="${1:-}"
    local quoted_body

    [ -z "$trap_definition" ] && return 0

    quoted_body=${trap_definition#trap -- }
    quoted_body=${quoted_body% EXIT}

    [ -z "$quoted_body" ] && return 0
    eval "printf '%s' $quoted_body"
}

_current_exit_trap_body() {
    _decode_trap_body "$(trap -p EXIT || true)"
}

_run_registered_temp_cleanup_on_exit() {
    local status=$?

    cleanup_temp_paths "${PV_REGISTERED_TEMP_PATHS[@]:-}"

    if [ -n "${PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_BODY:-}" ]; then
        local previous_exit_trap_body="$PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_BODY"
        (exit "$status")
        eval "$previous_exit_trap_body"
    fi

    return "$status"
}

register_temp_path() {
    local path
    for path in "$@"; do
        [ -n "$path" ] || continue
        PV_REGISTERED_TEMP_PATHS+=("$path")
    done

    if [ "$PV_REGISTERED_TEMP_TRAP_INSTALLED" -eq 0 ]; then
        PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_BODY="$(_current_exit_trap_body)"
        trap '_run_registered_temp_cleanup_on_exit' EXIT
        PV_REGISTERED_TEMP_TRAP_INSTALLED=1
    fi
}

make_temp_file() {
    local out_var="${1:-}"
    local suffix="${2:-}"
    local generated_temp_file

    [ -z "$out_var" ] && {
        error "make_temp_file requires an output variable name"
        exit 1
    }

    if [ -n "$suffix" ]; then
        generated_temp_file=$(mktemp --suffix="$suffix")
    else
        generated_temp_file=$(mktemp)
    fi

    register_temp_path "$generated_temp_file"
    printf -v "$out_var" '%s' "$generated_temp_file"
}

parse_template_var_tokens() {
    python3 -c "$(cat <<'PY'
import json
import re
import sys

text = sys.stdin.read()
tokens = []
i = 0
length = len(text)

while i < length:
    ch = text[i]
    if ch == '\\':
        if i + 1 < length and text[i + 1] in {'$', '\\'}:
            i += 2
        else:
            i += 1
        continue
    if ch != '$':
        i += 1
        continue
    if i + 1 >= length:
        i += 1
        continue

    nxt = text[i + 1]

    if nxt == '@':
        tokens.append({"kind": "valid", "token": "$@"})
        i += 2
        continue

    if nxt.isdigit():
        j = i + 1
        while j < length and text[j].isdigit():
            j += 1
        tokens.append({"kind": "valid", "token": text[i:j]})
        i = j
        continue

    if nxt == '{':
        j = i + 2
        while j < length and text[j] != '}':
            j += 1
        if j >= length:
            tokens.append({"kind": "unsupported", "token": text[i:]})
            break

        token = text[i:j + 1]
        body = text[i + 2:j]
        if re.fullmatch(r'@:\d+(?::\d+)?', body):
            tokens.append({"kind": "valid", "token": token})
        else:
            tokens.append({"kind": "unsupported", "token": token})
        i = j + 1
        continue

    if re.match(r'[A-Za-z_]', nxt):
        j = i + 1
        while j < length and re.match(r'[A-Za-z0-9_]', text[j]):
            j += 1
        token = text[i:j]
        tokens.append({"kind": "valid" if token == "$ARGUMENTS" else "unsupported", "token": token})
        i = j
        continue

    i += 1

for token in tokens:
    print(json.dumps(token, ensure_ascii=False))
PY
)"
}

template_valid_vars() {
    parse_template_var_tokens | jq -r 'select(.kind == "valid") | .token' | sort -u
}

template_unsupported_vars() {
    parse_template_var_tokens | jq -r 'select(.kind == "unsupported") | .token' | sort -u
}

template_position_indexes() {
    parse_template_var_tokens | jq -r 'select(.kind == "valid" and (.token | test("^\\$[0-9]+$"))) | (.token | ltrimstr("$"))' | sort -n | uniq
}

expand_template_content() {
    local content="${1:-}"
    shift || true

    TEMPLATE_CONTENT="$content" python3 - "$@" <<'PY'
import os
import re
import sys

text = os.environ.get('TEMPLATE_CONTENT', '')
args = sys.argv[1:]
out = []
i = 0
length = len(text)

while i < length:
    ch = text[i]

    if ch == '\\':
        if i + 1 < length and text[i + 1] in {'$', '\\'}:
            out.append(text[i + 1])
            i += 2
        else:
            out.append(ch)
            i += 1
        continue

    if ch != '$':
        out.append(ch)
        i += 1
        continue

    if i + 1 >= length:
        out.append(ch)
        i += 1
        continue

    nxt = text[i + 1]

    if nxt == '@':
        out.append(' '.join(args))
        i += 2
        continue

    if nxt.isdigit():
        j = i + 1
        while j < length and text[j].isdigit():
            j += 1
        index = int(text[i + 1:j]) - 1
        out.append(args[index] if 0 <= index < len(args) else '')
        i = j
        continue

    if nxt == '{':
        j = i + 2
        while j < length and text[j] != '}':
            j += 1
        if j >= length:
            out.append(text[i:])
            break

        token = text[i:j + 1]
        body = text[i + 2:j]
        match = re.fullmatch(r'@:(\d+)(?::(\d+))?', body)
        if match:
            start = int(match.group(1))
            slice_start = max(start - 1, 0)
            values = args[slice_start:]
            if match.group(2) is not None:
                values = values[:int(match.group(2))]
            out.append(' '.join(values))
        else:
            out.append(token)
        i = j + 1
        continue

    if re.match(r'[A-Za-z_]', nxt):
        j = i + 1
        while j < length and re.match(r'[A-Za-z0-9_]', text[j]):
            j += 1
        token = text[i:j]
        if token == '$ARGUMENTS':
            out.append(' '.join(args))
        else:
            out.append(token)
        i = j
        continue

    out.append(ch)
    i += 1

print(''.join(out), end='')
PY
}

PV_SIGNAL_FORWARD_CHILD_PID=""

_forward_registered_child_signal_and_exit() {
    local signal="${1:-TERM}"
    local signal_number

    trap - "$signal"

    if [ -n "${PV_SIGNAL_FORWARD_CHILD_PID:-}" ] && kill -0 "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null; then
        kill "-$signal" "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || kill "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || true
        wait "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || true
    fi

    signal_number=$(kill -l "$signal" 2>/dev/null || true)
    if [ -n "$signal_number" ]; then
        kill "-$signal" "$$" 2>/dev/null || exit $((128 + signal_number))
    fi

    exit 1
}

run_with_signal_forwarding() {
    "$@" &
    PV_SIGNAL_FORWARD_CHILD_PID=$!

    trap '_forward_registered_child_signal_and_exit TERM' TERM
    trap '_forward_registered_child_signal_and_exit INT' INT
    trap '_forward_registered_child_signal_and_exit HUP' HUP

    wait "$PV_SIGNAL_FORWARD_CHILD_PID"
    local status=$?

    trap - TERM INT HUP
    PV_SIGNAL_FORWARD_CHILD_PID=""

    return "$status"
}

# Export functions and variables for sourcing scripts
export -f info success warn error ensure_vault check_deps sql_escape require_numeric float_gt sanitize_terminal_text terminal_safe_preview sql_escape_base64 sql_decode_base64 dolt_json_query json_first_field json_first_field_record json_all_field json_rows_base64 json_decode_base64 cleanup_temp_paths register_temp_path make_temp_file parse_template_var_tokens template_valid_vars template_unsupported_vars template_position_indexes expand_template_content run_with_signal_forwarding
export SCRIPTS_DIR VAULT_DIR RED GREEN YELLOW BLUE NC

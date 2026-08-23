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
error() { echo -e "${RED}✗${NC} $1" >&2; }

usage_error() {
    local usage="${1:-}"
    shift || true
    local detail

    for detail in "$@"; do
        [ -n "$detail" ] || continue
        error "$detail"
    done

    if [ -n "$usage" ]; then
        error "Usage: $usage"
    fi

    exit 1
}

require_option_value() {
    local option="${1:-option}"
    local value="${2-}"
    local usage="${3:-}"

    if [ -z "${value:-}" ]; then
        usage_error "$usage" "$option requires a value"
    fi
}

require_allowed_value() {
    local label="${1:-value}"
    local value="${2:-}"
    local usage="${3:-}"
    shift 3 || true

    local allowed
    for allowed in "$@"; do
        if [ "$value" = "$allowed" ]; then
            return 0
        fi
    done

    usage_error "$usage" "Unsupported $label: $value"
}

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

base64_no_wrap() {
    if [ "$#" -gt 0 ]; then
        base64 < "$1" | tr -d '\r\n'
    else
        base64 | tr -d '\r\n'
    fi
}

# Alternative: Use base64 encoding for complex content
# Decodes in SQL with: FROM_BASE64('<encoded>')
sql_escape_base64() {
    local content="$1"
    printf '%s' "$content" | base64_no_wrap
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

dolt_sql_from_string() {
    local sql="${1:-}"
    local tmp_file status

    make_temp_file tmp_file .sql
    printf '%s' "$sql" > "$tmp_file"

    if ! dolt sql < "$tmp_file"; then
        status=$?
        rm -f -- "$tmp_file"
        return "$status"
    fi

    rm -f -- "$tmp_file"
}

json_array_from_csv() {
    local csv="${1:-}"

    python3 - "$csv" <<'PY'
import json
import sys

items = [item.strip() for item in sys.argv[1].split(',') if item.strip()]
print(json.dumps(items))
PY
}

entity_table_for_type() {
    local type="${1:-}"

    case "$type" in
        template) printf 'prompt_templates' ;;
        skill) printf 'skills' ;;
        *)
            error "Type must be 'template' or 'skill'"
            exit 1
            ;;
    esac
}

entity_content_column_for_type() {
    local type="${1:-}"

    case "$type" in
        template) printf 'content' ;;
        skill) printf 'readme' ;;
        *)
            error "Type must be 'template' or 'skill'"
            exit 1
            ;;
    esac
}

require_entity_record_json() {
    local type="${1:-}"
    local name="${2:-}"
    local fields="${3:-id, version, status}"
    local status_predicate="${4:-}"
    local table escaped_name where_clause record row_count

    check_deps jq
    table=$(entity_table_for_type "$type")
    escaped_name=$(sql_escape "$name")
    where_clause="name = '$escaped_name'"
    if [ -n "$status_predicate" ]; then
        where_clause="$where_clause AND $status_predicate"
    fi

    record=$(dolt_json_query "SELECT $fields FROM $table WHERE $where_clause ORDER BY version DESC LIMIT 1")
    row_count=$(printf '%s' "$record" | jq -r '(.rows // []) | length')

    if [ "$row_count" -eq 0 ]; then
        error "$type '$name' not found"
        exit 1
    fi

    printf '%s' "$record"
}

record_changelog() {
    local entity_type="${1:-}"
    local entity_id="${2:-}"
    local old_version="${3:-}"
    local new_version="${4:-}"
    local change_type="${5:-update}"
    local summary="${6:-}"
    local author escaped_summary escaped_author old_version_sql new_version_sql

    escaped_summary=$(sql_escape "$summary")
    author="${PV_CHANGELOG_AUTHOR:-$(git config user.name 2>/dev/null || printf '%s' "${USER:-unknown}")}"
    escaped_author=$(sql_escape "$author")
    old_version_sql="NULL"
    new_version_sql="NULL"
    [ -n "$old_version" ] && old_version_sql="$old_version"
    [ -n "$new_version" ] && new_version_sql="$new_version"

    dolt sql -q "
        INSERT INTO changelog (entity_type, entity_id, old_version, new_version, change_type, summary, author)
        VALUES ('$entity_type', $entity_id, $old_version_sql, $new_version_sql, '$change_type', '$escaped_summary', '$escaped_author')
    "
}

create_template_entity() {
    local name="${1:-}"
    local description="${2:-}"
    local content="${3:-}"
    local artifact_kind="${4:-procedure}"
    local control_mode="${5:-one_shot}"
    local formalization_level="${6:-structured}"
    local owner_company="${7:-core}"
    local visibility_companies_json="${8:-[]}"
    local controlled_vocabulary_json="${9:-}"
    local status="${10:-draft}"
    local escaped_name escaped_description escaped_content escaped_artifact_kind escaped_control_mode escaped_formalization_level escaped_owner_company escaped_visibility escaped_status controlled_vocabulary_sql entity_record entity_id version

    escaped_name=$(sql_escape "$name")
    escaped_description=$(sql_escape "$description")
    escaped_content=$(sql_escape "$content")
    escaped_artifact_kind=$(sql_escape "$artifact_kind")
    escaped_control_mode=$(sql_escape "$control_mode")
    escaped_formalization_level=$(sql_escape "$formalization_level")
    escaped_owner_company=$(sql_escape "$owner_company")
    escaped_visibility=$(sql_escape "$visibility_companies_json")
    escaped_status=$(sql_escape "$status")
    controlled_vocabulary_sql="NULL"
    if [ -n "$controlled_vocabulary_json" ]; then
        controlled_vocabulary_sql="'$(sql_escape "$controlled_vocabulary_json")'"
    fi

    dolt sql -q "
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
        )
        VALUES (
            '$escaped_name',
            '$escaped_description',
            '$escaped_content',
            '$escaped_artifact_kind',
            '$escaped_control_mode',
            '$escaped_formalization_level',
            '$escaped_owner_company',
            '$escaped_visibility',
            $controlled_vocabulary_sql,
            '$escaped_status'
        )
    "

    entity_record=$(require_entity_record_json template "$name" "id, version")
    entity_id=$(printf '%s' "$entity_record" | jq -r '.rows[0].id')
    version=$(printf '%s' "$entity_record" | jq -r '.rows[0].version')
    record_changelog template "$entity_id" "" "$version" create "Created template '$name'"
}

create_skill_entity() {
    local name="${1:-}"
    local description="${2:-}"
    local readme="${3:-}"
    local license="${4:-}"
    local compatibility="${5:-}"
    local owner_company="${6:-core}"
    local visibility_companies_json="${7:-[]}"
    local status="${8:-draft}"
    local escaped_name escaped_description escaped_readme escaped_license escaped_compatibility escaped_owner_company escaped_visibility escaped_status entity_record entity_id version

    escaped_name=$(sql_escape "$name")
    escaped_description=$(sql_escape "$description")
    escaped_readme=$(sql_escape "$readme")
    escaped_license=$(sql_escape "$license")
    escaped_compatibility=$(sql_escape "$compatibility")
    escaped_owner_company=$(sql_escape "$owner_company")
    escaped_visibility=$(sql_escape "$visibility_companies_json")
    escaped_status=$(sql_escape "$status")

    dolt sql -q "
        INSERT INTO skills (
            name,
            description,
            readme,
            license,
            compatibility,
            owner_company,
            visibility_companies,
            status
        )
        VALUES (
            '$escaped_name',
            '$escaped_description',
            '$escaped_readme',
            '$escaped_license',
            '$escaped_compatibility',
            '$escaped_owner_company',
            '$escaped_visibility',
            '$escaped_status'
        )
    "

    entity_record=$(require_entity_record_json skill "$name" "id, version")
    entity_id=$(printf '%s' "$entity_record" | jq -r '.rows[0].id')
    version=$(printf '%s' "$entity_record" | jq -r '.rows[0].version')
    record_changelog skill "$entity_id" "" "$version" create "Created skill '$name'"
}

update_entity_content_and_description() {
    local type="${1:-}"
    local name="${2:-}"
    local content="${3:-}"
    local description="${4:-}"
    local summary="${5:-Updated ${type} [${name}]}"
    local table content_column escaped_name escaped_content escaped_description entity_record entity_id version_before version_after

    table=$(entity_table_for_type "$type")
    content_column=$(entity_content_column_for_type "$type")
    escaped_name=$(sql_escape "$name")
    escaped_content=$(sql_escape "$content")
    escaped_description=$(sql_escape "$description")
    entity_record=$(require_entity_record_json "$type" "$name" "id, version")
    entity_id=$(printf '%s' "$entity_record" | jq -r '.rows[0].id')
    version_before=$(printf '%s' "$entity_record" | jq -r '.rows[0].version')

    dolt sql -q "
        UPDATE $table
        SET $content_column = '$escaped_content',
            description = '$escaped_description',
            version = COALESCE(version, 0) + 1
        WHERE name = '$escaped_name'
    "

    version_after=$(json_first_field "SELECT version FROM $table WHERE name = '$escaped_name' ORDER BY version DESC LIMIT 1" version)
    record_changelog "$type" "$entity_id" "$version_before" "$version_after" update "$summary"
    printf '%s' "$version_after"
}

set_entity_status() {
    local type="${1:-}"
    local name="${2:-}"
    local target_status="${3:-}"
    local table escaped_name entity_record entity_id version current_status updated_status change_type summary

    table=$(entity_table_for_type "$type")
    escaped_name=$(sql_escape "$name")
    entity_record=$(require_entity_record_json "$type" "$name" "id, version, status")
    entity_id=$(printf '%s' "$entity_record" | jq -r '.rows[0].id')
    version=$(printf '%s' "$entity_record" | jq -r '.rows[0].version')
    current_status=$(printf '%s' "$entity_record" | jq -r '.rows[0].status')

    if [ "$current_status" = "$target_status" ]; then
        info "$type '$name' already $target_status"
        return 0
    fi

    dolt sql -q "UPDATE $table SET status = '$target_status' WHERE name = '$escaped_name'"
    updated_status=$(json_first_field "SELECT status FROM $table WHERE name = '$escaped_name' LIMIT 1" status)
    if [ "$updated_status" != "$target_status" ]; then
        error "Failed to set $type '$name' to $target_status"
        exit 1
    fi

    case "$target_status" in
        active) change_type="reactivate" ;;
        deprecated) change_type="deprecate" ;;
        archived) change_type="archive" ;;
        *) change_type="update" ;;
    esac
    summary="Status: $current_status -> $target_status"
    record_changelog "$type" "$entity_id" "$version" "$version" "$change_type" "$summary"
}

set_template_export_flag() {
    local name="${1:-}"
    local export_enabled="${2:-false}"
    local escaped_name entity_record entity_id version current_export updated_export summary

    escaped_name=$(sql_escape "$name")
    entity_record=$(require_entity_record_json template "$name" "id, version, export_to_pi")
    entity_id=$(printf '%s' "$entity_record" | jq -r '.rows[0].id')
    version=$(printf '%s' "$entity_record" | jq -r '.rows[0].version')
    current_export=$(printf '%s' "$entity_record" | jq -r '.rows[0].export_to_pi')
    case "$current_export" in
        1|true|TRUE) current_export="true" ;;
        0|false|FALSE|"") current_export="false" ;;
    esac

    if [ "$current_export" = "$export_enabled" ]; then
        info "template '$name' export_to_pi already $export_enabled"
        return 0
    fi

    if [ "$export_enabled" = "true" ]; then
        dolt sql -q "UPDATE prompt_templates SET export_to_pi = TRUE WHERE name = '$escaped_name'"
    else
        dolt sql -q "UPDATE prompt_templates SET export_to_pi = FALSE WHERE name = '$escaped_name'"
    fi

    updated_export=$(json_first_field "SELECT export_to_pi FROM prompt_templates WHERE name = '$escaped_name' LIMIT 1" export_to_pi)
    case "$updated_export" in
        1|true|TRUE) updated_export="true" ;;
        0|false|FALSE|"") updated_export="false" ;;
    esac
    if [ "$updated_export" != "$export_enabled" ]; then
        error "Failed to set template '$name' export_to_pi to $export_enabled"
        exit 1
    fi

    summary="export_to_pi: $current_export -> $export_enabled"
    record_changelog template "$entity_id" "$version" "$version" update "$summary"
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
PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_DEFINITION=""

_trap_definition() {
    local signal="${1:-EXIT}"
    trap -p "$signal" || true
}

_decode_trap_body() {
    local trap_definition="${1:-}"
    local signal="${2:-EXIT}"
    local quoted_body

    [ -z "$trap_definition" ] && return 0

    quoted_body=${trap_definition#trap -- }
    quoted_body=${quoted_body% " $signal"}

    [ -z "$quoted_body" ] && return 0
    eval "printf '%s' $quoted_body"
}

_restore_trap_definition() {
    local signal="${1:-EXIT}"
    local trap_definition="${2:-}"

    if [ -n "$trap_definition" ]; then
        eval "$trap_definition"
    else
        trap - "$signal"
    fi
}

_run_decoded_trap_body_with_status() {
    local trap_definition="${1:-}"
    local status="${2:-0}"
    local signal="${3:-EXIT}"
    local trap_body

    trap_body=$(_decode_trap_body "$trap_definition" "$signal")
    [ -z "$trap_body" ] && return 0

    (exit "$status")
    eval "$trap_body"
}

_run_registered_temp_cleanup_on_exit() {
    local status=$?

    cleanup_temp_paths "${PV_REGISTERED_TEMP_PATHS[@]:-}"

    if [ -n "${PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_DEFINITION:-}" ]; then
        _run_decoded_trap_body_with_status "$PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_DEFINITION" "$status" EXIT
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
        PV_REGISTERED_TEMP_PREVIOUS_EXIT_TRAP_DEFINITION="$(_trap_definition EXIT)"
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
        token = text[i:j]
        tokens.append({"kind": "valid" if re.fullmatch(r'\$[1-9][0-9]*', token) else "unsupported", "token": token})
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
        if re.fullmatch(r'@:[1-9][0-9]*(?::[1-9][0-9]*)?', body):
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
        token = text[i:j]
        if re.fullmatch(r'\$[1-9][0-9]*', token):
            index = int(text[i + 1:j]) - 1
            out.append(args[index] if 0 <= index < len(args) else '')
        else:
            out.append(token)
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
        match = re.fullmatch(r'@:([1-9][0-9]*)(?::([1-9][0-9]*))?', body)
        if match:
            start = int(match.group(1))
            slice_start = start - 1
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
PV_SIGNAL_FORWARD_PREVIOUS_TERM_TRAP_DEFINITION=""
PV_SIGNAL_FORWARD_PREVIOUS_INT_TRAP_DEFINITION=""
PV_SIGNAL_FORWARD_PREVIOUS_HUP_TRAP_DEFINITION=""
PV_SIGNAL_FORWARD_GRACE_LOOPS="${PV_SIGNAL_FORWARD_GRACE_LOOPS:-25}"
PV_SIGNAL_FORWARD_GRACE_SLEEP="${PV_SIGNAL_FORWARD_GRACE_SLEEP:-0.2}"

_previous_signal_trap_definition() {
    local signal="${1:-TERM}"

    case "$signal" in
        TERM) printf '%s' "$PV_SIGNAL_FORWARD_PREVIOUS_TERM_TRAP_DEFINITION" ;;
        INT) printf '%s' "$PV_SIGNAL_FORWARD_PREVIOUS_INT_TRAP_DEFINITION" ;;
        HUP) printf '%s' "$PV_SIGNAL_FORWARD_PREVIOUS_HUP_TRAP_DEFINITION" ;;
        *) return 1 ;;
    esac
}

_store_previous_signal_trap_definition() {
    local signal="${1:-TERM}"
    local trap_definition="${2:-}"

    case "$signal" in
        TERM) PV_SIGNAL_FORWARD_PREVIOUS_TERM_TRAP_DEFINITION="$trap_definition" ;;
        INT) PV_SIGNAL_FORWARD_PREVIOUS_INT_TRAP_DEFINITION="$trap_definition" ;;
        HUP) PV_SIGNAL_FORWARD_PREVIOUS_HUP_TRAP_DEFINITION="$trap_definition" ;;
        *) return 1 ;;
    esac
}

_restore_previous_signal_trap_definition() {
    local signal="${1:-TERM}"
    _restore_trap_definition "$signal" "$(_previous_signal_trap_definition "$signal")"
}

_forward_signal_to_registered_child() {
    local signal="${1:-TERM}"
    local remaining_loops

    if [ -z "${PV_SIGNAL_FORWARD_CHILD_PID:-}" ] || ! kill -0 "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null; then
        return 0
    fi

    kill "-$signal" "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || kill "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || true

    remaining_loops="$PV_SIGNAL_FORWARD_GRACE_LOOPS"
    while [ "$remaining_loops" -gt 0 ] && kill -0 "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null; do
        sleep "$PV_SIGNAL_FORWARD_GRACE_SLEEP"
        remaining_loops=$((remaining_loops - 1))
    done

    if kill -0 "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null; then
        kill -KILL "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || true
    fi

    wait "$PV_SIGNAL_FORWARD_CHILD_PID" 2>/dev/null || true
}

_forward_registered_child_signal_and_exit() {
    local signal="${1:-TERM}"
    local signal_number

    _restore_previous_signal_trap_definition "$signal"
    _forward_signal_to_registered_child "$signal"

    signal_number=$(kill -l "$signal" 2>/dev/null || true)
    if [ -n "$signal_number" ]; then
        kill "-$signal" "$$" 2>/dev/null || exit $((128 + signal_number))
    fi

    exit 1
}

run_with_signal_forwarding() {
    "$@" &
    PV_SIGNAL_FORWARD_CHILD_PID=$!

    _store_previous_signal_trap_definition TERM "$(_trap_definition TERM)"
    _store_previous_signal_trap_definition INT "$(_trap_definition INT)"
    _store_previous_signal_trap_definition HUP "$(_trap_definition HUP)"

    trap '_forward_registered_child_signal_and_exit TERM' TERM
    trap '_forward_registered_child_signal_and_exit INT' INT
    trap '_forward_registered_child_signal_and_exit HUP' HUP

    wait "$PV_SIGNAL_FORWARD_CHILD_PID"
    local status=$?

    _restore_previous_signal_trap_definition TERM
    _restore_previous_signal_trap_definition INT
    _restore_previous_signal_trap_definition HUP
    PV_SIGNAL_FORWARD_CHILD_PID=""

    return "$status"
}

# --- Retrieval analytics sidecar (SQLite) -------------------------------
# Retrieval telemetry is machine-local exhaust, not governed content: it
# needs none of Dolt's versioning/branching and would otherwise grow the
# versioned repo's history monotonically. It lives in a WAL-mode SQLite
# sidecar next to the dolt store, append-only, no retention job needed at
# realistic volumes (~90MB/year worst case). Escape hatch: plain SQL.

analytics_db_path() {
    printf '%s/analytics.db' "$VAULT_DIR"
}

analytics_ensure() {
    command -v sqlite3 >/dev/null 2>&1 || {
        error "sqlite3 is required for retrieval analytics"
        return 1
    }
    local db current_version supported_version analytics_schema contract_path
    db=$(analytics_db_path)
    analytics_schema="$SCRIPTS_DIR/../schema/analytics.sql"
    contract_path="$SCRIPTS_DIR/../schema/client-compatibility.json"
    [ -f "$analytics_schema" ] || { error "Missing analytics schema: $analytics_schema"; return 1; }
    [ -f "$contract_path" ] || { error "Missing compatibility contract: $contract_path"; return 1; }
    supported_version=$(jq -r '.analytics_schema_version' "$contract_path")
    current_version=$(sqlite3 "$db" 'PRAGMA user_version;')
    if [ "$current_version" -gt "$supported_version" ]; then
        error "analytics.db schema v$current_version is newer than supported v$supported_version"
        return 1
    fi

    sqlite3 "$db" < "$analytics_schema" >/dev/null
}

analytics_query() {
    analytics_ensure || return 1
    sqlite3 -header -column "$(analytics_db_path)" "$1"
}

# Export functions and variables for sourcing scripts
export -f info success warn error usage_error require_option_value require_allowed_value ensure_vault check_deps sql_escape require_numeric float_gt sanitize_terminal_text terminal_safe_preview base64_no_wrap sql_escape_base64 sql_decode_base64 dolt_json_query json_first_field json_first_field_record json_all_field json_rows_base64 json_decode_base64 dolt_sql_from_string cleanup_temp_paths register_temp_path make_temp_file parse_template_var_tokens template_valid_vars template_unsupported_vars template_position_indexes expand_template_content run_with_signal_forwarding analytics_db_path analytics_ensure analytics_query
export SCRIPTS_DIR VAULT_DIR RED GREEN YELLOW BLUE NC

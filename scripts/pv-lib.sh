#!/usr/bin/env bash
# pv-lib.sh - Shared library for Prompt Vault scripts
set -euo pipefail

# Resolve VAULT_DIR relative to scripts directory
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "${VAULT_DIR:-}" ]; then
    VAULT_DIR="$SCRIPTS_DIR/../prompt-vault-db"
fi

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
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
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

json_all_field() {
    local sql="$1"
    local field="$2"
    dolt_json_query "$sql" | jq -r --arg field "$field" '(.rows // [])[][$field] // empty'
}

# Export functions and variables for sourcing scripts
export -f info success warn error ensure_vault check_deps sql_escape require_numeric float_gt sanitize_terminal_text terminal_safe_preview sql_escape_base64 sql_decode_base64 dolt_json_query json_first_field json_all_field
export SCRIPTS_DIR VAULT_DIR RED GREEN YELLOW BLUE NC

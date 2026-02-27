#!/usr/bin/env bash
# pv-lib.sh - Shared library for Prompt Vault scripts
set -euo pipefail

# Resolve VAULT_DIR relative to scripts directory
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${VAULT_DIR:=$SCRIPTS_DIR/../prompt-vault-db}"

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

# Safely escape content for SQL using heredoc approach
# Handles multi-line content, quotes, and special characters
sql_escape() {
    local content="$1"
    # Replace single quotes with doubled single quotes (SQL standard)
    # Use printf to handle special chars properly
    printf '%s' "$content" | sed "s/'/''/g"
}

# Alternative: Use base64 encoding for complex content
# Decodes in SQL with: FROM_BASE64('<encoded>')
sql_escape_base64() {
    local content="$1"
    printf '%s' "$content" | base64 -w0
}

# Export functions and variables for sourcing scripts
export -f info success warn error ensure_vault check_deps sql_escape sql_escape_base64
export SCRIPTS_DIR VAULT_DIR RED GREEN YELLOW BLUE NC

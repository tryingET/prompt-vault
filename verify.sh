#!/usr/bin/env bash
# verify.sh - Quick verification that prompt-vault works
set -euo pipefail

cd "$(dirname "$0")"
SCRIPTS_DIR="./scripts"
VAULT_DIR="./prompt-vault-db"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass=0
fail=0

check() {
    local name="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        pass=$((pass + 1))
    else
        echo -e "${RED}✗${NC} $name"
        fail=$((fail + 1))
    fi
}

check_output() {
    local name="$1"
    local expected="$2"
    shift 2
    local result
    result=$("$@" 2>&1) || true
    if [[ "$result" == *"$expected"* ]]; then
        echo -e "${GREEN}✓${NC} $name"
        pass=$((pass + 1))
    else
        echo -e "${RED}✗${NC} $name (expected '$expected' in output)"
        fail=$((fail + 1))
    fi
}

echo -e "${BLUE}=== Prompt Vault Verification ===${NC}"
echo ""

# Prerequisites
echo -e "${YELLOW}Prerequisites:${NC}"
check "dolt installed" command -v dolt
check "vault initialized" test -d "$VAULT_DIR/.dolt"
echo ""

# Core commands
echo -e "${YELLOW}Core Commands:${NC}"
check_output "pv --version" "1.0" "$SCRIPTS_DIR/pv" --version
check_output "pv --help" "Usage" "$SCRIPTS_DIR/pv" --help
check "pv templates" "$SCRIPTS_DIR/pv" templates
check "pv skills" "$SCRIPTS_DIR/pv" skills
echo ""

# Search & tags
echo -e "${YELLOW}Search & Tags:${NC}"
check "pv tag list" "$SCRIPTS_DIR/pv" tag list
check "pv search requires arg" bash -c "! $SCRIPTS_DIR/pv search 2>/dev/null"
echo ""

# Quality & lint
echo -e "${YELLOW}Quality & Lint:${NC}"
check "pv quality check" "$SCRIPTS_DIR/pv" quality check
check_output "pv-lint runs" "Linting" "$SCRIPTS_DIR/pv-lint"
check_output "pv-verify-ontology-contract" "Ontology contract verified" "$SCRIPTS_DIR/pv-verify-ontology-contract"
echo ""

# Subcommands exist
echo -e "${YELLOW}Subcommand Scripts:${NC}"
for script in "$SCRIPTS_DIR"/pv-*; do
    [ -x "$script" ] && check "$(basename $script) executable" test -x "$script"
done
echo ""

# Summary
echo -e "${BLUE}=== Results ===${NC}"
echo -e "Passed: ${GREEN}$pass${NC}"
echo -e "Failed: ${RED}$fail${NC}"

if [ $fail -eq 0 ]; then
    echo -e "\n${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some checks failed.${NC}"
    exit 1
fi

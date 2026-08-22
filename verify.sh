#!/usr/bin/env bash
# verify.sh - Quick verification that prompt-vault works
set -euo pipefail

cd "$(dirname "$0")"
export TMPDIR="${TMPDIR:-$PWD/.tmp}"
mkdir -p "$TMPDIR"
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
check "bats installed" command -v bats
check "vault initialized" test -d "$VAULT_DIR/.dolt"
echo ""

# Core commands
echo -e "${YELLOW}Core Commands:${NC}"
check_output "pv --version" "1.0" "$SCRIPTS_DIR/pv" --version
check_output "pv --help" "Usage" "$SCRIPTS_DIR/pv" --help
check "pv templates" "$SCRIPTS_DIR/pv" templates
check "pv skills" "$SCRIPTS_DIR/pv" skills
echo ""

# Search & releases
echo -e "${YELLOW}Search & Releases:${NC}"
check "pv tag list" "$SCRIPTS_DIR/pv" tag list
check "pv search requires arg" bash -c "! $SCRIPTS_DIR/pv search 2>/dev/null"
check "pv-diff summary" "$SCRIPTS_DIR/pv-diff" HEAD HEAD summary
check_output "pv-template-vars usage" "<args...>" "$SCRIPTS_DIR/pv-template-vars" usage e3d-htn
check_output "pv-template-vars validate named" "e3d-htn" "$SCRIPTS_DIR/pv-template-vars" validate e3d-htn
check_output "pv-integrate help" "Usage: pv-integrate" "$SCRIPTS_DIR/pv-integrate" help
check_output "pv-export-formats help" "Usage: pv-export-formats" "$SCRIPTS_DIR/pv-export-formats" help
echo ""

# Quality & lint
echo -e "${YELLOW}Quality & Lint:${NC}"
check_output "pv quality check" "Quality checks passed" "$SCRIPTS_DIR/pv" quality check
check_output "pv analytics outputs" "Output Capture Analytics" "$SCRIPTS_DIR/pv" analytics outputs
check_output "pv-lint targeted smoke" "=== Template: inversion ===" "$SCRIPTS_DIR/pv-lint" inversion
check_output "pv-verify-ontology-contract" "Ontology contract verified" "$SCRIPTS_DIR/pv-verify-ontology-contract"
check_output "pv-verify-evidence-promotion-ledger" "Evidence promotion ledger verified" "$SCRIPTS_DIR/pv-verify-evidence-promotion-ledger"
check "pv templates controlled-vocabulary filter" bash -c "$SCRIPTS_DIR/pv templates cv.routing_context=analysis_followup >/dev/null"
check "pv templates company visibility filter" bash -c "$SCRIPTS_DIR/pv templates visibility_company=software >/dev/null"
if [ "${PV_VERIFY_FULL:-0}" = "1" ]; then
    check "pv-bats full suite" "$SCRIPTS_DIR/pv-bats" tests/
else
    check "pv-bats contract suite" "$SCRIPTS_DIR/pv-bats" tests/pv-contracts.bats
    echo -e "${BLUE}ℹ${NC} Set PV_VERIFY_FULL=1 to run the full bats suite"
fi
echo ""

# Subcommands exist
echo -e "${YELLOW}Subcommand Scripts:${NC}"
for script in "$SCRIPTS_DIR"/pv-*; do
    [ -x "$script" ] && check "$(basename "$script") executable" test -x "$script"
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

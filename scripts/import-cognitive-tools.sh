#!/usr/bin/env bash
# Import cognitive tools from ~/steve/prompts/ into vault
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pv-lib.sh"

VAULT_DIR="${VAULT_DIR:-$SCRIPT_DIR/../prompt-vault-db}"
PROMPTS_DIR="${PROMPTS_DIR:-$HOME/steve/prompts}"

# Limits
MAX_CONTENT_SIZE=1048576  # 1MB max template size
MAX_DESC_SIZE=1024        # 1KB max description

cd "$VAULT_DIR"

# Validate template content
# Returns 0 if valid, 1 if issues found
validate_template() {
    local content="$1"
    local name="$2"
    local issues=()
    
    # Check size
    local size=${#content}
    if [ "$size" -gt "$MAX_CONTENT_SIZE" ]; then
        issues+=("Content too large: $size bytes (max $MAX_CONTENT_SIZE)")
    fi
    
    # Check for valid variable syntax (optional warning, not error)
    # Variables should be $1, $2, $@, ${@:N}, ${N}
    # Invalid: $, $$, $!, $@ with spaces, unclosed ${
    local invalid_vars
    invalid_vars=$(echo "$content" | grep -oE '\$[^0-9@{a-zA-Z_]' || true)
    if [ -n "$invalid_vars" ]; then
        # This is a warning, not an error - some $ symbols are intentional
        : # Silently allow for now
    fi
    
    # Check for unclosed braces
    local open_braces=$(echo "$content" | grep -o '\${' | wc -l)
    local close_braces=$(echo "$content" | grep -o '}' | wc -l)
    # Note: this is approximate - doesn't handle nested braces
    
    if [ ${#issues[@]} -gt 0 ]; then
        for issue in "${issues[@]}"; do
            warn "  $issue"
        done
        return 1
    fi
    return 0
}

import_trigger() {
    local file="$1"
    local legacy_type="${2:-cognitive}"
    local name=$(basename "$file" .md | tr '[:upper:]' '[:lower:]')
    
    # Skip INDEX and validate
    [[ "$name" == "index" ]] && return 0
    [[ ! -f "$file" ]] && { warn "File not found: $file"; return 1; }
    
    # Read content
    local content
    content=$(cat "$file")
    
    # Validate
    if ! validate_template "$content" "$name"; then
        error "Validation failed for: $name"
        return 1
    fi
    
    # Escape for SQL (using improved function from pv-lib.sh)
    local escaped_content
    escaped_content=$(sql_escape "$content")
    
    # Extract first line as description (up to MAX_DESC_SIZE chars)
    local desc
    desc=$(head -1 "$file" | sed 's/^#* *//' | cut -c1-$MAX_DESC_SIZE)
    local escaped_desc
    escaped_desc=$(sql_escape "$desc")
    
    local artifact_kind="procedure"
    local control_mode="one_shot"
    local formalization_level="structured"

    case "$legacy_type" in
        cognitive)
            artifact_kind="cognitive"
            formalization_level="napkin"
            ;;
        session)
            artifact_kind="session"
            formalization_level="structured"
            ;;
        loop)
            artifact_kind="procedure"
            control_mode="loop"
            formalization_level="workflow"
            ;;
        *)
            artifact_kind="procedure"
            control_mode="one_shot"
            formalization_level="structured"
            ;;
    esac

    info "Importing: $name ($artifact_kind/$control_mode/$formalization_level)"

    dolt sql -q "
        INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
        VALUES ('$name', '$escaped_desc', '$escaped_content', '$artifact_kind', '$control_mode', '$formalization_level', 'core', '["core","software","finance","house","health","teaching","holding"]', 'active')
        ON DUPLICATE KEY UPDATE 
            description = VALUES(description),
            content = VALUES(content),
            artifact_kind = VALUES(artifact_kind),
            control_mode = VALUES(control_mode),
            formalization_level = VALUES(formalization_level),
            owner_company = VALUES(owner_company),
            visibility_companies = VALUES(visibility_companies),
            status = VALUES(status),
            updated_at = CURRENT_TIMESTAMP
    " 2>/dev/null || { warn "  (skipped or error)"; return 1; }
    
    success "  Imported: $name"
}

# Stats
imported=0
failed=0

echo "=== Importing triggers ==="
for f in "$PROMPTS_DIR"/triggers/*.md; do
    if import_trigger "$f" "cognitive"; then
        imported=$((imported + 1))
    else
        failed=$((failed + 1))
    fi
done

echo ""
echo "=== Importing standalone prompts ==="
for f in \
    "$PROMPTS_DIR/transcendent-iteration.md: cognitive" \
    "$PROMPTS_DIR/unsung-foundations.md: task" \
    "$PROMPTS_DIR/fcos-model-first-convergence.md: task"
do
    file="${f%:*}"
    type="${f#*: }"
    type="${type:-cognitive}"
    if import_trigger "$file" "$type"; then
        imported=$((imported + 1))
    else
        failed=$((failed + 1))
    fi
done

echo ""
echo "=== Committing ==="
dolt add -A
dolt commit -m "Import cognitive tools: $imported imported, $failed failed" 2>/dev/null || info "No changes to commit"

echo ""
echo "=== Summary ==="
echo "Imported: $imported"
echo "Failed:   $failed"
echo ""
dolt sql -q "SELECT artifact_kind, control_mode, formalization_level, COUNT(*) as count FROM prompt_templates GROUP BY artifact_kind, control_mode, formalization_level ORDER BY artifact_kind, control_mode, formalization_level" -r tabular

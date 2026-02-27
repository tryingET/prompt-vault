#!/usr/bin/env bash
# Import cognitive tools from ~/steve/prompts/ into vault
set -euo pipefail

VAULT_DIR="${VAULT_DIR:-$(dirname "$0")/../prompt-vault-db}"
PROMPTS_DIR="${PROMPTS_DIR:-$HOME/steve/prompts}"

cd "$VAULT_DIR"

import_trigger() {
    local file="$1"
    local type="${2:-cognitive}"
    local name=$(basename "$file" .md | tr '[:upper:]' '[:lower:]')
    
    # Skip INDEX
    [[ "$name" == "index" ]] && return 0
    
    local content
    content=$(cat "$file" | sed "s/'/''/g")
    
    # Extract first line as description (up to 1024 chars)
    local desc
    desc=$(head -1 "$file" | sed 's/^#* *//' | cut -c1-1024 | sed "s/'/''/g")
    
    echo "Importing: $name ($type)"
    
    dolt sql -q "
        INSERT INTO prompt_templates (name, description, content, type, status, tags)
        VALUES ('$name', '$desc', '$content', '$type', 'active', '[\"cognitive\", \"trigger\"]')
        ON DUPLICATE KEY UPDATE 
            description = VALUES(description),
            content = VALUES(content),
            type = VALUES(type),
            status = VALUES(status),
            updated_at = CURRENT_TIMESTAMP
    " 2>/dev/null || echo "  (skipped or error)"
}

echo "=== Importing triggers ==="
for f in "$PROMPTS_DIR"/triggers/*.md; do
    import_trigger "$f" "cognitive"
done

echo ""
echo "=== Importing standalone prompts ==="
import_trigger "$PROMPTS_DIR/transcendent-iteration.md" "cognitive"
import_trigger "$PROMPTS_DIR/unsung-foundations.md" "task"
import_trigger "$PROMPTS_DIR/fcos-model-first-convergence.md" "task"

echo ""
echo "=== Committing ==="
dolt add -A
dolt commit -m "Import cognitive tools from ~/steve/prompts" 2>/dev/null || echo "No changes to commit"

echo ""
echo "=== Summary ==="
dolt sql -q "SELECT type, COUNT(*) as count FROM prompt_templates GROUP BY type" -r tabular

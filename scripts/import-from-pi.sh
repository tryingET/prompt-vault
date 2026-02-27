#!/usr/bin/env bash
# import-from-pi.sh - Import pi prompt templates and skills into the vault
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared library
source "$SCRIPT_DIR/pv-lib.sh"

if [ ! -d "$VAULT_DIR/.dolt" ]; then
    error "Vault not initialized. Run init-vault.sh first."
    exit 1
fi

cd "$VAULT_DIR"

echo "=== Importing from pi ==="

# Safely escape content for SQL using heredoc to avoid shell interpretation
# This handles backslashes, quotes, and multi-line content correctly
sql_escape_content() {
    local content="$1"
    # Use awk for robust single-quote escaping (SQL standard: '' for ')
    printf '%s' "$content" | awk '{gsub(/'"'"'/, "'"'"'"'"'"'"'"'"); print}' ORS=''
}

# Execute SQL using temp file to avoid shell interpretation issues
exec_sql() {
    local sql="$1"
    local tmp=$(mktemp --suffix=.sql)
    printf '%s' "$sql" > "$tmp"
    dolt sql < "$tmp" 2>/dev/null || true
    rm -f "$tmp"
}

# Import prompt templates
import_templates() {
    local template_count=0
    local dirs=(
        "$HOME/.pi/agent/prompts"
        "$(pwd)/../.pi/prompts"
    )
    
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "Scanning templates in: $dir"
            for file in "$dir"/*.md; do
                [ -f "$file" ] || continue
                local name=$(basename "$file" .md)
                local content=$(cat "$file")
                
                # Parse frontmatter
                local description=""
                if head -1 "$file" | grep -q "^---"; then
                    description=$(sed -n '/^description:/,/^$/p' "$file" | sed 's/^description: *//' | head -1)
                fi
                
                # Default description from first non-empty line
                if [ -z "$description" ]; then
                    description=$(grep -v '^$' "$file" | grep -v '^---' | head -1 | cut -c1-200)
                fi
                
                # Escape for SQL using safer method
                local escaped_content=$(sql_escape_content "$content")
                local escaped_desc=$(sql_escape_content "$description")
                
                exec_sql "
                    INSERT INTO prompt_templates (name, description, content, status)
                    VALUES ('$name', '$escaped_desc', '$escaped_content', 'active')
                    ON DUPLICATE KEY UPDATE 
                        content = VALUES(content),
                        description = VALUES(description),
                        updated_at = CURRENT_TIMESTAMP
                " || warn "Could not import $name"
                
                ((template_count++)) || true
                success "Imported template: $name"
            done
        fi
    done
    
    echo "Templates imported: $template_count"
}

# Import skills
import_skills() {
    local skill_count=0
    local dirs=(
        "$HOME/.pi/agent/skills"
        "$(pwd)/../.pi/skills"
    )
    
    for base_dir in "${dirs[@]}"; do
        if [ -d "$base_dir" ]; then
            echo "Scanning skills in: $base_dir"
            
            # Find SKILL.md files
            while IFS= read -r -d '' skill_file; do
                local skill_dir=$(dirname "$skill_file")
                local skill_name=$(basename "$skill_dir")
                
                # Skip if name doesn't match directory
                if [ ! -f "$skill_file" ]; then
                    continue
                fi
                
                local content=$(cat "$skill_file")
                
                # Parse frontmatter
                local description=""
                local license=""
                local compatibility=""
                
                if head -1 "$skill_file" | grep -q "^---"; then
                    description=$(sed -n '/^description:/,/^license:\|^compatibility:\|^---$/p' "$skill_file" | sed 's/^description: *//' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
                    license=$(sed -n 's/^license: *//p' "$skill_file" | head -1)
                    compatibility=$(sed -n 's/^compatibility: *//p' "$skill_file" | head -1)
                fi
                
                # Escape for SQL using safer method
                local escaped_content=$(sql_escape_content "$content")
                local escaped_desc=$(sql_escape_content "$description" | cut -c1-1024)
                local escaped_license=$(sql_escape_content "$license")
                local escaped_compat=$(sql_escape_content "$compatibility")
                
                # Insert skill
                exec_sql "
                    INSERT INTO skills (name, description, readme, license, compatibility, status)
                    VALUES ('$skill_name', '$escaped_desc', '$escaped_content', '$escaped_license', '$escaped_compat', 'active')
                    ON DUPLICATE KEY UPDATE
                        readme = VALUES(readme),
                        description = VALUES(description),
                        updated_at = CURRENT_TIMESTAMP
                " || { warn "Could not import skill $skill_name"; continue; }
                
                # Get skill ID for assets
                local skill_id=$(dolt sql -r csv -q "SELECT id FROM skills WHERE name = '$skill_name' ORDER BY id DESC LIMIT 1" | tail -1)
                
                # Import assets (scripts, references, etc.)
                find "$skill_dir" -type f ! -name "SKILL.md" | while read -r asset_file; do
                    local rel_path=${asset_file#$skill_dir/}
                    local escaped_path=$(sql_escape_content "$rel_path")
                    
                    # Check if binary
                    if file "$asset_file" | grep -q "text"; then
                        local asset_content=$(cat "$asset_file")
                        local escaped_asset=$(sql_escape_content "$asset_content")
                        exec_sql "
                            INSERT INTO skill_assets (skill_id, path, content, is_binary)
                            VALUES ($skill_id, '$escaped_path', '$escaped_asset', FALSE)
                            ON DUPLICATE KEY UPDATE content = VALUES(content), updated_at = CURRENT_TIMESTAMP
                        "
                    else
                        # Store binary files as base64 in binary_content column
                        local b64_content=$(base64 -w0 "$asset_file")
                        exec_sql "
                            INSERT INTO skill_assets (skill_id, path, binary_content, is_binary)
                            VALUES ($skill_id, '$escaped_path', FROM_BASE64('$b64_content'), TRUE)
                            ON DUPLICATE KEY UPDATE binary_content = VALUES(binary_content), updated_at = CURRENT_TIMESTAMP
                        "
                    fi
                done
                
                ((skill_count++)) || true
                success "Imported skill: $skill_name"
            done < <(find "$base_dir" -name "SKILL.md" -print0 2>/dev/null)
        fi
    done
    
    echo "Skills imported: $skill_count"
}

# Run imports
import_templates
echo ""
import_skills

# Commit changes
dolt add .
dolt commit -m "Import from pi templates and skills" 2>/dev/null || echo "No changes to commit"

echo ""
success "Import complete"
echo "View imported items:"
echo "  dolt sql -q 'SELECT name, status FROM prompt_templates'"
echo "  dolt sql -q 'SELECT name, status FROM skills'"

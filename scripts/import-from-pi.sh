#!/usr/bin/env bash
# import-from-pi.sh - Import pi prompt templates and skills into the vault
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared library
source "$SCRIPT_DIR/pv-lib.sh"

ensure_vault

echo "=== Importing from pi ==="

exec_sql() {
    local sql="$1"
    dolt_sql_from_string "$sql"
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
                
                local escaped_name escaped_content escaped_desc
                escaped_name=$(sql_escape "$name")
                escaped_content=$(sql_escape "$content")
                escaped_desc=$(sql_escape "$description")

                if ! exec_sql "
                    INSERT INTO prompt_templates (name, description, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, status)
                    VALUES ('$escaped_name', '$escaped_desc', '$escaped_content', 'procedure', 'one_shot', 'structured', 'core', '[\"core\",\"software\",\"finance\",\"house\",\"health\",\"teaching\",\"holding\"]', 'active')
                    ON DUPLICATE KEY UPDATE 
                        content = VALUES(content),
                        description = VALUES(description),
                        artifact_kind = VALUES(artifact_kind),
                        control_mode = VALUES(control_mode),
                        formalization_level = VALUES(formalization_level),
                        owner_company = VALUES(owner_company),
                        visibility_companies = VALUES(visibility_companies),
                        updated_at = CURRENT_TIMESTAMP
                "; then
                    warn "Could not import template: $name"
                    continue
                fi

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
                
                local escaped_skill_name escaped_content escaped_desc escaped_license escaped_compat
                escaped_skill_name=$(sql_escape "$skill_name")
                escaped_content=$(sql_escape "$content")
                escaped_desc=$(printf '%s' "$description" | cut -c1-1024 | sql_escape)
                escaped_license=$(sql_escape "$license")
                escaped_compat=$(sql_escape "$compatibility")

                if ! exec_sql "
                    INSERT INTO skills (name, description, readme, license, compatibility, owner_company, visibility_companies, status)
                    VALUES ('$escaped_skill_name', '$escaped_desc', '$escaped_content', '$escaped_license', '$escaped_compat', 'core', '[\"core\",\"software\",\"finance\",\"house\",\"health\",\"teaching\",\"holding\"]', 'active')
                    ON DUPLICATE KEY UPDATE
                        readme = VALUES(readme),
                        description = VALUES(description),
                        owner_company = VALUES(owner_company),
                        visibility_companies = VALUES(visibility_companies),
                        updated_at = CURRENT_TIMESTAMP
                "; then
                    warn "Could not import skill: $skill_name"
                    continue
                fi

                local skill_id
                skill_id=$(json_first_field "SELECT id FROM skills WHERE name = '$escaped_skill_name' ORDER BY id DESC LIMIT 1" id)
                if [ -z "$skill_id" ]; then
                    warn "Imported skill row not found after insert: $skill_name"
                    continue
                fi

                local asset_failures=0
                while IFS= read -r asset_file; do
                    [ -f "$asset_file" ] || continue

                    local rel_path escaped_path
                    rel_path=${asset_file#$skill_dir/}
                    escaped_path=$(sql_escape "$rel_path")

                    if file "$asset_file" | grep -q "text"; then
                        local asset_content escaped_asset
                        asset_content=$(cat "$asset_file")
                        escaped_asset=$(sql_escape "$asset_content")
                        if ! exec_sql "
                            INSERT INTO skill_assets (skill_id, path, content, is_binary)
                            VALUES ($skill_id, '$escaped_path', '$escaped_asset', FALSE)
                            ON DUPLICATE KEY UPDATE content = VALUES(content), updated_at = CURRENT_TIMESTAMP
                        "; then
                            warn "Could not import asset '$rel_path' for skill '$skill_name'"
                            asset_failures=$((asset_failures + 1))
                        fi
                    else
                        local b64_content
                        b64_content=$(base64_no_wrap "$asset_file")
                        if ! exec_sql "
                            INSERT INTO skill_assets (skill_id, path, binary_content, is_binary)
                            VALUES ($skill_id, '$escaped_path', FROM_BASE64('$b64_content'), TRUE)
                            ON DUPLICATE KEY UPDATE binary_content = VALUES(binary_content), updated_at = CURRENT_TIMESTAMP
                        "; then
                            warn "Could not import binary asset '$rel_path' for skill '$skill_name'"
                            asset_failures=$((asset_failures + 1))
                        fi
                    fi
                done < <(find "$skill_dir" -type f ! -name "SKILL.md")

                ((skill_count++)) || true
                if [ "$asset_failures" -eq 0 ]; then
                    success "Imported skill: $skill_name"
                else
                    warn "Imported skill '$skill_name' with $asset_failures asset failure(s)"
                fi
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

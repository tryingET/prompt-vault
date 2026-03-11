#!/usr/bin/env bash
# export-to-pi.sh - Export vault to pi-compatible file format
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${VAULT_DIR:-$SCRIPT_DIR/../prompt-vault-db}"
source "$SCRIPT_DIR/pv-lib.sh"

TEMPLATES_DIR="${TEMPLATES_DIR:-$HOME/.pi/agent/prompts}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.pi/agent/skills}"
TEMPLATE_MANIFEST="$TEMPLATES_DIR/.prompt-vault-managed-files"
SKILL_MANIFEST="$SKILLS_DIR/.prompt-vault-managed-files"

if [ ! -d "$VAULT_DIR/.dolt" ]; then
    echo "Error: Vault not initialized. Run init-vault.sh first."
    exit 1
fi

cd "$VAULT_DIR"
check_deps jq

echo "=== Exporting to pi format ==="

# Create directories
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$SKILLS_DIR"

clean_managed_outputs() {
    local manifest="$1"
    local root_dir="$2"

    [ -f "$manifest" ] || return 0

    while IFS= read -r rel_path; do
        [ -z "$rel_path" ] && continue
        rm -rf "$root_dir/$rel_path"
    done < "$manifest"

    rm -f "$manifest"
}

# Export templates
export_templates() {
    local count=0
    local template_names
    template_names=$(json_all_field "SELECT name FROM prompt_templates WHERE status = 'active' AND export_to_pi = true ORDER BY name" name)

    clean_managed_outputs "$TEMPLATE_MANIFEST" "$TEMPLATES_DIR"
    : > "$TEMPLATE_MANIFEST"

    while IFS= read -r name; do
        [ -z "$name" ] && continue

        local escaped_name
        escaped_name=$(sql_escape "$name")
        local content
        content=$(json_first_field "SELECT content FROM prompt_templates WHERE name = '$escaped_name' AND status = 'active' ORDER BY version DESC LIMIT 1" content)
        
        # Write file
        local output_file="$TEMPLATES_DIR/${name}.md"
        printf '%s\n' "$content" > "$output_file"
        echo "${name}.md" >> "$TEMPLATE_MANIFEST"

        ((count++)) || true
        echo "  ✓ Exported template: $name"
    done <<< "$template_names"
    
    echo "Templates exported: $count → $TEMPLATES_DIR"
}

# Export skills
export_skills() {
    local count=0
    local skill_names
    skill_names=$(json_all_field "SELECT name FROM skills WHERE status = 'active' ORDER BY name" name)

    clean_managed_outputs "$SKILL_MANIFEST" "$SKILLS_DIR"
    : > "$SKILL_MANIFEST"

    while IFS= read -r name; do
        [ -z "$name" ] && continue

        local escaped_name
        escaped_name=$(sql_escape "$name")
        local readme
        readme=$(json_first_field "SELECT readme FROM skills WHERE name = '$escaped_name' AND status = 'active' ORDER BY version DESC LIMIT 1" readme)
        
        # Create skill directory
        local skill_dir="$SKILLS_DIR/$name"
        mkdir -p "$skill_dir"
        echo "$name" >> "$SKILL_MANIFEST"
        
        # Write SKILL.md
        printf '%s\n' "$readme" > "$skill_dir/SKILL.md"
        
        # Export assets
        local skill_id
        skill_id=$(json_first_field "SELECT id FROM skills WHERE name = '$escaped_name' ORDER BY version DESC LIMIT 1" id)
        
        if [ -n "$skill_id" ]; then
            local asset_paths
            asset_paths=$(json_all_field "SELECT path FROM skill_assets WHERE skill_id = $skill_id ORDER BY path" path)
            while IFS= read -r asset_path; do
                [ -z "$asset_path" ] && continue

                local escaped_path
                escaped_path=$(sql_escape "$asset_path")
                local is_binary
                is_binary=$(json_first_field "SELECT is_binary FROM skill_assets WHERE skill_id = $skill_id AND path = '$escaped_path'" is_binary)
                
                if [ "$is_binary" = "0" ] || [ "$is_binary" = "false" ] || [ "$is_binary" = "FALSE" ]; then
                    local asset_content
                    asset_content=$(json_first_field "SELECT content FROM skill_assets WHERE skill_id = $skill_id AND path = '$escaped_path'" content)
                    
                    # Create directory structure
                    mkdir -p "$skill_dir/$(dirname "$asset_path")"
                    printf '%s\n' "$asset_content" > "$skill_dir/$asset_path"
                fi
            done <<< "$asset_paths"
        fi
        
        ((count++)) || true
        echo "  ✓ Exported skill: $name"
    done <<< "$skill_names"
    
    echo "Skills exported: $count → $SKILLS_DIR"
}

export_templates
echo ""
export_skills

echo ""
echo "=== Export complete ==="
echo "Templates: $TEMPLATES_DIR"
echo "Skills: $SKILLS_DIR"

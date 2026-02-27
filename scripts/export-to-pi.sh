#!/usr/bin/env bash
# export-to-pi.sh - Export vault to pi-compatible file format
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_DIR="${VAULT_DIR:-$SCRIPT_DIR/../prompt-vault-db}"

TEMPLATES_DIR="${TEMPLATES_DIR:-$HOME/.pi/agent/prompts}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.pi/agent/skills}"

if [ ! -d "$VAULT_DIR/.dolt" ]; then
    echo "Error: Vault not initialized. Run init-vault.sh first."
    exit 1
fi

cd "$VAULT_DIR"

echo "=== Exporting to pi format ==="

# Create directories
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$SKILLS_DIR"

# Export templates
export_templates() {
    local count=0
    local template_names=$(dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active'" | tail -n +2)
    
    for name in $template_names; do
        [ -z "$name" ] && continue
        
        local content=$(dolt sql -r csv -q "SELECT content FROM prompt_templates WHERE name = '$name' AND status = 'active' ORDER BY version DESC LIMIT 1" | tail -1)
        local description=$(dolt sql -r csv -q "SELECT description FROM prompt_templates WHERE name = '$name' AND status = 'active' ORDER BY version DESC LIMIT 1" | tail -1)
        
        # Unescape (basic)
        content=$(echo "$content" | sed "s/''/'/g")
        description=$(echo "$description" | sed "s/''/'/g")
        
        # Write file
        local output_file="$TEMPLATES_DIR/${name}.md"
        echo "$content" > "$output_file"
        
        ((count++)) || true
        echo "  ✓ Exported template: $name"
    done
    
    echo "Templates exported: $count → $TEMPLATES_DIR"
}

# Export skills
export_skills() {
    local count=0
    local skill_names=$(dolt sql -r csv -q "SELECT name FROM skills WHERE status = 'active'" | tail -n +2)
    
    for name in $skill_names; do
        [ -z "$name" ] && continue
        
        local readme=$(dolt sql -r csv -q "SELECT readme FROM skills WHERE name = '$name' AND status = 'active' ORDER BY version DESC LIMIT 1" | tail -1)
        
        # Unescape
        readme=$(echo "$readme" | sed "s/''/'/g")
        
        # Create skill directory
        local skill_dir="$SKILLS_DIR/$name"
        mkdir -p "$skill_dir"
        
        # Write SKILL.md
        echo "$readme" > "$skill_dir/SKILL.md"
        
        # Export assets
        local skill_id=$(dolt sql -r csv -q "SELECT id FROM skills WHERE name = '$name' ORDER BY version DESC LIMIT 1" | tail -1)
        
        if [ -n "$skill_id" ]; then
            dolt sql -r csv -q "SELECT path FROM skill_assets WHERE skill_id = $skill_id" | tail -n +2 | while read -r asset_path; do
                [ -z "$asset_path" ] && continue
                
                local is_binary=$(dolt sql -r csv -q "SELECT is_binary FROM skill_assets WHERE skill_id = $skill_id AND path = '$asset_path'" | tail -1)
                
                if [ "$is_binary" = "0" ] || [ "$is_binary" = "FALSE" ]; then
                    local asset_content=$(dolt sql -r csv -q "SELECT content FROM skill_assets WHERE skill_id = $skill_id AND path = '$asset_path'" | tail -1)
                    asset_content=$(echo "$asset_content" | sed "s/''/'/g")
                    
                    # Create directory structure
                    mkdir -p "$skill_dir/$(dirname "$asset_path")"
                    echo "$asset_content" > "$skill_dir/$asset_path"
                fi
            done
        fi
        
        ((count++)) || true
        echo "  ✓ Exported skill: $name"
    done
    
    echo "Skills exported: $count → $SKILLS_DIR"
}

export_templates
echo ""
export_skills

echo ""
echo "=== Export complete ==="
echo "Templates: $TEMPLATES_DIR"
echo "Skills: $SKILLS_DIR"

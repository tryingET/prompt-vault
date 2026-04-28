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
TEMPLATE_EXPORT_STATE="$TEMPLATES_DIR/.prompt-vault-export-state.json"

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
    local template_names receipt_jsonl generated_at
    template_names=$(json_all_field "SELECT name FROM prompt_templates WHERE status = 'active' AND export_to_pi = true ORDER BY name" name)
    receipt_jsonl=$(mktemp "${TMPDIR:-/tmp}/prompt-vault-template-export.XXXXXX.jsonl")

    clean_managed_outputs "$TEMPLATE_MANIFEST" "$TEMPLATES_DIR"
    : > "$TEMPLATE_MANIFEST"

    while IFS= read -r name; do
        [ -z "$name" ] && continue

        local escaped_name
        escaped_name=$(sql_escape "$name")
        local content version
        content=$(json_first_field "SELECT content FROM prompt_templates WHERE name = '$escaped_name' AND status = 'active' ORDER BY version DESC LIMIT 1" content)
        version=$(json_first_field "SELECT version FROM prompt_templates WHERE name = '$escaped_name' AND status = 'active' ORDER BY version DESC LIMIT 1" version)
        
        # Write file
        local output_file="$TEMPLATES_DIR/${name}.md"
        printf '%s\n' "$content" > "$output_file"
        echo "${name}.md" >> "$TEMPLATE_MANIFEST"

        local sha256
        sha256=$(sha256sum "$output_file" | awk '{print $1}')
        jq -n \
            --arg name "$name" \
            --arg path "${name}.md" \
            --arg version "$version" \
            --arg sha256 "$sha256" \
            '{name: $name, path: $path, version: ($version | tonumber), sha256: $sha256}' >> "$receipt_jsonl"

        ((count++)) || true
        echo "  ✓ Exported template: $name"
    done <<< "$template_names"

    generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    jq -s \
        --arg schema "prompt-vault/pi-export-receipt/v1" \
        --arg exported_at "$generated_at" \
        --arg vault_dir "$VAULT_DIR" \
        --arg templates_dir "$TEMPLATES_DIR" \
        --arg skills_dir "$SKILLS_DIR" \
        '{schema: $schema, exported_at: $exported_at, source: {vault_dir: $vault_dir}, targets: {templates_dir: $templates_dir, skills_dir: $skills_dir}, template_count: length, templates: .}' \
        "$receipt_jsonl" > "$TEMPLATE_EXPORT_STATE"
    rm -f "$receipt_jsonl"
    echo "$(basename "$TEMPLATE_EXPORT_STATE")" >> "$TEMPLATE_MANIFEST"
    
    echo "Templates exported: $count → $TEMPLATES_DIR"
    echo "Template export receipt: $TEMPLATE_EXPORT_STATE"
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

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
check_deps jq python3 sha256sum

echo "=== Exporting to pi format ==="
mkdir -p "$TEMPLATES_DIR" "$SKILLS_DIR"

clean_managed_outputs() {
    local manifest="$1"
    local root_dir="$2"
    [ -f "$manifest" ] || return 0
    while IFS= read -r rel_path; do
        [ -z "$rel_path" ] && continue
        if [[ "$rel_path" == */* || "$rel_path" == *".."* || ! "$rel_path" =~ ^[A-Za-z0-9._-]+$ ]]; then
            echo "Error: unsafe managed projection path in $manifest: $rel_path" >&2
            exit 1
        fi
        rm -rf -- "$root_dir/$rel_path"
    done < "$manifest"
    rm -f -- "$manifest"
}

export_templates() {
    local db_json policy_json generated_at count quarantine_count
    db_json=$(mktemp "${TMPDIR:-/tmp}/prompt-vault-template-db.XXXXXX.json")
    policy_json=$(mktemp "${TMPDIR:-/tmp}/prompt-vault-template-policy.XXXXXX.json")
    trap 'rm -f "${db_json:-}" "${policy_json:-}"' RETURN

    dolt sql -r json -q "SELECT name, version, content, artifact_kind, control_mode, formalization_level, owner_company, visibility_companies, controlled_vocabulary FROM prompt_templates WHERE status = 'active' AND export_to_pi = true ORDER BY name" > "$db_json"
    "$SCRIPT_DIR/pv-export-policy.py" --controlled-vocabulary-contract "$SCRIPT_DIR/../ontology/controlled-vocabulary-contract.json" < "$db_json" > "$policy_json"

    clean_managed_outputs "$TEMPLATE_MANIFEST" "$TEMPLATES_DIR"
    : > "$TEMPLATE_MANIFEST"

    while IFS= read -r encoded; do
        [ -z "$encoded" ] && continue
        local item name content output_file sha256 expected_sha
        item=$(printf '%s' "$encoded" | base64 --decode)
        name=$(jq -r '.name' <<< "$item")
        content=$(jq -r '.content' <<< "$item")
        expected_sha=$(jq -r '.projected_sha256' <<< "$item")
        output_file="$TEMPLATES_DIR/${name}.md"
        printf '%s\n' "$content" > "$output_file"
        sha256=$(sha256sum "$output_file" | awk '{print $1}')
        if [ "$sha256" != "$expected_sha" ]; then
            echo "Error: projected hash mismatch while writing $name" >&2
            exit 1
        fi
        echo "${name}.md" >> "$TEMPLATE_MANIFEST"
        echo "  ✓ Exported template: $name"
    done < <(jq -r '.exported[] | @base64' "$policy_json")

    while IFS= read -r name; do
        [ -z "$name" ] && continue
        if [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
            if [ -e "$TEMPLATES_DIR/${name}.md" ]; then
                echo "Error: quarantined template has an unmanaged raw projection: $TEMPLATES_DIR/${name}.md" >&2
                exit 1
            fi
        fi
        echo "  ⊘ Quarantined template: $name"
    done < <(jq -r '.quarantined[] | select(.name != "") | .name' "$policy_json")

    generated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local state_tmp="$TEMPLATE_EXPORT_STATE.tmp.$$"
    jq \
        --arg schema "prompt-vault/pi-export-receipt/v2" \
        --arg exported_at "$generated_at" \
        --arg vault_dir "$VAULT_DIR" \
        --arg templates_dir "$TEMPLATES_DIR" \
        --arg skills_dir "$SKILLS_DIR" \
        '{schema: $schema, exported_at: $exported_at, policy: .policy, source: {vault_dir: $vault_dir}, targets: {templates_dir: $templates_dir, skills_dir: $skills_dir}, candidate_count, exported_count, quarantined_count, templates: [.exported[] | del(.content, .disposition) | .sha256 = .projected_sha256 | del(.projected_sha256, .content_sha256, .facets)], quarantined: [.quarantined[] | del(.disposition)]}' \
        "$policy_json" > "$state_tmp"
    mv -f -- "$state_tmp" "$TEMPLATE_EXPORT_STATE"
    echo "$(basename "$TEMPLATE_EXPORT_STATE")" >> "$TEMPLATE_MANIFEST"

    count=$(jq -r '.exported_count' "$policy_json")
    quarantine_count=$(jq -r '.quarantined_count' "$policy_json")
    echo "Templates exported: $count → $TEMPLATES_DIR"
    echo "Templates quarantined: $quarantine_count"
    echo "Template export receipt: $TEMPLATE_EXPORT_STATE"
}

export_skills() {
    local count=0
    local skill_names
    skill_names=$(json_all_field "SELECT name FROM skills WHERE status = 'active' ORDER BY name" name)
    clean_managed_outputs "$SKILL_MANIFEST" "$SKILLS_DIR"
    : > "$SKILL_MANIFEST"
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]]; then
            echo "Error: unsafe skill projection name: $name" >&2
            exit 1
        fi
        local escaped_name readme skill_dir skill_id
        escaped_name=$(sql_escape "$name")
        readme=$(json_first_field "SELECT readme FROM skills WHERE name = '$escaped_name' AND status = 'active' ORDER BY version DESC LIMIT 1" readme)
        skill_dir="$SKILLS_DIR/$name"
        mkdir -p "$skill_dir"
        echo "$name" >> "$SKILL_MANIFEST"
        printf '%s\n' "$readme" > "$skill_dir/SKILL.md"
        skill_id=$(json_first_field "SELECT id FROM skills WHERE name = '$escaped_name' ORDER BY version DESC LIMIT 1" id)
        if [ -n "$skill_id" ]; then
            local asset_paths
            asset_paths=$(json_all_field "SELECT path FROM skill_assets WHERE skill_id = $skill_id ORDER BY path" path)
            while IFS= read -r asset_path; do
                [ -z "$asset_path" ] && continue
                local escaped_path is_binary
                escaped_path=$(sql_escape "$asset_path")
                is_binary=$(json_first_field "SELECT is_binary FROM skill_assets WHERE skill_id = $skill_id AND path = '$escaped_path'" is_binary)
                if [ "$is_binary" = "0" ] || [ "$is_binary" = "false" ] || [ "$is_binary" = "FALSE" ]; then
                    local asset_content
                    asset_content=$(json_first_field "SELECT content FROM skill_assets WHERE skill_id = $skill_id AND path = '$escaped_path'" content)
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

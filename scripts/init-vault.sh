#!/usr/bin/env bash
# init-vault.sh - Initialize a new Prompt Vault database
set -euo pipefail

VAULT_DIR="${VAULT_DIR:-./prompt-vault-db}"
VAULT_NAME="${VAULT_NAME:-prompt-vault}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Initializing Prompt Vault ==="

# Check if already initialized
if [ -d "$VAULT_DIR/.dolt" ]; then
    echo "Vault already exists at $VAULT_DIR"
    echo "To reinitialize, remove the directory first: rm -rf $VAULT_DIR"
    exit 1
fi

# Create vault directory
mkdir -p "$VAULT_DIR"
cd "$VAULT_DIR"

# Ensure dolt has user config
if ! dolt config --global --list 2>/dev/null | grep -q "user.email"; then
    echo "Configuring Dolt user identity..."
    dolt config --global --add user.email "vault@localhost"
    dolt config --global --add user.name "Prompt Vault"
fi

# Initialize Dolt
dolt init
echo "✓ Created Dolt repository: $VAULT_NAME"

# Apply schema
dolt sql < "$SCRIPT_DIR/../schema/schema.sql"
echo "✓ Applied schema"

# Create initial commit
dolt add .
dolt commit -m "Initial schema: templates, skills, executions, feedback"
echo "✓ Created initial commit"

# Create initial branches
dolt branch staging
dolt branch experiments
echo "✓ Created branches: staging, experiments"

# Create config
cat > vault.yaml << 'EOF'
# Prompt Vault Configuration
vault:
  name: prompt-vault
  version: 1.0.0

export:
  templates_dir: ~/.pi/agent/prompts
  skills_dir: ~/.pi/agent/skills
  
sync:
  auto_export: false
  watch: false

metrics:
  track_executions: true
  retention_days: 90
EOF

echo "✓ Created vault.yaml"

echo ""
echo "=== Vault initialized at $VAULT_DIR ==="
echo ""
echo "Next steps:"
echo "  cd $VAULT_DIR"
echo "  ../scripts/import-from-pi.sh    # Import existing templates/skills"
echo "  dolt sql                       # Query the database"
echo "  ../scripts/export-to-pi.sh     # Export to pi format"

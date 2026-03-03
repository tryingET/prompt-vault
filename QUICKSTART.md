# Quick Start

> [← Back to README](README.md) · [Full Docs](docs/WORKFLOWS.md) · [Changelog](CHANGELOG.md)

Get started with Prompt Vault in 5 minutes.

## Prerequisites

```bash
# Install Dolt (Git for data)
brew install dolt

# Verify
dolt version
```

## Installation

```bash
# Clone
git clone https://github.com/your-org/prompt-vault.git
cd prompt-vault

# Initialize vault
./scripts/pv init

# Import from pi (optional)
./scripts/pv import
```

## First Steps

### 1. List Templates

```bash
./scripts/pv templates
./scripts/pv templates cognitive  # Just cognitive tools
./scripts/pv templates task       # Just task templates
```

### 2. View a Template

```bash
./scripts/pv show template inversion
./scripts/pv show template meta-orchestration
```

### 3. Search

```bash
./scripts/pv search "shadow"
./scripts/pv search "review"
```

### 4. View Tag Vocabulary

```bash
./scripts/pv vocabulary
```

Shows all tags grouped by namespace (action, phase, formalization, domain, scope).

### 5. Create a Template

```bash
./scripts/pv new-template my-review
# Enter description and content when prompted
./scripts/pv activate template my-review
```

### 5. A/B Test

```bash
# Create experiment branch
./scripts/pv branch experiment/faster-review

# Edit template
./scripts/pv edit-template my-review

# Commit
./scripts/pv commit "Add security focus"

# Compare with main
./scripts/pv diff main experiment/faster-review

# Ship it
./scripts/pv checkout main
./scripts/pv merge experiment/faster-review
```

## Pi Integration

The vault-client extension connects pi directly:

**Human Commands:**
```
/vaults                     # List all templates
/vault:inversion            # Load inversion framework
/vault:nexus "my problem"   # Load with context
/vault-search bug           # Search content
/route I'm stuck on X       # Get tool recommendation
/vault-stats                # Show usage statistics
```

**LLM Tools (autonomous):**
```
vault_query({ tags: ["action:invert"], limit: 3 })
vault_retrieve({ names: ["inversion", "nexus"] })
vault_vocabulary()
vault_rate({ template_name: "inversion", rating: 4, success: true })
```

## Maintenance

```bash
# Check schema version
./scripts/pv migrate status

# Cleanup old logs
./scripts/pv cleanup 30 --dry-run

# Backup
./scripts/pv backup create
```

## Architecture

```
~/steve/prompts/          prompt-vault/           pi
┌─────────────┐          ┌─────────────┐      ┌─────────────┐
│ triggers/   │ import   │ Dolt DB     │      │ extension   │
│ 27 tools    │ ───────► │ 48 templates│ ──── │ vault-client│
└─────────────┘          └─────────────┘      └─────────────┘
```

## Next Steps

- [Workflows](docs/WORKFLOWS.md) — Team collaboration, CI/CD
- [Comparison](docs/COMPARISON.md) — Vault vs flat files
- [Patterns](docs/CRYSTALLIZED.md) — Design decisions

## Troubleshooting

### Vault not initialized

```bash
./scripts/pv init
```

### Extension not loading

```bash
# Check extension exists
ls ~/.pi/agent/extensions/vault-client/

# Check VAULT_DIR matches
grep VAULT_DIR ~/.pi/agent/extensions/vault-client/index.ts
```

### Import fails

```bash
# Check triggers directory
ls ~/steve/prompts/triggers/

# Run import with debug
bash -x ./scripts/import-cognitive-tools.sh
```

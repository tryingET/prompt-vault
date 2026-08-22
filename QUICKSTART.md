---
summary: "Install and run Prompt Vault in a minimal 5-minute flow."
read_when:
  - "Setting up Prompt Vault for the first time"
  - "Needing the shortest path to a working local setup"
---

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
./scripts/pv templates cognitive                    # Just cognitive tools
./scripts/pv templates control_mode=router          # Just routers
./scripts/pv templates formalization_level=workflow # Workflow-grade prompts
./scripts/pv templates visibility_company=software  # What software can see
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

### 4. View Governed Vocabulary

```bash
./scripts/pv vocabulary
```

Shows:
- ontology facets (`artifact_kind`, `control_mode`, `formalization_level`)
- governed router controlled vocabulary
- company visibility boundary

### 5. Inspect Quality + Evidence Coverage

```bash
./scripts/pv quality dashboard
./scripts/pv quality coverage
./scripts/pv quality rollup control_mode
./scripts/pv analytics outputs
```

Notes:
- capture remains privacy-defaulted
- private captures stay aggregated-only in analytics/quality surfaces
- only explicitly public captures render text previews

### 6. Create a Template

```bash
./scripts/pv new-template my-review
# Enter description and content when prompted
./scripts/pv activate template my-review
```

### 7. A/B Test

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
(cd prompt-vault-db && dolt checkout main)
./scripts/pv merge experiment/faster-review
```

## Pi Integration

For the canonical Pi command surface and UX notes, see [[README.md]] → **Pi Integration**.

Minimal quickstart commands:

```bash
/vault                  # open the full visible picker
/vault inversion        # exact-load a visible template
/vault:review           # live picker / exact-name transform path
/vault-search review    # search visible template content
/route I'm stuck on X   # route to the best next prompt
```

Troubleshooting and selector behavior:
- [[docs/reference/fuzzy-selector-troubleshooting.md]]

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
~/source/prompts/          prompt-vault/                 pi
┌─────────────┐           ┌────────────────────────┐    ┌──────────────────┐
│ source set  │  import   │ Dolt DB (schema v10)   │    │ vault-client     │
│ + prompt IP │ ───────►  │ facets + vocabulary +  │───►│ picker + tools + │
│             │           │ visibility + evidence  │    │ diagnostics      │
└─────────────┘           └────────────────────────┘    └──────────────────┘
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
# Check current import source directories
ls ~/.pi/agent/prompts/
ls ~/.pi/agent/skills/

# Run the current importer with debug
bash -x ./scripts/import-from-pi.sh
```

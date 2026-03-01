# Prompt Vault — Session Context

> **Location:** `~/ai-society/softwareco/owned/prompt-vault`

## Quick Status

| Aspect | Status |
|--------|--------|
| Version | v1.1.0 (deep review complete) |
| Templates | 48 (28 cognitive, 20 task) |
| Verification | 33/33 checks pass |
| Schema | v1 (versioned) |
| Extension | Connected at new path |

## Architecture

```
~/steve/prompts/triggers/   →  import  →  prompt-vault-db/  →  pi extension
     (source)                    (Dolt)        (vault-client)
```

## Key Commands

```bash
cd ~/ai-society/softwareco/owned/prompt-vault

./scripts/pv templates              # List all
./scripts/pv show template <name>   # View
./scripts/pv search <query>         # Search
./scripts/pv cleanup 30             # Maintenance
./scripts/pv migrate status         # Check schema

./verify.sh                         # Full verification
```

## Pi Integration

```
/vaults                     # List templates
/vault:inversion            # Load cognitive tool
/route I'm stuck on X       # Get tool recommendation
/vault-stats                # Usage stats
```

## Next Steps

### Immediate

1. **Set up remote** — Add DoltHub or GitLab remote for backup/collaboration
2. **Test extension** — Verify `/vault:name` and `/route` work in pi with new path
3. **Archive old location** — Remove or archive `~/programming/prompt-vault`

### Short-term

4. **Output capture** — Add optional `output_text` column to executions table
5. **Rate limiting** — Add throttling to `/vault:name` command
6. **Quality dashboard** — Build `pv quality dashboard` with charts

### Future

7. **HTTP API** — Abstract query layer when third client appears
8. **Multi-tenancy** — Support multiple vaults per user/team
9. **Web UI** — Browser-based template management

## Documentation

| File | Purpose |
|------|---------|
| [README.md](README.md) | Project overview |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute setup |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [docs/CRYSTALLIZED.md](docs/CRYSTALLIZED.md) | Patterns & learnings |
| [docs/WORKFLOWS.md](docs/WORKFLOWS.md) | Team collaboration |
| [docs/project/](docs/project/) | Vision, goals, status |

## Recent History

```
b560267 docs: fill in template placeholders with prompt-vault context
900fe0e docs: update AGENTS.md for prompt-vault specifics
675253c Merge prompt-vault with full git history
3e4a07e Initial commit from softwareco-templates L1
7749fba docs: prepare for publication with badges, navigation
```

## Known Issues

| Issue | Status | Fix |
|-------|--------|-----|
| No output capture | Planned | Add `output_text` column |
| No rate limiting | Planned | Add to extension |
| CSV parsing | Fixed | Switched to JSON |

## Extension Path

```typescript
// ~/.pi/agent/extensions/vault-client/index.ts
const VAULT_DIR = process.env.VAULT_DIR ||
  "/home/tryinget/ai-society/softwareco/owned/prompt-vault/prompt-vault-db";
```

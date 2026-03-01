# Prompt Vault — Session Context

> **Location:** `~/ai-society/softwareco/owned/prompt-vault`
> **Moving to:** `~/ai-society/core/prompt-vault`

## Quick Status

| Aspect | Status |
|--------|--------|
| Version | v1.1.0 (deep review complete) |
| Templates | 48 (28 cognitive, 20 task) |
| Verification | 33/33 checks pass |
| Schema | v1 (versioned) |
| Extension | Connected |

## Strategic Direction

**Decision: Move to `core/`**

> "I would go with core, and then we can always extract the individual prompt tables for each company at a later stage. Each agent should be attributed its own prompts. And the results should be stored there, from each JSONL file, right?! With details about each toolcall and so on."

**No, not too crazy — this is the right architecture.**

### Future Architecture

```
ai-society/
├── core/
│   └── prompt-vault/                    # L0 - Master vault
│       ├── prompt-vault-db/             # Dolt DB (all cognitive tools)
│       ├── triggers/                    # Canonical source (synced from ~/steve)
│       ├── scripts/                     # CLI tools
│       └── extension/                   # pi integration
│
├── softwareco/
│   ├── infra/workstation/prompts/       # ← symlink or import from core
│   └── owned/                           # Project repos (use core vault)
│
└── holdingco/
    └── (same pattern)
```

### Why Core?

1. **Cognitive triggers are universal** — inversion, audit, nexus aren't company-specific
2. **Single source of truth** — one vault, all tools, no duplication
3. **Follows L0→L1→L2 pattern** — consistent with template hierarchy
4. **Per-company extraction later** — can filter by tags/type when needed

### Agent Attribution Vision

Each execution should track:
- `agent_id` — Which agent/session used the template
- `tool_calls[]` — Each tool invocation with args/result
- `output_text` — Full response
- `rating` — Human feedback

### JSONL Structure (Per Execution)

```json
{
  "timestamp": "2026-03-01T12:00:00Z",
  "agent_id": "softwareco-nexus",
  "template": "inversion",
  "template_version": 3,
  "model": "claude-3-sonnet",
  "latency_ms": 3420,
  "input_context": "Review the authentication module",
  "tool_calls": [
    {"tool": "read", "args": {"path": "auth.py"}, "result": "..."},
    {"tool": "bash", "args": {"cmd": "pytest"}, "result": "..."}
  ],
  "output_text": "## Shadow Analysis...",
  "rating": 4,
  "rating_notes": "Good but missed error paths"
}
```

## Next Steps

### Immediate

1. **Move to core** — `mv ~/ai-society/softwareco/owned/prompt-vault ~/ai-society/core/prompt-vault`
2. **Sync triggers** — Consolidate `~/steve/prompts/triggers/` → `core/prompt-vault/triggers/`
3. **Clean up duplicates** — Remove/symlink `softwareco/infra/workstation/prompts/triggers/`
4. **Update extension** — Point to new core location

### Short-term

5. **Add `agent_id` column** — Track which agent used each template
6. **Add `tool_calls` column** — JSON array of tool invocations
7. **Output capture** — Add `output_text` column
8. **JSONL export** — `pv export-executions --format jsonl --agent softwareco-nexus`

### Future

9. **Per-company extraction** — `pv extract --company softwareco --output company-vault/`
10. **JSONL ingestion** — Import agent logs back to vault for analytics
11. **Agent analytics** — Per-agent quality dashboards
12. **Multi-tenant schema** — Partition by company/agent if needed

## Key Commands

```bash
cd ~/ai-society/core/prompt-vault

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

## Open Questions

| Question | Options |
|----------|---------|
| JSONL storage | One file per session? Per day? Per agent? |
| Tool call capture | Full output or truncated? |
| Privacy | What gets stored vs redacted? |
| Agent ID format | `company-agent-name` or UUID? |

## Documentation

| File | Purpose |
|------|---------|
| [README.md](README.md) | Project overview |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [docs/CRYSTALLIZED.md](docs/CRYSTALLIZED.md) | Patterns & learnings |
| [docs/project/](docs/project/) | Vision, goals, status |

## Recent History

```
2b00bd4 docs: merge next_steps.md into next_session_prompt.md
b560267 docs: fill in template placeholders with prompt-vault context
900fe0e docs: update AGENTS.md for prompt-vault specifics
675253c Merge prompt-vault with full git history
```

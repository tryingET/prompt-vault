# Next Session: Vault Extension for Pi

## Completed

**Schema evolution:**
- Added `type` column: `cognitive` | `task` | `session`
- Updated schema.sql with new column

**Imported cognitive tools:**
- 22 triggers from `~/steve/prompts/triggers/`
- 1 standalone: `transcendent-iteration`
- Total: 23 cognitive tools

**Imported task prompts:**
- 18 existing pi templates
- 2 new: `unsung-foundations`, `fcos-model-first-convergence`
- Total: 20 task templates

**Cleanup performed:**
- `active-snippets.md` → deleted (redundant with INDEX.md)
- `next-session.md` → moved to diary
- `operating-modes.md` → already cleaned
- `prompt-snippets.md` → kept as master reference (not imported)

**CLI updated:**
- `pv templates` now shows type column
- `import-cognitive-tools.sh` script created

---

## Remaining: Vault Extension for Pi

**The gap:** Pi currently reads templates from flat files (`~/.pi/agent/prompts/`). Vault has templates in Dolt DB with versioning, metrics, and A/B testing capability — but no direct connection.

**What's needed:**

```typescript
// ~/.pi/agent/extensions/vault-client/index.ts
export default function (pi: ExtensionAPI) {
  // 1. Register /vault:name command
  pi.on("input", async (event, ctx) => {
    if (!event.text.startsWith("/vault:")) return { action: "continue" };
    
    const name = event.text.slice(7).trim();
    const template = await queryVault(name);
    
    if (!template) {
      ctx.ui.notify(`Template not found: ${name}`, "error");
      return { action: "handled" };
    }
    
    // Return content for LLM to process
    return { action: "transform", text: template.content };
  });

  // 2. Track executions
  pi.on("tool_result", async (event, ctx) => {
    // Log to vault.executions table
  });
}
```

**Features:**
- `/vault:inversion` — query vault directly
- `/vault --type cognitive` — list by type
- Execution tracking (tokens, latency, model)
- A/B testing via branches

---

## Architecture Decision

| Option | Pros | Cons |
|--------|------|------|
| **Direct query** | Real-time, no sync | Requires MySQL client |
| **Export on change** | Simple, works offline | Stale possible |
| **Hybrid** | Best of both | More complex |

**Recommendation:** Hybrid
- `pv export` generates flat files for pi's existing template system
- Extension queries vault for metrics, search, and A/B testing
- Flat files are cache, vault is source of truth

---

## Actions

- [ ] Build vault-client extension for pi
- [ ] Add `/vault:name` command
- [ ] Add execution tracking hook
- [ ] Add `--type` filter to pv CLI
- [ ] Document workflow: edit in vault → export → use in pi

---

## Quick Reference

```bash
# Vault operations
cd /home/tryinget/programming/prompt-vault
./scripts/pv templates              # List all
./scripts/pv show template inversion # View one
./scripts/pv search "shadow"        # Search content

# Import more tools
./scripts/import-cognitive-tools.sh

# Export to pi (when extension built)
./scripts/pv export
```

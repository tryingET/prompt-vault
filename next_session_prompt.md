# Prompt Vault — Session Context

> **Location:** `~/ai-society/core/prompt-vault`
> **Status:** v1.1.0 | 48 templates (30 cognitive, 18 task) | 33/33 checks pass

---

## Current State

### Schema (existing)
```sql
prompt_templates:
  id, name, description, content, variables, tags (JSON),
  version, parent_id, status, created_at, updated_at, type

executions:
  id, entity_type, entity_id, entity_version, input_context,
  model, success, created_at

feedback:
  id, execution_id, rating, notes, issues
```

### Extension (`~/.pi/agent/extensions/vault-client/`)
- `/vault:name` — load template
- `/vaults` — list all
- `/vault-search query` — search
- `/route context` — meta-orchestration recommendation
- `/vault-stats` — usage stats

### CLI (`~/ai-society/core/prompt-vault/scripts/`)
- `pv templates` — list
- `pv show template <name>` — view
- `pv search <query>` — search content
- `pv-template-vars` — extract/validate variables
- + 20+ other commands

---

## Decisions from Last Session

### 1. NO full rebuild
- Keep Dolt DB (versioning works)
- Keep existing extension (it works)
- Keep CLI scripts (they work)

### 2. Add tags vocabulary (not enums)
```
tags: ['action:invert', 'phase:sensemaking', 'formalization:napkin', 'domain:security', 'scope:code']
```
Namespaced strings, flexible, no schema migrations.

### 3. Add LLM tools (not just slash commands)
Tools let LLM query autonomously. Commands require humans.

---

## Implementation Plan

### Phase 1: Add Tools to Extension

**New tools in `vault-client/index.ts`:**

```typescript
// 1. Query by tags/keywords
vault_query({ tags: [], keywords: [], limit: 3, include_content: false })

// 2. Retrieve by name
vault_retrieve({ names: [], include_content: true })

// 3. List vocabulary (what tags/namespaces exist)
vault_vocabulary()

// 4. Insert with vocabulary check
vault_insert({ name, content, description, tags, source, confirm_new_tags: false })

// 5. Rate for A/B tracking
vault_rate({ template_name, variant, rating, success, notes })
```

**Changes to existing extension:**
- Keep existing `/vault:*` commands for humans
- Add new `vault_*` tools for LLM
- Add `tags` to query logic

### Phase 2: Tag Existing Templates

**Tag vocabulary:**

| Namespace | Values |
|-----------|--------|
| `action:` | invert, reduce, expand, generate, validate, project, crystallize |
| `phase:` | sensemaking, hypothesis, probing, validation, execution |
| `formalization:` | napkin, structured, bounded, workflow, operational |
| `domain:` | security, database, frontend, backend, testing, infrastructure, documentation, governance |
| `scope:` | self, code, system, organization, portfolio |
| `source:` | softwareco, holdingco, core |

**Migration script:**
```bash
# Add tags to existing templates based on type and analysis
./scripts/pv-tag-templates
```

### Phase 3: Vocabulary Enforcement

**In `vault_insert` tool:**
1. Query existing tags from DB
2. Compare new tags against vocabulary
3. If new tags detected, return confirmation request with suggestions
4. LLM must explicitly confirm new tags

**Example:**
```
LLM: vault_insert({ tags: ["action:shadow"] })
Tool: { status: "confirm", new_tags: ["action:shadow"],
        existing: { action: ["invert", "validate", ...] },
        suggestion: "Did you mean action:invert?" }
LLM: vault_insert({ tags: ["action:invert"], confirm_new_tags: true })
Tool: { status: "ok" }
```

---

## Files to Change

### MUST change:
| File | Change |
|------|--------|
| `~/.pi/agent/extensions/vault-client/index.ts` | Add 5 new tools |
| `~/ai-society/core/prompt-vault/scripts/pv-tag` | Script to bulk-tag templates |

### SHOULD change:
| File | Change |
|------|--------|
| `vault-client/evaluator.ts` | Update for new tool interface |
| `scripts/import-cognitive-tools.sh` | Extract tags from frontmatter |
| `input/*.md` | Add frontmatter with tags |

### MAY change (later):
| File | Change |
|------|--------|
| Schema | Add `source`, `owner`, `predecessor` columns |
| `scripts/pv-*` | Update for tag-based queries |
| `prompt-template-accelerator` | Integrate with new tools |

### SHOULD NOT change:
| File | Reason |
|------|--------|
| Dolt DB | Works, has versioning |
| Existing `/vault:*` commands | Humans use them |
| CLI scripts | They work |

---

## Tag Assignments (Draft)

### Cognitive Tools → Actions

| Template | action | phase | formalization |
|----------|--------|-------|---------------|
| inversion | invert | sensemaking, hypothesis | napkin |
| nexus | reduce | hypothesis, execution | structured |
| audit | validate | validation | bounded |
| first-principles | reduce | sensemaking | napkin |
| simplification | reduce | execution | structured |
| telescopic | expand | sensemaking, validation | napkin |
| adversary | validate | validation | bounded |
| mirror | generate | probing | bounded |
| scaffold | generate | hypothesis | bounded |
| doppelganger | generate | validation | bounded |
| inquisition | validate | validation | bounded |
| deep-review | validate | validation | workflow |
| blast-radius | project | validation | bounded |
| escape-hatch | project | execution | bounded |
| temporal-degradation | project | sensemaking | structured |
| constraint-inventory | reduce | sensemaking | napkin |
| knowledge-crystallization | crystallize | execution | structured |
| implicit-explicit | crystallize | validation | structured |
| meta-orchestration | (control) | (all) | structured |
| crisis | (control) | sensemaking | napkin |
| morning | (control) | sensemaking | napkin |
| decision | (control) | hypothesis | napkin |
| napkin | (mode) | sensemaking | napkin |
| controlled | (mode) | execution | bounded |

### Task Templates

| Template | domain |
|----------|--------|
| commit | backend |
| pr | backend |
| preflight* | infrastructure |
| frontend-design | frontend |
| e3d-htn | planning |

---

## Next Actions

1. **Add `tags` column queries to extension** — update `getTemplate`, `listTemplates`, `searchTemplates`
2. **Implement `vault_query` tool** — query by tags with overlap matching
3. **Implement `vault_retrieve` tool** — get by names
4. **Implement `vault_vocabulary` tool** — list existing tags grouped by namespace
5. **Implement `vault_insert` tool** — with vocabulary check
6. **Implement `vault_rate` tool** — for feedback loop
7. **Tag existing templates** — migration script
8. **Test LLM autonomous querying** — verify tool works
9. **Update import script** — read tags from frontmatter
10. **Document tag vocabulary** — in AGENTS.md or docs/

---

## Open Questions

| Question | Decision needed |
|----------|-----------------|
| Where does `source:` live? | In tags or separate column? |
| How to handle variants (A/B)? | `inversion@exp` as separate name or `variant:exp` tag? |
| Control/mode templates | Special `type:control` tag or separate handling? |
| Vocabulary storage | In DB (query on insert) or hardcoded in tool? |

---

## Key Commands

```bash
cd ~/ai-society/core/prompt-vault

# CLI
./scripts/pv templates
./scripts/pv show template inversion
./scripts/pv search "shadow"
./scripts/pv-template-vars list inversion

# Verification
./verify.sh

# DB
cd prompt-vault-db
dolt sql -q "SELECT name, tags FROM prompt_templates LIMIT 5"
```

## Pi Commands (human)

```
/vaults                     # List all
/vault:inversion            # Load template
/vault-search bug           # Search
/route I'm stuck            # Get recommendation
/vault-stats                # Usage
```

## Pi Tools (LLM)

```
vault_query({ tags: ["action:invert"], limit: 3 })
vault_retrieve({ names: ["inversion", "nexus"] })
vault_vocabulary()
vault_insert({ name: "...", content: "...", tags: [...] })
vault_rate({ template_name: "inversion", rating: 4, success: true })
```

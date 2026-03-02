# Prompt Vault — Session Context

> **Location:** `~/ai-society/core/prompt-vault`
> **Status:** v1.2.0 | 50 templates (30 cognitive, 20 task) | 34/34 checks pass | All templates tagged

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

### LLM Tools (NEW)
- `vault_query({ tags, keywords, limit, include_content })` — query by tags/keywords
- `vault_retrieve({ names, include_content })` — get by exact names
- `vault_vocabulary()` — list tag vocabulary
- `vault_insert({ name, content, description, tags, source, confirm_new_tags })` — insert with vocab check
- `vault_rate({ template_name, rating, success, notes })` — rate for feedback loop

### CLI (`~/ai-society/core/prompt-vault/scripts/`)
- `pv templates` — list
- `pv show template <name>` — view
- `pv search <query>` — search content
- `pv vocabulary` — show tag vocabulary (NEW)
- `pv-tag-templates` — bulk tag templates (NEW)
- `pv-template-vars` — extract/validate variables
- + 20+ other commands

---

## ✅ COMPLETED (This Session)

### Phase 1: Add Tools to Extension ✅
Added 5 new LLM tools to `vault-client/index.ts`:
1. `vault_query` — Query templates by tags and/or keywords
2. `vault_retrieve` — Retrieve templates by exact names
3. `vault_vocabulary` — List all tags grouped by namespace
4. `vault_insert` — Insert template with vocabulary validation
5. `vault_rate` — Rate template for feedback loop

### Phase 2: Tag Existing Templates ✅
Created `scripts/pv-tag-templates` and tagged all 50 templates:
- 9 action types: validate, expand, crystallize, reduce, control, project, generate, mode, invert
- 5 phase types: sensemaking (19), validation (15), execution (12), hypothesis (9), probing (2)
- 4 formalization levels: structured (17), bounded (14), napkin (12), workflow (7)
- 6 domains: infrastructure, backend, security, planning, governance, frontend
- 4 scopes: self (13), code (10), system (7), portfolio (1)

### Phase 3: Vocabulary Command ✅
Added `pv vocabulary` command to show tag vocabulary with counts.

### Phase 4: Import Script Enhancement ✅
Updated `import-cognitive-tools.sh` to read tags from YAML frontmatter.

---

## Decisions Made

### 1. NO full rebuild ✅
- Kept Dolt DB (versioning works)
- Kept existing extension (it works)
- Kept CLI scripts (they work)

### 2. Add tags vocabulary (not enums) ✅
```
tags: ['action:invert', 'phase:sensemaking', 'formalization:napkin', 'domain:security', 'scope:code']
```
Namespaced strings, flexible, no schema migrations.

### 3. Add LLM tools (not just slash commands) ✅
Tools let LLM query autonomously. Commands require humans.

### 4. Vocabulary check on insert (optional) ✅
`vault_insert` can validate against existing vocabulary with `confirm_new_tags` flag.

---

## Tag Vocabulary (Current)

| Namespace | Values (count) |
|-----------|----------------|
| action | validate(6), expand(6), crystallize(5), reduce(4), control(4), project(3), generate(3), mode(2), invert(1) |
| phase | sensemaking(19), validation(15), execution(12), hypothesis(9), probing(2) |
| formalization | structured(17), bounded(14), napkin(12), workflow(7) |
| domain | infrastructure(8), backend(5), security(1), planning(1), governance(1), frontend(1) |
| scope | self(13), code(10), system(7), portfolio(1) |

---

## Key Commands

```bash
cd ~/ai-society/core/prompt-vault

# CLI
./scripts/pv templates
./scripts/pv show template inversion
./scripts/pv search "shadow"
./scripts/pv vocabulary              # NEW: show tag vocabulary
./scripts/pv-template-vars list inversion

# Verification
./verify.sh                          # 34/34 checks pass

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

---

## Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Where does `source:` live? | In `type` column (cognitive/task/session), not tags |
| How to handle variants (A/B)? | Use existing `prompt_variants` table |
| Control/mode templates | Tagged with `action:control` or `action:mode` |
| Vocabulary storage | Queried from DB on each insert |

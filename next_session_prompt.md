# Next Session: Complete Trigger Schema

## Current State

**Vault:** 48 templates (28 cognitive, 20 task)
**Extension:** vault-client with execution tracking
**CLI:** `pv templates [type]` filter working

---

## DEEP REVIEW FINDINGS

### Bugs Found

| Bug | Files | Severity |
|-----|-------|----------|
| Missing OUTPUT FORMAT | dependency-cartography, knowledge-crystallization, temporal-degradation, recursion-engine | HIGH |
| OUTPUT naming inconsistent | 4 files use `OUTPUT:` or `OUTPUT STRUCTURE:` | MEDIUM |
| Mode/tool classification unclear | controlled, morning, decision have OUTPUT but are "modes" | LOW |

### Missing OUTPUT FORMAT

```
dependency-cartography.md  — 25 lines, no OUTPUT
knowledge-crystallization.md — 22 lines, no OUTPUT
temporal-degradation.md    — 17 lines, no OUTPUT
recursion-engine.md        — 54 lines, no OUTPUT
```

### Naming Variants

```
OUTPUT FORMAT:      (16 files) ← STANDARD
OUTPUT:             (3 files)
OUTPUT STRUCTURE:   (1 file - deep-review.md)
```

---

## Actions

### 1. Add OUTPUT FORMAT to 4 files

For each of: `dependency-cartography`, `knowledge-crystallization`, `temporal-degradation`, `recursion-engine`

Add before closing ```:
```
OUTPUT FORMAT:
```
[appropriate output structure]
```
```

### 2. Standardize naming

Change `OUTPUT:` and `OUTPUT STRUCTURE:` → `OUTPUT FORMAT:`

### 3. Re-import to vault

```bash
cd /home/tryinget/programming/prompt-vault
./scripts/import-cognitive-tools.sh
```

### 4. Update validation

Add to `validate.sh`:
- Check all cognitive tools have OUTPUT FORMAT
- Check naming is standardized

### 5. Document schema

Create `~/steve/prompts/triggers/TRIGGER_FORMAT.md`:
```markdown
## TRIGGER CONTRACT

Every cognitive tool MUST have:
1. Header: `NAME — Description` (no prefix)
2. Content in code block
3. `OUTPUT FORMAT:` section

Mode triggers (napkin, crisis, controlled, morning, decision):
- Define state/mode, not analysis
- MAY omit OUTPUT FORMAT

Naming: Always `OUTPUT FORMAT:` (not OUTPUT: or OUTPUT STRUCTURE:)
```

---

## Quick Reference

```bash
# Validate triggers
~/steve/prompts/triggers/validate.sh

# List by type
./scripts/pv templates cognitive
./scripts/pv templates task

# Re-import after edits
./scripts/import-cognitive-tools.sh

# Test in pi
/vault:dependency-cartography
/vault:temporal-degradation
```

---

## Files Summary

```
~/.pi/agent/extensions/vault-client/
├── index.ts          # 359 lines, execution tracking
└── package.json

~/steve/prompts/
├── prompt-snippets.md      # Master reference
├── triggers/               # 27 triggers + INDEX + validate.sh
│   ├── 4 need OUTPUT FORMAT added
│   └── 4 need OUTPUT naming fixed
└── ...

~/programming/prompt-vault/
├── schema/schema.sql       # With type column
├── scripts/pv              # CLI with --type filter
└── prompt-vault-db/        # 48 templates
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   ~/steve/prompts/          prompt-vault/           pi          │
│   ┌─────────────┐          ┌─────────────┐      ┌─────────────┐ │
│   │ triggers/   │ import   │ Dolt DB     │      │ extension   │ │
│   │ 27 tools    │ ───────► │ 48 templates│ ──── │ vault-client│ │
│   │ + validate  │          │ 28 cognitive│      │             │ │
│   └─────────────┘          │ 20 task     │      │ /vault:name │ │
│                            └─────────────┘      │ /route ctx   │ │
│                                                 │ /vault-stats │ │
│                                                 └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cognitive Tools (28)

| Category | Tools |
|----------|-------|
| **Router** | meta-orchestration |
| **Core 6** | inversion, telescopic, nexus, audit, first-principles, simplification |
| **Mode** | napkin, controlled, crisis, morning, decision |
| **Quality** | deep-review, atomic-completion, blast-radius, escape-hatch |
| **Testing** | mirror, adversary, inquisition, doppelganger, scaffold |
| **Architecture** | dependency-cartography*, temporal-degradation*, knowledge-crystallization*, recursion-engine* |
| **Docs** | elevate |
| **Problem** | constraint-inventory |

*Needs OUTPUT FORMAT added

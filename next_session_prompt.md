# Prompt Vault + Pi Integration

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   ~/steve/prompts/          prompt-vault/           pi          │
│   ┌─────────────┐          ┌─────────────┐      ┌─────────────┐ │
│   │ triggers/   │ import   │ Dolt DB     │      │ extension   │ │
│   │ 27 tools    │ ───────► │ 48 templates│ ──── │ vault-client│ │
│   │ + INDEX     │          │ 28 cognitive│      │             │ │
│   │ + validate  │          │ 20 task     │      │ /vault:name │ │
│   └─────────────┘          └─────────────┘      │ /vaults      │ │
│                                                 │ /route ctx   │ │
│                                                 │ /vault-stats │ │
│                                                 └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Usage

### Pi Commands

```
/vaults                     # List all 48 templates
/vault cognitive            # Same (via command)
/vault:inversion            # Load inversion framework
/vault:meta-orchestration   # Load the router
/vault:nexus "my problem"   # Load with context
/route I'm stuck on X       # Get tool recommendation
/vault-search "shadow"      # Search vault content
/vault-stats                # Show execution statistics
```

### CLI

```bash
cd ~/programming/prompt-vault

./scripts/pv templates              # List all
./scripts/pv templates cognitive    # List cognitive tools only
./scripts/pv templates task         # List task templates only
./scripts/pv show template inversion # View one
./scripts/pv search "shadow"        # Search

# Re-import after editing triggers
./scripts/import-cognitive-tools.sh
```

### Validation

```bash
~/steve/prompts/triggers/validate.sh
```

---

## The Router

**meta-orchestration** is the phase navigator:

| Phase | Goal | Tools |
|-------|------|-------|
| SENSEMAKING | Understand problem space | inversion, telescopic |
| HYPOTHESIS | Generate solutions | nexus, simplification |
| PROBING | Test cheaply | blast-radius, escape-hatch |
| VALIDATION | Stress-test | audit, adversary |
| EXECUTION | Run bounded process | atomic-completion |

**Formalization Ladder:**
- 0: NAPKIN — disposable, fast
- 1: SKETCH — temporary structure
- 2: BOUNDED — executable with guards
- 3: WORKFLOW — stable, repeatable
- 4: OPERATIONAL — production-grade

---

## Cognitive Tools (28)

| Category | Tools |
|----------|-------|
| **Router** | meta-orchestration |
| **Core 6** | inversion, telescopic, nexus, audit, first-principles, simplification |
| **Mode** | napkin, controlled, crisis, morning, decision |
| **Quality** | deep-review, atomic-completion, blast-radius, escape-hatch |
| **Testing** | mirror, adversary, inquisition, doppelganger, scaffold |
| **Architecture** | dependency-cartography, temporal-degradation, knowledge-crystallization, recursion-engine |
| **Docs** | elevate |
| **Problem** | constraint-inventory |

---

## Files

```
~/.pi/agent/extensions/vault-client/
├── index.ts          # Extension (359 lines)
└── package.json

~/steve/prompts/
├── prompt-snippets.md      # Master reference (1834 lines)
├── triggers/               # 27 triggers + INDEX + validate.sh
│   ├── INDEX.md
│   ├── validate.sh
│   ├── meta-orchestration.md
│   ├── inversion.md
│   └── ... (25 more)
├── transcendent-iteration.md
├── unsung-foundations.md
└── fcos-model-first-convergence.md

~/programming/prompt-vault/
├── schema/schema.sql       # With type column
├── scripts/
│   ├── pv                  # CLI (templates --type)
│   ├── import-cognitive-tools.sh
│   └── ...
└── prompt-vault-db/        # Dolt database
```

---

## Features

| Feature | Status |
|---------|--------|
| Direct vault query | ✅ `/vault:name` |
| List by type | ✅ `/vaults`, `pv templates cognitive` |
| Routing via meta-orchestration | ✅ `/route <context>` |
| Search | ✅ `/vault-search` |
| Execution tracking | ✅ Logs to vault.executions |
| Stats | ✅ `/vault-stats` |
| Validation | ✅ `validate.sh` |
| A/B testing | 🔲 Future (dolt branches) |
| Auto-suggest | 🔲 Future |

---

## Quick Reference

```
# In pi
/vaults                         # List all
/vault:inversion                # Use tool
/route <situation>              # Get recommendation
/vault-stats                    # See usage

# CLI
./scripts/pv templates cognitive
./scripts/pv search "shadow"

# Validate
~/steve/prompts/triggers/validate.sh
```

# Vault + Pi Integration Complete

## What's Built

```
┌─────────────────────────────────────────────────────────────────┐
│                         ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ~/steve/prompts/          prompt-vault/           pi          │
│   ┌─────────────┐          ┌─────────────┐      ┌─────────────┐ │
│   │ triggers/   │ import   │ Dolt DB     │      │ extension   │ │
│   │ 27 tools    │ ───────► │ 48 templates│ ──── │ vault-client│ │
│   │ + INDEX     │          │ 28 cognitive│      │             │ │
│   └─────────────┘          │ 20 task     │      │ /vault:name │ │
│                            └─────────────┘      │ /vaults      │ │
│                                                 │ /route ctx   │ │
│                                                 └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## How to Use

### 1. LIST AVAILABLE TOOLS

```
/vaults              # List all 48 templates by type
/vault cognitive     # List only cognitive tools
/vault task          # List only task templates
```

### 2. INVOKE A TOOL DIRECTLY

```
/vault:inversion                    # Load inversion framework
/vault:nexus                        # Load nexus framework
/vault:meta-orchestration           # Load the router itself
/vault:audit "Button.tsx"           # Load audit with context
```

### 3. ROUTE VIA META-ORCHESTRATION

```
/route I'm stuck on a refactoring and don't know where to start
/route Tests are failing and I don't understand why
/route I need to make a risky change to the payment system
```

This invokes `meta-orchestration` which:
1. Determines your PHASE (sensemaking → execution)
2. Suggests FORMALIZATION level (0-4)
3. Recommends TOOLS
4. Gives you the command to invoke

---

## The Router Logic

**meta-orchestration IS the router:**

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

## Cognitive Tools in Vault

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

## Files Created

```
~/.pi/agent/extensions/vault-client/
├── index.ts          # Extension (8028 bytes)
└── package.json      # Metadata

~/programming/prompt-vault/
├── scripts/import-cognitive-tools.sh   # Import script
├── schema/schema.sql                   # Updated with type column
└── prompt-vault-db/                    # Dolt database
    └── 48 templates (28 cognitive, 20 task)
```

---

## Test It

```bash
# Start pi (extension auto-loads)
pi

# List tools
/vaults

# Route a problem
/route I'm overwhelmed with too many things to do

# Invoke directly
/vault:crisis
```

---

## Next Enhancements

- [ ] Execution tracking (log to vault.executions)
- [ ] A/B testing (return different versions by branch)
- [ ] Search by tag: `/vault-tag cognitive`
- [ ] Auto-suggest on keywords ("I'm stuck" → suggests inversion)
- [ ] Full-text search with relevance scoring

---

## Quick Reference

```bash
# Vault CLI
cd ~/programming/prompt-vault
./scripts/pv templates              # List all
./scripts/pv show template inversion # View one
./scripts/pv search "shadow"        # Search

# Re-import after adding triggers
./scripts/import-cognitive-tools.sh

# Pi commands
/vaults                             # List all
/vault:inversion                    # Use tool
/route <situation>                  # Get routing suggestion
/vault-search <query>               # Search vault
```

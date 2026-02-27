# Next Session: Prompt Classification & Schema Evolution

## Current State

**In vault (templates):**
- 18 pi templates from `~/.pi/agent/prompts/`
- Invocation via `/template-name` in pi
- Schema: name, description, content, tags, version, status

**Available but not imported:**

```
~/steve/prompts/
├── prompt-snippets.md        (66KB - cognitive frameworks)
├── active-snippets.md        (4KB - quick invocations)
├── operating-modes.md        (15KB - reasoning frameworks)
├── transcendent-iteration.md (4KB)
├── fcos-model-first-convergence.md (4KB)
├── unsung-foundations.md     (4KB)
└── triggers/                 (24 files, ~4KB total)
    ├── inversion.md
    ├── telescopic.md
    ├── nexus.md
    ├── elevate.md
    ├── first-principles.md
    ├── audit.md
    ├── blast-radius.md
    └── ... (17 more)
```

---

## The Classification Problem

**What's the difference between:**

| Type | Current Location | Invocation | Structure |
|------|-----------------|------------|-----------|
| Template | `~/.pi/agent/prompts/*.md` | `/name` in pi | Frontmatter + content |
| Snippet | `~/steve/prompts/prompt-snippets.md` | Manual copy | Named blocks with explanation |
| Trigger | `~/steve/prompts/triggers/*.md` | Manual copy | Short directive + output format |
| Operating Mode | `~/steve/prompts/operating-modes.md` | Manual copy | Framework definition |

**Questions:**

1. Should snippets become templates? (invocable via `/inversion`, `/nexus`)
2. Should triggers be a separate table? (lighter weight, different usage pattern)
3. Should operating modes be templates or a new category?
4. What about the 66KB prompt-snippets.md master file?

---

## Proposed Schema Evolution

### Option A: Single Table, Type Column

```sql
ALTER TABLE prompt_templates
ADD COLUMN type ENUM('template', 'snippet', 'trigger', 'mode') DEFAULT 'template';

ALTER TABLE prompt_templates
ADD COLUMN invocation_style ENUM('slash', 'inline', 'framework') DEFAULT 'slash';
```

### Option B: Separate Tables

```sql
-- Lightweight invocable snippets
CREATE TABLE prompt_snippets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    shorthand VARCHAR(32),           -- 'inversion', 'nexus', etc.
    directive TEXT NOT NULL,         -- the actual prompt text
    explanation TEXT,                -- why it works
    tags JSON,
    status ENUM('draft', 'active', 'deprecated') DEFAULT 'active'
);

-- Full frameworks (operating modes)
CREATE TABLE prompt_frameworks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    trigger_context TEXT,            -- when to use
    framework TEXT NOT NULL,         -- full framework content
    output_format TEXT,
    tags JSON,
    status ENUM('draft', 'active', 'deprecated') DEFAULT 'active'
);
```

### Option C: Tag-Based Classification

Keep single table, use tags for querying:

```bash
./pv templates --tag snippet
./pv templates --tag trigger
./pv templates --tag framework
./pv templates --tag mode
```

---

## Analysis Needed

1. **Inventory all prompts** — List everything in `~/steve/prompts/` with metadata
2. **Determine invocation patterns** — How does each type get used?
3. **Map relationships** — Do snippets reference templates? Do modes include snippets?
4. **Consider access patterns** — Query by tag? By type? Full-text search?

---

## Potential New Category: Cognitive Tools

The snippets/triggers are different from templates:

| Templates | Cognitive Tools |
|-----------|-----------------|
| Domain-specific | Domain-agnostic |
| Produces output | Shifts perspective |
| Linear execution | Epistemic framework |
| `/review`, `/commit` | `/inversion`, `/nexus` |

Could add:

```sql
CREATE TABLE cognitive_tools (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    shorthand VARCHAR(32),
    category ENUM('inversion', 'analysis', 'synthesis', 'validation', 'planning'),
    directive TEXT NOT NULL,
    rationale TEXT,
    example_usage TEXT,
    tags JSON,
    status ENUM('draft', 'active', 'deprecated') DEFAULT 'active'
);
```

Then:

```bash
./pv tools                    # List cognitive tools
./pv tools --category analysis
./pv show tool inversion
./pv search "assumption"
```

---

## Actions

- [ ] Inventory `~/steve/prompts/` with metadata
- [ ] Inventory `~/steve/prompts/triggers/` with metadata
- [ ] Decide: single table vs multiple tables
- [ ] Update schema if needed
- [ ] Write import script for snippets/triggers
- [ ] Update CLI to support new categories
- [ ] Test queries: by type, by tag, full-text

---

## Open Questions

1. Should the 66KB master file be the source of truth, or individual trigger files?
2. How do we handle snippet relationships (nexus depends on first-principles)?
3. Should tools have a "requires" field for dependencies?
4. Export format: how do cognitive tools differ from templates in export?

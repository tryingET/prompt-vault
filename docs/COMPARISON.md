---
summary: "Prompt Vault vs pi flat files: when to use each"
read_when:
  - "Deciding between vault and flat files"
  - "Making the case for vault adoption"
---

# Prompt Vault vs Flat Files

> [← Back to README](../README.md) · [Changelog](../CHANGELOG.md)

Pi uses flat markdown files. Vault uses a SQL database with Git semantics.

The difference: **pi trusts. Vault verifies.**

## The Tradeoff

| Flat Files (pi) | Prompt Vault |
|-----------------|--------------|
| Zero setup | Requires Dolt |
| Instant everywhere | Needs installation |
| No learning curve | SQL + Git concepts |
| No metrics | Full analytics |
| No history per prompt | Entity-level versioning |
| Manual A/B testing | First-class branching |
| grep for search | SQL queries |
| Git PRs on files | DoltHub PRs on rows |

**Pi wins:** Simplicity, portability, speed
**Vault wins:** Everything else

## The Seven Gaps

Flat files cannot answer these questions. Vault can.

### 1. Version Control
*Which version of this prompt performed best?*

Pi: File history exists but mixes all prompts together. Rollback is manual.
Vault: `pv history <name>` shows every version. `pv rollback <name>@3` restores.

### 2. Experimentation
*Which variant should we ship?*

Pi: Copy the file, rename it, manually track which is which.
Vault: `pv branch experiment/a`, edit, measure, `pv merge experiment/a`.

### 3. Analytics
*Is this prompt actually good?*

Pi: No data. Trust your gut.
Vault: Execution counts, latency, success rates, average ratings.

### 4. Search
*Find all prompts about security.*

Pi: `grep -r security ~/.pi/agent/prompts/`
Vault: `pv search security` or `pv templates cv.input_artifact=review_findings`

### 5. Collaboration
*Review this prompt change.*

Pi: Git diff on a markdown file. Context limited to that file.
Vault: DoltHub PR showing row-level diff with full history context.

### 6. Quality
*Which prompts need work?*

Pi: Open each file and read it.
Vault: `pv quality dashboard` — missing descriptions, low ratings, no executions.

### 7. Export
*Use these prompts in Python.*

Pi: Write a parser.
Vault: `pv export-fmt python prompts.py`

## When to Use Each

**Use pi when:**
- Solo developer
- < 10 templates
- No need for metrics
- Zero-config required

**Use vault when:**
- Team collaboration
- A/B testing variants
- Data-driven iteration
- Quality enforcement
- Multi-tool export
- Release management

## Migration Path

```bash
# Preserve pi's simplicity, add vault's power
./pv init
./pv import                    # One-time from pi
./pv export --output ~/.pi/agent/prompts  # Sync back when needed
```

Hybrid: keep pi for quick prototypes, vault for production prompts.

## Should Pi Adopt Vault?

**Recommended:** Keep flat files default, offer vault as opt-in.

```json
{
  "promptBackend": "vault"  // opt-in to Dolt
}
```

This preserves zero-config philosophy while enabling pro features.

---

## Summary

| Dimension | Pi | Vault |
|-----------|----|----|
| Setup | Zero | Dolt required |
| History | File-level | Entity-level |
| Metrics | None | Full tracking |
| Search | grep | SQL |
| Collaboration | Git PRs | DoltHub PRs |
| Quality | Manual | Automated |
| Export | MD only | Multi-format |

Flat files are fine for notes. Prompts deserve infrastructure.

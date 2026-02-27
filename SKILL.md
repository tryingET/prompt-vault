---
name: prompt-vault
description: Version-controlled prompt templates using Dolt SQL database. Use when creating, iterating on, or collaborating around prompts with analytics and A/B testing.
license: MIT
---

# Prompt Vault

Prompts are programs. They deserve version control, metrics, and collaborative review.

**Core insight:** Flat files can't tell you which prompt version performed best, what changed, or who changed it. A SQL database with Git semantics can.

## The Loop

```
write ──► execute ──► measure ──► learn ──► iterate
  ▲                                           │
  └───────────────────────────────────────────┘
```

Vault closes this loop. Every execution tracked. Every rating recorded.

## Setup

```bash
cd scripts
./pv init      # Create database
./pv import    # From pi templates/skills
```

## Essentials

```bash
./pv templates                    # List
./pv show template <name>         # View
./pv edit-template <name>         # Edit
./pv search <query>               # Find

./pv branch experiment/x          # A/B test
./pv merge experiment/x           # Ship winner

./pv exec template x "args"       # Run with tracking
./pv rate <exec-id> 4 "notes"     # Feedback
./pv stats                        # See what works
```

## Schema

```
prompt_templates: id, name, content, description, tags, version, status
executions:       id, entity_type, entity_id, latency_ms, success
feedback:         id, execution_id, rating, notes, issues
```

## Direct SQL

```bash
cd prompt-vault-db && dolt sql

SELECT * FROM prompt_templates WHERE status = 'active';
SELECT t.name, AVG(f.rating) FROM prompt_templates t
  JOIN executions e ON e.entity_id = t.id
  JOIN feedback f ON f.execution_id = e.id
  GROUP BY t.name;
```

## Reference

Full docs: [README.md](README.md) | [WORKFLOWS.md](docs/WORKFLOWS.md) | [COMPARISON.md](docs/COMPARISON.md)

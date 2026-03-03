# Prompt Vault

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dolt](https://img.shields.io/badge/Database-Dolt-blue)](https://www.dolthub.com/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green)](https://www.gnu.org/software/bash/)

**Version-controlled prompt templates with SQL, Git semantics, and analytics.**

Prompts are programs. They deserve the same rigor as code: version control, testing, metrics, and collaborative review.

Prompt Vault treats prompts as structured data in a SQL database with Git-style version control. Every prompt has a history. Every change is tracked. Every execution measured.

## The Problem

You have dozens of prompts scattered across files, chat history, and notes. You iterate on them constantly but can't answer:

- Which version performed best?
- What changed between last week and today?
- Who wrote this and why?
- Which prompts need work?

Flat files can't answer these. Git gives you file history, not prompt history. There's no feedback loop.

## The Solution

A Dolt database where prompts are rows, not files.

```
prompt_templates: id, name, content, description, tags, version, status
executions:       id, entity_type, entity_id, latency_ms, success, tokens
feedback:         id, execution_id, rating, notes, issues
```

Dolt is Git for data. You get branches, merges, diffs, and rollback—per prompt, not per file. Query history with SQL. Collaborate via DoltHub PRs. Track what works.

## Quick Start

```bash
cd scripts

./pv init        # Create the database
./pv import      # Pull in existing pi templates
./pv templates   # List what you have
./pv search review --tag security  # Find by content or tag

./pv branch experiment/faster-review   # Try something new
./pv edit-template code-review         # Make changes
./pv diff main experiment/faster-review # Compare
./pv merge experiment/faster-review    # Ship it

./pv exec template code-review "Button.tsx"  # Run with tracking
./pv rate 42 4 "Good but missed error handling"  # Leave feedback
./pv stats       # See what's working
```

## Mental Model

**Prompts are intellectual property that compound.** Every execution teaches you something. Without a system, that knowledge evaporates.

```
┌─────────────────────────────────────────────────────────┐
│                     FEEDBACK LOOP                        │
│                                                          │
│   write ──► execute ──► measure ──► learn ──► iterate   │
│     ▲                                              │      │
│     └──────────────────────────────────────────────┘      │
│                                                          │
│   Each cycle makes every prompt better.                  │
│   Vault closes the loop.                                 │
└─────────────────────────────────────────────────────────┘
```

**Three primitives:**

| Primitive | Purpose | Command |
|-----------|---------|---------|
| Template | A reusable prompt | `pv templates`, `pv show`, `pv edit-template` |
| Execution | A template invocation with metrics | `pv exec`, `pv stats` |
| Feedback | Human judgment on quality | `pv rate`, `pv quality` |

**Version control at entity level:**

```bash
./pv history code-review      # See every version of this prompt
./pv rollback code-review@5   # Restore a specific version
./pv diff @~1 code-review     # What changed in last edit
./pv tag release v1.2.0       # Snapshot for reproducibility
```

## Schema

Six tables. Everything you need, nothing you don't.

```
prompt_templates ──► executions ──► feedback
        │
        └──► collections (grouping)

skills ──► skill_assets
```

| Table | Purpose |
|-------|---------|
| `prompt_templates` | The prompts themselves |
| `skills` | Complex multi-file capabilities |
| `skill_assets` | Supporting files for skills |
| `executions` | Every time a prompt runs |
| `feedback` | Human ratings and notes |
| `collections` | Logical groupings |

## Commands

**Daily use:**
```bash
./pv templates              # List all
./pv show template review   # View one
./pv search "security"      # Find by content
./pv edit-template review   # Modify
./pv commit "clarify steps" # Save
```

**Experimentation:**
```bash
./pv branch experiment/x    # Try something
./pv diff main experiment/x # Compare
./pv merge experiment/x     # Ship winner
```

**Analytics:**
```bash
./pv stats                  # Usage overview
./pv quality dashboard      # Health scores
./pv exec template x "arg"  # Run with tracking
./pv rate <id> 4 "notes"    # Record feedback
```

**Export:**
```bash
./pv export                    # pi format
./pv export-fmt typescript     # TS constants
./pv export-fmt python         # Python module
./pv integrate langchain out   # LangChain ready
```

## Requirements

- Dolt 0.40+ — `brew install dolt`
- bash 4.0+
- jq
- fzf (optional, for TUI)

## Verification

```bash
./verify.sh      # 33 checks
bats tests/      # Full suite
```

## Documentation

| File | When to Read |
|------|--------------|
| [QUICKSTART.md](QUICKSTART.md) | Get started in 5 minutes |
| [CHANGELOG.md](CHANGELOG.md) | Version history and changes |
| [WORKFLOWS.md](docs/WORKFLOWS.md) | Team collaboration, CI/CD, advanced patterns |
| [COMPARISON.md](docs/COMPARISON.md) | Deciding vault vs flat files |
| [CRYSTALLIZED.md](docs/CRYSTALLIZED.md) | Patterns, anti-patterns, lessons learned |

## Pi Integration

The vault-client extension connects pi directly to the vault:

**Human Commands:**
```
/vaults                     # List all templates
/vault:inversion            # Load inversion framework
/vault:nexus "my problem"   # Load with context
/vault-search bug           # Search content
/route I'm stuck on X       # Get tool recommendation
/vault-stats                # Show usage statistics
```

**LLM Tools (autonomous access):**
```
vault_query({ tags: ["action:invert"], limit: 3 })
vault_retrieve({ names: ["inversion", "nexus"], include_content: true })
vault_vocabulary()
vault_insert({ name: "my-tool", content: "...", tags: ["action:validate"] })
vault_rate({ template_name: "inversion", rating: 4, success: true })
```

**Tag Vocabulary:**
| Namespace | Purpose | Values |
|-----------|---------|--------|
| `action:` | What it does | invert, reduce, expand, generate, validate, project, crystallize |
| `phase:` | When to apply | sensemaking, hypothesis, probing, validation, execution |
| `formalization:` | Rigor level | napkin, bounded, structured, workflow |
| `domain:` | Subject area | backend, frontend, infrastructure, security, governance |
| `scope:` | Application level | self, code, system, portfolio |

## Maintenance

```bash
./pv cleanup 30             # Remove executions older than 30 days
./pv cleanup 30 --dry-run   # Preview cleanup
./pv migrate status         # Check schema version
./pv backup create          # Create backup
./pv backup list            # List backups
```

## Philosophy

Most prompt engineering is faith-based. You write a prompt, use it, hope it works. No metrics. No history. No learning.

Vault closes the loop. Every prompt has a past. Every execution leaves evidence. Every judgment gets recorded. Over time, patterns emerge. Weak prompts reveal themselves. Strong ones compound.

The database is small. The impact is not.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Contributing

1. Read [CRYSTALLIZED.md](docs/CRYSTALLIZED.md) for patterns and conventions
2. Run `./verify.sh` before submitting changes
3. Follow conventional commit format

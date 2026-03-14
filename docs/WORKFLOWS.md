---
summary: "Advanced patterns for teams, CI/CD, and analytics-driven prompt engineering"
read_when:
  - "Setting up team collaboration"
  - "Implementing A/B testing workflows"
  - "Building analytics dashboards"
  - "Integrating with CI/CD"
---

# Prompt Vault Workflows

> [← Back to README](../README.md) · [Comparison](COMPARISON.md) · [Patterns](CRYSTALLIZED.md)

For practitioners who've outgrown flat files.

## The A/B Testing Protocol

Every prompt improvement should be measured. The protocol:

```bash
# 1. Baseline
./pv exec review Button.tsx
./pv rate <id> 3 "Baseline"

# 2. Create variant
./pv branch experiment/add-security-check
./pv edit-template review
# Add: "Check for XSS vulnerabilities in event handlers"
./pv commit "Add security focus"

# 3. Run variant
dolt checkout experiment/add-security-check
./pv exec review Button.tsx
./pv rate <id> 4 "Caught XSS issue"

# 4. Compare
dolt checkout main
./pv diff main experiment/add-security-check

# 5. Ship or abandon
./pv merge experiment/add-security-check  # or delete branch
```

**Rule:** Never merge without data. If you can't measure it, you're guessing.

## Team Collaboration

### Setup

```bash
# On DoltHub, create: your-org/prompt-vault
dolt remote add origin your-org/prompt-vault
./pv push origin
```

### Branch Discipline

```
main          ──► production prompts
  │
  ├── staging ──► pre-release review
  │
  └── experiments/
        ├── faster-review
        ├── security-focus
        └── simpler-output
```

**Workflow:**
1. Branch from `staging`
2. Develop and test
3. PR to `staging` for review
4. Merge to `main` on release

### Code Review for Prompts

DoltHub shows row-level diffs. Reviewers see:

```
- content: "Review the code for bugs"
+ content: "Review the code for bugs and security vulnerabilities"
```

Not a file diff. A data diff. Context is the full prompt history.

### Conflict Resolution

```bash
./pv merge experiment/x
# Conflict detected

dolt conflicts ls                    # See what's broken
dolt conflicts resolve prompt_templates --ours   # Or --theirs, --manual
./pv commit "Resolve conflict"
```

## Analytics-Driven Iteration

### The Query Library

```sql
-- Which prompts get used most?
SELECT t.name, COUNT(e.id) as uses
FROM prompt_templates t
JOIN executions e ON e.entity_id = t.id AND e.entity_type = 'template'
WHERE t.status = 'active'
GROUP BY t.name ORDER BY uses DESC;

-- Which prompts need work?
SELECT t.name, AVG(f.rating) as avg_rating, COUNT(f.id) as ratings
FROM prompt_templates t
JOIN executions e ON e.entity_id = t.id
JOIN feedback f ON f.execution_id = e.id
GROUP BY t.name
HAVING avg_rating < 3.5 OR ratings < 3
ORDER BY avg_rating;

-- Improvement trend for a prompt
SELECT DATE(e.created_at) as date, AVG(f.rating) as rating
FROM executions e
JOIN feedback f ON f.execution_id = e.id
WHERE e.entity_id = (SELECT id FROM prompt_templates WHERE name = 'review')
GROUP BY DATE(e.created_at)
ORDER BY date;

-- Latency outliers
SELECT t.name, e.latency_ms, e.input_args
FROM executions e
JOIN prompt_templates t ON t.id = e.entity_id
WHERE e.entity_type = 'template'
  AND e.latency_ms > 5000
ORDER BY e.latency_ms DESC
LIMIT 20;
```

### Dashboard View

```bash
# Daily health check
./pv sql -q "
SELECT
  'Active templates' as metric, COUNT(*) as value FROM prompt_templates WHERE status = 'active'
UNION ALL
SELECT 'Executions today', COUNT(*) FROM executions WHERE DATE(created_at) = CURDATE()
UNION ALL
SELECT 'Avg rating today', ROUND(AVG(rating), 2) FROM feedback WHERE DATE(created_at) = CURDATE()
UNION ALL
SELECT 'Low-rated prompts', COUNT(DISTINCT e.entity_id)
  FROM feedback f JOIN executions e ON f.execution_id = e.id
  WHERE f.rating < 3 AND DATE(f.created_at) = CURDATE()
" -r table
```

### Safe Output-Capture Analytics

```bash
# Aggregate private+public capture coverage without leaking private text
./pv analytics outputs

# Per-template evidence summary plus public previews only
./pv analytics template analysis-router
```

Rules:
- private captures stay aggregated-only in analytics surfaces
- public previews render only for rows explicitly captured as `public`
- export/report surfaces should use `output_capture_mode` + `output_chars`, not raw private `output_text`

### Execution Wrapper

Log every use:

```bash
#!/usr/bin/env bash
# pv-run - Execute with tracking

TEMPLATE="$1"; shift
ARGS="$*"

# Resolve template ID
TID=$(dolt sql -r csv -q "SELECT id FROM prompt_templates WHERE name='$TEMPLATE' AND status='active'")

# Execute and time
START=$(date +%s%3N)
OUTPUT=$(claude --prompt "$(dolt sql -r csv -q "SELECT content FROM prompt_templates WHERE id=$TID")" "$ARGS")
END=$(date +%s%3N)

# Log
dolt sql -q "INSERT INTO executions (entity_type, entity_id, latency_ms, success) VALUES ('template', $TID, $((END-START)), TRUE)"

echo "$OUTPUT"
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Validate Prompts

on:
  push:
    paths: ['prompt-vault/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Dolt
        run: |
          curl -L https://github.com/dolthub/dolt/releases/latest/download/dolt-linux-amd64.tar.gz | tar xz
          sudo mv dolt /usr/local/bin/

      - name: Lint
        run: |
          cd prompt-vault/scripts
          ./pv-lint || exit 1

      - name: Export artifacts
        run: |
          cd prompt-vault/scripts
          ./export-to-pi.sh

      - uses: actions/upload-artifact@v4
        with:
          name: prompts
          path: ~/.pi/agent/prompts
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

cd prompt-vault/prompt-vault-db
if ! dolt diff --quiet 2>/dev/null; then
  echo "Uncommitted vault changes. Run: ./pv commit 'message'"
  exit 1
fi
```

## Migration

### From Pi

```bash
./pv init
./pv import --from ~/.pi/agent/prompts --type template
./pv import --from ~/.pi/agent/skills --type skill
./pv commit "Initial import"
```

### From Any System

Export to JSON, then:

```python
import json, subprocess

with open('prompts.json') as f:
    prompts = json.load(f)

for p in prompts:
    content = p['content'].replace("'", "''")
    desc = p.get('description', '').replace("'", "''")
    subprocess.run([
        'dolt', 'sql', '-q',
        f"INSERT INTO prompt_templates (name, description, content, status) "
        f"VALUES ('{p['name']}', '{desc}', '{content}', 'active')"
    ], cwd='prompt-vault-db')
```

## Best Practices

1. **Branch for experiments** — Never edit main directly for significant changes
2. **Write descriptions** — Your future self needs context
3. **Track executions** — Data enables improvement
4. **Rate after use** — Build the quality signal
5. **Tag releases** — `dolt tag v1.0.0` enables reproducibility
6. **Review before merge** — Use DoltHub PRs
7. **Backup** — Multiple remotes, periodic clones

## Recovery

For stage-gated DB mutation policy, see: `docs/reference/db-stage-backup-policy.md` and run:

```bash
# Low-risk local exact-name row/content edit
./scripts/db-change-preflight.sh --stage db-dev

# Promotion gates beyond db-dev
./scripts/db-change-preflight.sh --stage db-test
./scripts/db-change-preflight.sh --stage db-stage
./scripts/db-change-preflight.sh --stage db-prod --exception-file governance/db-backup-exceptions.md
```

```bash
# Undo last commit
dolt reset --hard HEAD~1

# Restore from history
dolt checkout HEAD~3 -- prompt_templates
dolt sql -q "SELECT * FROM prompt_templates AS OF HEAD~3 WHERE name = 'review'"

# Recover deleted
dolt sql -q "SELECT * FROM prompt_templates AS OF 'main~5'"
```

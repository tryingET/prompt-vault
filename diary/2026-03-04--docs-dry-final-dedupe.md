---
summary: "Final DRY dedupe pass across README/QUICKSTART/CHANGELOG with canonical linking."
read_when:
  - "Reviewing final documentation deduplication decisions"
  - "Tracing why QUICKSTART now links to README for Pi integration details"
date: "2026-03-04"
---

# Diary — Final Docs DRY Dedupe

## What I changed
- Reduced duplicated Pi integration details in [[QUICKSTART.md]] and pointed to canonical section in [[README.md]].
- Kept QUICKSTART minimal with only essential operator commands.
- Compressed overlapping changelog bullets into a single normalized docs-update entry linking:
  - [[README.md]]
  - [[QUICKSTART.md]]
  - [[docs/reference/fuzzy-selector-troubleshooting.md]]

## Validation
- Ran strict docs metadata check:
  - `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`
  - Result: pass

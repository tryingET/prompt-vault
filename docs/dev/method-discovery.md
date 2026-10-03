---
summary: "Read-only cross-client reuse discovery for templates, Vault skill snapshots and source skill packages."
read_when:
  - "Selecting an existing method or considering a new reusable skill."
type: "reference"
---

# Method discovery before creation

`./scripts/pv discover "where did we leave off?" --company core` ranks existing
continuity methods instead of assuming an absent skill name means an absent
capability. It queries current template and skill tables, then reads the direct
children of active Pi, Codex, Claude and shared agent skill roots plus their
repo-local counterparts. Backups, plugin caches, sessions and arbitrary recursive
directories are excluded. `--skill-root <dir>` selects explicit roots instead;
`--limit 1..50` bounds output. PyYAML is required for skill metadata.

The JSON reports inventories, custody, hashes, governed facets, visibility and
publication eligibility separately. A stored skill snapshot is not a registered
client skill. Filesystem presence is not proof of authoring ownership, loading or behavior. Runtime
binding, installed admission and accepted outcomes remain unverified here.
Unavailable/archived template candidates remain labelled as such; with an
explicit company, invisible Vault rows are excluded. Without a company, visibility
is explicitly unverified. Current methods must be retrieved and reviewed before
reuse, revision or creation.

Ranking is a deterministic discovery aid, not a suitability decision or ontology
owner. Continuity phrases expand to next-session/handoff/execution-memory terms;
name and description matches outweigh incidental body mentions. New intents
still need current-source inspection. This helper does not mutate the Vault,
install skills, populate snapshots, grant authorization or dispatch a workflow.

---
summary: "Patterns, anti-patterns, and heuristics discovered during development"
read_when:
  - "Understanding design decisions"
  - "Contributing to the project"
  - "Debugging issues"
  - "Before making architectural changes"
---

# Crystallized Learnings

> [← Back to README](../README.md) · [Workflows](WORKFLOWS.md) · [Comparison](COMPARISON.md)

Knowledge extracted from development and review sessions.

## Patterns Discovered

### LLM Tools Alongside Human Commands
- **Pattern:** Same extension provides both `/slash-commands` (human) and `tool_functions` (LLM)
- **Where it works:** AI assistants that need autonomous access to structured data
- **Apply when:** Building tools for both human operators and AI agents
- **Implementation:** Commands transform user input; tools return structured data for LLM reasoning

### Governed Vocabulary over Free Tags
- **Pattern:** Keep prompt semantics in facets plus controlled vocabulary, not free-form tags
- **Why:** Preserves ontological category boundaries and avoids shadow taxonomies
- **Apply when:** Retrieval/orchestration semantics affect selection, validation, or client behavior
- **Implementation:** Contract-backed dimensions with explicit cardinality and semantic category metadata

### Dolt as Application Database
- **Pattern:** Using Dolt (Git-for-data) as the primary storage for versioned content
- **Where it works:** Single-user local use, content that benefits from history/branching
- **Apply when:** You need audit trails, rollback, A/B testing on structured data
- **Avoid when:** High-frequency writes (e.g., per-request logging), multi-tenant SaaS

### Triggers → Vault → Extension Pipeline
- **Pattern:** Three-stage flow: authoring (markdown) → storage (SQL) → consumption (API)
- **Where it works:** Cognitive tools authored as markdown, served to AI assistants
- **Apply when:** Content has multiple consumers, needs versioning, requires query access
- **Benefits:** Authors edit familiar format, storage handles history, consumers get structured access

### JSON Over CSV for Programmatic Consumption
- **Pattern:** Using `dolt sql -r json` instead of `-r csv`
- **Why:** CSV parsing fails on edge cases (commas in content, quoted fields, newlines)
- **Apply when:** Querying Dolt from code that consumes the output
- **Lesson:** "Simple CSV parse" is never simple enough for production data

### Fail-Closed Analytics and Quality Surfaces
- **Pattern:** Analytics/quality commands should reject bad subcommands, reject injected names, and share one escaping/sanitization layer
- **Why:** A green script that silently returns usage or broadens a query is worse than a loud failure
- **Apply when:** CLI surfaces feed operator trust, dashboards, or release decisions
- **Implementation:** shared `pv-lib.sh` helpers for SQL escaping, numeric validation, typed identity, and terminal-safe preview rendering

### Machine-Readable Authority Must Be a Machine File
- **Pattern:** If a surface is called canonical machine-readable state, keep it in a parseable machine file and validate it directly
- **Why:** Markdown fences are explanation, not authority; duplicated live payloads drift fast
- **Apply when:** Promotion ledgers, policy registries, or any repo-local operational state needs both human and machine consumers
- **Implementation:** keep the authoritative JSON/TOML file separate from the explanatory Markdown wrapper and validate paths/ids structurally in CI

### Schema Versioning from Day One
- **Pattern:** `schema_version` table tracking applied migrations
- **Why:** Without it, schema changes become uncoordinated disasters
- **Apply when:** Any database that will evolve over time
- **Implementation:** Version number + description + timestamp, checked on startup

### Escape Early, Escape Often
- **Pattern:** Proper SQL escaping at the boundary, not at storage
- **Why:** `sed "s/'/''/g"` misses backslash-quote sequences, null bytes
- **Apply when:** Any string going into SQL
- **Implementation:** `tr -d '\0' | sed 's/\\/\\\\/g; s/'\''/'\'''\''/g'`

## Anti-Patterns Found

### Naive CSV Parsing
- **What looked right:** `line.split(",")` - simple and fast
- **Why it was wrong:** Breaks on any content containing commas, quotes, newlines
- **The fix:** Use proper JSON output, parse with real JSON parser
- **General lesson:** Text formats without formal grammars are traps

### Error Swallowing
- **What looked right:** `2>/dev/null || true` - keeps scripts running
- **Why it was wrong:** Hides real problems, makes debugging impossible
- **The fix:** Log errors, return meaningful exit codes, fail visibly
- **General lesson:** Silent failures compound into mysterious bugs

### Process Success Without Semantic Success
- **What looked right:** health checks returned `0` and printed help text, so verification looked green
- **Why it was wrong:** a nonexistent or wrong subcommand can pass CI while doing no real validation
- **The fix:** assert contract-bearing output, fail non-zero on unknown commands, and test negative paths explicitly
- **General lesson:** if a health check can pass against the wrong behavior, it is not a health check

### Markdown Fences as Operational Authority
- **What looked right:** a Markdown doc with fenced JSON looked structured enough to act as canonical state
- **Why it was wrong:** machines cannot reliably consume prose wrappers, duplicated examples drift, and wildcard evidence hints are not bindings
- **The fix:** move the live state into a parseable authority file and make Markdown explain the contract instead of duplicating the payload
- **General lesson:** if you need automation, make the authority artifact directly parseable

### Hardcoded Paths
- **What looked right:** `VAULT_DIR = "/home/user/..."` - works on my machine
- **Why it was wrong:** Breaks on any other machine, blocks testing
- **The fix:** Environment variables with sensible defaults
- **General lesson:** Configurability belongs in the interface, not the implementation

### Execution Tracking Without Output
- **What looked right:** Log that something ran, privacy preserved
- **Why it was wrong:** Can't evaluate quality without seeing what was produced
- **The fix:** Optional output capture, explicit privacy controls
- **General lesson:** Measurement requires the thing being measured

## Surprises

### Test Data Too Tame
- **Expectation:** Tests with simple content would catch parsing bugs
- **What happened:** Edge cases (commas, unicode, backslash-quote) slipped through
- **Lesson:** Test data must include adversarial cases: special characters, unicode, long strings, null bytes

### Dolt Commit Errors Are Common
- **Expectation:** `dolt commit` either succeeds or fails
- **What happened:** "Nothing to commit" exits with error, breaking scripts
- **Lesson:** `2>/dev/null || true` pattern needed for expected non-error failures

### CSV Output Truncation
- **Expectation:** `dolt sql -r csv` returns complete data
- **What happened:** Large content can hit buffer limits
- **Lesson:** JSON output is more reliable, or stream results

## Heuristics Validated

### "If you can't describe the rollback, you haven't designed the change"
- **Evidence:** This project has clear rollback (Dolt reset), which enabled confident changes
- **Application:** Before any migration, document the reverse operation

### "Duplication is cheaper than wrong abstraction"
- **Evidence:** Two clients (bash CLI, TypeScript extension) with duplicated query logic
- **Decision:** Wait for third client before abstracting to HTTP API
- **Reasoning:** The abstraction would add complexity now for uncertain future benefit

### "Test what can fail, not what must succeed"
- **Evidence:** Happy path tests pass trivially; edge case tests found real bugs
- **Application:** Focus tests on parsing, escaping, boundaries, error paths

## Caveats

### What Doesn't Generalize

| Finding | Why It's Specific |
|---------|-------------------|
| Dolt as database | Requires single-user model; multi-tenant needs different approach |
| Output capture policy needs explicit defaults | Privacy-sensitive use cases should stay opt-in/private by default even when telemetry expands |
| Local-only | Remote collaboration needs DoltHub or similar |

### When Patterns Break

| Pattern | Breaking Condition |
|---------|-------------------|
| Triggers → Vault → Extension | If triggers need real-time sync, file-based is too slow |
| JSON output | If streaming multi-GB results, need different approach |
| Bash scripts | If Windows support needed, rewrite in portable language |

## Codification Actions

### Completed
- [x] Add schema_version table
- [x] Fix CSV parsing (switch to JSON)
- [x] Fix SQL escaping (handle backslashes)
- [x] Add adversarial test cases
- [x] Add cleanup command for old executions
- [x] Add LLM tools for autonomous vault access
- [x] Tag all templates with vocabulary
- [x] Add vocabulary command to CLI

### Pending

See [docs/dev/status.md](dev/status.md) and [next_session_prompt.md](../next_session_prompt.md) for current work items and handoff state.

## For Contributors

When adding new features:

1. **Test with adversarial data** - Include commas, quotes, unicode, long strings
2. **Document the rollback** - How do users undo your change?
3. **Check schema version** - Will this work with existing databases?
4. **Consider the extension** - Does bash CLI change need TypeScript update?
5. **Add to this file** - What did you learn that others should know?

---
summary: "Task 5557: canonical commit procedures now require real gate exits, fresh creation binding and exact files; selected local exports verified."
read_when:
  - "Investigating commit attribution, gate-status truth, or the September 8 commit-procedure release."
  - "Checking which canonical commit prompt versions and local exports were hardened."
---

# Commit-procedure hardening — task 5557

## Authority and scope

The operator requested a durable fix after workstation commit orchestration
continued after an index-lock failure, annotated the unchanged foreign HEAD,
and claimed a full gate from a status-masking output pipeline. The erroneous
note was removed; no prior note was lost. Foreign staged changes were not swept.
Coordinator: task:5555; provider guards: task:5556; scoped publisher: task:5561.
FCOS item: `commit-provenance-fail-closed-20260908` (coordination, not authority).

The operator explicitly approved a local-operator exact-template publishing path
across the two existing owners, preserving every unrelated prompt. No
active-company Vault mutation guard was bypassed; no owner or company environment
was reassigned. The native owner CLI performed the approved content updates.
Prompt bodies remain exclusively canonical in the DB, not checked-in Markdown.

## Published state

Dolt commit: `afmo87co6equhr8blmrhi85rqti2eupb`, on the pre-existing
`sf7-iw8-adaptive-portfolio-4163` branch (no branch switch or push).

| Template | Owner | Version | Canonical content SHA-256 |
|---|---|---|---|
| commit | core | 5 → 6 | `6fee5e0f18a57e010fbb8238d379817ef57c2abd0b552fcfeb6305f8d609c44f` |
| commit-terse | holding | 1 → 2 | `ee1996653821ac8b675d2353b8dbce5ef922b43eee7185d29d09babb32fbfb0f` |

Both remain active/export-enabled bounded one-shot procedures. Content frontmatter
(including model and description) was preserved byte-for-byte. Complete row
comparison proved all fields except content, version, updated_at unchanged.
Dolt diff showed only those two modified template rows and their two new changelog
entries before commit; canonical DB status was clean afterward.

Selected installed files: `~/.pi/agent/prompts/commit.md` and `commit-terse.md`.
Independent receipts: `.prompt-vault-scoped-commit.json` and
`.prompt-vault-scoped-commit-terse.json`. `pv scoped check --name commit --name
commit-terse` passed with `scoped_fresh=true` and `global_freshness=not_checked`.

## Future behavior

- Failed commit commands stop all dependent effects; no HEAD-derived success.
- Each commit attempt uses a fresh 64-hex creation marker scoped to that one Git
  invocation. The shared helper resolves the exact worktree creation record.
- Exact file verification is mandatory; no raw note fallback or weaker mode.
- Explicit path commits leave foreign staging untouched; no lock deletion,
  process killing, blanket staging, or human-override flags.
- Gate examples return the observed failing exit after printing logs. A failed
  FAST_GATE cannot fabricate a FULL_GATE result; unrun full gates remain pending.
- `commit` retains bounded safe repair; `commit-terse` retains fail-fast behavior.
- Provenance remains non-authoritative metadata, not AK/KES evidence authority.

Provider implementation: agent-scripts Git commit
`839ac9317b27f082ec5c5f5b494e82434d54fb84`; 177 tests and full CI verification
passed. Marker correlation is caller-owned local evidence, not tamper-proof
attestation. Fresh-token discipline and observed commit success are still required.

## Validation and review

- Scoped update plans and source guards passed before each actual mutation.
- The new publisher passed 161 isolated Bats cases, including 24 scoped Python
  regressions, and the 56-check quick gate. Tests never touched canonical DB/home.
- Independent executable review caught and corrected two draft issues: gate
  examples that returned the formatter's success, and labeling an unexecuted full
  gate as failed after FAST_GATE failure. Corrected examples return 7 for `exit 7`
  and 1 for `false | true`; appended dependent commands never execute. Success
  controls return 0 and continue.
- After publication, the installed Pi default prompt loader and expander were
  invoked read-only. Each name resolved once; Bash example variables remained
  literal, `$ARGUMENTS` expanded, and the same failure/success controls passed.
  This is fresh-loader proof, not proof an already-running TUI reloaded its cache.
- Native lint for both templates: exit 0, no errors, two existing-style warnings
  (TODO-marker heuristic and frontmatter name). `pv vars validate` warned about
  Bash example variables; installed Pi's actual parser proved these remain literal
  rather than being consumed as template placeholders.
- Full installed prompt/skill before/after SHA-256 and inode/mode/mtime inventories
  matched outside the exact four admitted output files. Unrelated `inversion.md`,
  managed manifests, and global export receipt were unchanged. The global receipt's
  prior fixture-source provenance and unrelated inversion drift are not repaired
  or reported fresh by this scoped publication.

## Operator follow-through

Run `/reload` once in existing Pi sessions before using `/commit` or
`/commit-terse`; new sessions load the updated files. No DNS/runtime restart is
needed. Future changes can use the owner-declared scoped CLI documented in
[the projection boundary](../docs/dev/pi-export-projection-boundary.md), avoiding
broad exporter side effects. Active-session compliance with the procedure is not
mechanically guaranteed by prompt text; the shared helper supplies target/file
checks, not a universal execution sandbox.

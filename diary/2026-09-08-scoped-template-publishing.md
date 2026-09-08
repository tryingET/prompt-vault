---
summary: "Task 5561: scoped publisher passes 161 isolated tests; parent applies exactly commit and commit-terse with unrelated projections preserved."
read_when:
  - "Reviewing task 5561 implementation or applying commit/commit-terse locally"
  - "Recovering a scoped publication without broad export or a second version increment"
---

# Scoped template publishing — task 5561

## Authority and execution boundary

Claimed AK task 5561 and narrowed its scope to the ten implementation, test and
documentation paths below. The operator explicitly authorized the local
lifecycle across the core/holding owners; this is not permission to relax the
active-company client guard. Implementation/testing used no Vault client tools,
owner reassignment, PI_COMPANY override, canonical DB mutation, installed Pi export,
package installation, or commit. Parent review and exact-two live application
subsequently passed (see final verification below). The foreign untracked
`transcendent-iteration-external.md` was left untouched.

## Implementation

- `scripts/pv`: two-line command/help registration only.
- `scripts/pv-scoped`: native CLI delegation through pv-lib environment setup.
- `scripts/pv_scoped.py`: explicit plan/apply/check orchestration and recovery.
- `scripts/pv_scoped_db.py`: owner preflight, existing library vault/query
  guards, full-row optimistic CAS and transactional changelog; no DB retries.
- `scripts/pv_scoped_projection.py`: shared raw policy, selected-file admission,
  checked individual atomic writes and independent per-template receipts.
- `tests/pv-scoped-publishing.bats`: isolated existing-copy fixture harness and
  canonical CLI registration checks.
- `tests/test_scoped_publishing.py`: 21 real-Dolt/adversarial cases.
- `docs/dev/pi-export-projection-boundary.md`: flags, receipt/failure contract,
  operator examples and concurrency/validation limits.
- `README.md`: scoped lifecycle entrypoint.
- This diary file.

Update requires an exact existing name, expected owner/version/source hash and
whole new content file. Only active published text-safe bounded one_shots are
supported. The applied content/version/updated_at and changelog are the only DB
changes. Unchanged update is a no-op. Separate scoped receipts preserve global
receipt provenance, manifests, unrelated prompts (including inversion drift),
symlinks and skills. The global freshness checker is unchanged and must not be
reported healthy on scoped evidence.

## Validation evidence

All execution used a scratch checkout under
`$TMPDIR/pv-scoped-validation.Yxgeai`, with a copied fixture DB and isolated
HOME, TMPDIR, prompt and skill directories. No tests were run against the real
installed projection roots. Dolt version: **2.3.1**.

| Command/check | Observed exit/result |
|---|---|
| `./scripts/pv-bats --show-output-of-passing-tests tests/pv-scoped-publishing.bats` | **0**; 2 Bats cases, containing 21 passing Python cases |
| `./scripts/pv-bats tests/pv-export-projection.bats` | **0**; 6 existing regression cases |
| `./verify.sh` with exported VAULT_DIR | **1**; 53 pass, 3 existing relative-path failures |
| `env -u VAULT_DIR ./verify.sh` in the same validated isolated checkout | **0**; 56 pass, 0 fail |
| Bash syntax, Python AST syntax, `git diff --check` | **0** each |
| canonical docs-list `--docs . --strict` | **1**; sole issue: foreign `transcendent-iteration-external.md` missing frontmatter/read_when |

The quick gate assigns relative `VAULT_DIR=./prompt-vault-db`. When that
variable was exported on entry, tag/quality/analytics inherited it after the
parent command changed cwd and failed on a second relative resolution.
Each failed command separately passed with an absolute fixture VAULT_DIR.
Removing the inherited variable **only inside the scratch checkout** let the
unmodified quick gate use its normal default fixture location and pass. This
is not evidence of a repaired verify script. Full `PV_VERIFY_FULL=1` Bats was
not run; no dependency was installed.

Fixture tests prove successful/zero-row CAS and rollback of content mutation
when changelog insertion fails. Three injected failure positions after DB
success prove known-partial reporting and exact export-only recovery with no
additional version/changelog increment. Tests also cover ambiguous DB rows,
metadata/content concurrency, large quoted UTF-8 content, stale target bytes,
unsafe names/symlinks/hardlinks/unmanaged collisions, pending first install,
policy refusal, scoped provenance and preservation of unrelated receipt bytes.

## Parent handoff and remaining limits

Use the exact commands in
[the owner contract](../docs/dev/pi-export-projection-boundary.md#exact-template-local-operator-lifecycle):
plan current commit/commit-terse exports to inspect owner/version/source hash;
plan then explicitly apply **commit first, commit-terse second** with separate
whole-content temporary files; finally check both scoped receipts. No broad
export is needed or authorized by this implementation.

Exit 3 is known-partial and includes a source/target-bound `pv scoped export`
recovery command. Never repeat an effect-indeterminate DB update. Scoped
publishers cooperate via advisory directory locks; arbitrary editors, legacy
exporters and other DB clients do not. Individual writes are atomic, not the
DB/files/receipts together. Global freshness and Pi hot reload are not proven.

## Independent-review blocker fix: cleanup must not replace outcome

Changed only `scripts/pv_scoped.py`, `scripts/pv_scoped_projection.py`,
`tests/test_scoped_publishing.py`, the projection-boundary doc and this diary.
`Directory.close()` now attempts every owned staging cleanup, records I/O
failures by path, and closes the directory FD in `finally`. Cleanup diagnostics
are returned separately rather than raised over the primary result.

`CLEANUP-INCOMPLETE` on stderr preserves the operation's exit classification:
known-partial acknowledged DB success remains **3**, indeterminate DB failure
remains **1**, and successful publication remains **0 with an explicit cleanup
warning**. The warning does not assert cleanup success or authorize repeating
a DB update. Scoped publication and scratch cleanup are separate facts.

Focused isolated rerun:
`./scripts/pv-bats --show-output-of-passing-tests tests/pv-scoped-publishing.bats`
returned **0** (2 Bats cases containing **24 passing Python cases**). Three new
regressions cover combined publication+cleanup EROFS after a real fixture DB
update, successful publication with injected staging residue, and preservation
of an indeterminate DB error during cleanup failure. The combined regression
checks every cleanup attempt, proves the FD closed via EBADF, checks residue
paths in diagnostics, and verifies export-only recovery without another version
increment. Log: `$TMPDIR/pv-scoped-validation.Yxgeai/cleanup-regression.log`.
No live DB/home mutation or commit; full verification was not rerun for this
bounded blocker fix. EROFS was injected, not induced on a live filesystem.

## Final verification and first operator publication

- Fresh current-source snapshot at
  `$TMPDIR/pv-scoped-final.9hku40/repo`, run through its `run-isolated.sh`:
  read-only host mounts, writable fixture root only, isolated network/PIDs,
  clean HOME/TMPDIR/XDG and export directories, VAULT_DIR intentionally unset.
- `./verify.sh`: actual exit **0**, 56 checks.
- `./scripts/pv-bats --show-output-of-passing-tests tests/`: actual exit **0**,
  **161 passed, 0 skipped**, including 24 scoped Python regressions. Source and
  snapshot hashes matched for 226 files before/after. One non-failing
  BrokenPipeError diagnostic occurred in signal-forwarding coverage.
- Independent reviewer reproduced the corrected known-partial cleanup result
  and found no remaining scoped-publisher blocker.
- Parent applied only `commit` v5→v6 and `commit-terse` v1→v2 through
  `pv scoped update`, with expected owners core/holding, versions and source
  hashes. Both final scoped freshness checks passed. Full-row comparison proved
  all non-content metadata preserved. Only content/version/updated_at and two
  changelog rows changed in the canonical DB.
- Before/after SHA-256 and file-identity inventories of the installed prompt and
  skill trees matched after excluding only the two selected `.md` files and
  their two new scoped receipts. Inversion, global manifests and global receipt
  were unchanged. Global freshness remains deliberately unclaimed.
- Template mutation/projection and actual Pi parser checks are recorded in
  [task 5557's diary](2026-09-08-commit-procedure-hardening.md).

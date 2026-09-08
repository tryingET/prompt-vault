---
summary: "Clarifies pi_export_enabled/export_to_pi as projection eligibility, and defines local Pi prompt export freshness receipts."
read_when:
  - "Changing export-to-pi behavior"
  - "Investigating why a Prompt Vault template update is not visible in Pi prompts"
  - "Designing automatic Prompt Vault to Pi projection refreshes"
system4d:
  container: "Prompt Vault DB truth, local Pi prompt projections, and export freshness receipts."
  compass: "Keep canonical DB truth separate from machine-local projection state while making stale projections detectable."
  engine: "Select active export-enabled rows -> classify raw-file eligibility -> export text-safe rows / quarantine gated rows -> write receipt -> verify files and absence before claiming Pi is current."
  fog: "The name export_to_pi can be misread as completed export instead of projection eligibility."
---

# Pi Export Projection Boundary

## Purpose

This note clarifies the boundary between:

- Prompt Vault DB truth
- the `export_to_pi` column
- local files under `~/.pi/agent/prompts`
- projection freshness checks

## Naming truth

The schema column is currently named:

```text
export_to_pi
```

Its actual meaning is:

```text
pi_export_enabled
```

That is, the template is eligible to be written by the next Pi export projection. It does **not** mean the current machine's Pi prompt files have already been refreshed.

Keep the physical column as `export_to_pi` for schema-v9/client compatibility until a governed schema migration renames or aliases it. In docs and operator explanations, call it:

```text
Pi export enabled
```

or:

```text
pi_export_enabled semantics
```

## Projection lifecycle

The truthful lifecycle is:

```text
Prompt Vault row changes
  -> row is active and export_to_pi=true
  -> raw projection policy classifies it
  -> text-safe row is materialized OR gated/unknown/unbound row is quarantined
  -> export writes .prompt-vault-export-state.json receipt
  -> pv-export-freshness verifies exported files and absence of quarantined raw files
```

Do not collapse eligibility and materialization.

## Export receipt

`./scripts/pv export` writes this machine-local receipt next to the prompt projection:

```text
~/.pi/agent/prompts/.prompt-vault-export-state.json
```

The receipt uses schema:

```text
prompt-vault/pi-export-receipt/v2
```

For each exported text-safe template it records name, path, version, and projected-file SHA-256. For each quarantined candidate it records name, version, source-content SHA-256, facets, and one reason: `malformed`, `unknown`, `unbound`, or `gated`.

The receipt also records candidate/exported/quarantined counts and policy `prompt-vault/raw-pi-projection-policy/v1`. Exported-file hashes use exactly one trailing newline; quarantine content hashes cover the unprojected source bytes.

`export_to_pi=true` is candidacy, not permission to bypass runtime dispatch. Loop templates are `unbound` at this owner layer because execution bindings are downstream runtime facts; workflow templates are `gated`. Neither is emitted as a raw `.md` prompt.

## Freshness check

Use:

```bash
./scripts/pv-export-freshness
```

Fresh means:

- every active export-enabled candidate has exactly one receipt disposition
- every text-safe candidate has one matching local `<name>.md` file
- every gated/unknown/unbound/malformed candidate has no raw prompt file
- exported and quarantine hashes/facets/reasons match DB truth
- receipt counts and policy match the recomputed inventory
- the receipt has no missing, duplicate, or extra entries

If stale, the checker fails closed and prints:

```text
Run: ./scripts/pv export
```

## Automation policy

Do not treat every DB write as permission to mutate a local Pi prompt directory. The local Pi projection is a machine-local cache, while Prompt Vault DB truth is canonical/shareable.

Safe automation should use one of these policies:

1. Explicit projection:
   ```bash
   ./scripts/pv export
   ./scripts/pv-export-freshness
   ```
2. Local operator auto-export for `pv` template lifecycle commands that affect an active export-enabled template.
3. Fail-closed freshness gates before claiming a running Pi surface is current.

Current `pv` local operator behavior:

- `pv edit-template <name>` auto-exports after changing an active export-enabled template.
- `pv activate template <name>` auto-exports when the activated template is export-enabled.
- `pv publish <name>` auto-exports when the template is active.
- `pv unpublish <name>` auto-exports when removing an active template from the local projection.
- `pv deprecate template <name>` auto-exports when removing an active export-enabled template from the local projection.
- `pv rollback template <name> <commit-ref>` auto-exports when the rolled-back template is active and export-enabled.

Set `PV_AUTO_EXPORT=0` to disable auto-export. In that mode, the same lifecycle command fails closed if the local projection is stale and tells the operator to run:

```bash
./scripts/pv export
```

Direct SQL, Dolt-level migrations, governed external clients, and headless/CI paths should still run an explicit projection or freshness check; they must not assume a DB write rewrote the user's local Pi prompt directory.

## Relation to execution binding

This projection receipt solves a different problem than runtime orchestration.

Projection freshness answers:

```text
Does every active export-enabled row have the correct raw-export or quarantine disposition, and does local Pi state match it?
```

Execution binding answers:

```text
Which runtime executor should run this template when the operator asks to execute it?
```

Do not overload `export_to_pi`, `formalization_level`, or `control_mode` to answer both questions.

## Programmatic projection freshness

`pi-vault-client` now exposes a programmatic projection freshness check in `src/dispatchPosture.ts`:

- `checkProjectionFreshness(template)` compares the DB content SHA-256 digest to the local `~/.pi/agent/prompts/<name>.md` file digest.
- Returns one of: `fresh`, `stale`, `not_exported`, `no_local_file`, `error`.
- The `vault_schema_diagnostics` tool now includes projection freshness results in its output.

This is a complementary check to `./scripts/pv-export-freshness`, operating from the Pi runtime side rather than the Prompt Vault CLI side. Both should agree when the local projection is current.

## Exact-template local operator lifecycle

`pv scoped` is an additive, noninteractive **local operator** surface. It does
not use or relax `vault_update`'s active-company guard, change `PI_COMPANY`, or
reassign row owners. Explicit lifecycle authorization from the local operator
is required, including each owner when selecting across owners. It is not a
new autonomous cross-company client tool. Prompt bodies remain DB-only canon;
input files and installed projections are temporary/derived, not repo sources.

This bounded version supports only existing, active, Pi-export-enabled,
text-safe `one_shot` + `bounded` templates. It reuses
`scripts/pv-export-policy.py` and refuses gated, unbound, malformed, unknown,
router, other formalization, unpublished and inactive selections. No delete,
unpublish, skill publishing, or broad-export fallback is provided.

### Plan, apply, check

All names are exact, case-sensitive, safe flat identifiers (maximum 64
characters; no traversal or `..`). Export/check accept repeated `--name`;
update accepts exactly one. Unknown/missing/ambiguous names and duplicate
selections fail closed. The target directory must already exist with no
symlink ancestors. Always explicitly bind the intended vault and prompt root:

```bash
export VAULT_DIR="$PWD/prompt-vault-db"
export TEMPLATES_DIR="$HOME/.pi/agent/prompts"

# Read-only plans: expose current versions, owners and source-content hashes.
./scripts/pv scoped export --name commit --name commit-terse --dry-run

# Use the observed OLD version/owner/source hash, never guessed values.
# Caller supplies the entire NEW UTF-8 content, including its frontmatter.
./scripts/pv scoped update --name commit \
  --expected-owner core --expected-version "$COMMIT_VERSION" \
  --expected-content-sha256 "$COMMIT_SOURCE_SHA256" \
  --content-file "$COMMIT_CONTENT_FILE" --dry-run

# After reviewing the same command/inputs, replace --dry-run with --apply.
# Then do commit-terse separately, with its own observed version/hash:
./scripts/pv scoped update --name commit-terse \
  --expected-owner holding --expected-version "$TERSE_VERSION" \
  --expected-content-sha256 "$TERSE_SOURCE_SHA256" \
  --content-file "$TERSE_CONTENT_FILE" --dry-run

# After both explicit applies:
./scripts/pv scoped check --name commit --name commit-terse
```

Omitting both mode flags also means plan; they are mutually exclusive.
Dry-run does not write DB or live projections/receipts. An unchanged content
update is a true no-op, including version, changelog and projection: it does
**not** claim scoped freshness. Use export/check if only projection is needed.
`PV_AUTO_EXPORT` is irrelevant to this surface; no legacy auto-export runs.

Update requires expected owner, version **and** SHA-256 over exact old UTF-8
source bytes (including trailing newlines). It rechecks every row field in a
Dolt transaction, including nullable metadata and governance that other
lifecycle operations can change without incrementing version. A successful
change affects only content, version, updated_at and one changelog row.
Description, frontmatter outside the supplied content, ontology, variables,
visibility, status and export eligibility are not inferred or rewritten.
Frontmatter *inside* content changes only as supplied in the whole input file.
NUL bytes, non-UTF-8 and content exceeding the SQL TEXT byte limit are refused.
The existing `scripts/db-change-preflight.sh --stage db-dev` runs automatically
before an actual content write. Because that preflight uses a cwd-relative
identity, the helper presents the selected initialized Dolt directory through
a scratch `prompt-vault-db` symlink, not the repo's possibly different DB.

### File ownership and scoped provenance

Each selected template has an independent local receipt:

```text
.prompt-vault-scoped-<name>.json
schema: prompt-vault/pi-scoped-template-receipt/v1
```

The parseable JSON records `state` (`pending`/`complete`), policy identifier,
source vault absolute path + template id, target directory, exact name/path,
version, source hash, projected hash and policy facets. A pending receipt also
records `previous_sha256` for checked recovery. No body is stored in receipts.
There is intentionally no new DB schema or machine-wide receipt migration.

The global `.prompt-vault-export-state.json`, both managed manifests, every
unrelated receipt/file/symlink and all skills remain **byte-identical**. A
fixture-origin global receipt is never relabeled as canonical. Initial
adoption of an existing file requires exactly one selected entry in the
managed manifest and full v2 receipt, with its recorded hash matching the
installed file. This establishes prior file ownership, **not** current DB
freshness or source provenance. Subsequent scoped receipts must bind the same
vault, row and target. An absent target can be newly projected; an existing
unmanaged collision cannot be adopted. Missing previously scoped files
require inspection rather than silent recreation, except a pending first
installation whose prior target was absent.

Selected target symlinks, hardlinks, nonregular files, foreign-uid files,
unsafe directories, malformed ownership receipts and stale target bytes are
refused before DB mutation. Unrelated symlinks are never traversed or changed.
A pending receipt must be recovered with export before another content update.
No command deletes an unrelated or formerly published file. Scoped ownership
is recorded only in the selected receipt, without appending shared manifests.

`pv scoped check` compares only named rows, files and **complete scoped**
receipts. Success says `global_freshness: not_checked`, never globally healthy.
The existing global checker is unchanged and may (in the known fixture-receipt
case, does) remain stale. Do **not** follow its broad-export recovery suggestion
when unrelated drift must be preserved. Scoped commands cannot repair global
provenance, and this feature does not establish Pi hot-reload behavior.

### Failure and recovery contract

All selected data/receipts are staged and checked before DB mutation or first
publication. Each live replacement is an individually checked atomic rename
with file/directory fsync; there is **no multi-resource atomicity** across DB,
files, receipts or multiple selected templates. Replacement files use mode
0600. Directory-descriptor/no-follow traversal prevents symlink redirection;
an advisory directory lock serializes these scoped publishers. Legacy exports,
other clients and arbitrary editors do not honor that lock: do not run them
concurrently. Snapshots are rechecked immediately before writes and after
publication, but there is no kernel CAS rename against an uncooperative writer,
nor a DB lock spanning filesystem publication. This is a local operator
lifecycle, not an adversarial multi-writer filesystem transaction.

Exit statuses: 0 successful plan/no-op/scoped publication/check; 2 invalid CLI;
1 refusal/read error or explicitly **effect-indeterminate** DB failure;
3 **KNOWN-PARTIAL** acknowledged DB success or interrupted publication.
A rejected SQL CAS makes no content/version/changelog change. Update and
changelog share one transaction; installed Dolt 2.3.1 fixture tests exercise
successful CAS, zero-row CAS, and rollback on changelog failure. No DB operation
is automatically retried. On indeterminate DB failure, inspect the exact row
and changelog before deciding anything; never repeat the update mechanically.

After known DB success with failed projection, stderr prints the exact bound
export-only recovery command. For example:

```bash
# Keep the same explicitly bound VAULT_DIR and TEMPLATES_DIR.
./scripts/pv scoped export --name commit --dry-run
./scripts/pv scoped export --name commit --apply
./scripts/pv scoped check --name commit --name commit-terse
```

Export-only recovery never increments a version or writes the DB. The pending
receipt accepts only the previously recorded bytes or the exact staged new
bytes; it is never fresh by itself. External drift or changed pending DB
identity fails closed and needs operator inspection, not a force flag. A
process kill may leave selected `.pv-scoped-*.stage` scratch files; no generic
cleanup/delete authority is granted. Normal failure paths remove their own
staging files only. Cleanup attempts every owned staging file and always attempts
to close the directory FD, even when unlink fails. Cleanup I/O failures emit a
separate `CLEANUP-INCOMPLETE` stderr diagnostic naming staging residue or FD-close
errors; they never replace the primary result or its exception. Thus known-partial
remains exit 3, an indeterminate DB error remains exit 1, and a successful operation
remains exit 0 **with a cleanup warning**, not a claim that cleanup succeeded.
Do not repeat DB work to resolve cleanup residue; inspect the named scratch files
separately. A cleanup warning does not revoke verified scoped publication.

### Isolated validation

Run `./scripts/pv-bats tests/pv-scoped-publishing.bats` in an isolated checkout.
The dedicated fixture harness copies a vault and validates that HOME, TMPDIR,
VAULT_DIR, TEMPLATES_DIR and SKILLS_DIR all stay under its scratch root. Tests
cover cross-owner local authorization without changing PI_COMPANY, exact-two
preservation (including installed inversion drift and fixture provenance),
SQL metadata/content CAS, transactional changelog, no-op/plan, policy refusal,
unsafe paths/collisions, scoped freshness, and injected known-partial recovery.

**Do not rely on environment overrides alone for `./verify.sh`:** it assigns
`VAULT_DIR=./prompt-vault-db`, and shared Bats setup also binds the checkout's
DB. Use a scratch checkout with a fixture DB at that relative path plus
isolated HOME/TMPDIR/TEMPLATES_DIR/SKILLS_DIR. The current quick gate also
inherits an existing relative-VAULT_DIR child-process bug when VAULT_DIR was
exported: tag/quality/analytics can fail after a second directory change. In
that **isolated checkout only**, `env -u VAULT_DIR ./verify.sh` exercises the
normal default vault path, which must first be validated as the fixture DB.
Never run fixture exports against the installed Pi directories. No package installation is required by this work.

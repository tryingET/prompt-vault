---
summary: "Exact source-owned skill snapshots in Dolt: curated plans, guarded imports, full bundle projections, and the separate backup-gated live adoption."
read_when:
  - "Importing or inspecting skill snapshots in Prompt Vault"
  - "Checking original skill ownership, assets, or bundle round-trip evidence"
type: "reference"
---

# Source-owned skill snapshots

## Authority and scope

The operator selected **versioned Vault snapshots**, not relocation of skill
source ownership. Original packages remain authoring owners. `skills.metadata`
records source owner/root/frontmatter, file identities and bundle digest under
`prompt-vault/skill-snapshot/v1`; SKILL.md stays byte-exact in `skills.readme`,
with resources in `skill_assets`. No schema migration or executor binding is added.
`source_root` identifies the sampled package, which may be an installed copy;
it is not proof of an upstream repository revision or canonical authoring location.
Original frontmatter claims are retained as source data, not independently accepted
skill-verification or release evidence.

`owner_company` governs snapshot custody/visibility, not an invented transfer
of the original author's ownership. The local operator CLI is not a new autonomous
cross-company client tool. Snapshot status `active` means available stored content,
not demonstrated skill effectiveness or installed-runtime adoption.

The initial [machine catalogue](../../.pi/skill-snapshot-catalogue.json) selects:
- prompt-vault-operator (repo-owned);
- ai-society-core-repo-router;
- softwareco-owned-repo-router;
- softwareco-infra-repo-router;
- agent-skill-engineer, including its public helpers/assets.

Third-party/synced packages are not selected. ASE auditing found private evaluator
material in refactorops, package-local versus external-reference ambiguity in
runtime-recipes, and deliberate malformed/nested fixtures in pi-session-jsonl.
They are excluded pending source-owner adjudication, not silently rewritten or
stripped. Cache directories/compiled Python files are omitted and disclosed in
snapshot metadata; evaluator directories, hidden resources, resource symlinks,
hardlinks, special files/modes, and recognizable credential signatures fail closed.
These guards and static audits are not universal declassification or secret detection.

## Plan, import and inspect

Requirements: existing Dolt/jq/Python tooling and installed PyYAML for real YAML
metadata parsing (including folded descriptions/BOM); duplicate keys and YAML
aliases are refused. JSON resources are parsed for evaluator-only keys rather
than scraped. No command installs packages.
Use an explicit vault, catalogue and source root. Root symlink aliases resolve to
an exact original package; resource symlinks do not. The catalogue binds each
source, original owner, custody company and allowed visibility.

```bash
export VAULT_DIR="$PWD/prompt-vault-db"
CATALOGUE="$PWD/.pi/skill-snapshot-catalogue.json"
PLAN="$TMPDIR/approved-skill-plan.json"  # fresh path; no implicit overwrite
./scripts/pv skill-bundle plan --catalogue "$CATALOGUE" \
  --agent-root "$HOME/.pi/agent/skills" --out "$PLAN"
./scripts/pv skill-bundle import --catalogue "$CATALOGUE" \
  --agent-root "$HOME/.pi/agent/skills" --plan "$PLAN" --dry-run
# Only after exact-plan review, source-owner authorization and a verified receipt:
PV_BACKUP_ASSURANCE_RECEIPT="$RECEIPT" ./scripts/pv skill-bundle import --catalogue "$CATALOGUE" \
  --agent-root "$HOME/.pi/agent/skills" --plan "$PLAN" --apply
./scripts/pv skill-bundle inspect --name prompt-vault-operator
```

Plan/import default to no DB effects. Plan output includes source/governance
identity, manifest hashes, exact Dolt branch/HEAD and expected current row/asset
state, never private execution outputs. Import re-derives sources and compares
the whole approved plan; source/row/governance/branch/HEAD drift requires new
discovery, not mechanical replay. Transaction admission rechecks branch/HEAD too.

Apply performs one selected-scope transaction after preflight. SQL admission checks
all selected rows **and assets**, including lifecycle/governance fields; refusal
changes none. New rows start at v1; a changed selected bundle increments version and
replaces only that skill's assets. Same snapshot is a true no-op. Unmanaged legacy
rows or a changed original authoring owner cannot be adopted silently. Imports do
not execute code, mutate prompt rows, export, install, or commit automatically.

One exact low-risk skill operation uses `db-dev`; multi-skill scope uses `db-test`
with real local/DS1621/offsite backup quorum. Do not subdivide a bulk adoption to
bypass its stage, invent backup paths, or treat fixture directories as live backups.
Pass a verified backup assurance receipt (`PV_BACKUP_ASSURANCE_RECEIPT` or the
preflight's `--assurance-receipt`); without one the preflight refuses with
`unable_to_verify`. Directory copies, immutable paths, exception notes and
arbitrary JSON cannot grant admission. The operator selected exact captured-state
local/primary and independent offsite recovery, with zero accepted drift at
mutation admission. Follow the [stage/backup policy](../reference/db-stage-backup-policy.md)
and [assurance design](../project/2026-10-03-backup-assurance-design.md).
The transaction guard binds selected rows/assets, branch/HEAD and, for a `db-test`
import, the verified staged and working roots. A refused guard writes nothing.
After an import the vault state differs, so the same receipt never admits again.

After admitted live adoption, record Dolt history for **only skills and skill_assets**
through the owning interface; inspect staging first. Do not run the legacy bulk
importer: it also imports prompts, rewrites company fields and commits the whole
working set. Existing prompt/changelog changes and branch-settlement authority
remain untouched. AK6480 owns backup-gated live population; its pending/deferred
state is not completion. AK6479 owns the isolated tooling/curation proof.

## Full-bundle projection, separate from authoring and runtime

```bash
# TARGET_PARENT must exist; exact-name target must be absent or already byte-fresh
TARGET_PARENT="$TMPDIR/skill-projection"
./scripts/pv skill-bundle export --name prompt-vault-operator \
  --target "$TARGET_PARENT/prompt-vault-operator" --dry-run
# --apply explicitly creates a new owner-only target directory, never overwrites drift
./scripts/pv skill-bundle export --name prompt-vault-operator \
  --target "$TARGET_PARENT/prompt-vault-operator" --apply
./scripts/pv skill-bundle check --name prompt-vault-operator \
  --target "$TARGET_PARENT/prompt-vault-operator"
```

Text and binary bytes round-trip exactly, including CRLF, quotes and Unicode.
Executable intent is normalized to 0755 versus 0644; special mode bits are refused.
The receipt schema is `prompt-vault/skill-projection-receipt/v1`, binding exact vault,
row id/version and bundle hash. New target root is 0700; receipt is 0600. Existing
foreign, partial, symlinked, hardlinked, extra-file or stale targets fail closed.
Nothing cleans or refreshes global prompt/skill manifests, receipts, projections
or original source packages. A fresh isolated directory is a derived bundle, not
proof Pi loaded it or that its external resources/runtime paths work.

Limits: 256 files/eight MiB per bundle, current TEXT limit for SKILL.md and BLOB
limit (65535 bytes) for each binary asset. Catalogue selects at most 32 skills.
No unrestricted recursion across source owners or historical live revision selector.
Dolt history retains earlier committed states; current names remain UNIQUE.

## Failure and proof contract

- Exit0: successful read/plan/no-op/import/projection check.
- Exit1: refused/read error or DB effect-indeterminate failure; inspect exact
  skills/assets before retrying. No automatic DB retry.
- Exit2: argument-parser error.
- Exit3: **KNOWN-PARTIAL** acknowledged import with post-readback drift, or owned
  projection target with incomplete/uncertain bytes. Preserve receipts and inspect;
  no automatic deletion, overwrite, receipt laundering or whole-export fallback.
- FD cleanup faults emit `CLEANUP-INCOMPLETE` without replacing the primary
  effect classification; all owned FD closes are attempted. A warning does not
  mean cleanup succeeded or permission to repeat DB work.

Individual filesystem writes are not globally atomic with SQL. Held no-follow
FDs and exclusive target ownership prevent path-based overwrite; an uncooperative
writer/rename can still cause known-partial state. Source scans/readbacks are
bounded snapshots, not a kernel lock over source packages. A later source edit
invalidates a future plan; it cannot mutate an already stored version's bytes.

[Native regression tests](../../tests/pv-skill-bundles.bats) exercise real Dolt
fixtures through `pv`, negative paths, transactional CAS, no-op/update semantics,
complete binary/executable bundles and known-partial export failures.
The real agent-skill-engineer bundle exposed an installed-Dolt `TO_BASE64`
`*val.TextStorage` panic after acknowledged SQL import. The bounded read/CAS path
now uses native `HEX` byte transport; regression coverage includes out-of-line
LONGTEXT and 50-KiB binary assets. Post-acknowledgment read failures remain
KNOWN-PARTIAL, never a reason to reapply the import. The failed trial/diagnostics
are retained alongside its read/export-only recovery. Run them
with isolated HOME/TMPDIR/Vault/projection roots, then the full repo suite. Fixture
success is not a live import, backup-quorum pass or skill behavioral-benefit claim.

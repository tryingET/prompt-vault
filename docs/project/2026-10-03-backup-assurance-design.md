---
summary: "AK6505: owner-selected exact-state requirement, the 2026-10-06 receipt/recovery-record interface that verifies it, and the earlier path-proxy containment."
read_when:
  - "Implementing or inspecting Prompt Vault backup assurance"
  - "Deciding whether bulk skill adoption can be admitted"
type: reference
---

# Backup assurance: exact-state requirement, accepted interface and containment

## Accepted interface, 2026-10-06

The owner instructed completion on 2026-10-06 (AK6505 evidence14192). The
interface below satisfies the "Required future owner interfaces" table further
down; the sections after it are kept as the record of the containment step.

| Requirement | Implemented by |
|---|---|
| Source identity | `scripts/pv_backup_assurance.py`: live branch, HEAD, staged/working roots, schema version and all table/schema digests, with the workstation's exact serialization |
| Stable capture | Workstation capture manifest (`workstation/dolt-stable-capture/v1`), bound by path and SHA-256 in the receipt |
| Local/primary and offsite recovery | `prompt-vault/recovery-record/v1`, written by the workstation helper's `byteproof`, `probe` and `record` subcommands after a verified restore, stored as AK `backup_recovery_record` evidence by the owning repo |
| Producer verification | `schema/backup-assurance-v1.json` fixes the record schema, owner repos, origins and restore flags; the verifier re-reads AK on every check |
| Exact mutation binding | Preflight prints the verified identity; the skill import transaction adds `DOLT_HASHOF_DB('STAGED')` and `DOLT_HASHOF_DB('WORKING')` to its guard and writes nothing on a mismatch |
| Validity and invalidation | Exact state only: any change to the live roots or table digests invalidates the receipt; time never does |

`db-test` is the only stage the receipt admits. `db-stage` and `db-prod` also need
owner Gates B and C, which the script does not verify.

First live use, 2026-10-06:
- The capture is `AK6495-20261003T0448Z.IPoOSU` (manifest `bf83b78d…`) and the
  snapshot is `723e44a6…`.
- The primary record (AK evidence14197) comes from a fresh restore from
  `/BackupWorkstationRestic/restic-repo`.
- The offsite record (evidence14198) comes from the AK6638 read-back of the
  Hyper Backup archive export.
- The live vault still held exactly the captured state: `bind` verified it, and
  the preflight passed `db-test` and refused `db-stage`. A receipt naming a generic
  validation row (evidence14032) was refused.

Tests: `tests/test_backup_assurance.py` (14 real-Dolt scenarios with a fixture
`ak`), `tests/pv-db-change-preflight.bats` (18) and `tests/test_skill_bundles.py` (26).
No live import followed; AK6480 still owns that decision.


## Decision and implementation boundary

On 2026-10-03 the operator requested Gherkin-style red-green TDD for the interim
repair and selected **exact captured Dolt state, verified local/primary recovery
and independent offsite recovery, with zero accepted state drift at mutation
admission**. The controller interpreted the TDD instruction as authorization for
the described containment and addition of `tests/test_skill_bundles.py` to AK6505;
the native scope readback records that addition. No weaker periodic-recovery or
loss-window profile was selected. No numeric freshness default was invented.

This establishes the consumer requirement and interim behavior, **not an accepted
producer-consumer assurance interface**. Markdown is explanation, not a machine
receipt, live task queue, or evidence authority. No trusted parser, verifier
command, receipt format or positive admission profile is published by this change.
AK6505's full done contract requires those interfaces and positive integration;
containment alone cannot satisfy it.

## Five whys: the path-proxy error

1. Why did preflight admit an unproved bulk operation? It tested only whether
   three filesystem paths existed.
2. Why was that insufficient? Presence proves neither scope, integrity, native
   recovery, exact state, freshness nor independent failure domains.
3. Why did it also produce a false absence interpretation? It assumed mounted
   per-project directories although owner transport is SFTP Restic.
4. Why cannot a successful primary restore simply replace the proxy? Primary
   recovery does not establish independent offsite restoration or operation-bound
   admission.
5. Why not just accept a new JSON `protected` flag? Without an accepted owner
   producer/verifier and effect binding, that would recreate the same proxy with
   a more convincing format.

These are causal findings from source behavior, not reconstructed author intent.

## Implemented containment

The shared [preflight](../../scripts/db-change-preflight.sh) keeps the existing
`db-dev` prerequisite and refuses `db-test`, `db-stage` and `db-prod` with exit1,
`backup assurance unable_to_verify`, and `result: FAIL`. Missing mounts are not
reported as absent backups. Legacy location variables, an immutable path, an
exception note and arbitrary receipt/verifier variables grant no admission.
Missing argument values now produce explicit exit2 errors.

This deliberately removes false-positive compatibility. A genuine protected
operation also remains blocked until its accepted interface exists; the script
cannot currently recognize or certify it. This is not a universal DB-writer
firewall. Do not split bulk scope or downgrade stages to evade the refusal.
An immutable-only exception never waives mandatory local/primary/offsite recovery.

The skill caller selects stage from the whole selected plan. It propagates
preflight refusal before submitting mutation SQL. Existing selected-row/asset
and branch/HEAD CAS, no-op behavior and post-acknowledgment effect classification
are preserved. A genuine all-no-op plan remains effect-free without preflight;
it is not a new admission verdict. No source change was made to the transaction.

## Required future owner interfaces

| Requirement | Owner and acceptance needed |
|---|---|
| Source identity | Prompt Vault: canonical vault, schema, branch/HEAD, staged/working roots and all table/schema fingerprints, including dirty rows |
| Stable capture | Workstation: before/after roots, exact file inventory/hashes, omissions, separate inspection copy and capture receipt |
| Local/primary recovery | Workstation: explicit snapshot/repository identity, supported restore command and effects, exact recovered bytes and native roots/digests |
| Independent offsite recovery | DS1621-admin: supported acquisition from the remote archive, exact task/version, full Restic dependency closure, provenance excluding primary fill-in |
| Producer verification | Source owners: published evidence format and contract revision, reproducible verification, provenance/effect checks and invalidation rules |
| Exact mutation binding | Prompt Vault: supported atomic guard or serialization preventing complete-state drift between evidence check and mutation; current selected-row CAS is insufficient |
| Execution | Operator/native task authority: exact approved mutation scope and separately authorized acquisition/restore; no authorization inferred from an evidence `pass` |

No observation has indefinite validity. A source-state change invalidates exact
state equivalence. Owners must define evidence validity and conflicting/stale
observation handling; elapsed time alone cannot turn propagation into recovery.
A preflight-time root check without an enforceable mutation-boundary guard leaves
a race and must not be advertised as exact-state admission.

## Existing proof, with limits

The workstation's source report records primary snapshot
`723e44a617191cb703bb39c574532aacef16c181210838ac83e6616b7f153727`, restored
bytes, schema13, ten table/schema digests and staged/working roots. Its helper
issues no admission verdict. Capture excludes SQLite retrieval telemetry.
The NAS source report records a selected-share remote run ending
2026-10-02T20:12:29Z, before the fresh capture. That is not fresh propagation or
offsite restoration proof. These are references to prior owner evidence, not
new restores or an indefinite current-source assertion:

- [Workstation primary proof](../../../../softwareco/infra/workstation/docs/project/2026-10-03-prompt-vault-dolt-recovery-proof.md)
- [NAS coverage and interface limits](../../../../softwareco/infra/ds1621-admin/docs/project/2026-10-03-prompt-vault-hyperbackup-coverage.md)

## Executable Given/When/Then checks

[Preflight scenarios](../../tests/pv-db-change-preflight.bats) exercise absent
mounts, empty directories, ordinary files, same-domain aliases, local copies,
immutable/exception proxies, arbitrary assertion files and unsupported overrides.
The wrong-vault/stale/corrupt/drift assertions prove refusal of **all unbound
inputs**; they are not tests of a future producer schema or actual corruption
classification. Separate scenarios preserve `db-dev` compatibility and argument
errors.

[The real skill CLI test](../../tests/test_skill_bundles.py)
`test_given_unbound_copies_when_bulk_import_then_no_dolt_effects` uses isolated
Dolt, HOME, TMPDIR and source packages. It submits two selected skills through
`pv skill-bundle import --apply`, then asserts refusal, zero skill/asset rows and
unchanged native staged/working roots. Local database copies are not relabeled
independent offsite fixtures.

Observed TDD sequence:
- Before production change: preflight suite fails the proxy/refusal scenarios;
  corrected skill test fails because the CLI returns exit0 and imports both rows.
- The first skill test attempt used the wrong root function (`DOLT_HASHOF` instead
  of `DOLT_HASHOF_DB`); it was corrected and rerun before claiming a behavioral red.
- After production change: 14 preflight scenarios and 24 skill tests pass.
- Independent inspection found no containment blocker, while identifying the
  incomplete positive interface and opportunities to strengthen no-effect checks.
  Root/branch/HEAD equivalence now surrounds both refusal invocations. Two added
  scenarios cover whole selected scope with one no-op and effect-free all-no-ops.
- Duplicate-stage downgrade ambiguity received its own failing Given/When/Then
  scenario, followed by an explicit exit2 duplicate-stage refusal.
- Final isolated runs: **15 preflight scenarios, 26 skill tests, 185 full Bats
  scenarios, and 63 verify.sh checks pass**. Earlier full runs had three failures
  because the verification setup exported VAULT_DIR, which verify.sh reassigned
  to a relative path. A controlled reproduction showed that override failing and
  the unset override passing. The final run used repo-default fixture paths with
  isolated HOME/TMPDIR; no production verification-script change was made.
- Actual live preflight dogfood returns db-dev PASS and db-test exit1 with truthful
  unable_to_verify, without native DB commands. A read-only current five-skill
  catalogue plan was produced through pv; no live apply was attempted.

Raw red/green logs are retained in session-owned
`$TMPDIR/pv-assurance-6505.bejFm1/`; durable native evidence must retain outcomes.
No live import, snapshot creation, repeated restore, commit, push, installation,
knowledge promotion or adoption-hold release follows from these tests.

## Remaining falsifiers before positive acceptance

A future accepted interface must independently reject wrong vault, missing Dolt
files, same-size byte corruption, capture-time root drift, current-state drift,
old offsite versions, incomplete Restic dependency closure, primary-assisted
repair of an alleged offsite export, same-domain aliases and unbound native pass
rows. It must preserve genuine owner-backed protection through a positive
producer-consumer integration fixture and enforce state binding at mutation.
Those positive and semantic negative tests cannot be manufactured from booleans
or the current refusal-only implementation.

See the [stage policy](../reference/db-stage-backup-policy.md) for durable consumer
rules. Native task contracts/evidence retain completion authority; this document
neither closes AK6505 nor resolves AK6480's active deferral.

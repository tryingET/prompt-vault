---
summary: "4-stage DB handling and backup quorum policy for Prompt Vault Dolt assets."
read_when:
  - "Planning database mutations or migrations"
  - "Defining db-test/db-stage/db-prod promotion gates"
---

# DB Stage + Backup Policy (Prompt Vault)

## Scope
Applies to all Prompt Vault database mutations (schema/data/migration) for Dolt-backed assets.

## Stage model (4-stage)
1. `db-dev` — local experimentation only.
2. `db-test` — restore validation + integration checks.
3. `db-stage` — production-like rehearsal.
4. `db-prod` — controlled change window only.

## Stage intent

### `db-dev`
Use for low-risk local Prompt Vault edits such as:
- exact-name row/content updates
- single-template metadata corrections
- other Dolt-versioned prompt content changes with clear rollback

Required in `db-dev`:
- database identity verified (`prompt-vault.db` or `prompt-vault-db/.dolt` exists)
- exact target and blast radius understood
- Dolt commit recorded after the change

Backup quorum is **not** required for `db-dev`.
Escalate to `db-test` or beyond for bulk mutations, destructive changes, migration rehearsal, or anything with broader blast radius.

## Promotion gates

### Gate A (required for all stages beyond `db-dev`)
- Database identity verified (`prompt-vault.db` or `prompt-vault-db/.dolt` exists)
- Working tree clean enough for audit (`git status` reviewed)
- Actual recoverability of the exact captured Dolt state is verified locally,
  from primary NAS (DS1621), and from an independent offsite failure domain.
- Branch/HEAD, staged/working roots and complete schema/row fingerprints bind
  that recovery to the admitted mutation. Zero state drift is accepted.
- A selected share, successful job, readable archive, mounted path, local copy,
  or generic evidence `pass` row is not sufficient recovery or admission proof.

The operator selected this exact-state requirement on 2026-10-03. Since
2026-10-06 the shared preflight verifies it through a **backup assurance receipt**
(contract: [`schema/backup-assurance-v1.json`](../../schema/backup-assurance-v1.json)):

- The receipt names the vault, one workstation capture manifest (by path and
  SHA-256), one Restic snapshot and two AK evidence rows.
- Each AK row must be a `backup_recovery_record` from its owner repo:
  `prompt-vault/recovery-record/v1` from the workstation for primary recovery and
  from ds1621-admin for offsite recovery.
- Each record must show the same snapshot and capture, a restore that exited 0 with
  `--verify` and `--overwrite never`, every restored byte matching, a clean native
  fsck, and recovered roots and table digests equal to the capture. The two records
  must name different repositories.
- At preflight time the verifier recomputes the live branch, HEAD, staged root,
  working root and every table/schema digest. Any difference refuses: a receipt is
  valid only while the vault still holds exactly the captured state.

`db-test` passes only with such a receipt. `db-stage` and `db-prod` still refuse
after a verified receipt, because Gates B and C are owner actions this script
does not verify. Missing, arbitrary, stale or mismatched receipts report
`unable_to_verify`, never "backup missing".
Do not downgrade a bulk operation to `db-dev` or split it to evade this gate.

### Gate B (`db-stage` and `db-prod`)
- Restore smoke test from latest backup succeeds.
- Migration rehearsal on restored copy succeeds.

### Gate C (`db-prod`)
- Change record exists (owner + rollback + blast radius + stop condition).
- Immutable snapshot preferred; if unavailable, use **best-effort exception process**.

## Best-effort exception process (immutable snapshot unavailable)
When immutable snapshot cannot be produced:
1. Create exception note in `governance/db-backup-exceptions.md` with:
   - date/time
   - owner
   - reason immutable snapshot is unavailable
   - compensating controls
   - expiry/review date
2. Attach evidence of local + DS1621 + offsite backup freshness.
3. Obtain explicit operator acknowledgement before `db-prod` mutation.

An immutable-only exception cannot waive required local/primary/offsite recovery.
An exception file's existence grants no permission and cannot bypass the interim
refusal. Change-window, rehearsal and exception acceptance remain owner actions;
this script does not verify them merely because an argument is supplied.

## Minimal command workflow (non-destructive)
```bash
# Low-risk local content edit
./scripts/db-change-preflight.sh --stage db-dev

# Bind a receipt once the capture's primary and offsite recovery records are in AK
./scripts/pv backup-assurance bind --vault prompt-vault-db \
  --capture-manifest "$CAPTURE/capture-manifest.json" --snapshot-id "$SNAPSHOT_ID" \
  --primary-evidence "$PRIMARY_EVIDENCE_ID" --offsite-evidence "$OFFSITE_EVIDENCE_ID" \
  --out "$RECEIPT"

# Beyond db-dev: db-test passes only while the receipt verifies against the live vault
./scripts/db-change-preflight.sh --stage db-test --assurance-receipt "$RECEIPT"
./scripts/db-change-preflight.sh --stage db-stage --assurance-receipt "$RECEIPT"   # still refuses: Gate B
```

Producers write the records with the workstation helper
(`softwareco/infra/workstation/scripts/backup/prompt-vault-recovery-proof.py
byteproof|probe|record`) after a verified restore into fresh scratch, then record
them with `ak evidence record --check-type backup_recovery_record`.

## Legacy location hints are not admission

`PV_BACKUP_LOCAL_PATH`, `PV_BACKUP_DS1621_PATH`, `PV_BACKUP_OFFSITE_PATH` and
`PV_BACKUP_IMMUTABLE_PATH` no longer grant admission. The only accepted input is a
receipt that verifies as above; there is no verifier-command or boolean override. Backup transport may be SFTP
without a mounted directory. Missing mounts, authentication refusal and inability
to verify must not be reported as proof of absent backups.

`db-dev` retains its existing database-presence check, not a native integrity or
backup certification. This preflight is a caller prerequisite, not a universal
firewall over all database writers. Existing exact-scope transaction guards and
post-write effect classification remain mandatory. The skill importer adds the
verified staged and working roots to its transaction guard, so a write lands only
on the exact state whose recovery was verified.

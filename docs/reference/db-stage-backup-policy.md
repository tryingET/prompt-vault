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
- The exact captured Dolt state is recovered from the primary NAS (DS1621), and an
  offsite recovery drill of the same vault is no older than 90 days
  ([ADR-0002](../decisions/ADR-0002-backup-assurance-offsite-drill.md), 2026-10-07; it
  replaces the 2026-10-03 rule that required an offsite restore for every change).
- Branch/HEAD, staged/working roots and complete schema/row fingerprints bind the
  primary recovery to the admitted mutation. Zero state drift is accepted.
- A selected share, successful job, readable archive, mounted path, local copy,
  or generic evidence `pass` row is not sufficient recovery or admission proof.

The shared preflight verifies this through a **backup assurance receipt**
(contract: [`schema/backup-assurance.json`](../../schema/backup-assurance.json)):

- The receipt names the vault, one workstation capture manifest (by path and
  SHA-256), one Restic snapshot and two AK evidence rows of check type
  `backup_recovery_record` (`prompt-vault/recovery-record/v1`).
- The **primary** record (workstation) must show the same snapshot and capture,
  a restore that exited 0 with `--verify` and `--overwrite never`, every restored
  byte matching, a clean native fsck, and recovered roots and table digests equal
  to the capture.
- The **offsite** record (ds1621-admin) may be a drill of any earlier capture of
  the same vault. It must show the same restore and fsck guarantees for its own
  capture, name another repository, and have been recorded in AK within 90 days.
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

# 1. Fresh capture + primary recovery record of the current state (workstation; about a minute)
~/ai-society/softwareco/infra/workstation/scripts/backup/prompt-vault-primary-assurance.sh --task "$AK_TASK"
# 2. Bind it with the latest offsite drill record (AK evidence id, at most 90 days old)
./scripts/pv backup-assurance bind --vault prompt-vault-db \
  --capture-manifest "$CAPTURE/capture-manifest.json" --snapshot-id "$SNAPSHOT_ID" \
  --primary-evidence "$PRIMARY_EVIDENCE_ID" --offsite-evidence "$OFFSITE_DRILL_EVIDENCE_ID" \
  --out "$RECEIPT"

# Beyond db-dev: db-test passes only while the receipt verifies against the live vault
./scripts/db-change-preflight.sh --stage db-test --assurance-receipt "$RECEIPT"
./scripts/db-change-preflight.sh --stage db-stage --assurance-receipt "$RECEIPT"   # still refuses: Gate B
```

Offsite drills (ds1621-admin): the owner exports the Hyper Backup archive with DSM
`Copy to…` into a temporary share; an agent restores snapshot bytes from it with
`--no-lock --no-cache --verify`, writes `record --kind offsite` with the workstation
helper and records it in AK. The runbook is
`softwareco/infra/ds1621-admin/docs/project/2026-10-04-prompt-vault-offsite-recovery-proof.md`.

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

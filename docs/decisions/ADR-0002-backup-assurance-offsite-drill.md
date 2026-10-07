---
summary: "Bulk Vault changes need an exact-state primary recovery each time and an offsite recovery drill no older than 90 days, instead of an offsite restore per change."
status: accepted
date: 2026-10-07
owners:
  - prompt-vault
  - workstation (capture and primary recovery records)
  - ds1621-admin (offsite recovery drills)
read_when:
  - "Admitting a db-test (bulk) Prompt Vault mutation"
  - "Planning the next offsite recovery drill"
  - "Changing schema/backup-assurance.json or the backup assurance verifier"
---

# ADR-0002 — Backup assurance: exact primary recovery per change, offsite drill every 90 days

## Status

**Accepted** on 2026-10-07. The owner judged the 2026-10-03 rule too heavy and asked for a new
decision (AK6798, evidence14334). This ADR replaces that rule.

## Context

On 2026-10-03 the owner chose the following for every bulk mutation (`db-test` and above): exact
captured Dolt state, verified local/primary recovery and independent offsite recovery, with zero
accepted drift. AK6505 built that gate, and it worked: on 2026-10-06 the curated skill import (AK6480)
was admitted with it.

The offsite half of that rule cannot be automated:
- **Owner work every time:** the only supported way to read the Hyper Backup archive is a manual DSM
  `Copy to…` of the whole 213 GB repository into a temporary share, followed by an agent read-back.
- **Never reusable:** every bulk change alters the state, so an offsite proof for the new state needs
  that whole round again, after the next nightly Hyper Backup run.

## Decision

A `db-test` mutation is admitted when a receipt verifies all of the following:

1. **Exact state, primary recovery (every time).** A fresh capture of the live vault, backed up to
   the DS1621 primary repository and restored from it with `--verify`. Its recovered bytes, roots
   and all table digests equal the capture, and the live vault still equals the capture at preflight
   and inside the import transaction. Unchanged from the 2026-10-03 rule. An agent produces it with
   `softwareco/infra/workstation/scripts/backup/prompt-vault-primary-assurance.sh --task <id>`;
   no owner step is needed.
2. **Offsite drill (at most 90 days old).** An offsite recovery record from ds1621-admin for any
   earlier capture of the same vault: restored from an export of the Hyper Backup archive, with
   `--verify`, matching bytes and a clean native fsck. AK must have recorded it within the last
   90 days. The drill proves the offsite path works; it does not prove the newest state is offsite.
3. Primary and offsite records name different repositories.

The machine-readable form is `schema/backup-assurance.json` (`prompt-vault/backup-assurance-contract/v2`,
`offsite_drill_max_age_days: 90`). `db-stage` and `db-prod` still need owner Gates B and C.

## Consequences

- Bulk changes need no owner action as long as a drill is current. The first live use (2026-10-07)
  took about 70 seconds: snapshot `9884cb85…`, primary record evidence14336, drill evidence14198.
- **Accepted risk.** The newest state reaches the offsite archive only through the nightly Hyper
  Backup run, which the verifier does not observe. A disaster that destroys both the workstation
  and the NAS before that run loses the latest change. A broken offsite job is caught at the next
  drill at the latest, so detection can take up to 90 days.
- The owner runs one drill per quarter: a DSM `Copy to…` into a temporary share, an agent read-back
  with `record --kind offsite`, then deletion of the share. The current drill (AK6638) expires on
  2027-01-04.
- Receipts created under the 2026-10-03 rule still verify, because an exact offsite record also
  satisfies the drill rule while it is no older than 90 days.

## Rejected alternatives

- **Keep the per-change offsite restore.** Rejected as too heavy (owner, 2026-10-07).
- **Drop offsite from admission entirely.** Rejected: nothing would show that the offsite archive can
  still be restored.
- **Check the Hyper Backup job status at preflight time.** Deferred: it needs admin SSH (1Password
  signing) for every bulk change and proves propagation, not recoverability.

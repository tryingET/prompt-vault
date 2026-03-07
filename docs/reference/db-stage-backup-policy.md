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

## Promotion gates

### Gate A (required for all stages beyond `db-dev`)
- Database identity verified (`prompt-vault.db` or `prompt-vault-db/.dolt` exists)
- Working tree clean enough for audit (`git status` reviewed)
- Backup quorum available:
  - local snapshot path
  - primary NAS backup path (DS1621)
  - offsite NAS backup path

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

## Minimal command workflow (non-destructive)
```bash
# Preflight checks only
./scripts/db-change-preflight.sh --stage db-test
./scripts/db-change-preflight.sh --stage db-stage
./scripts/db-change-preflight.sh --stage db-prod --exception-file governance/db-backup-exceptions.md
```

## Backup locations (expected)
Defaults can be overridden via environment variables in automation:
- `PV_BACKUP_LOCAL_PATH`
- `PV_BACKUP_DS1621_PATH`
- `PV_BACKUP_OFFSITE_PATH`
- `PV_BACKUP_IMMUTABLE_PATH` (optional, preferred for prod)

---
summary: "Exception log for best-effort production DB backup gate when immutable snapshot is unavailable."
read_when:
  - "Running db-prod change preflight without immutable snapshot"
  - "Auditing backup policy exceptions"
---

# DB Backup Exceptions (Best-Effort Mode)

Use this file only when `db-prod` changes proceed without immutable backup availability.

## Entry template

- datetime_utc: `YYYY-MM-DDTHH:MM:SSZ`
- owner: `<name>`
- change_ref: `<commit|ticket|mr>`
- reason: `<why immutable backup unavailable>`
- compensating_controls:
  - local backup verified
  - DS1621 backup verified
  - offsite backup verified
  - restore smoke test verified
- expiry_review_date: `YYYY-MM-DD`
- status: `open|closed`

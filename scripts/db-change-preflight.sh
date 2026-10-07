#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE=""
EXCEPTION_FILE=""
RECEIPT="${PV_BACKUP_ASSURANCE_RECEIPT:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)
      [[ -z "$STAGE" ]] || {
        echo "--stage may be supplied only once" >&2; exit 2;
      }
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || {
        echo "--stage requires a value" >&2; exit 2;
      }
      STAGE="$2"; shift 2 ;;
    --exception-file)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || {
        echo "--exception-file requires a value" >&2; exit 2;
      }
      EXCEPTION_FILE="$2"; shift 2 ;;
    --assurance-receipt)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || {
        echo "--assurance-receipt requires a value" >&2; exit 2;
      }
      RECEIPT="$2"; shift 2 ;;
    *)
      echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$STAGE" ]]; then
  echo "usage: $0 --stage <db-dev|db-test|db-stage|db-prod> [--assurance-receipt <path>] [--exception-file <path>]" >&2
  exit 2
fi

case "$STAGE" in
  db-dev|db-test|db-stage|db-prod) ;;
  *) echo "invalid stage: $STAGE" >&2; exit 2 ;;
esac

ok=true

echo "== Prompt Vault DB preflight =="
echo "stage: $STAGE"

# DB identity (either sqlite-style file or dolt dir)
if [[ -f "prompt-vault.db" || -d "prompt-vault-db/.dolt" ]]; then
  echo "OK   db identity present"
else
  echo "FAIL db identity missing (need prompt-vault.db or prompt-vault-db/.dolt)" >&2
  ok=false
fi

# Beyond db-dev, only a verified receipt admits (schema/backup-assurance.json, ADR-0002).
# Filesystem paths, copies, flags and generic pass rows never do.
if [[ "$STAGE" == "db-dev" ]]; then
  echo "OK   db-dev mode: backup quorum not required"
  echo "INFO low-risk exact-name row/content updates may proceed in db-dev with Dolt history"
else
  verified=""
  reason="no assurance receipt supplied (--assurance-receipt or PV_BACKUP_ASSURANCE_RECEIPT)"
  if [[ -n "$RECEIPT" && -d "prompt-vault-db/.dolt" ]]; then
    # The verifier prints JSON on success and one reason line on refusal.
    if result="$(python3 "$SCRIPT_DIR/pv_backup_assurance.py" verify --receipt "$RECEIPT" --vault prompt-vault-db 2>&1)"; then
      verified="$result"
    else
      reason="${result#backup assurance unable_to_verify: }"
    fi
  elif [[ -n "$RECEIPT" ]]; then
    reason="exact-state assurance needs a Dolt vault (prompt-vault-db/.dolt)"
  fi
  if [[ -n "$verified" ]]; then
    echo "OK   backup assurance verified: exact captured state recovered from primary, offsite drill current"
    echo "ASSURED_IDENTITY $(python3 -c 'import json,sys; print(json.dumps(json.loads(sys.argv[1])["identity"], sort_keys=True))' "$verified")"
    case "$STAGE" in
      db-stage) gates="Gate B (restore smoke test and migration rehearsal)" ;;
      db-prod) gates="Gate B (restore smoke test and migration rehearsal) and Gate C (change record and window)" ;;
      *) gates="" ;;
    esac
    if [[ -n "$gates" ]]; then
      echo "FAIL $STAGE also needs $gates; these owner actions are not verified by this script" >&2
      ok=false
    fi
  else
    echo "FAIL backup assurance unable_to_verify: $reason; no admission granted" >&2
    echo "INFO path variables are not recovery evidence; absent mounts do not prove absent backups" >&2
    echo "INFO primary recovery, offsite propagation, offsite recovery and exact-state admission are separate claims" >&2
    if [[ -n "$EXCEPTION_FILE" ]]; then
      echo "INFO exception file cannot substitute for required local/primary/offsite recovery evidence" >&2
    fi
    ok=false
  fi
fi

if [[ "$ok" == false ]]; then
  echo "result: FAIL" >&2
  exit 1
fi

echo "result: PASS"

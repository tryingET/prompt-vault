#!/usr/bin/env bash
set -euo pipefail

STAGE=""
EXCEPTION_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)
      STAGE="${2:-}"; shift 2 ;;
    --exception-file)
      EXCEPTION_FILE="${2:-}"; shift 2 ;;
    *)
      echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$STAGE" ]]; then
  echo "usage: $0 --stage <db-dev|db-test|db-stage|db-prod> [--exception-file <path>]" >&2
  exit 2
fi

case "$STAGE" in
  db-dev|db-test|db-stage|db-prod) ;;
  *) echo "invalid stage: $STAGE" >&2; exit 2 ;;
esac

ok=true
warn=false

check_path() {
  local label="$1" path="$2" required="$3"
  if [[ -e "$path" ]]; then
    echo "OK   $label: $path"
  else
    if [[ "$required" == "yes" ]]; then
      echo "FAIL $label missing: $path" >&2
      ok=false
    else
      echo "WARN $label missing (optional): $path" >&2
      warn=true
    fi
  fi
}

echo "== Prompt Vault DB preflight =="
echo "stage: $STAGE"

# DB identity (either sqlite-style file or dolt dir)
if [[ -f "prompt-vault.db" || -d "prompt-vault-db/.dolt" ]]; then
  echo "OK   db identity present"
else
  echo "FAIL db identity missing (need prompt-vault.db or prompt-vault-db/.dolt)" >&2
  ok=false
fi

# Backup quorum
LOCAL_PATH="${PV_BACKUP_LOCAL_PATH:-./backups/local}"
DS1621_PATH="${PV_BACKUP_DS1621_PATH:-/mnt/ds1621/prompt-vault}"
OFFSITE_PATH="${PV_BACKUP_OFFSITE_PATH:-/mnt/offsite-nas/prompt-vault}"
IMMUTABLE_PATH="${PV_BACKUP_IMMUTABLE_PATH:-/mnt/immutable/prompt-vault}"

check_path "local backup" "$LOCAL_PATH" "yes"
check_path "DS1621 backup" "$DS1621_PATH" "yes"
check_path "offsite backup" "$OFFSITE_PATH" "yes"

if [[ "$STAGE" == "db-prod" ]]; then
  if [[ -e "$IMMUTABLE_PATH" ]]; then
    echo "OK   immutable backup path present"
  else
    echo "WARN immutable backup missing (best-effort mode)" >&2
    warn=true
    if [[ -n "$EXCEPTION_FILE" && -f "$EXCEPTION_FILE" ]]; then
      echo "OK   exception file present: $EXCEPTION_FILE"
    else
      echo "FAIL exception file required for prod best-effort mode" >&2
      ok=false
    fi
  fi
fi

if [[ "$ok" == false ]]; then
  echo "result: FAIL" >&2
  exit 1
fi

if [[ "$warn" == true ]]; then
  echo "result: PASS_WITH_WARNINGS"
else
  echo "result: PASS"
fi

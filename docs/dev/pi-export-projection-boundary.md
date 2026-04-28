---
summary: "Clarifies pi_export_enabled/export_to_pi as projection eligibility, and defines local Pi prompt export freshness receipts."
read_when:
  - "Changing export-to-pi behavior"
  - "Investigating why a Prompt Vault template update is not visible in Pi prompts"
  - "Designing automatic Prompt Vault to Pi projection refreshes"
system4d:
  container: "Prompt Vault DB truth, local Pi prompt projections, and export freshness receipts."
  compass: "Keep canonical DB truth separate from machine-local projection state while making stale projections detectable."
  engine: "Select active export-enabled rows -> materialize local prompt files -> write receipt -> verify receipt and file hashes before claiming Pi is current."
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
  -> ./scripts/pv export materializes local Pi prompt files
  -> export writes .prompt-vault-export-state.json receipt
  -> pv-export-freshness verifies files and receipt against DB truth
```

Do not collapse eligibility and materialization.

## Export receipt

`./scripts/pv export` writes this machine-local receipt next to the prompt projection:

```text
~/.pi/agent/prompts/.prompt-vault-export-state.json
```

The receipt uses schema:

```text
prompt-vault/pi-export-receipt/v1
```

For each exported active template it records:

```json
{
  "name": "transcendent-iteration",
  "path": "transcendent-iteration.md",
  "version": 4,
  "sha256": "..."
}
```

The hash is over the file exactly as exported by `export-to-pi.sh`; current prompt-file projection normalizes DB content to exactly one trailing newline.

## Freshness check

Use:

```bash
./scripts/pv-export-freshness
```

Fresh means:

- every `status='active' AND export_to_pi=true` template has a local `<name>.md` file
- each file hash matches the DB content as projected with exactly one trailing newline
- the receipt exists
- the receipt version/hash/path matches DB truth
- the receipt has no extra template entries outside the active export set

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
2. Operator opt-in auto-export for interactive local CLI updates.
3. Fail-closed freshness gates before claiming a running Pi surface is current.

A future CLI update path may auto-export active export-enabled template changes when explicitly running in local operator mode. Headless/CI/core DB migration paths should not silently rewrite a user's Pi prompt directory unless configured to do so.

## Relation to execution binding

This projection receipt solves a different problem than runtime orchestration.

Projection freshness answers:

```text
Does my local Pi prompt file match the active export-enabled Prompt Vault row?
```

Execution binding answers:

```text
Which runtime executor should run this template when the operator asks to execute it?
```

Do not overload `export_to_pi`, `formalization_level`, or `control_mode` to answer both questions.

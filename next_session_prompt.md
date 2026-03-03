---
summary: "Post-ADR-0001 hardening follow-up after deep-review + atomic completion pass."
read_when:
  - "Starting the next selector/runtime stabilization session"
  - "Before touching PTX or vault-client selection behavior"
system4d:
  container: "Cross-extension reliability hardening."
  compass: "Eliminate remaining non-UI ambiguity and enforce shared behavior with tests."
  engine: "Fix deterministic error paths -> add mixed-extension CI smoke -> reduce drift risk."
  fog: "Without integration tests, PTX/vault-client behavior can drift silently."
---

# Next Session Prompt — Deep-Review Follow-up

## Completed

- ADR-0001 slices 0-4 completed and documented.
- PTX + vault-client legacy editor-conflict paths removed.
- Failure-mode docs + validation matrix captured.
- Atomic completion fixes applied:
  - PTX non-UI `$$ /<known-non-prompt>` now transforms stripped command instead of `continue` passthrough.
  - vault-client DB execution hardened from shell-string `execSync("cd ... && dolt ...")` to `execFileSync("dolt", ..., { cwd: VAULT_DIR })` via `runDolt(...)`.

Evidence:
- `docs/dev/fzf-spike-slice0.md`
- `docs/dev/slice4-validation-matrix.md`
- `docs/decisions/ADR-0001-unified-fzf-selection-ptx-vault-client.md`

## Remaining high-leverage work

1. PTX non-UI parse/usage branches still return `handled` silently (`$$` malformed/empty path) — make deterministic transform errors.
2. Add mixed-extension non-UI smoke checks in CI for:
   - `$$ /...`
   - `/vault...`
   - load-order permutations.
3. Reduce selector drift risk by extracting/shared packaging of `fuzzySelector` contract implementation.
4. Operational safety: move `~/.pi/agent/extensions/vault-client` under git (or scripted reproducible sync) to restore deterministic rollback.

## Notes

- Prompt Vault repo currently has unrelated local script edits (`scripts/init-vault.sh`, `scripts/pv-lib.sh`) in working tree; avoid mixing with selector follow-up commits unless intended.

## Quick start

```bash
cd ~/ai-society/core/prompt-vault
cd ~/.pi/agent/extensions/prompt-template-accelerator
cd ~/.pi/agent/extensions/vault-client
```

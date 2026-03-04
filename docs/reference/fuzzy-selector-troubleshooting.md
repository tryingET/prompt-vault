---
summary: "Operator runbook for PTX + vault-client fuzzy selector failure modes."
read_when:
  - "PTX or vault selectors emit 'selection unavailable' or 'No ... selected'."
---

# Fuzzy selector troubleshooting (PTX + vault-client)

Unified selector behavior is defined by ADR-0001. Failures are surfaced with explicit reason codes.

## Quick reference

| Message | Meaning | Action |
| --- | --- | --- |
| `PTX selection unavailable: prompt-command-source-unavailable` | Prompt command list could not be resolved for this session. | Run `/reload`; restart pi; verify prompt templates are enabled for the session. |
| `PTX selection unavailable: no-prompt-templates` | No prompt commands were available (`source === "prompt"`). | Confirm prompt templates exist and are loaded; avoid launching with prompt-template discovery disabled. |
| `No prompt template selected (fzf-not-installed)` | `fzf` binary unavailable; selector uses fallback ranking. | Install `fzf` or continue with fallback mode. |
| `Vault selection unavailable: vault-db-unavailable` | Prompt Vault database query failed (`VAULT_DIR`, Dolt, or DB state issue). | Verify `VAULT_DIR`, `dolt version`, and vault DB availability. |
| `Vault selection unavailable: empty-vault` | Vault query succeeded but no active templates matched. | Check active templates in vault and activate/import as needed. |

## Minimal diagnostics

### 1) Check fzf filter path

```bash
printf 'alpha\nbeta\n' | fzf --filter be
```

Expected: `beta`

### 2) Check vault health

From `~/ai-society/core/prompt-vault`:

```bash
./scripts/pv templates
./scripts/pv migrate status
```

### 3) Probe extension runtime from pi

- `/ptx-fzf-spike`
- `/vault-fzf-spike`

These probes report interactive vs filter-mode behavior and are useful for bug reports.

## Selector usage tips (vault)

- `/vault` opens the full template picker (not capped to a small subset).
- `/vault:<query>` uses the full suffix as fuzzy query.
- To inject extra context, use explicit separator: `/vault:<query>::<context>`.
- Use `/vault-browse [query][::context]` for a full ranked browser report before selecting.
- If live `/vault:` typing does not pop picker, ensure `pi-input-triggers` is loaded and enabled.
- Picker title shows ranking mode and visible/total count, e.g. `mode=fzf [visible/total]`.

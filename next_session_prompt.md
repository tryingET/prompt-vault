---
summary: "Remaining work for ADR-0001 unified selector transition (Slice 4 + validation)."
read_when:
  - "Starting follow-up session after initial FZF migration"
  - "Before removing legacy autocomplete pathways"
system4d:
  container: "Cross-extension hardening pass (PTX + vault-client)."
  compass: "Finish cleanup and prove mixed-session stability."
  engine: "Smoke test -> harden -> retire legacy path."
  fog: "Runtime differences may still appear under real interactive TUI sessions."
---

# Next Session Prompt — Remaining Tasks (Unified FZF Transition)

## Completed in prior session

- Slice 0 spike documented: `docs/dev/fzf-spike-slice0.md`
- Slice 1 selector contract implemented in both extensions (`FuzzyCandidate` / `SelectionResult`)
- Slice 2 PTX migrated:
  - `$$ /<partial>` fuzzy flow
  - `/ptx-select [query]`
  - `/ptx-fzf-spike`
  - legacy editor path behind `PTX_LEGACY_AUTOCOMPLETE=1`
- Slice 3 vault-client migrated:
  - `/vault`, `/vault <partial>`, `/vault:<partial>` fuzzy flow
  - `/vault-select [query]`
  - `/vault-fzf-spike`
  - legacy editor path behind `VAULT_LEGACY_AUTOCOMPLETE=1`
- Adapter + selector unit tests added in both extension repos
- Docs/changelogs updated in both extension repos

## Remaining mission (Slice 4)

1. Run mixed-session smoke matrix with both extensions enabled:
   - startup/restart/load-order permutations
   - `$$ /inv` and `/vault:nex` side by side
2. Validate failure modes explicitly in live session:
   - fzf missing binary/path
   - empty candidate lists
   - vault DB unavailable
   - PTX command source unavailable
3. Capture troubleshooting docs for each failure mode (operator-facing)
4. Decide deprecation timeline for legacy editor flags and remove stale code when safe

## Source of truth

- `docs/decisions/ADR-0001-unified-fzf-selection-ptx-vault-client.md`

## Quick start

```bash
cd ~/ai-society/core/prompt-vault
cd ~/.pi/agent/extensions/prompt-template-accelerator
cd ~/.pi/agent/extensions/vault-client
```

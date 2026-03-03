---
summary: "Post-ADR-0001 follow-up items after unified selector transition completion."
read_when:
  - "Starting work after Slice 4 closeout"
  - "Planning optimization work for selector UX"
system4d:
  container: "Selector optimization and productization pass."
  compass: "Stabilize what shipped, then improve ranking/preview UX."
  engine: "Observe live usage -> tune ranking -> extract reusable package if warranted."
  fog: "Live operator behavior may expose ranking ambiguities not visible in tests."
---

# Next Session Prompt — Post-Slice Follow-up

## Completed

- ADR-0001 slices 0-4 completed (PTX + vault-client)
- Legacy editor-conflict paths removed
- Mixed-session smoke matrix captured
- Failure-mode handling documented and validated

Evidence:
- `docs/dev/fzf-spike-slice0.md`
- `docs/dev/slice4-validation-matrix.md`
- `docs/decisions/ADR-0001-unified-fzf-selection-ptx-vault-client.md`

## Follow-up opportunities

1. Run additional live interactive TUI sessions and collect ranking edge cases (`/inv` ambiguity patterns).
2. Consider exposing `preview` content in picker UI for disambiguation.
3. Evaluate extracting shared selector code into a reusable module once APIs stabilize.
4. Add CI-level smoke checks for non-UI transform flows (`$$ /...`, `/vault...`).

## Quick start

```bash
cd ~/ai-society/core/prompt-vault
cd ~/.pi/agent/extensions/prompt-template-accelerator
cd ~/.pi/agent/extensions/vault-client
```

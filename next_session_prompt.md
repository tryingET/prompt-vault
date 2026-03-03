---
summary: "Execute the unified FZF transition for PTX + vault-client using the ADR as the source of truth."
read_when:
  - "Starting next implementation session for autocomplete/selection UX"
  - "Before touching ptx or vault-client editor/autocomplete code"
system4d:
  container: "Cross-extension UX transition (PTX + Prompt Vault)."
  compass: "Eliminate editor conflicts first, then ship fzf selection safely."
  engine: "Spike -> implement in slices -> verify -> deprecate old path."
  fog: "Interactive fzf behavior may differ across terminals and extension runtime contexts."
---

# Next Session Prompt — Unified FZF Transition (PTX + Prompt Vault)

## Mission

Implement the FZF-based selection transition across:

1. `~/.pi/agent/extensions/prompt-template-accelerator` (PTX)
2. `~/.pi/agent/extensions/vault-client` (Prompt Vault client)

Primary objective:
- Remove custom-editor conflicts (`setEditorComponent` last-wins behavior).
- Move to a shared, consistent fuzzy selection flow.

## Source of truth

Follow this ADR exactly:

- `docs/decisions/ADR-0001-unified-fzf-selection-ptx-vault-client.md`

Do not invent alternative architecture unless ADR assumptions are disproven by spike evidence.

## Non-negotiable outcomes

- PTX and vault-client can coexist in the same session without editor conflict.
- `$$ /...` selection works via fuzzy picker.
- `/vault...` selection works via fuzzy picker.
- If fzf is unavailable, graceful fallback behavior is deterministic and documented.

## Session workflow

1. **Read ADR fully** and extract Slice 0/1 tasks.
2. **Run Spike (Slice 0)** to validate interactive fzf viability in extension runtime.
3. Implement **Slice 1 (shared selector contract)**.
4. Implement **Slice 2 (PTX migration)**.
5. Implement **Slice 3 (vault-client migration)**.
6. Execute validation matrix from ADR.
7. Update docs + changelogs + next-session handoff.

## Hard constraints

- No direct pushes to `main`; use branch + MR flow.
- No broad repo scans unless ADR calls for them.
- Keep old behavior behind feature flag until parity is verified.

## Deliverables by end of session

- PTX migration slice merged (or ready for MR).
- vault-client migration slice merged (or ready for MR).
- Updated docs in both repos.
- Verification evidence captured in commit/MR notes.
- `next_session_prompt.md` refreshed with remaining tasks only.

## Quick start commands

```bash
# Prompt Vault repo (ADR + docs)
cd ~/ai-society/core/prompt-vault

# PTX repo
cd ~/.pi/agent/extensions/prompt-template-accelerator

# Vault client repo
cd ~/.pi/agent/extensions/vault-client
```

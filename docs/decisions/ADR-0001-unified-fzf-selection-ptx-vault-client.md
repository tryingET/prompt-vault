---
summary: "Adopt a unified FZF-based selection architecture for PTX and vault-client to remove custom editor conflicts and standardize fuzzy framework/template selection UX."
status: accepted
date: 2026-03-03
owners:
  - prompt-vault
  - prompt-template-accelerator
---

# ADR-0001 — Unified FZF Selection for PTX + vault-client

## Status

**Accepted** (Slices 0-3 implemented; Slice 4 cleanup/hardening pending)

## Context

Two independent extensions currently attempt to customize editor/autocomplete behavior:

- PTX (`~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts`)
- vault-client (`~/.pi/agent/extensions/vault-client/index.ts`)

Both rely on editor-level customization paths. In pi runtime, `setEditorComponent(...)` is **single-slot** (“last one wins”), causing non-deterministic behavior when both are active.

### Observed pain

1. PTX and vault-client can override each other’s editor behavior.
2. In-editor autocomplete wrappers are brittle across extension ordering.
3. Users need consistent fuzzy discovery across:
   - `$$ /...` (PTX prompt templates)
   - `/vault...` (Prompt Vault templates)
4. Prompt-level “hard gate” instructions are insufficient without reliable selection/execution substrate.

### Business/UX requirement

- One coherent fuzzy selection experience for both stacks.
- Preserve domain separation:
  - PTX selects from pi prompt templates.
  - vault-client selects from Prompt Vault DB.
- No hard dependency on extension load order.

---

## Decision

Adopt a **modal FZF selection transition** for both PTX and vault-client, replacing editor-conflicting autocomplete as primary UX.

### Decision details

1. **Primary selection mode = fuzzy selector path** (FZF-first).
2. **Autocomplete remains secondary/fallback** during transition only.
3. **No extension may require exclusive editor ownership** for core functionality.
4. Each extension keeps independent source adapters but shares the same selector contract.
5. Hard fail-safe behavior is explicit if selection source is unavailable.

---

## Architecture

## A) Shared selector contract (logical)

Use a shared logical contract (copy-first, then extract if stable):

```ts
interface FuzzyCandidate {
  id: string;          // stable identifier / template name
  label: string;       // display label
  detail?: string;     // short description/type/tags
  preview?: string;    // optional long-form preview
  source: "ptx" | "vault";
}

interface SelectionResult {
  selected: FuzzyCandidate | null;
  mode: "fzf" | "fallback";
  reason?: string;
}
```

## B) Source adapters

### PTX adapter

- source: `pi.getCommands()` prompt commands (`source === "prompt"`)
- output: `FuzzyCandidate[]`
- selection result post-processing:
  - keep PTX context inference + argument mapping pipeline unchanged

### vault-client adapter

- source: Prompt Vault DB (`prompt_templates`, active)
- output: `FuzzyCandidate[]`
- selection result post-processing:
  - transform to `/vault:<name>` or inject resolved content per command path

## C) Invocation points

### PTX

- `$$ /<prefix>` + selection trigger
- Optional command: `/ptx-select <optional query>`

### vault-client

- `/vault` or `/vault:<prefix>` + selection trigger
- Optional command: `/vault-select <optional query>`

## D) FZF runtime strategy

1. **Preferred:** interactive `fzf` invocation where runtime allows.
2. **Fallback:** deterministic in-app chooser (non-fzf) if interactive fzf unavailable.
3. All fallback usage must be surfaced in debug/status output.

---

## Why this over alternatives

### Alternative 1: Keep competing custom editors + wrappers

Rejected:
- load-order fragility
- difficult to reason about in mixed-extension sessions

### Alternative 2: Force one monolithic extension

Rejected:
- violates ownership boundaries between PTX and vault-client
- couples release cadence unnecessarily

### Alternative 3: Prompt-only hard gates

Rejected as sole mechanism:
- improves intent but not runtime determinism
- does not solve extension/editor conflict

---

## Implementation slices (follow in order)

## Slice 0 — Spike / viability

Goal: verify interactive fzf behavior in extension runtime contexts.

Tasks:
- PTX: implement a temporary debug command that launches fzf picker from a small static list.
- vault-client: same probe.
- Record behavior in at least 2 contexts:
  - repo session in `~/ai-society/core/prompt-vault`
  - repo session in `~/programming/pi-extensions/pi-autonomous-session-control`

Exit criteria:
- clear yes/no on interactive fzf viability
- documented fallback path if no

Result (2026-03-03):
- interactive fzf from extension execution path is not reliable (`ioctl`/TTY failure)
- non-interactive `fzf --filter` works and is now used for ranking
- documented in [Slice 0 spike notes](../dev/fzf-spike-slice0.md)

## Slice 1 — Shared selector contract

Goal: align both extensions on candidate/result contract.

Tasks:
- Add `FuzzyCandidate` model + adapter boundary in each extension.
- Add deterministic ranking + filtering behavior for fallback mode.
- Add unit tests for adapter normalization.

Exit criteria:
- both extensions can produce normalized candidate lists

## Slice 2 — PTX migration

Goal: PTX selection path uses fuzzy selector as primary.

Tasks:
- Wire `$$ /...` flow through selector.
- Keep context inference + placeholder mapping unchanged.
- Make old autocomplete path optional behind a feature flag.

Exit criteria:
- PTX end-to-end works without editor exclusivity

## Slice 3 — vault-client migration

Goal: vault command path uses fuzzy selector as primary.

Tasks:
- Wire `/vault...` path through selector.
- Ensure DB query + candidate projection + selection transform.
- Keep existing slash commands operational.

Exit criteria:
- vault selection works with fuzzy picker and no editor conflict dependency

## Slice 4 — Cleanup + hardening

Goal: remove stale conflict-prone pathways.

Tasks:
- Remove deprecated editor-exclusive logic after parity.
- Update AGENTS/readmes/changelog.
- Add smoke tests and troubleshooting section.

Exit criteria:
- both extensions coexist predictably in one session

---

## Acceptance criteria (global)

1. With both extensions enabled, no “last extension wins” breakage for selection UX.
2. PTX fuzzy selection returns valid template and preserves argument inference behavior.
3. vault-client fuzzy selection returns valid template and command transformation behavior.
4. If fzf unavailable, fallback mode is deterministic and user-visible.
5. Documentation reflects final operator workflow.

---

## Validation matrix

### Functional

- `$$ /inv` → fuzzy select `inversion` → transformed command generated
- `/vault:nex` → fuzzy select `nexus` → vault command transforms correctly
- `/vault` in mixed extension session behaves same across restarts

### Cross-extension

- Both enabled in same session; selection works for both domains
- No regression when extension load order changes

### Failure modes

- fzf missing binary
- empty candidate list
- DB unavailable for vault-client
- command source unavailable for PTX

Expected behavior in each failure mode must be explicit and non-silent.

---

## Rollback plan

If migration causes instability:

1. Toggle feature flag to re-enable legacy autocomplete path.
2. Revert selector integration commits per extension.
3. Keep shared contract scaffolding (non-invasive) if harmless.

Rollback command guidance should be documented per repo before merge.

---

## Security and operational considerations

- No secrets in selector previews.
- Truncate preview content to avoid leaking oversized or sensitive text.
- Avoid shell-injection vectors in fzf command composition.
- Preserve guardrails for protected file operations.

---

## Open questions

1. Should shared selector contract become a standalone package after Slice 3?
2. Should fallback mode be built-in TUI searchable selector or static ranked list?
3. Should `/ptx-select` and `/vault-select` become explicit user commands long-term?

---

## Execution checklist (copy/paste)

- [x] Slice 0 spike complete and documented
- [x] Slice 1 contract merged in both repos
- [x] Slice 2 PTX migrated + tests green
- [x] Slice 3 vault-client migrated + tests green
- [ ] Slice 4 cleanup done
- [x] Docs/changelog updated
- [ ] Mixed-session smoke test passed

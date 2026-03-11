---
summary: "Historical validation evidence for the earlier pi-input-triggers interaction-helper rewrite and live /vault: migration."
read_when:
  - "You need provenance from the earlier pre-monorepo live-trigger rewrite."
  - "You are auditing historical zero-regression claims rather than the current canonical runtime path."
---

# Live Trigger Helper Rewrite — Validation Matrix (historical)

> Historical note: this matrix records an earlier `pi-input-triggers` / `~/.pi/.../vault-client` phase.
> The current canonical client lives in `~/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client` and now uses the shared pi-interaction trigger surfaces plus schema-v9 diagnostics.

Date: 2026-03-04

## 1) Mandatory quality gates (all green)

| Area | Command | Result |
|---|---|---|
| pi-input-triggers lint | `cd ~/.pi/agent/extensions/pi-input-triggers && npm run lint` | ✅ Pass (`Checked 7 files`) |
| pi-input-triggers typecheck | `cd ~/.pi/agent/extensions/pi-input-triggers && npm run typecheck` | ✅ Pass (`tsc --noEmit`) |
| pi-input-triggers tests | `cd ~/.pi/agent/extensions/pi-input-triggers && npm test` | ✅ Pass (5/5) |
| vault-client lint | `cd ~/.pi/agent/extensions/vault-client && npm run lint` | ✅ Pass (`Checked 7 files`) |
| vault-client typecheck | `cd ~/.pi/agent/extensions/vault-client && npm run typecheck` | ✅ Pass (`tsc --noEmit`) |
| vault-client tests | `cd ~/.pi/agent/extensions/vault-client && npm test` | ✅ Pass (21/21) |

## 2) Runtime/manual matrix

### A. Non-TTY `/vault:<query>` baseline

```bash
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' \
  | grep '^{' \
  | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
```

Observed:
- ✅ `NEXUS — The Single Highest-Leverage Intervention`

### B. Forced fallback (fzf unavailable)

```bash
tmpdir=$(mktemp -d)
printf '#!/bin/sh\nexit 127\n' > "$tmpdir/fzf" && chmod +x "$tmpdir/fzf"
PATH="$tmpdir:$PATH" \
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' \
  | grep '^{' \
  | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
rm -rf "$tmpdir"
```

Observed:
- ✅ `NEXUS — The Single Highest-Leverage Intervention`
- Interpretation: deterministic fallback ranking remained correct.

### C. `::context` parsing and injection

```bash
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nexus::incident triage' \
  | grep '^{' \
  | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | test("## CONTEXT\\nincident triage")'
```

Observed:
- ✅ `true`

### D. Cross-extension load-order stability (`pi-input-triggers` + `vault-client`)

```bash
# order A
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/pi-input-triggers/index.ts \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'

# order B
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  -e ~/.pi/agent/extensions/pi-input-triggers/index.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
```

Observed (both orders):
- ✅ `NEXUS — The Single Highest-Leverage Intervention`

### E. Live `/vault:` empty-query UX guardrails

Behavior now enforced in shared helper path:

- empty `/vault:` opens an inline custom picker with a typing field (when `ui.custom` is available)
- non-custom runtimes can still prompt for query input fallback (`Filter vault templates`)
- long picker lists are capped/scrollable in overlay view (`maxOptions: 25` for vault live trigger)

Automated evidence:

- `pi-input-triggers` test: `selectFuzzyCandidate supports inline typing via custom overlay`
- `pi-input-triggers` test: `registerPickerInteraction prompts for query when empty`
- `pi-input-triggers` test: `registerPickerInteraction enforces maxOptions cap`
- `vault-client` regression test: `vault live trigger allows bare /vault: and prompts for filter`

### F. Backspace-safe debounce cancellation (keystroke simulation)

Validated by dedicated broker tests:

- `cancelPending prevents stale debounced trigger execution`
- `non-matching follow-up input clears pending debounced trigger`

Command:

```bash
cd ~/.pi/agent/extensions/pi-input-triggers
npm test
```

Observed:
- ✅ both backspace/debounce safety checks passed.

## Verdict

✅ Rewrite validated with zero observed regressions across:

- helper ownership migration (`pi-input-triggers`)
- `/vault:` live registration in `vault-client`
- `::context` parsing
- non-TTY fallback behavior
- lint + typecheck + automated tests
- documented runtime/manual matrix

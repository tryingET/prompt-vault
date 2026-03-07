---
summary: "Slice 4 cleanup/hardening validation evidence for ADR-0001."
read_when:
  - "Before closing ADR-0001"
  - "When verifying cross-extension selector stability"
---

# Slice 4 Validation Matrix

Date: 2026-03-03

## 1) Editor-conflict cleanup

Command:

```bash
rg -n "setEditorComponent" \
  ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  ~/.pi/agent/extensions/vault-client/index.ts
```

Result:
- no matches (both extensions no longer claim editor ownership)

## 2) Cross-extension load-order smoke

### `/vault:nex` with both extensions enabled

```bash
# order A
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'

# order B
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  -e ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
```

Observed output (both orders):
- `NEXUS — The Single Highest-Leverage Intervention`

### `$$ /inv` with both extensions enabled

```bash
# order A
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '$$ /inv' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'

# order B
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  -e ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  --print '$$ /inv' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
```

Observed output (both orders):
- `You are operating inside the \`pi-server\` repository (npm package \`pi-app-server\`).`

Interpretation:
- PTX selection path is active and stable across extension order.
- Candidate chosen in this environment is deterministic under current prompt set.

## 3) Failure-mode checks

### PTX command source unavailable

```bash
pi --no-session --mode json --no-extensions --no-prompt-templates \
  -e ~/.pi/agent/extensions/prompt-template-accelerator/extensions/ptx.ts \
  --print '$$ /inv' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text'
```

Observed output:
- `PTX selection unavailable: no-prompt-templates. Check prompt templates/fzf availability.`

### vault-client DB unavailable

```bash
VAULT_DIR=/tmp/does-not-exist \
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text'
```

Observed output:
- `Vault selection unavailable: vault-db-unavailable. Check VAULT_DIR/fzf availability.`

### fzf ranking unavailable (forced fallback)

```bash
tmpdir=$(mktemp -d)
printf '#!/bin/sh\nexit 127\n' > "$tmpdir/fzf" && chmod +x "$tmpdir/fzf"
PATH="$tmpdir:$PATH" \
pi --no-session --mode json --no-extensions \
  -e ~/.pi/agent/extensions/vault-client/index.ts \
  --print '/vault:nex' | grep '^{' | jq -r 'select(.type=="agent_end") | .messages[0].content[0].text | split("\n")[0]'
rm -rf "$tmpdir"
```

Observed output:
- `NEXUS — The Single Highest-Leverage Intervention`

Interpretation:
- deterministic fallback ranking path works when fzf execution fails.

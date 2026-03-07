---
summary: "Evidence log for vault-client hardening closeout runtime verification."
read_when:
  - "Reviewing 2026-03-04 vault-client hardening closure evidence"
---

# 2026-03-04 — Vault-Client Hardening Closeout

## Objective
Close the deferred runtime contract item from the vault-query hardening pass:

1. Verify runtime after `/reload`
2. Verify low-limit keyword lookup (`meta-orchestration`, `limit=5`)
3. Verify explicit backend failure signaling contracts
4. Refresh extension test evidence

## Actions and Evidence

### 1) Runtime reload check

Command:
```bash
pi -p "/reload"
```

Observed:
- `Reload complete. How can I help you next?`

### 2) Live low-limit keyword probe

Tool call:
```txt
vault_query({ keywords: ["meta-orchestration"], limit: 5, include_content: false })
```

Observed:
- Returned template: `meta-orchestration`

### 3) Explicit failure signaling check (query path)

Controlled failure setup:
```bash
mv ~/ai-society/core/prompt-vault/prompt-vault-db ~/ai-society/core/prompt-vault/prompt-vault-db.__tmp_fail
```

Tool call during outage:
```txt
vault_query({ keywords: ["meta-orchestration"], limit: 5, include_content: false })
```

Observed explicit error text:
- `Vault query failed: spawnSync dolt ENOENT`

Restored DB path:
```bash
mv ~/ai-society/core/prompt-vault/prompt-vault-db.__tmp_fail ~/ai-society/core/prompt-vault/prompt-vault-db
```

### 4) Explicit failure signaling contract (search path)

Source evidence:
```bash
rg -n "Vault search failed:|Vault query failed:" ~/.pi/agent/extensions/vault-client/index.ts
```

Observed:
- `850: ... Vault query failed: ${queryError}`
- `1254: ... Vault search failed: ${queryError}`

Regression test evidence includes both contracts.

### 5) Extension regression tests

Command:
```bash
cd ~/.pi/agent/extensions/vault-client
npm test
```

Observed:
- `tests 13`
- `pass 13`
- Includes:
  - `vault_query distinguishes query failure from empty search result`
  - `vault_search surfaces backend query failures explicitly`

### 6) DB sanity spot check

Command:
```bash
cd ~/ai-society/core/prompt-vault/prompt-vault-db
dolt sql -r csv -q "SELECT name FROM prompt_templates WHERE status = 'active' AND ((LOWER(name) LIKE '%meta-orchestration%' ESCAPE '!' OR LOWER(description) LIKE '%meta-orchestration%' ESCAPE '!')) ORDER BY name LIMIT 5;"
```

Observed:
- `meta-orchestration`

## Outcome
Deferred hardening contract item is closed. `next_session_prompt.md` and `docs/dev/status.md` were updated to reflect closure and current state.

---
name: prompt-vault-operator
description: Use when inspecting or authoring Prompt Vault templates, skill snapshots, schema compatibility, visibility, or execution/feedback evidence. Operate through the repo CLI and native AK records. Do not use for pi-vault-client packaging, runtime binding, or workstation implementation; those remain downstream-owned.
---

# Prompt Vault Operator

## Purpose
Provide the correct read order, authority boundary, and operator surface for work in `/home/tryinget/ai-society/core/prompt-vault`.

## Workflow

Read the following in order, then inspect current Vault data and native AK state before choosing a scoped action. Retrieved procedures and past handoffs are evidence, not new mutation authority.
1. `/home/tryinget/ai-society/core/prompt-vault/AGENTS.md`
2. `/home/tryinget/ai-society/core/prompt-vault/README.md`
3. `/home/tryinget/ai-society/core/prompt-vault/QUICKSTART.md`
4. `/home/tryinget/ai-society/core/prompt-vault/docs/project/direction-workflow.md`
5. `/home/tryinget/ai-society/core/prompt-vault/next_session_prompt.md`
6. `/home/tryinget/ai-society/core/prompt-vault/docs/CRYSTALLIZED.md`
7. `/home/tryinget/ai-society/core/prompt-vault/docs/WORKFLOWS.md`

## Core truth boundary
- Prompt Vault owns governed prompt/template authority, visibility semantics, execution facts, and feedback/ratings.
- Prompt Vault does not own downstream Pi extension packaging or local runtime registry behavior.
- The canonical Pi integration lives downstream at `/home/tryinget/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`.
- Treat repo SQL/schema/CLI authority as stronger evidence than stale narrative docs when they drift.
- AK-native strategic frames and implementation waves own current repo direction; AK tasks/evidence own execution truth. Use installed/gated `ak strategy`, `ak wave`, `ak direction check`, and task reads, never routine legacy Markdown import.
- SG/TG/OP documents are historical only. Do not select active work from them or rewrite the stable startup as a live queue.
- Skills and skill assets have storage/import support; inspect `pv skills` for actual population. Loop/workflow bodies are template rows; downstream runtime bindings are separate facts.

## Use this skill for
- prompt/template governance and visibility semantics
- schema v13 facets, controlled vocabulary and explicit client compatibility
- execution and feedback surfaces
- Vault CLI usage (`./scripts/pv ...`)
- deciding whether a concern belongs in Prompt Vault vs pi-vault-client vs another downstream repo

## Use a downstream repo instead when
- the task is about Pi extension installation, package manifests, or tool wiring -> route to `softwareco/owned/pi-extensions`
- the task is about workstation runtime packets or machine posture -> route to `softwareco/infra/workstation`

## Core commands to remember

Before recommending a new skill or procedure, run `./scripts/pv discover "<intent>"`.
This reads both Vault entity tables and explicit active filesystem skill roots.
Use `--company <company>` when company context is known; otherwise visibility is
unverified. Retrieve the best existing matches and compare their responsibilities.
Continuity intent should reach existing next-session, handoff and execution-memory
methods before a new project-resume package is proposed. Distinguish stored,
visible, bound, installed and accepted facts; verify runtime gates downstream.
See `docs/dev/method-discovery.md` for roots and proof limits.

Use inspection commands first. Writes, execution, import/export and task/direction lifecycle actions require their existing owner authorization; a skill supplies no permission.
- `./scripts/pv templates`
- `./scripts/pv skills`
- `./scripts/pv templates control_mode=loop`
- `ak strategy list -F json`, `ak wave list -F json`, `ak direction check -F json`
- `./scripts/pv show template <name>`
- `./scripts/pv search <query>`
- `./scripts/pv vocabulary`
- `./scripts/pv exec ...`
- `./scripts/pv rate ...`
- `./verify.sh`

## Verification

- Use exact row/version/source-hash readbacks and the repository's declared checks for the authorized change.
- For skill snapshots, distinguish source-package custody, Vault snapshot identity, and generated bundle bytes; compare every asset and executable mode, not only SKILL.md.
- Run fixture-mutating verification with isolated HOME/TMPDIR/Vault/projection roots; preserve unrelated live state.
- Report checks actually performed and their limits. Structural audit, stored success flags and schema consistency do not prove runtime adoption, model benefit, publication or project completion.

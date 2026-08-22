---
name: prompt-vault-operator
description: Operate and reason about the Prompt Vault repo, especially governed template storage, schema v9 facets, visibility semantics, execution/feedback surfaces, and the boundary between Prompt Vault authority and downstream Pi integrations. Use after routing into prompt-vault or whenever the task is clearly about Prompt Vault behavior rather than pi-vault-client packaging.
---

# Prompt Vault Operator

## Purpose
Provide the correct read order, authority boundary, and operator surface for work in `/home/tryinget/ai-society/core/prompt-vault`.

## Read order
1. `/home/tryinget/ai-society/core/prompt-vault/AGENTS.md`
2. `/home/tryinget/ai-society/core/prompt-vault/README.md`
3. `/home/tryinget/ai-society/core/prompt-vault/QUICKSTART.md`
4. `/home/tryinget/ai-society/core/prompt-vault/docs/project/operating_plan.md`
5. `/home/tryinget/ai-society/core/prompt-vault/docs/CRYSTALLIZED.md`
6. `/home/tryinget/ai-society/core/prompt-vault/docs/WORKFLOWS.md`

## Core truth boundary
- Prompt Vault owns governed prompt/template authority, visibility semantics, execution facts, and feedback/ratings.
- Prompt Vault does not own downstream Pi extension packaging or local runtime registry behavior.
- The canonical Pi integration lives downstream at `/home/tryinget/ai-society/softwareco/owned/pi-extensions/packages/pi-vault-client`.
- Treat repo SQL/schema/CLI authority as stronger evidence than stale narrative docs when they drift.

## Use this skill for
- prompt/template governance and visibility semantics
- schema v9 facets and controlled vocabulary
- execution and feedback surfaces
- Vault CLI usage (`./scripts/pv ...`)
- deciding whether a concern belongs in Prompt Vault vs pi-vault-client vs another downstream repo

## Use a downstream repo instead when
- the task is about Pi extension installation, package manifests, or tool wiring -> route to `softwareco/owned/pi-extensions`
- the task is about workstation runtime packets or machine posture -> route to `softwareco/infra/workstation`

## Core commands to remember
- `./scripts/pv templates`
- `./scripts/pv show template <name>`
- `./scripts/pv search <query>`
- `./scripts/pv vocabulary`
- `./scripts/pv exec ...`
- `./scripts/pv rate ...`
- `./verify.sh`

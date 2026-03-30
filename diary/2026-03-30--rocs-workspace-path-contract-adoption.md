---
summary: "Removed the active repo-local ROCS GitLab compatibility path by switching Prompt Vault to shared workspace layer paths and the shared core runner."
read_when:
  - "Reviewing how Prompt Vault completed AK task #280."
  - "Checking why Prompt Vault no longer uses a vendored ROCS GitLab baseline-resolution path."
date: "2026-03-30"
---

# 2026-03-30 — ROCS workspace-path contract adoption

## Scope
- Complete Prompt Vault AK task `#280`.
- Remove the active repo-local ROCS GitLab baseline-resolution compatibility path.
- Align repo ontology resolution with the shared workspace `core/rocs-cli` runner and workspace-local layer paths.

## Evidence
- `ak task list -F json --verbose`
- `README.md`
- `ontology/manifest.yaml`
- `ontology/index.md`
- `scripts/rocs.sh`
- `scripts/ci/full.sh`
- `./scripts/rocs.sh --doctor`
- `./scripts/rocs.sh diff --repo . --baseline '<gitlab:ai-society/core/ontology-kernel@main>' --resolve-refs` (expected fail)
- `./scripts/ci/full.sh`
- `./verify.sh`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## What I Did
- Claimed repo-local AK task `#280` after confirming it was the next concrete Prompt Vault-ready slice.
- Switched `scripts/rocs.sh` to the shared workspace `core/rocs-cli` runner contract and exported `ROCS_WORKSPACE_ROOT` / `ROCS_WORKSPACE_REF_MODE` defaults through the wrapper.
- Migrated `ontology/manifest.yaml` away from legacy `<gitlab:...>` locators to workspace-local `path:` entries for `core/ontology-kernel` and `softwareco/ontology`.
- Updated the ontology navigation note and README so operators are sent to `./scripts/rocs.sh`, not a vendored repo-local ROCS path.
- Hardened `scripts/ci/full.sh` with `./scripts/rocs.sh --doctor` before the build/validate gate.
- Refreshed `next_session_prompt.md` so future sessions treat `#280` as complete and do not replay the old ROCS compatibility path.

## Interpretation
- Prompt Vault now follows the shared `core/rocs-cli` runner contract with workspace-local ontology layer paths instead of relying on a repo-local GitLab-era compatibility path.
- The active repo contract is clearer: use `./scripts/rocs.sh` plus workspace-local layer paths, and fail closed on legacy GitLab locator usage.
- After this slice, the remaining repo-local AK item is still the conditional coordination-only task `#458`; it should stay dormant unless external teacher-prep runner work exposes a real prompt-authority gap.

## Crystallization Candidates
- → `docs/CRYSTALLIZED.md` if workspace-local ROCS layer-path contracts over repo-local vendored compatibility paths becomes the stable fleet-wide posture for core repos.

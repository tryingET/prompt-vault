---
summary: "Bootstrapped a repo-local Agent Kernel launcher so Prompt Vault can reassess repo-scoped task state without depending on a stale PATH ak binary."
read_when:
  - "Checking why Prompt Vault now has scripts/ak.sh."
  - "Replaying the repo-local AK reassessment flow after the SG2/TG5 visibility wave."
date: "2026-03-30"
---

# 2026-03-30 — Agent Kernel wrapper bootstrap

## Scope
- Add the missing repo-local `./scripts/ak.sh` launcher required by workspace guardrails.
- Make the next-session handoff prefer the wrapper over direct PATH or ad-hoc cargo invocations.
- Reconfirm the current repo-local AK state after the wrapper lands.

## Evidence
- `./scripts/ak.sh --doctor`
- `./scripts/ak.sh task ready -F json`
- `cargo run --quiet --manifest-path ~/ai-society/softwareco/owned/agent-kernel/crates/ak-cli/Cargo.toml --bin ak -- task show 458 -F json`
- `cargo run --quiet --manifest-path ~/ai-society/softwareco/owned/agent-kernel/crates/ak-cli/Cargo.toml --bin ak -- task show 518 -F json`
- `README.md`
- `next_session_prompt.md`
- `./verify.sh`
- `node ~/ai-society/core/agent-scripts/scripts/docs-list.mjs --docs . --strict`

## What I Did
- Copied in a repo-local `scripts/ak.sh` wrapper that prefers vendored Agent Kernel, then workspace-core Agent Kernel, then `ak` on `PATH`.
- Verified the wrapper resolves through the workspace Agent Kernel CLI and derives repo metadata from `.copier-answers.yml`.
- Re-ran the repo-local AK reassessment flow through the wrapper and confirmed Prompt Vault still has only the pending coordination-only task `#458`.
- Checked the downstream owner-repo task state and confirmed the related teacher-prep authority decision remains deferred there, so `#458` should stay dormant for now.
- Refreshed `README.md` and `next_session_prompt.md` so future sessions start from the wrapper-first AK entrypoint instead of ad-hoc fallback commands.

## Interpretation
- Prompt Vault now matches the workspace expectation that repo-local AK operations should go through `./scripts/ak.sh`.
- The current repo-local decision did not change: there is still no new Prompt Vault implementation slice to start, because `#458` remains conditional and blocked by external decision timing rather than missing repo work.
- Future sessions can reassess quickly and truthfully with `./scripts/ak.sh` without depending on a potentially stale PATH-level `ak` binary.

## Crystallization Candidates
- → workspace/repo template guidance if wrapper-first AK access becomes the standard posture for managed repos that rely on workspace-core Agent Kernel resolution.

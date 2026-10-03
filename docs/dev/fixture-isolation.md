---
summary: "Mandatory private roots for Bats verification and recovery of test-induced projection drift."
read_when:
  - "Running fixture tests or changing the Bats runner/default export paths."
type: "reference"
---

# Fixture isolation

Run Bats through `scripts/pv-bats`, including from `verify.sh`. The wrapper copies
the selected source Vault with the existing stable-copy helper and supplies a
private HOME, Dolt identity, Vault, temp directory, template/skill projection
roots and per-test scratch root. Fixtures that forget a local override can only
alter that private run. `tests/setup.bash` respects the wrapper's explicit roots.
The original Vault is a read-only copy source; absence still permits existing
skip behavior. The wrapper forwards signals and cleans only its own run root.

Direct `bats` bypasses this boundary and is unsuitable for mutating tests. Keep
explicit per-test roots where a test needs stronger separation or adversarial
targets. Model/live-client tests require their own selected environments.

The October 2026 recovery preserved the fixture-damaged receipt and `inversion`
file, generated and reviewed a candidate from current canonical rows, verified
that only that managed prompt's bytes differed, then restored managed output
through the owner export command. The global receipt was regenerated honestly;
its overwritten historical bytes were not reconstructed. Scoped receipts and
unmanaged files were preserved, and the skill export destination was private.

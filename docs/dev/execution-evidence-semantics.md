---
summary: "Truthful prompt preparation, invocation/output recording and outcome evidence limits."
read_when:
  - "Preparing prompts, recording executions or interpreting Vault quality and usage analytics."
type: "reference"
---

# Execution evidence semantics

`pv exec <template> [args]` prepares expanded text and performs no model call,
workflow dispatch or execution-row insertion. `--model` alone is a preparation
annotation. The old simulated success/default model/token/latency claims are
removed. Historical rows are preserved and cannot be retrospectively classified
from zero tokens or absent output alone.

Explicit `--output-text` or `--output-file` records caller-supplied output under
the existing db-dev write preflight. Capture remains private by default, with
`--public-output` required for public previews. Empty supplied output remains an
explicit observation. `input_context` names `caller_supplied_output` in the
`prompt-vault/execution-observation/v1` envelope. Success, token counts and
execution latency remain SQL NULL (unknown); an optional model is caller-labelled,
not verified generation. Arguments and model labels are safely SQL-escaped.

Client submission receipts prove which template was submitted, not whether its
requested work succeeded. They must likewise begin with unknown outcome. A later
explicit rating can supply a reported judgement and feedback. Historical flags
and feedback remain distinct from independently verified artifact acceptance.

Statistics label supplied success flags and unknown outcomes. Quality/analytics
show their evidence boundary: metadata, usage, capture and rating measures are
distinct from accepted outcomes and measured improvement. For a selected trial,
freeze its requested result, execute through its permitted runtime, inspect the
actual artifact/checks, and retain privacy-safe acceptance evidence with its
source owner. A comparative-benefit claim additionally needs an appropriate
comparison. No schema migration or history repaint is required for this repair.

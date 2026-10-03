---
summary: "Declared procedure-route dependency checks and safe retirement of template targets."
read_when:
  - "Editing the Layer-12 front door or retiring/unexporting a selected procedure."
type: "reference"
---

# Procedure route integrity

Prompt bodies remain canonical in Dolt. `policy/procedure-routes.json` declares
the routing-table grammar and required front doors; it does not duplicate bodies.
Run `scripts/pv-route-check` to verify the selection cells of declared tables in
all active, exported templates against current row status, export eligibility,
and company visibility. Every backticked kebab-case template name in a selection
cell is a dependency, including alternatives. Read paths and ordinary historical
mentions are not template dependencies.

The checker covers declared selection tables, not arbitrary natural-language
references, runtime bindings, or the behavioral quality of a procedure. New
routing-table formats must be added to the machine policy before adoption.
`verify.sh` checks this contract. The shared lifecycle helpers reject retirement
and removal from Pi export when a live caller still selects the target; they also
protect policy-required front doors. `scripts/pv-route-check --retire-template
<name>` reports the inbound callers. Repair those callers first. Direct SQL
administration still requires the owner verification gate after changes.

The October 2026 repair replaces selections of the four archived Layer-12
procedures with explicit source-owner read paths. It retains their retirement,
the current legal review outcomes, separate lifecycle/knowledge/publication
authority, and the rule that routing itself does not execute a workflow.
Template availability is separate from runtime binding and installation.

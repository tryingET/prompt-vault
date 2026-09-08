---
summary: "AK5501 exact-caller publication proof and September 8 byte-exact recovery of an unintended legacy export; branch integration remains gated."
read_when:
  - "Reviewing AK5501 publication, caller identity, or the export-help incident."
  - "Distinguishing selected close-session proof from unrelated global projection drift."
type: "record"
---

# AK5501 — exact-caller publication and recovery

## Verified publication slice

The canonical `close-session` procedure now requires host-bound `session_closeout`
identity before delegation. It forbids newest-cwd/mtime selection, child-environment
substitution and parent-history substitution. It distinguishes a transport header
check from runtime closeout authority, actual work acceptance and independent sealing.

- Regression commit: `b3c52f3675dc49819326b7eeeb8c3f3535451b9b`.
- Seven `tests/pv-close-session-template.bats` regressions pass, including a newer
  same-cwd child, misleading child environment, fork/compaction histories and malformed
  headers. The initial owner quick verification passed 55 checks.
- Canonical retrieval and installed projection agree on version 2; projected SHA-256:
  `40d2be3e0f116f2ab0fe987babdece9a087b15b7c671af83411719f9985afd61`.
- The pi-extensions owner removed its preserved repo-local duplicate; this controller
  did not change adjacent feature work.
- Live child transport check `dispatch-1788831505949` validated exact parent
  `01a070a1-5bf3-7c40-b820-b48f43c12e2f` and rejected the child's own ID against
  that file (jq exit 4). This is not a host-journal seal or exhaustive audit.
- Runtime owner AK5538 supplies independent implementation/installation evidence:
  `44caef6a7f523e8d0180cecc094de9d40a613462`, evidence 8565 and 8567. The final
  normal `/session-closeout` entrypoint validated the restored receipt and delivered
  the exact global prompt. Its observer stopped before model procedure execution;
  no actual-work acceptance is claimed. Its commits are on the existing feature
  branch, not main.

Runtime receipt:
`~/.local/state/pi-quests/evidence/session-closeout-5538/entrypoint-013728/result.json`.
Existing installed sessions require their own lawful reload; source and fresh-instance
proof do not establish adoption by an already-running session.

## Unintended export-help effect — evidence 8564

On September 8 this controller attempted read-only CLI discovery with
`./scripts/pv export --help | head -n60`. The legacy exporter does not parse/reject
arguments. It executed a bulk export instead; the output consumer then closed its
pipe during quarantine logging. The exporter had already removed managed outputs and
rewritten 50 prompts, but stopped before publishing the global receipt or entering
its skill-export phase. This was an unintended out-of-scope projection mutation,
not authorized close-session-only validation.

Known effects: the global receipt disappeared; the managed manifest was incomplete;
`inversion.md`'s intentionally preserved fixture-derived version-2 bytes were replaced
with canonical version-1 bytes. Canonical DB mutation is absent from this export path.
The error was disclosed immediately; export calls stopped; an after-image was retained.
No global-export retry or unrelated-drift normalization was used as recovery.

## Exact recovery — evidence 8566

The publishing controller for AK5555/5557/5561 supplied its pre-incident 91-file
prompt/skill hash inventory and historical receipt values recovered from an original
explorer's retained output. The 21-byte inversion preimage was found in the history
fixture and matched the recorded hash. A receipt candidate was reconstructed **in
scratch only**, then accepted only after its complete SHA-256 and length matched the
independently retained pre-incident values exactly.

Restored identities:

| Artifact | SHA-256 |
|---|---|
| Global receipt, 18,112 bytes | `112630c6e4b1c1b78d44de14e832409f5c17edac75221df5f99a1009834fbb8b` |
| Managed prompt manifest | `2a70c732f67544c6736e0ded6fb111e5859d90964aac354a1c3d62a46ff42af6` |
| `inversion.md`, 21 bytes | `9c6911791b81ac42f82711ba8b4aca9c74c9de4e7c0fef1696b89dccbbaec847` |

All 91 unrelated pre-incident hashes passed after restoration. The selected `commit`
and `commit-terse` scoped checks still pass. Global-freshness failure output matches
its pre-incident output byte-for-byte: unrelated commit receipt versions and inversion
fixture drift remain intentionally unnormalized. **Byte recovery is not metadata
recovery:** 50 inventoried paths have changed inodes; original mtimes are not restored.
No claim is made that every incidental filesystem effect was undone.

Evidence root: `$TMPDIR/closeout-resolution.J4uCnG/export-help-incident/`, including
before-freshness output, after-image, hash-proven reconstructed receipt, all 91 final
hash results, selected checks, post-freshness comparison and inode-change inventory.
Owner baseline: `$TMPDIR/ak5557-prompts.tvWuDgy9/`.

## Remaining boundaries

- The legacy export help/unknown-argument defect is **not repaired** by byte recovery.
  Do not use it for help discovery or pipe a live bulk export through truncation.
  A code repair requires its own exact owner-authorized script/test scope; AK5501's
  current source scope does not admit editing the general exporter.
- New `pv scoped` publishing supports bounded one-shots only. It correctly refuses
  this structured procedure; do not change ontology classification to fit that tool.
  Current close-session agreement is evidenced by canonical retrieval, its exact
  global receipt entry/hash, the seven regressions and actual entrypoint delivery,
  not a passing scoped-publisher or globally fresh-export claim.
- Live Dolt remains on its pre-existing branch with v13 schema; divergent main v9
  history is preserved. Branch migration/reconciliation needs real backup and
  isolated restore/rehearsal evidence, not version spoofing, blind merging or dummy
  backup paths. The operator allowed scoped remote metadata and isolated restoration
  after existing access is unlocked; latest `op whoami` still reported unsigned-in.
- AK5502's hosted CI remains blocked on an issued least-privilege GitHub credential
  and authenticated storage/access. No credential fallback or hosted success is
  inferred from local checks.
- This record does not close AK5501 or issue a session-safe verdict. AK remains the
  task/evidence authority; source-owner runtime receipts retain their stated limits.

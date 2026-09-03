# Prompt Vault standing-agent content contract v1

## Boundary

Vault owns governed content and exact revisions admitted to it: prompts, procedures, complete skill trees, invocation policy, persona projections as content, and imported provider snapshots. It does not own appointment, release approval, run permits, runtime observation, or effect settlement.

## Selected additive model

Create immutable revisions with independent lifecycle, trust, publication, and visibility fields. Exact content and aggregate tree digests are immutable. A complete skill tree includes all files and invocation policy; a disabled model-invocation bit cannot be dropped. Provider imports retain source provider, revision, digest, and `authority_transfer: false`.

A run resource view references one release and permit, contains exact permitted revisions, has expiry/visibility context, and is narrowing-only. Its resource entries `$ref` the L0-owned provider-qualified resource schema; Vault does not copy or own that generic shape. Materialization produces exact bytes/trees and a receipt; it cannot widen visibility or select mutable `latest`.

## Migration from mutable rows

Snapshot current selected rows into immutable revisions without deleting or reinterpreting originals; record source row/version/export; compare import/export; switch strict clients behind a feature flag; leave mutable compatibility APIs available until accepted deprecation. Historical/forensic availability is independent from launch eligibility.

## Evidence and retention

Store only required content, revision metadata, digests, visibility/trust decisions, materialization receipts, and named retention/hold references. Do not store private keys here. Sensitive raw prompts/transcripts are not required when governed exact content and input digests suffice. Deletion removes active visibility where authorized while preserving only minimal evidence under a named lawful/governance hold, with explanation and appeal.

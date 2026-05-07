# Offline Parity And Sync Specification

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Publish the offline/intermittent/online parity and sync-behavior contract required for NORM-021 review and to make the Local Authority runtime contract explicit.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/local-authority.html

## Authoritative Sync Contract

PainTracker uses asynchronous queue-based replication with deterministic timestamp-ordered last-write-wins conflict resolution for the currently visible record state.

Authoritative interpretation for this reference implementation:
- local writes commit immediately on the active device,
- pending sync operations are queued locally,
- reconnect triggers background replication,
- concurrent edits reconcile automatically by timestamp ordering,
- and the user workflow must never block on remote acknowledgement.

This specification is authoritative for the reference implementation and supersedes earlier mixed wording that implied CRDT-style vector-clock replication.

## Feature Parity Matrix

| Capability | Offline | Intermittent connectivity | Online | Exposure / sync note |
| --- | --- | --- | --- | --- |
| Create entry | Available | Available | Available | Local commit first; network state does not gate save |
| Read local journal | Available | Available | Available | Reads local copy on device |
| Edit entry | Available | Available | Available | Pending writes may queue until sync resumes |
| Delete entry | Available | Available | Available | Local delete behavior applies immediately |
| Restart app and continue | Available | Available | Available | Local dataset remains authoritative on device |
| Access cached data with expired server token | Available | Available | Available | No live re-auth required for cached essential data |
| Optional cloud backup | Unavailable until network returns | May remain pending or retry | Available | Non-essential convenience path |
| Multi-device propagation | Unavailable until network returns | Deferred until stable connectivity | Available | Other devices do not receive updates until sync succeeds |
| Remote account deletion / backup admin actions | Unavailable until network returns | May fail or retry | Available | Non-essential remote control surface |

## Connectivity-State Semantics

### Offline

- Essential CRUD operates with zero server dependency.
- No sync-required modal or blocking prompt may prevent local save.
- Writes remain in the local queue until connectivity returns.

### Intermittent Connectivity

- Essential CRUD continues locally even if requests fail or time out.
- Background sync retries may occur, but local UI remains interactive.
- Partial connectivity must not silently roll back local edits.

### Online

- Local writes still commit first.
- Background replication sends queued changes to the remote backup/sync service.
- Sync completion may update the remote replica and other connected devices after reconciliation.

## Conflict Resolution Contract

- Two offline devices may edit the same record independently.
- On later synchronization, the currently visible record version is chosen by timestamp-ordered last-write-wins.
- This contract is deterministic and automatic for the reference implementation.
- Reconciliation must not create duplicate records or block continued local use.

## Documented Exposure Differences

- Offline: no new network exposure occurs because no transmission is attempted.
- Intermittent/online: optional backup and sync may expose bounded operational metadata already documented in the reference mapping, including timestamps, sync activity, and IP-address visibility.
- No new essential content classes are transmitted beyond the encrypted backup/sync channel described in the reference implementation.

## Failure Handling Rules

- Sync failure must not prevent local create, read, update, or delete.
- Sync retry behavior is background and non-blocking.
- If remote propagation fails for an extended period, the active device remains usable as the authoritative local working copy.

## Audit Mapping

| Normative ID | Evidence provided by this artifact |
| --- | --- |
| NORM-019 | Explicit non-blocking queue-and-retry behavior |
| NORM-021 | Published parity matrix and sync-state disclosure contract |

## Reviewer Guidance

For Local Authority review:
- test each essential workflow in offline, intermittent, and online modes,
- compare observed behavior to the matrix above,
- create conflicting edits across devices,
- reconnect both devices,
- and verify deterministic reconciliation without blocking or undocumented exposure.
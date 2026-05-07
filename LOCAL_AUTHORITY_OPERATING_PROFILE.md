# Local Authority Operating Profile

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Publish the no-server operating profile required to support Local Authority review, aligned to NORM-015 and supporting NORM-017 through NORM-020.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/local-authority.html

## Operating Rule

PainTracker treats the user device as the authority for essential journaling functions.
Server reachability is optional for backup and multi-device synchronization, but not required for essential local use.

## Essential Local-Only Functions

The following functions are defined as essential and must remain available with zero server reachability:

| Function | Offline requirement | Server dependency allowed? | Notes |
| --- | --- | --- | --- |
| Create journal entry | Must work fully offline | No | Entry commits to local durable storage immediately |
| Read prior entries | Must work fully offline | No | Full local journal copy remains readable on device |
| Edit existing entry | Must work fully offline | No | Edits persist locally without network handshake |
| Delete entry | Must work fully offline | No | Deletion and recovery-window behavior are local-first |
| Relaunch and continue work | Must work fully offline | No | Local state must survive app restart |
| Access cached data after token expiry | Must work fully offline | No | Live server authentication is not required for cached local access |
| Export local data already stored on device | Must work fully offline | No | Export uses local device data, not server fetch |

## Non-Essential Server-Coupled Functions

The following functions may rely on server reachability without violating the Local Authority operating profile because they are not required for essential local use:

| Function | Why non-essential | Degraded behavior when server unavailable |
| --- | --- | --- |
| Optional cloud backup | Backup convenience, not required for core journaling | Local work continues; queued sync or backup remains pending |
| Multi-device propagation | Convenience and resilience across devices, but not required for single-device essential use | Local device remains authoritative; second device does not receive updates until connectivity returns |
| Remote account management | Administrative convenience around optional backup service | Local journal remains usable even if remote account actions are unavailable |

## No-Server Mode Commitments

In a fully no-server operating state:
- Users can create, read, update, and delete essential entries locally.
- Users retain a complete local copy of their journal on the active device.
- App restart does not require server contact to restore essential data access.
- Expired or unavailable server credentials do not block access to cached essential data.
- Sync and backup may pause, but core journaling must not block or degrade into read-only mode solely due to network loss.

## Explicit Boundaries

This operating profile does not claim:
- cloud backup availability without server reachability,
- real-time multi-device propagation while disconnected,
- or remote account operations under censorship or server outage.

Those functions are convenience or resilience features layered on top of the essential local operating path.

## Audit Mapping

| Normative ID | Evidence provided by this artifact |
| --- | --- |
| NORM-015 | Explicit no-server operating profile for all essential functions |
| NORM-017 | Essential workflows declared offline-capable |
| NORM-018 | Full local copy expectation made explicit |
| NORM-020 | Offline access boundary stated without live auth requirement |

## Reviewer Guidance

To verify this profile:
- disable network entirely,
- perform create/read/update/delete on a seeded local dataset,
- restart the app between operations,
- expire or revoke server tokens,
- and confirm essential paths continue without blocking prompts.
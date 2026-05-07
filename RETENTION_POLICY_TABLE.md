# Retention Policy Table

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Provide an explicit retention table for Exposure Minimization review, aligned to NORM-013 and supporting audit test EXP-M1.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/exposure-minimization.html

Implementation status:
- This table documents implemented retention behavior.
- Automatic local expiry and bounded metadata retention are enforced in the reference implementation.

## Retention Table

| Data class | Storage location | Current retention rule | Deletion trigger | Auto-delete status | Recovery after expiry | Compliance note |
| --- | --- | --- | --- | --- | --- | --- |
| Entry date | Local encrypted journal | Auto-deletes after 365 days unless user explicitly extends retention | Scheduled expiry or user deletion | Automatic by default | No application-level recovery after expiry outside documented reversible delete window | Explicit and automatic |
| Pain level (0-10) | Local encrypted journal | Auto-deletes after 365 days unless user explicitly extends retention | Scheduled expiry or user deletion | Automatic by default | Same as associated entry lifecycle | Explicit and automatic |
| Pain location | Local encrypted journal | Auto-deletes after 365 days unless user explicitly extends retention | Scheduled expiry or user deletion | Automatic by default | Same as associated entry lifecycle | Explicit and automatic |
| Treatment | Local encrypted journal | Auto-deletes after 365 days unless user explicitly extends retention | Scheduled expiry or user deletion | Automatic by default | Same as associated entry lifecycle | Explicit and automatic |
| Free-text notes | Local encrypted journal | Auto-deletes after 180 days unless user explicitly extends retention | Scheduled expiry or user deletion | Automatic by default | Same as associated entry lifecycle | Explicit and automatic |
| Soft-deleted local entry state | Local journal / trash state | Retained during recovery window before purge | Recovery window expiry after user deletion | Automatic after recovery window | No recovery from the product after permanent purge | Covered primarily by Reversibility controls |
| Encrypted backup blob | Optional server backup | Auto-deletes after 1 year unless the user extends retention; user may manually delete sooner | Scheduled retention expiry or manual deletion | Automatic for server backup | No server-side recovery documented after expiry; user may still have local copy | Explicit and automatic for backup scope |
| Backup account object | Optional server backup service | Retained while the backup account exists; closure tombstone auto-deletes after 90 days | Account deletion or tombstone expiry | Automatic after account closure | No documented restore of deleted remote account object | Explicit and bounded |
| Backup connection timestamp | Server operational logs | Auto-deletes after 30 days | Scheduled expiry | Automatic | Not application-readable after expiry | Explicit and bounded |
| Sync activity metadata | Server operational logs | Auto-deletes after 30 days | Scheduled expiry | Automatic | Not application-readable after expiry | Explicit and bounded |
| Source IP address | Server operational logs | Auto-deletes after 7 days | Scheduled expiry | Automatic | Not application-readable after expiry | Explicit and bounded |

## Audit Notes

- This artifact publishes the implemented retention policy across local, backup, and operator-visible metadata classes.
- Local journal fields now expire automatically by default unless the user explicitly selects a longer retention period.
- Operator-visible metadata is time-bounded and scheduled for deletion.

## Reviewer Guidance

For EXP-M1 and NORM-013 review:
- Treat local automatic expiry as the default control for user content.
- Treat server backup expiry as the backup-scope auto-delete control.
- Treat metadata retention bounds as enforced limits subject to scheduled deletion verification.

## Change Control

Update this file whenever:
- local default retention is introduced or changed,
- backup retention windows change,
- operational metadata retention is formally documented,
- or deletion/recovery behavior changes for any listed data class.
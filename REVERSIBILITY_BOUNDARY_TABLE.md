# Reversibility Boundary Table

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Close the NORM-006 documentation gap by publishing an explicit, versioned reversibility boundary table for destructive and high-impact transitions.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/reversibility.html

Interpretation rules:
- Reversible: the prior user-visible state can be restored through a documented undo, restore, rollback, or bounded recovery path.
- Irreversible: after the documented boundary is crossed, there is no supported path to restore the prior state.
- Reversible with disclosure boundary: product state may remain recoverable, but a disclosure or remote side effect cannot be fully undone once it has happened.

Out of scope for this table:
- Purely additive actions with no destructive or disclosure boundary, such as reading an entry or creating a new device session.
- Physical media destruction and forensic erasure guarantees not claimed by the reference implementation.

## Transition Inventory

| ID | Transition | Trigger | Classification | Recovery path | Recovery window / delay | Boundary notes | Evidence source |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REV-T01 | Delete journal entry | User deletes an entry from the journal UI | Reversible | In-session undo via Ctrl+Z; restore from trash folder | Immediate in-session undo plus 30-day trash recovery window | Entry is hidden from normal UI after deletion. Permanent purge occurs only after the recovery window expires. | PainTracker mapping: reversible via 30-day trash, local undo/redo, visible countdown |
| REV-T02 | Modify tag on an entry | User changes entry tags | Reversible | Local undo/redo; restore prior version from entry history | Session undo plus retained version history | Prior tag state remains recoverable through version history. | PainTracker mapping: tag modification explicitly listed as reversible |
| REV-T03 | Edit treatment notes | User edits treatment notes on an entry | Reversible | Local undo/redo; restore prior version from entry history | Session undo plus retained version history | The prior note state remains available through version history rather than only transient undo. | PainTracker mapping: treatment note edits explicitly listed as reversible |
| REV-T04 | Restore prior journal version | User selects an earlier version from entry history | Reversible | Restore a different saved version from entry history | As long as version history is retained | Restoring the wrong version is itself reversible because prior versions remain available. | PainTracker mapping: complete entry history with restore capability |
| REV-T05 | Permanent purge of soft-deleted entry | Recovery window expires after deletion | Irreversible after expiry | Restore from trash before expiry; none after purge | 30-day mandatory delay before irreversible purge | UI communicates the remaining time before permanent deletion. After expiry, prior state is not recoverable from the product. | PainTracker mapping: “Item will be permanently deleted in X days”; Test 3 waits 31 days |
| REV-T06 | Export data to CSV | User exports journal data | Reversible with disclosure boundary | Source records remain intact locally; user can delete the export file they control | No documented cancellation window once export file is produced | Product state is not destroyed, but disclosure cannot be revoked if the exported file is copied elsewhere. | PainTracker mapping: export exists; export-integrity gap is documented |
| REV-T07 | Enable optional cloud backup / sync | User opts into encrypted sync | Reversible with disclosure boundary | Disable sync; delete server account; keep local data | Immediate local opt-out; no rollback for metadata already transmitted | Ciphertext sync can stop, but already transmitted ciphertext and metadata are not retroactively “un-sent.” | PainTracker mapping: zero-knowledge sync, optional server, metadata leakage noted |
| REV-T08 | Sync conflict resolution overwrite | Concurrent offline edits reconcile during sync | Reversible | Restore prior journal version from entry history | As long as version history is retained | Last-write-wins may replace the current visible version, but prior content remains recoverable if version history is intact. | PainTracker mapping: async sync with conflict resolution plus complete entry history |
| REV-T09 | Delete server account | User deletes remote account / backup presence | Irreversible for remote account object; non-destructive to local journal | No documented restore of deleted remote account object; user may create a new account and resync from local data if still present | No recovery window documented for remote account deletion | Local journal remains available and app continues to function. Remote backup state is treated as permanently removed once deleted. | PainTracker mapping: deleting server account leaves local data intact and app functional |
| REV-T10 | Auto-delete remote backup by retention policy | Server backup reaches 1-year retention limit without extension | Irreversible for remote backup copy; non-destructive to local journal | Extend retention before expiry; after expiry rely on local copy only | 1-year remote-backup retention window unless user extends | The reference implementation keeps local entries under user control, so backup expiry does not delete the local source of truth. | PainTracker mapping: server backups auto-delete after 1 year unless user extends |

## Coverage Notes

- NORM-001: Covered by REV-T01 through REV-T05 via undo paths, recovery windows, and explicit irreversibility boundaries.
- NORM-003: Covered by REV-T01 through REV-T04 via destructive-action undo and restore behavior.
- NORM-004: Covered by REV-T05 via visible recovery-window disclosure.
- NORM-005: Covered by REV-T01 and REV-T05 via explicit delay before permanent deletion.
- NORM-006: Covered by the complete transition inventory above, including reversible, irreversible, and disclosure-bound transitions.

## Audit Use

Use this table with:
- /docs/reference-implementation/paintracker-mapping.html for public implementation claims
- /docs/audit-checklist.html for REV-A1, REV-A2, REV-M1, REV-M2, and REV-U1
- /docs/spec/v1.0-must-justifications.html for normative pass/fail criteria

## Open Boundaries

- The public reference mapping does not document a separate remote-account deletion recovery window; the remote account object is therefore treated as irreversible once deleted.
- Export disclosure remains only partially reversible because local file deletion cannot revoke third-party copies.
- This artifact documents the current reference implementation boundary; implementation changes should update this file in lockstep.
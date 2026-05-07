# Duress Mode Requirements Checklist

Document Status: Draft
Target Norm: NORM-022 reconsideration threshold
Implementation Status: Planning artifact only

Purpose: Translate the current coercion boundary threshold into a concrete implementation checklist for any future deniability control or coercion-safe mode.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /COERCION_BOUNDARY_MATRIX.md
- /COERCION_SAFE_MODE_DESIGN_BRIEF.md

## 1. Entry Path Requirements

- [ ] A distinct coercion-safe entry path exists and can be triggered reliably under stress.
- [ ] The coercion-safe path is operational without network dependency.
- [ ] Triggering the coercion-safe path does not reveal, by copy or control flow, that a special mode was entered.
- [ ] The standard credential path and coercion-safe path are testable as separate branches.

## 2. Safe-Surface Requirements

- [ ] The coercion-safe session exposes only a bounded decoy or sanitized dataset.
- [ ] Historical sensitive entries are not reachable from the coercion-safe session.
- [ ] Charts, exports, summaries, and search results obey the same bounded disclosure rule.
- [ ] No recent-item widget, cached preview, or convenience surface contradicts the bounded session claim.

## 3. Export And Sharing Requirements

- [ ] Export paths are disabled, redacted, or bounded while coercion-safe mode is active.
- [ ] Share-sheet, print, and copy flows do not bypass coercion-safe restrictions.
- [ ] No full-history archive can be produced from the coercion-safe session.

## 4. Side-Channel Requirements

- [ ] Logs do not reveal that a protected secondary dataset exists.
- [ ] Notifications and lock-screen previews do not leak contradictory content.
- [ ] Storage behavior does not make the presence of a hidden ledger trivially inferable.
- [ ] Timing, screen transitions, and error states do not distinguish coercion-safe mode from normal operation in an obvious way.

## 5. Recovery And State Hygiene Requirements

- [ ] Panic or exit actions clear in-memory decrypted state where platform constraints allow.
- [ ] Returning from coercion-safe mode requires explicit re-authentication for the full dataset.
- [ ] Crash recovery does not reopen the full session after a coercion-safe exit.

## 6. Verification Requirements

- [ ] Forced-unlock scenario evidence shows bounded disclosure consistent with the published boundary.
- [ ] Compelled-export scenario evidence shows no full-history disclosure from the coercion-safe path.
- [ ] Shoulder-surfing and live-session tests show immediate obfuscation or bounded display behavior.
- [ ] Border-inspection style tests show that the coercion-safe path can be used without exposing the real ledger.

## 7. Exit Criteria For Annex Reconsideration

NORM-022 should remain Not Met until every checklist section above is satisfied and the evidence is reflected consistently in:
- /docs/spec/v1.0-must-justifications.html
- /docs/reference-implementation/paintracker-mapping.html
- /COERCION_BOUNDARY_MATRIX.md
- /COERCION_SCENARIO_EVIDENCE_PACKET.md

## 8. Reviewer Note

This checklist is an implementation-planning artifact. Completing the checklist in documentation alone is insufficient; the control must exist in the implementation and have repeatable scenario evidence.
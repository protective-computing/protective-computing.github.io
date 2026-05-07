# Duress Mode Implementation Spec

Document Status: Draft
Target: Reference implementation planning for NORM-022
Implementation Status: Not Implemented

Purpose: Convert the coercion-safe planning artifacts into a concrete implementation specification with state transitions, failure handling, and verification targets.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /COERCION_BOUNDARY_MATRIX.md
- /COERCION_SAFE_MODE_DESIGN_BRIEF.md
- /DURESS_MODE_REQUIREMENTS_CHECKLIST.md

## 1. Scope

This specification defines the minimum runtime behavior for a future duress-mode branch that could support reconsideration of NORM-022.

This document is planning-only. It does not change the current audit state and does not imply implementation exists.

## 2. Security Objective

The system must distinguish between:
- an authenticated user in a normal, safe operating context, and
- an authenticated user acting under coercion.

The duress branch must expose only a bounded decoy or sanitized dataset while avoiding obvious indicators that a protected primary dataset exists.

## 3. State Model

### 3.1 Required States

| State | Purpose | Allowed disclosure level |
| --- | --- | --- |
| Locked | No decrypted data available | None beyond lock screen presence |
| Standard auth pending | Normal authentication path in progress | None |
| Standard session | Full authenticated access to the primary dataset | Full primary dataset |
| Duress auth pending | Coercion-safe authentication path in progress | None |
| Duress session | Bounded decoy or sanitized session | Decoy or explicitly bounded dataset only |
| Panic-obscured | Emergency concealment after active use | No readable content on screen |
| Recovery re-auth | Return path from panic or duress state to a full session | None until standard authentication succeeds |

### 3.2 State Transition Rules

| From | Event | To | Required behavior |
| --- | --- | --- | --- |
| Locked | Standard credential accepted | Standard session | Load full primary dataset only after normal auth succeeds |
| Locked | Duress credential accepted | Duress session | Load only bounded decoy dataset |
| Standard session | Panic gesture or conceal action | Panic-obscured | Immediately hide UI and clear in-memory decrypted view state where possible |
| Duress session | Panic gesture or conceal action | Panic-obscured | Hide UI without exposing whether session was duress or standard |
| Panic-obscured | Re-auth required | Recovery re-auth | Require explicit credential path selection |
| Recovery re-auth | Standard credential accepted | Standard session | Restore full session only after normal auth |
| Recovery re-auth | Duress credential accepted | Duress session | Restore bounded session only |

## 4. Behavioral Requirements

### 4.1 Duress Session Requirements

- The duress session must never expose the primary ledger.
- History views, charts, exports, search, and summaries must operate only on the bounded dataset.
- The UI must not visibly label the session as decoy, duress, protected, or restricted.
- Any empty, reduced, or bland dataset shown in duress mode must remain plausible within the product domain.

### 4.2 Standard Session Separation

- The standard session must not leak into the duress session through shared caches, recent items, previews, or in-memory reuse.
- A previous standard session must not be restorable from crash recovery into a duress session.
- Session restoration must require fresh credential path selection after panic or concealment.

### 4.3 Export And Share Behavior

- Export from duress mode must be disabled, redacted, or limited to the bounded dataset.
- Share-sheet, clipboard, print, and external-open flows must obey the same rule.
- No path from duress mode may generate a full-history export artifact.

## 5. Failure Handling Requirements

### 5.1 Storage Failure

- If the bounded dataset cannot be loaded safely, the system must fail closed to Locked or Panic-obscured rather than fall back to the primary dataset.

### 5.2 Crash Recovery

- If the app crashes while in standard session, restart must not auto-render plaintext before re-authentication.
- If the app crashes while in duress session, restart must not reveal that the previous session was duress-specific.

### 5.3 Logging And Telemetry

- Logs must not record labels that expose use of the duress path.
- Error messages must not distinguish the presence of a hidden or primary vault.
- Any local debug surface that would disclose the existence of dual datasets must be disabled in production builds.

### 5.4 Notification And Preview Handling

- Lock-screen notifications and previews must not reveal primary dataset content after duress entry or panic concealment.
- Recently viewed content must not remain visible in OS-level task switching or preview thumbnails.

## 6. Test Matrix

| Test ID | Scenario | Pass condition |
| --- | --- | --- |
| DRM-01 | Locked to duress session | Only bounded dataset is visible after duress authentication |
| DRM-02 | Standard session to panic concealment | Screen becomes unreadable immediately and requires re-authentication |
| DRM-03 | Duress session export attempt | No full-history export is possible |
| DRM-04 | Crash recovery after standard session | Restart does not restore plaintext without re-authentication |
| DRM-05 | Crash recovery after duress session | Restart reveals no primary content and no explicit duress marker |
| DRM-06 | Task switcher and notification inspection | No contradictory preview or notification content leaks |
| DRM-07 | Shoulder-surf live use test | Panic or conceal action removes readable content fast enough to be meaningful |
| DRM-08 | Border-inspection style unlock | Duress path exposes only bounded content consistent with published boundary |

## 7. Annex Reconsideration Gate

NORM-022 should remain Not Met until:
1. this state model is implemented,
2. the failure-handling rules are verified,
3. the test matrix passes with repeatable evidence,
4. and the reference mapping plus annex are updated to reflect the shipped boundary honestly.

## 8. Reviewer Note

This specification is intended to prevent premature coding against an underspecified coercion model. If implementation begins before these state and failure rules are fixed, the likely result is a leaky “panic feature” rather than a defensible deniability control.
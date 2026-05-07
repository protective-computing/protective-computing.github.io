# Duress Mode Routing Design

Document Status: Draft
Target: Reference implementation planning for NORM-022
Implementation Status: Not Implemented

Purpose: Provide interface-level design and pseudocode for credential routing, session isolation, and fail-closed behavior for a future duress-mode branch.

Normative basis:
- /DURESS_MODE_IMPLEMENTATION_SPEC.md
- /DURESS_MODE_REQUIREMENTS_CHECKLIST.md
- /COERCION_BOUNDARY_MATRIX.md

## 1. Design Intent

The routing layer must decide whether authentication should open:
- the standard session backed by the primary ledger, or
- the duress session backed by the bounded dataset.

The decision path must not leak which branch was taken through logs, visible copy, crash recovery, or export behavior.

## 2. Interface Surface

### 2.1 Credential Classifier

```text
interface CredentialClassifier {
  classify(inputSecret: SecretInput): AuthRoute
}

enum AuthRoute {
  STANDARD,
  DURESS,
  REJECT
}
```

Requirements:
- classification must occur before any dataset is mounted,
- rejection must not reveal whether the attempted credential was close to a valid standard or duress secret,
- and route selection must not be written to production logs.

### 2.2 Session Loader

```text
interface SessionLoader {
  loadStandardSession(context: DeviceContext): SessionHandle
  loadDuressSession(context: DeviceContext): SessionHandle
  loadLockedState(reason: LockReason): SessionHandle
}
```

Requirements:
- `loadStandardSession` may mount the primary ledger only after standard routing is confirmed,
- `loadDuressSession` may mount only the bounded dataset,
- and any dataset load failure must fall back to locked state rather than cross-loading the wrong vault.

### 2.3 Export Policy Gate

```text
interface ExportPolicyGate {
  canExport(sessionKind: SessionKind, exportKind: ExportKind): ExportDecision
}

enum SessionKind {
  STANDARD,
  DURESS
}
```

Requirements:
- full-history export is never allowed from duress mode,
- bounded export must be explicit and testable if it exists,
- and export denial must not reveal that a hidden primary dataset exists.

## 3. Pseudocode

### 3.1 Entry Routing

```text
function handleUnlock(inputSecret, deviceContext): SessionHandle {
  route = credentialClassifier.classify(inputSecret)

  if route == REJECT {
    return sessionLoader.loadLockedState(INVALID_CREDENTIAL)
  }

  if route == DURESS {
    boundedSession = sessionLoader.loadDuressSession(deviceContext)
    if boundedSession.failed {
      return sessionLoader.loadLockedState(DURESS_LOAD_FAILURE)
    }
    return boundedSession
  }

  standardSession = sessionLoader.loadStandardSession(deviceContext)
  if standardSession.failed {
    return sessionLoader.loadLockedState(STANDARD_LOAD_FAILURE)
  }
  return standardSession
}
```

### 3.2 Panic Transition

```text
function handlePanic(activeSession): SessionHandle {
  clearVisibleState(activeSession)
  clearDecryptedMemoryWherePossible(activeSession)
  suppressPreviewsAndNotifications()
  return sessionLoader.loadLockedState(PANIC_TRIGGERED)
}
```

### 3.3 Crash Recovery

```text
function recoverAfterCrash(crashContext): SessionHandle {
  suppressAutomaticDatasetRestore()
  clearAnySessionSpecificPreviewArtifacts()
  return sessionLoader.loadLockedState(REAUTH_REQUIRED_AFTER_CRASH)
}
```

## 4. Isolation Rules

- Standard and duress sessions must not share recent-item caches.
- Standard and duress sessions must not share export staging artifacts.
- Crash recovery must not infer the previously mounted dataset to the UI.
- Task switcher previews must be neutralized before either session can leak readable content.

## 5. Failure Cases To Test

- Valid duress credential with corrupted bounded dataset.
- Standard session interrupted by panic gesture mid-render.
- Duress session export attempt via share sheet.
- Crash immediately after successful standard authentication.
- Crash immediately after successful duress authentication.
- Notification or OS preview generation during session switch.

## 6. Audit Consequence

This routing design is a planning artifact only. It should be used to prevent unsafe implementation shortcuts, not to justify a change in current coercion audit status.
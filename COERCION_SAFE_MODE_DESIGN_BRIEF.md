# Coercion-Safe Mode: Design Brief

Document Status: Draft
Target: Reference Implementation (Protective Computing Core v1.0)
Implementation Status: Not Implemented

Purpose: Describe the architectural controls required for the reference implementation to eventually satisfy NORM-022 without overstating current capability.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/coercion-resistance.html

## 1. Abstract

Standard encryption protects data at rest against passive extraction. It does not protect against rubber-hose attacks, forced disclosure, or institutional coercion where the user is compelled to provide the key or unlock the application.

This brief outlines candidate architectural controls for plausible deniability and a coercion-safe mode within an offline-first, local-storage environment.

## 2. Core Constraints

- Zero-cloud dependency: the control must execute entirely on local device hardware.
- Cryptographic plausibility: the existence of a hidden secondary ledger must not be provable from ordinary storage inspection.
- Low cognitive load: the control must be operable by a user under stress, pain, panic, or cognitive fatigue.

## 3. Proposed Mitigation Strategies For Evaluation

### 3.1 Duress PIN / Decoy Ledger

- Mechanism: the system accepts two distinct passcodes.
- Standard PIN: decrypts the core data vault containing full history, high-severity entries, and sensitive notes.
- Duress PIN: decrypts an isolated parallel database containing bland, low-risk, or pre-curated baseline data.
- Audit posture: when the duress PIN is used, the UI must behave identically to standard operation and must not reveal, through copy, logs, timing, or storage side effects, that a secondary vault exists.

### 3.2 Ephemeral Panic UI State

- Mechanism: a gross-motor gesture, rapid shortcut, or other low-friction action immediately obscures the screen.
- Behavior: the app returns to a locked or bounded state, clears in-memory decrypted state where possible, and requires re-authentication before full history becomes visible again.

## 4. Implementation Roadblocks

Current browser-local storage patterns such as IndexedDB and localStorage make true cryptographic deniability difficult because browsers expose storage allocation, quotas, and footprint behavior in ways that can undermine a hidden-ledger claim.

Implementing a defensible decoy ledger likely requires custom encrypted blob handling that conceals both entropy distribution and payload size while preventing obvious storage-level differentiation between the primary and decoy vaults.

## 5. Audit Consequence

- This brief is a planning artifact only.
- It does not satisfy NORM-022 on its own.
- NORM-022 remains Not Met until a coercion-safe control is implemented, boundary-tested, and reflected consistently in the annex and reference mapping.

See also: /DURESS_MODE_REQUIREMENTS_CHECKLIST.md for the implementation threshold that must be satisfied before annex reconsideration.
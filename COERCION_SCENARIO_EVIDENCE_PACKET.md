# Coercion Scenario Evidence Packet

Document Status: Draft
Audit Target: NORM-022 Justifications
Implementation Status: Not Met

Purpose: Record the concrete coercion scenarios that establish why the current reference implementation fails NORM-022.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/coercion-resistance.html

## 1. Overview

This packet documents the current failure modes of the reference implementation under adversarial, high-duress environments. It is the evidentiary basis for keeping NORM-022 at Not Met.

## 2. Boundary Mapping Summary

This packet should be read against /COERCION_BOUNDARY_MATRIX.md.

Current evidence supports three boundary conclusions:
- passive theft and operator-only access are meaningfully resisted before coerced authentication,
- active coercion after compelled authentication is not resisted,
- and bounded metadata exposure remains visible in backup-service or operator-visible paths.

## 3. Scenario Results By Boundary Class

### 3.1 Currently Resisted Boundaries

| Scenario ID | Scenario | Result | Observed boundary |
| --- | --- | --- | --- |
| COE-R1 | Passive device theft while device remains locked | Pass | Local encrypted storage remains unreadable before authentication |
| COE-R2 | Operator-only disclosure demand using server or backup access | Pass | Operator can obtain ciphertext and bounded metadata only; no plaintext ledger recovery |
| COE-R3 | Network interception without endpoint compromise | Pass | No direct plaintext recovery path observed through the network channel alone |

### Scenario Alpha: The Institutional Audit

- Context: a user is told by an insurer, evaluator, or medical reviewer that their claim or treatment will be denied unless they unlock the application and export their full history immediately.
- Current system behavior: the user authenticates, the application opens normally, and the export pathway exposes a complete ledger without a coercion-safe redaction path.
- Result: the system fails to protect user sovereignty under compelled export.

### Scenario Beta: The Hostile Domestic Environment

- Context: a user is tracking harm, delay, or health events and is forced by an abusive partner to reveal the device contents.
- Current system behavior: the only available credential opens the full history. No safe mode, decoy ledger, or panic boundary exists to limit disclosure.
- Result: the system becomes a vector for further harm once the primary authentication boundary is breached under duress.

### Scenario Gamma: Border Inspection After Compelled Authentication

- Context: a user is detained in transit and compelled to unlock the device and open the application for inspection.
- Current system behavior: once the standard authentication path is used, the active session can reveal full local history with no deniable branch or bounded decoy dataset.
- Result: the system fails to preserve confidentiality once the user is compelled into the real session.

### Scenario Delta: Live Shoulder-Surfing During Logging

- Context: a user is entering a record while another actor demands to see the device immediately.
- Current system behavior: no panic gesture, immediate obfuscation control, or bounded safe surface exists. On-screen plaintext remains visible.
- Result: the system fails to protect against live-session disclosure.

## 4. Disclosure-Class Inventory

| Data class | Before coerced authentication | After coerced authentication | Notes |
| --- | --- | --- | --- |
| Ledger entries | Protected | Exposed | Full history becomes visible in the standard session |
| Sensitive notes and contextual free text | Protected | Exposed | Highest-harm disclosure class in domestic and institutional scenarios |
| Export archive contents | Protected | Exposed | Full export can be compelled once user is authenticated |
| Cached on-screen history | Protected | Exposed | Live UI reveals recent and historical content |
| Backup ciphertext | Protected as ciphertext | Protected as ciphertext to operator-only access | Remains non-plaintext without user-held secret |
| Operator-visible metadata | Partially exposed | Partially exposed | Still visible within documented retention bounds |

## 5. Audit Conclusion

The reference implementation hardens meaningfully against passive device theft and network-level extraction through offline-first behavior and encryption at rest.

The evidence also shows a complete lack of survivability once the human operator is compromised by coercion. Until the system can functionally separate authenticated user from safe user through a defensible deniability control or coercion-safe mode, it remains unsuitable for active-coercion scenarios.

## 6. Audit Consequence

- This packet supports keeping NORM-022 at Not Met.
- It supports truthful boundary disclosure under NORM-027.
- It does not justify Coercion Resistance signoff.
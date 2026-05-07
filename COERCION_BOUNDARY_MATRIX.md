# Coercion Boundary Matrix

Document Status: Draft
Related Norm: NORM-022 (Deniability Control)
Implementation Status: Not Met

Purpose: Map active-coercion vectors against current system boundaries and document the present failure state of the reference implementation under hostile human pressure.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/coercion-resistance.html

## 1. Objective

Map active-coercion vectors against system boundaries to identify exposure in zero-trust environments. This matrix assumes the adversary has physical control of the device and psychological, institutional, or physical leverage over the user.

## 2. Threat Vector Matrix

| Threat Actor | Coercion Vector | System Boundary Targeted | Current Response State | Exposure Severity |
| --- | --- | --- | --- | --- |
| Intimate partner / domestic actor | Forced unlocking of device or app under threat of violence | Authentication surface and visible UI | System fully decrypts and surfaces all ledger entries after primary authentication succeeds | Critical |
| Institutional actor (medical, insurance, evaluator) | Mandated data review; refusal of care or claims without full transparency | Export pipeline and operator-visible audit surface | Export path can disclose complete unredacted history once the user is compelled to authenticate and export | High |
| Border or state authority | Compelled decryption during transit via legal or physical duress | OS-level session boundary and local filesystem access after unlock | Full payload becomes reachable once the primary biometric or PIN boundary is breached under coercion | Critical |
| Informal guardian or caretaker | Shoulder-surfing or demand to reveal the screen during active use | Session state and live UI flow | No quick-obfuscation or panic gesture exists; live content remains legible | Moderate |

## 3. Current Boundary Classification

### Currently Resisted

The reference implementation does provide meaningful protection in the following non-coercive or pre-authentication scenarios:

| Scenario | Why it is currently resisted | Residual exposure |
| --- | --- | --- |
| Passive device theft while the device is locked | At-rest encryption and user-held secrets keep stored content unreadable before authentication | Coarse device possession metadata |
| Operator-only disclosure demand using server or backup access | Operator cannot decrypt user content using admin access alone | Bounded metadata and ciphertext only |
| Network interception without endpoint compromise | Transport and local-first architecture reduce plaintext exposure on the wire | Traffic timing and bounded metadata |

### Currently Not Resisted

The reference implementation does not resist the following active-coercion scenarios once the user is forced to unlock or reveal content:

| Scenario | Why it fails today | Primary disclosure class |
| --- | --- | --- |
| Forced unlock of the device or app | The primary credential opens the real ledger with no duress branch | Full plaintext history |
| Compelled export under institutional pressure | Export path lacks coercion-safe redaction or decoy behavior | Complete export payload |
| Shoulder-surfing during live use | No panic gesture or immediate obfuscation path exists | On-screen plaintext |
| Border inspection after compelled authentication | No deniable second boundary exists once the user authenticates | Full local dataset available through the live session |

## 4. Exposed Versus Protected Data Classes

| Data class | Protected before coerced authentication? | Protected after coerced authentication? | Notes |
| --- | --- | --- | --- |
| Ledger entries | Yes | No | Fully exposed once the standard credential path is used |
| Sensitive notes and contextual free text | Yes | No | High-harm disclosure class under domestic or institutional coercion |
| Export archive contents | Yes | No | User can be compelled to generate a full export |
| Cached on-screen history | Yes | No | Visible immediately in a live authenticated session |
| Backup ciphertext | Yes | Yes | Remains ciphertext to operator-only access without user secret |
| Operator-visible metadata | No, not fully | No, not fully | Still bounded, but visible within documented retention windows |

## 5. Boundary Failure Summary

The current architecture assumes a binary security state: the user is either fully locked out or operating in a safe, uncompromised environment.

Under active coercion, that binary model fails. Once the primary authentication boundary is breached under duress, the system lacks a secondary protective boundary such as a decoy ledger, silent redaction mode, or coercion-safe session. As a result, the product cannot preserve confidentiality when the authenticated user is not a safe user.

## 6. Minimum Boundary Required For Reconsideration

NORM-022 should not be reconsidered until the implementation can show all of the following:

1. A distinct coercion-safe entry path exists and is operable under stress.
2. That path exposes only a bounded decoy or sanitized dataset.
3. The UI, export pipeline, logs, notifications, and storage behavior do not reveal that a protected secondary dataset exists.
4. Forced-unlock and compelled-export scenarios have repeatable evidence showing bounded disclosure consistent with the published boundary.

## 7. Audit Consequence

- This artifact documents why the current coercion boundary is insufficient.
- It does not change the implementation state.
- NORM-022 remains Not Met until the reference implementation gains a defensible deniability control or coercion-safe mode that limits plaintext disclosure under forced access.
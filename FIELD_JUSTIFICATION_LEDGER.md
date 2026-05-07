# Field Justification Ledger

Version: 2026-03-18

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Provide a versioned field-by-field minimization ledger for Exposure Minimization review, aligned to NORM-010 and supporting NORM-007.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/exposure-minimization.html

Reference statements used:
- PainTracker collects only essential user-facing fields: entry date, pain level, location, treatment, notes.
- PainTracker uses encrypted optional backup and does not share data with third parties.
- PainTracker still exposes some server-side metadata such as timestamps, sync activity, and IP addresses.

Interpretation rules:
- Essential workflow linkage must be explicit for each persisted data class.
- Sensitivity class is documented from the perspective of user harm if disclosed.
- Retention bound documents implemented default behavior, including automatic expiry where enforced.

## Essential Workflow Basis

Canonical essential workflow for the reference implementation:
- Chronic pain patients record symptoms, treatments, and triggers offline so they can identify patterns and communicate medically without requiring connectivity or third-party disclosure.

## Ledger

| Data class | Stored where | Essential use / justification | Sensitivity class | Current retention bound | Consent / disclosure notes |
| --- | --- | --- | --- | --- | --- |
| Entry date | Local encrypted journal; optional encrypted backup | Required to reconstruct symptom chronology, identify patterns over time, and support clinician review | Sensitive health data | Local: auto-delete after 365 days unless user explicitly extends retention; backup: auto-delete after 1 year unless extended | Not shared with third parties; included in user-controlled export and encrypted backup |
| Pain level (0-10) | Local encrypted journal; optional encrypted backup | Required for symptom severity tracking and treatment efficacy comparison | Sensitive health data | Local: auto-delete after 365 days unless user explicitly extends retention; backup: auto-delete after 1 year unless extended | Not shared with third parties; encrypted at rest and in backup |
| Pain location | Local encrypted journal; optional encrypted backup | Required for identifying anatomical patterns and care context | Sensitive health data | Local: auto-delete after 365 days unless user explicitly extends retention; backup: auto-delete after 1 year unless extended | Not shared with third parties; encrypted at rest and in backup |
| Treatment | Local encrypted journal; optional encrypted backup | Required to correlate interventions with symptom changes and support medical communication | Sensitive health data | Local: auto-delete after 365 days unless user explicitly extends retention; backup: auto-delete after 1 year unless extended | Not shared with third parties; encrypted at rest and in backup |
| Free-text notes | Local encrypted journal; optional encrypted backup | Required to capture symptoms, triggers, and contextual observations that structured fields cannot represent | Highly sensitive free-text health data | Local: auto-delete after 180 days unless user explicitly extends retention; backup: auto-delete after 1 year unless extended | Highest disclosure risk; encrypted locally and during optional backup |
| Encrypted backup blob | Server backup storage | Required only when user opts into cloud backup so the user can restore data across devices or after device loss | Ciphertext carrying highly sensitive content | Auto-delete after 1 year unless user extends; user can manually delete sooner | Server stores ciphertext only; user-held key material required for decryption |
| Backup account identifier | Server backup service | Required to associate encrypted backup state with the user-controlled backup account | Sensitive account metadata | Exists while backup account exists; deleted when account is deleted | Not a third-party sharing field; still creates operator-visible metadata surface |
| Backup connection timestamp | Server logs / operational metadata | Operational telemetry byproduct for service processing and troubleshooting; not required for the core offline journaling workflow | Sensitive metadata | Auto-delete after 30 days | Operator-visible for a bounded interval; not encrypted |
| Sync activity metadata | Server logs / operational metadata | Operational telemetry byproduct indicating backup/sync events; not required for the core offline journaling workflow | Sensitive metadata | Auto-delete after 30 days | Reveals usage patterns only within bounded retention window |
| Source IP address | Server logs / operational metadata | Network-layer byproduct when backup service is used; not required for the core offline journaling workflow | Sensitive metadata | Auto-delete after 7 days | Operator-visible for short-lived abuse defense only |

## Audit Notes

- This artifact closes the prior documentation gap for the explicit per-field ledger requested by NORM-010.
- Local journal retention defaults and operator-visible metadata bounds are now documented as implemented controls.
- Remaining privacy review should focus on bounded visibility and coercion implications rather than undocumented retention.

## Change Control

Update this file whenever:
- a new persisted user-facing field is introduced,
- optional backup begins storing additional metadata,
- retention defaults change,
- or a field changes sensitivity or workflow linkage.
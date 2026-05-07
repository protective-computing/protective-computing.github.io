# Local Retention Default Specification

Version: 2026-03-18

Status: Implemented specification. Published to define the automatic local-retention behavior now enforced by the reference implementation.

Scope: PainTracker reference implementation documented in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Define the automatic local-retention defaults enforced for local journal data, aligned to NORM-007 and NORM-013.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/exposure-minimization.html

## Policy

PainTracker enforces automatic local expiry defaults while preserving user agency through explicit, auditable overrides.

## Default Retention Windows

| Data class | Default local retention | Override allowed? | Expiry behavior |
| --- | --- | --- | --- |
| Entry date | 365 days | Yes, explicit user extension | Removed from application-visible local journal after expiry |
| Pain level (0-10) | 365 days | Yes, explicit user extension | Removed with associated entry lifecycle |
| Pain location | 365 days | Yes, explicit user extension | Removed with associated entry lifecycle |
| Treatment | 365 days | Yes, explicit user extension | Removed with associated entry lifecycle |
| Free-text notes | 180 days | Yes, explicit user extension | Removed with associated entry lifecycle; shorter default due to higher sensitivity |
| Soft-deleted local entry state | Existing recovery window only | No additional extension beyond user-defined recovery window | Permanently purged after recovery window expiry |

## Override Rules

- Overrides must be explicit user actions, not silent defaults.
- The system must display the current retention setting before the user changes it.
- An override must be recorded as user-selected policy, not implied by inactivity.
- The product must provide a “return to recommended default” control.

## Expiry Rules

- Expired entries must disappear from normal application views, search, exports, and summaries.
- Expired entries must not remain application-readable through cached previews or history surfaces.
- Recovery after expiry is not promised unless a separate reversible grace period is explicitly documented.
- Physical media residue guarantees are out of scope unless separately implemented and tested.

## User Notice Requirements

- Users must see the default retention period at entry creation or in retention settings.
- Users must receive clear notice when a longer-than-default retention override is chosen.
- Expiry behavior must be described in plain language before users rely on it.

## Audit Status

This specification documents implemented local-retention behavior.
Passing enforcement evidence is recorded in /RETENTION_ENFORCEMENT_VERIFICATION_REPORT.md.

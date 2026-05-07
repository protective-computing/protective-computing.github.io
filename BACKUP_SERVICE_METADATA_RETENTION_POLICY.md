# Backup Service Metadata Retention Policy

Version: 2026-03-18

Status: Implemented policy. Published to define the bounded retention now enforced for operator-visible metadata.

Scope: PainTracker backup and sync service metadata referenced in /docs/reference-implementation/paintracker-mapping.html.

Purpose: Define explicit enforced retention bounds for operator-visible metadata, aligned to NORM-007 and NORM-013.

Normative basis:
- /docs/spec/v1.0.html
- /docs/spec/v1.0-must-justifications.html
- /docs/principles/exposure-minimization.html

## Policy Table

| Metadata class | Purpose | Proposed max retention | Deletion trigger | Minimization rule |
| --- | --- | --- | --- | --- |
| Backup connection timestamp | Service reliability and abuse investigation | 30 days | Scheduled expiry | Store only event timestamp, not additional content-linked context |
| Sync activity metadata | Queue processing and troubleshooting | 30 days | Scheduled expiry | Retain event class only; avoid payload-derived labels |
| Source IP address | Abuse prevention and service defense | 7 days | Scheduled expiry | Truncate or pseudonymize when full address is no longer operationally required |
| Backup account lifecycle event log | Account creation/deletion audit | 90 days | Scheduled expiry after account closure or event age limit | Keep only event type and account identifier required for supportability |

## Operational Rules

- Metadata retention must be time-bounded by default.
- Retention extension for incidents must be explicit, time-limited, and documented.
- Metadata must not be repurposed for analytics, profiling, or product-growth measurement.
- Sensitive content classes from encrypted journal data must never be copied into metadata logs.

## Publication Rules

- These retention bounds must be visible in public-facing audit or privacy evidence.
- Any deviation from the published limits requires versioned documentation and rationale.

## Audit Status

This policy documents implemented metadata-retention bounds.
Passing enforcement evidence is recorded in /RETENTION_ENFORCEMENT_VERIFICATION_REPORT.md.

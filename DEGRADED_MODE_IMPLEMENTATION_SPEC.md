# Degraded Mode Implementation Spec

Document Status: Draft
Target Norms: NORM-028, NORM-030, NORM-031, NORM-032, NORM-034
Implementation Status: Not Implemented as a complete compliant baseline

Purpose: Define the target runtime behavior, degradation order, and verification model required to move Degraded Functionality toward Met.

Normative basis:
- /DEGRADED_MODE_REMEDIATION_MATRIX.md
- /DEGRADED_MODE_REQUIREMENTS_CHECKLIST.md
- /docs/spec/v1.0-must-justifications.html

## 1. Runtime Goal

When resources are constrained, the system must preserve the essential journaling path first and reduce or disable only non-essential capabilities.

## 2. Essential-First Degradation Order

| Priority | Capability class | Required behavior under stress |
| --- | --- | --- |
| 1 | Create, read, edit, delete essential entries | Must remain available |
| 2 | Privacy and retention controls | Must remain available |
| 3 | Minimal export of essential summary | Should remain available if already claimed essential |
| 4 | Charts and enhanced visualizations | May degrade to plain text summaries first |
| 5 | Rich widgets and enhanced JS interactions | May be replaced by simpler controls |

## 3. Baseline Fallback Rules

- If advanced widgets fail, fall back to plain controls rather than block the workflow.
- If charts cannot render accessibly, provide text equivalents without losing the underlying data path.
- If memory pressure rises, drop non-essential enhancement layers before affecting the core form and history views.
- If the network is unstable, preserve local operations and avoid hidden online requirements.

## 4. Reduced-Input Requirements

- Every essential action must be possible by keyboard only.
- Any widget used in the essential path must expose a plain keyboard-safe fallback.
- Focus state must remain visible under constrained rendering conditions.

## 5. Accessibility Requirements

- Contrast for essential-path controls and information must meet WCAG 2.1 AA.
- Date entry and chart access must expose screen-reader-compatible alternatives.
- Errors, confirmations, and workflow transitions must be announced or semantically exposed.

## 6. Verification Model

| Test ID | Scenario | Pass condition |
| --- | --- | --- |
| DGM-01 | High latency and low bandwidth | Essential path completes without sync-required blocking |
| DGM-02 | Sub-512MB memory profile | Core journaling path remains stable |
| DGM-03 | Keyboard-only essential path | Zero blocked essential controls |
| DGM-04 | Screen-reader essential path | Critical workflows remain understandable and operable |
| DGM-05 | Enhancement failure | System falls back to simpler controls rather than failing the workflow |

## 7. Annex Reconsideration Gate

NORM-028, NORM-030, NORM-031, NORM-032, and NORM-034 should remain non-Met until the runtime behavior above is implemented and supported by repeatable evidence.

## 8. Reviewer Note

This spec is meant to prevent a superficial “responsive but not resilient” interpretation of degraded functionality. Responsive layout alone is not sufficient.